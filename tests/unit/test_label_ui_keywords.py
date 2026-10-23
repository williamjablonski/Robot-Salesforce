import unittest
from unittest.mock import Mock, patch

from libraries.label_ui_keywords import LabelUIKeywords


class LabelUIKeywordsTests(unittest.TestCase):
    def setUp(self):
        self.library = LabelUIKeywords()
        self.selenium = Mock()
        self.builtin_patcher = patch(
            "libraries.label_ui_keywords.BuiltIn",
            return_value=Mock(
                get_library_instance=Mock(return_value=self.selenium)
            ),
        )
        self.builtin_patcher.start()
        self.addCleanup(self.builtin_patcher.stop)

    def test_type_text_uses_associated_label_and_clears_existing_value(self):
        label = Mock(is_displayed=Mock(return_value=True))
        label.get_attribute.return_value = "account-name"
        control = Mock(
            id="account-name",
            tag_name="input",
            is_displayed=Mock(return_value=True),
        )
        control.get_attribute.return_value = "text"
        self.selenium.get_webelements.side_effect = [
            [label],
            [control],
            [],
        ]

        self.library.type_text("Account Name", "Robot Account QA")

        self.selenium.input_text.assert_called_once_with(
            control,
            "Robot Account QA",
            clear=True,
        )

    def test_type_text_fails_when_label_matches_multiple_controls(self):
        label_a = Mock(id="label-a", is_displayed=Mock(return_value=True))
        label_b = Mock(id="label-b", is_displayed=Mock(return_value=True))
        label_a.get_attribute.return_value = "control-a"
        label_b.get_attribute.return_value = "control-b"
        control_a = Mock(id="control-a", is_displayed=Mock(return_value=True))
        control_b = Mock(id="control-b", is_displayed=Mock(return_value=True))
        self.selenium.get_webelements.side_effect = [
            [label_a, label_b],
            [control_a],
            [control_b],
            [],
            [],
        ]

        with self.assertRaisesRegex(AssertionError, "found 2"):
            self.library.type_text("Account Name", "Robot Account QA")

        self.selenium.input_text.assert_not_called()

    def test_click_text_clicks_one_matching_element(self):
        button = Mock(id="save-button", is_displayed=Mock(return_value=True))
        self.selenium.get_webelements.return_value = [button]

        self.library.click_text("Save")

        self.selenium.click_element.assert_called_once_with(button)

    def test_verify_text_fails_if_matching_text_is_not_visible(self):
        text_element = Mock(is_displayed=Mock(return_value=False))
        self.selenium.get_webelements.return_value = [text_element]

        with self.assertRaisesRegex(AssertionError, "Expected visible text"):
            self.library.verify_text("Account created")

    def test_xpath_literal_escapes_both_quote_types(self):
        self.assertEqual(
            self.library._xpath_literal("""Manager's "Special" Account"""),
            """concat('Manager', "'", 's "Special" Account')""",
        )


if __name__ == "__main__":
    unittest.main()
