from __future__ import annotations

from typing import Any

from robot.api.deco import keyword, library
from robot.libraries.BuiltIn import BuiltIn
from selenium.webdriver.common.by import By


@library(scope="SUITE", auto_keywords=False)
class LabelUIKeywords:
    """Label-oriented UI keywords that reuse the active SeleniumLibrary browser."""

    def __init__(self, selenium_library_name: str = "SeleniumLibrary") -> None:
        self._selenium_library_name = selenium_library_name

    @keyword("Type Text")
    def type_text(self, label: str, text: str) -> None:
        """Replace the value of the visible form control associated with label."""
        selenium = self._selenium()
        label_locator = self._form_label_locator(label)
        selenium.wait_until_element_is_visible(
            label_locator,
            error=f"No visible form label found with text {label!r}.",
        )

        controls = self._form_controls_for_label(selenium, label)
        control = self._single_visible_element(
            controls,
            label,
            "form control",
        )
        tag_name = control.tag_name.lower()
        input_type = (control.get_attribute("type") or "text").lower()
        if tag_name not in {"input", "textarea"} or input_type in {
            "button",
            "checkbox",
            "file",
            "hidden",
            "image",
            "radio",
            "reset",
            "submit",
        }:
            raise AssertionError(
                f"Label {label!r} identifies a non-text form control "
                f"({tag_name}, type={input_type!r})."
            )

        selenium.wait_until_element_is_visible(
            control,
            error=f"Form control for label {label!r} is not visible.",
        )
        selenium.input_text(control, text, clear=True)

    @keyword("Click Text")
    def click_text(self, text: str) -> None:
        """Click one visible button, link, role control, or label matching text."""
        selenium = self._selenium()
        locator = self._clickable_text_locator(text)
        selenium.wait_until_element_is_visible(
            locator,
            error=f"No visible clickable element found with label or text {text!r}.",
        )
        element = self._single_visible_element(
            selenium.get_webelements(locator),
            text,
            "clickable element",
        )
        selenium.click_element(element)

    @keyword("Verify Text")
    def verify_text(self, text: str) -> None:
        """Verify that an element with the exact normalized text is visible."""
        selenium = self._selenium()
        locator = f"xpath=//*[normalize-space(.) = {self._xpath_literal(text)}]"
        selenium.wait_until_element_is_visible(
            locator,
            error=f"Expected visible text {text!r} was not found.",
        )
        if not any(
            element.is_displayed() for element in selenium.get_webelements(locator)
        ):
            raise AssertionError(f"Expected visible text {text!r} was not found.")

    def _selenium(self) -> Any:
        return BuiltIn().get_library_instance(self._selenium_library_name)

    def _form_label_locator(self, label: str) -> str:
        literal = self._xpath_literal(label)
        return (
            "xpath="
            f"//label[normalize-space(.) = {literal}]"
            " | "
            f"//input[@aria-label = {literal}]"
            " | "
            f"//textarea[@aria-label = {literal}]"
        )

    def _form_controls_for_label(self, selenium: Any, label: str) -> list[Any]:
        literal = self._xpath_literal(label)
        labels = selenium.get_webelements(
            f"xpath=//label[normalize-space(.) = {literal}]"
        )
        controls: list[Any] = []

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
                        By.XPATH,
                        ".//input | .//textarea",
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
        return self._unique_elements(controls)

    def _clickable_text_locator(self, text: str) -> str:
        literal = self._xpath_literal(text)
        return (
            "xpath="
            f"//button[normalize-space(.) = {literal} or @aria-label = {literal}]"
            " | "
            f"//a[normalize-space(.) = {literal} or @aria-label = {literal}]"
            " | "
            f"//*[@role = 'button' and "
            f"(normalize-space(.) = {literal} or @aria-label = {literal})]"
            " | "
            f"//*[@role = 'link' and "
            f"(normalize-space(.) = {literal} or @aria-label = {literal})]"
            " | "
            f"//*[@role = 'tab' and "
            f"(normalize-space(.) = {literal} or @aria-label = {literal})]"
            " | "
            f"//*[@role = 'menuitem' and "
            f"(normalize-space(.) = {literal} or @aria-label = {literal})]"
            " | "
            f"//*[@role = 'option' and "
            f"(normalize-space(.) = {literal} or @aria-label = {literal})]"
            " | "
            f"//label[normalize-space(.) = {literal}]"
            " | "
            f"//input[(@type = 'button' or @type = 'submit') "
            f"and (@value = {literal} or @aria-label = {literal})]"
        )

    def _single_visible_element(
        self,
        elements: list[Any],
        label: str,
        description: str,
    ) -> Any:
        visible = [
            element
            for element in self._unique_elements(elements)
            if element.is_displayed()
        ]
        if not visible:
            raise AssertionError(
                f"No visible {description} found for label or text {label!r}."
            )
        if len(visible) > 1:
            raise AssertionError(
                f"Expected one visible {description} for label or text {label!r}, "
                f"but found {len(visible)}. Scope the page or use a unique label."
            )
        return visible[0]

    def _unique_elements(self, elements: list[Any]) -> list[Any]:
        unique: dict[str, Any] = {}
        for element in elements:
            unique[element.id] = element
        return list(unique.values())

    def _xpath_literal(self, value: str) -> str:
        if "'" not in value:
            return f"'{value}'"
        if '"' not in value:
            return f'"{value}"'
        parts = value.split("'")
        return "concat(" + ', "\'", '.join(f"'{part}'" for part in parts) + ")"
