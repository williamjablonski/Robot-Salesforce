from __future__ import annotations

import imaplib
import os
import re
import ssl
import time
from datetime import datetime, timezone
from email import policy
from email.parser import BytesParser
from email.utils import getaddresses
from html.parser import HTMLParser
from typing import Any

from robot.api.deco import keyword, library
from robot.libraries.BuiltIn import BuiltIn
from selenium.common.exceptions import WebDriverException
from selenium.webdriver.common.by import By

from libraries.label_ui_keywords import highlight_selenium_element


class _HTMLTextParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.text: list[str] = []

    def handle_data(self, data: str) -> None:
        self.text.append(data)


@library(scope="SUITE", auto_keywords=False)
class SalesforceEmailKeywords:
    """Read Salesforce verification emails and complete the active Selenium login."""

    @keyword("Get Salesforce Login Request Timestamp")
    def get_salesforce_login_request_timestamp(self) -> float:
        """Return the time immediately before submitting Salesforce credentials."""
        return time.time()

    @keyword("Wait For Salesforce Login State")
    def wait_for_salesforce_login_state(
        self,
        expected_path: str,
        verification_label: str,
        timeout: float = 60,
        polling_interval: float = 0.5,
    ) -> str:
        """Wait until Salesforce reaches Lightning or displays its verification field."""
        selenium = self._selenium()
        deadline = time.monotonic() + timeout

        while True:
            if expected_path in selenium.get_location():
                return "authenticated"
            if self._visible_form_controls(selenium, verification_label):
                return "verification"
            if time.monotonic() >= deadline:
                raise AssertionError(
                    "Salesforce did not reach Lightning or display the "
                    f"{verification_label!r} verification field within {timeout:g} seconds."
                )
            time.sleep(polling_interval)

    @keyword("Retrieve And Submit Salesforce Verification Code")
    def retrieve_and_submit_salesforce_verification_code(
        self,
        verification_label: str,
        verify_button: str,
        expected_sender: str,
        request_timestamp: float,
        imap_host: str = "imap.gmail.com",
        timeout: float = 120,
        polling_interval: float = 2,
    ) -> None:
        """Read a fresh Salesforce email code, submit it, and wait for Lightning."""
        if not re.fullmatch(r'[^"\r\n\s]+@[^"\r\n\s]+', expected_sender):
            raise ValueError("SF_MFA_EMAIL_SENDER must be a valid email address.")

        username = os.environ.get("SF_MFA_EMAIL_USERNAME", "").strip()
        password = os.environ.get("SF_MFA_EMAIL_PASSWORD", "")
        if not username or not password:
            raise RuntimeError(
                "SF_MFA_EMAIL_USERNAME and SF_MFA_EMAIL_PASSWORD must be "
                "configured securely to read the Salesforce verification email."
            )
        if not imap_host.strip():
            raise ValueError("SF_MFA_IMAP_HOST must not be empty.")

        code = self._wait_for_verification_code(
            imap_host.strip(),
            username,
            password,
            expected_sender,
            request_timestamp,
            timeout,
            polling_interval,
        )
        selenium = self._selenium()
        field = self._single_visible_element(
            self._visible_form_controls(selenium, verification_label),
            verification_label,
            "verification field",
        )
        button = self._single_visible_element(
            self._visible_clickables(selenium, verify_button),
            verify_button,
            "verification button",
        )
        try:
            highlight_selenium_element(selenium, field)
            field.clear()
            field.send_keys(code)
            if field.get_attribute("value") != code:
                highlight_selenium_element(selenium, field)
                field.clear()
                raise AssertionError(
                    "Salesforce verification code could not be entered."
                )
            highlight_selenium_element(selenium, button)
            button.click()
        except WebDriverException:
            highlight_selenium_element(selenium, field)
            field.clear()
            raise

        deadline = time.monotonic() + 60
        while time.monotonic() < deadline:
            if "/lightning/" in selenium.get_location():
                return
            time.sleep(0.5)
        highlight_selenium_element(selenium, field)
        field.clear()
        raise AssertionError(
            "Salesforce did not complete login after the verification code was submitted."
        )

    def _wait_for_verification_code(
        self,
        imap_host: str,
        username: str,
        password: str,
        expected_sender: str,
        request_timestamp: float,
        timeout: float,
        polling_interval: float,
    ) -> str:
        search_date = datetime.fromtimestamp(
            request_timestamp, timezone.utc
        ).strftime("%d-%b-%Y")
        deadline = time.monotonic() + timeout

        with imaplib.IMAP4_SSL(
            imap_host,
            timeout=10,
            ssl_context=ssl.create_default_context(),
        ) as mailbox:
            mailbox.login(username, password)
            status, _ = mailbox.select("INBOX", readonly=True)
            if status != "OK":
                raise RuntimeError("Could not open the configured email inbox.")

            while True:
                code = self._find_fresh_code(
                    mailbox,
                    expected_sender,
                    search_date,
                    request_timestamp,
                )
                if code:
                    return code
                if time.monotonic() >= deadline:
                    raise TimeoutError(
                        "No new Salesforce verification code email was found "
                        f"from {expected_sender!r} within {timeout:g} seconds."
                    )
                time.sleep(polling_interval)

    def _find_fresh_code(
        self,
        mailbox: imaplib.IMAP4_SSL,
        expected_sender: str,
        search_date: str,
        request_timestamp: float,
    ) -> str | None:
        status, results = mailbox.uid(
            "search",
            None,
            "FROM",
            f'"{expected_sender}"',
            "SINCE",
            search_date,
        )
        if status != "OK":
            raise RuntimeError("Could not search the configured email inbox.")

        message_ids = results[0].split() if results else []
        for message_id in reversed(message_ids):
            status, response = mailbox.uid(
                "fetch", message_id, "(INTERNALDATE BODY.PEEK[])"
            )
            if status != "OK":
                raise RuntimeError("Could not read a Salesforce email message.")
            metadata = next(
                (
                    item[0]
                    for item in response
                    if isinstance(item, tuple) and isinstance(item[0], bytes)
                ),
                None,
            )
            raw_message = next(
                (
                    item[1]
                    for item in response
                    if isinstance(item, tuple) and isinstance(item[1], bytes)
                ),
                None,
            )
            if metadata is None or raw_message is None:
                raise RuntimeError("The email server returned an incomplete message.")
            received_at = imaplib.Internaldate2tuple(metadata)
            if received_at is None:
                raise RuntimeError("The email server omitted the message receive time.")
            if time.mktime(received_at) < request_timestamp:
                continue

            message = BytesParser(policy=policy.default).parsebytes(raw_message)
            senders = {
                address.casefold()
                for _, address in getaddresses(message.get_all("From", []))
            }
            if expected_sender.casefold() not in senders:
                continue
            code = self._verification_code_from_message(message)
            if code:
                return code
        return None

    def _verification_code_from_message(self, message: Any) -> str | None:
        text_parts: list[str] = []
        for part in message.walk():
            if part.is_multipart() or part.get_content_disposition() == "attachment":
                continue
            if part.get_content_type() not in {"text/plain", "text/html"}:
                continue
            content = part.get_content()
            if part.get_content_type() == "text/html":
                parser = _HTMLTextParser()
                parser.feed(content)
                content = " ".join(parser.text)
            text_parts.append(content)

        matches = list(
            dict.fromkeys(
                re.findall(
                    r"Código\s+de\s+verificação\s*:\s*([A-Za-z0-9-]+)",
                    "\n".join(text_parts),
                    flags=re.IGNORECASE,
                )
            )
        )
        if len(matches) > 1:
            raise RuntimeError(
                "The newest matching Salesforce email contains multiple "
                "verification codes."
            )
        return matches[0] if matches else None

    def _visible_form_controls(self, selenium: Any, label: str) -> list[Any]:
        literal = self._xpath_literal(label)
        controls: list[Any] = []
        labels = selenium.get_webelements(
            f"xpath=//label[normalize-space(.) = {literal}]"
        )
        for label_element in labels:
            if not label_element.is_displayed():
                continue
            control_id = label_element.get_attribute("for")
            if control_id:
                controls.extend(
                    selenium.get_webelements(
                        f"xpath=//*[@id = {self._xpath_literal(control_id)}]"
                    )
                )
            else:
                controls.extend(
                    label_element.find_elements(
                        By.XPATH, ".//input | .//textarea"
                    )
                )
        controls.extend(
            selenium.get_webelements(
                "xpath="
                f"//input[@aria-label = {literal}]"
                " | "
                f"//textarea[@aria-label = {literal}]"
            )
        )
        return [
            element
            for element in self._unique_elements(controls)
            if element.is_displayed()
            and element.tag_name.lower() in {"input", "textarea"}
        ]

    def _visible_clickables(self, selenium: Any, text: str) -> list[Any]:
        literal = self._xpath_literal(text)
        locator = (
            "xpath="
            f"//button[normalize-space(.) = {literal} or @aria-label = {literal}]"
            " | "
            f"//*[@role = 'button' and "
            f"(normalize-space(.) = {literal} or @aria-label = {literal})]"
            " | "
            f"//input[@type = 'submit' and "
            f"(@value = {literal} or @aria-label = {literal})]"
        )
        return [
            element
            for element in self._unique_elements(selenium.get_webelements(locator))
            if element.is_displayed()
        ]

    def _single_visible_element(
        self,
        elements: list[Any],
        label: str,
        description: str,
    ) -> Any:
        if not elements:
            raise AssertionError(
                f"No visible {description} found for label or text {label!r}."
            )
        if len(elements) > 1:
            raise AssertionError(
                f"Expected one visible {description} for label or text {label!r}, "
                f"but found {len(elements)}."
            )
        return elements[0]

    def _unique_elements(self, elements: list[Any]) -> list[Any]:
        unique: dict[str, Any] = {}
        for element in elements:
            unique[element.id] = element
        return list(unique.values())

    def _selenium(self) -> Any:
        return BuiltIn().get_library_instance("SeleniumLibrary")

    def _xpath_literal(self, value: str) -> str:
        if "'" not in value:
            return f"'{value}'"
        if '"' not in value:
            return f'"{value}"'
        parts = value.split("'")
        return "concat(" + ', "\'", '.join(f"'{part}'" for part in parts) + ")"
