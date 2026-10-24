import imaplib
import os
import time
import unittest
from email import policy
from email.message import EmailMessage
from email.parser import BytesParser
from unittest.mock import ANY, Mock, call, patch

from libraries.salesforce_email_keywords import SalesforceEmailKeywords


class SalesforceEmailKeywordsTests(unittest.TestCase):
    def setUp(self):
        self.library = SalesforceEmailKeywords()
        self.sleep_patcher = patch("libraries.label_ui_keywords.time.sleep")
        self.sleep_patcher.start()
        self.addCleanup(self.sleep_patcher.stop)

    def _message(self, body, content_type="text/plain"):
        message = EmailMessage()
        message["From"] = "Salesforce <noreply@salesforce.com>"
        if content_type == "text/html":
            message.set_content(body, subtype="html")
        else:
            message.set_content(body)
        return BytesParser(policy=policy.default).parsebytes(message.as_bytes())

    def test_extracts_code_from_plain_text_email(self):
        message = self._message("Código de verificação: 904218")

        self.assertEqual(
            self.library._verification_code_from_message(message),
            "904218",
        )

    def test_extracts_code_from_html_email(self):
        message = self._message(
            "<p>Código de verificação: <b>904218</b></p>",
            content_type="text/html",
        )

        self.assertEqual(
            self.library._verification_code_from_message(message),
            "904218",
        )

    def test_multipart_duplicate_representation_is_one_code(self):
        message = EmailMessage()
        message["From"] = "Salesforce <noreply@salesforce.com>"
        message.set_content("Código de verificação: 904218")
        message.add_alternative(
            "<p>Código de verificação: <b>904218</b></p>",
            subtype="html",
        )
        parsed = BytesParser(policy=policy.default).parsebytes(message.as_bytes())

        self.assertEqual(
            self.library._verification_code_from_message(parsed),
            "904218",
        )

    def test_rejects_multiple_distinct_codes_in_email(self):
        message = self._message(
            "Código de verificação: 904218\nCódigo de verificação: 318572"
        )

        with self.assertRaisesRegex(RuntimeError, "multiple verification codes"):
            self.library._verification_code_from_message(message)

    def test_finds_code_only_in_message_received_after_login_request(self):
        raw_message = self._message(
            "Código de verificação: 904218"
        ).as_bytes()
        metadata = (
            b'1 (INTERNALDATE "23-Oct-2026 21:01:00 -0300" '
            b"BODY[] {128})"
        )
        mailbox = Mock()
        mailbox.uid.side_effect = [
            ("OK", [b"1"]),
            ("OK", [(metadata, raw_message), b")"]),
        ] * 2
        received_at = imaplib.Internaldate2tuple(metadata)
        request_timestamp = time.mktime(received_at) - 60

        self.assertEqual(
            self.library._find_fresh_code(
                mailbox,
                "noreply@salesforce.com",
                "23-Oct-2026",
                request_timestamp,
            ),
            "904218",
        )
        self.assertEqual(mailbox.uid.call_count, 2)

        self.assertIsNone(
            self.library._find_fresh_code(
                mailbox,
                "noreply@salesforce.com",
                "23-Oct-2026",
                request_timestamp + 120,
            )
        )

    def test_requires_private_mailbox_credentials(self):
        with patch.dict(os.environ, {}, clear=True):
            with self.assertRaisesRegex(
                RuntimeError, "SF_MFA_EMAIL_USERNAME and SF_MFA_EMAIL_PASSWORD"
            ):
                self.library.retrieve_and_submit_salesforce_verification_code(
                    "Código de verificação",
                    "Verificar",
                    "noreply@salesforce.com",
                    1,
                )

    def test_login_state_detects_direct_lightning_login_without_mfa(self):
        selenium = Mock()
        selenium.get_location.side_effect = [
            "https://example.test/login",
            "https://example.test/lightning/page/home",
        ]
        self.library._selenium = Mock(return_value=selenium)
        self.library._visible_form_controls = Mock(return_value=[])

        self.assertEqual(
            self.library.wait_for_salesforce_login_state(
                "/lightning/", "Código de verificação"
            ),
            "authenticated",
        )

    def test_login_state_detects_verification_challenge(self):
        selenium = Mock()
        selenium.get_location.return_value = "https://example.test/login"
        self.library._selenium = Mock(return_value=selenium)
        self.library._visible_form_controls = Mock(return_value=[Mock()])

        self.assertEqual(
            self.library.wait_for_salesforce_login_state(
                "/lightning/", "Código de verificação"
            ),
            "verification",
        )

    def test_submits_code_without_returning_it_to_robot(self):
        selenium = Mock()
        field = Mock(tag_name="input")
        field.get_attribute.return_value = "904218"
        button = Mock()
        selenium.attach_mock(field, "field")
        selenium.attach_mock(button, "button")
        self.library._selenium = Mock(return_value=selenium)
        self.library._wait_for_verification_code = Mock(return_value="904218")
        self.library._visible_form_controls = Mock(return_value=[field])
        self.library._visible_clickables = Mock(return_value=[button])
        selenium.get_location.return_value = "/lightning/page/home"

        with patch.dict(
            os.environ,
            {
                "SF_MFA_EMAIL_USERNAME": "robot@example.test",
                "SF_MFA_EMAIL_PASSWORD": "synthetic-test-app-password",
            },
        ):
            result = self.library.retrieve_and_submit_salesforce_verification_code(
                "Código de verificação",
                "Verificar",
                "noreply@salesforce.com",
                1,
            )

        self.assertIsNone(result)
        field.clear.assert_called_once_with()
        field.send_keys.assert_called_once_with("904218")
        button.click.assert_called_once_with()
        self.library._wait_for_verification_code.assert_called_once()
        self.assertLess(
            selenium.mock_calls.index(
                call.driver.execute_script(ANY, field)
            ),
            selenium.mock_calls.index(call.field.clear()),
        )
        self.assertLess(
            selenium.mock_calls.index(
                call.driver.execute_script(ANY, button)
            ),
            selenium.mock_calls.index(call.button.click()),
        )


if __name__ == "__main__":
    unittest.main()
