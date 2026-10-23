import tempfile
import unittest
from pathlib import Path

from libraries.robot_report import add_screenshot_gallery


class RobotReportTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.output_dir = Path(self.directory.name)
        self.output_xml = self.output_dir / "output.xml"
        self.report_html = self.output_dir / "report.html"

    def test_adds_test_screenshot_to_report(self):
        self.output_xml.write_text(
            '<robot><suite><test name="Login &amp; verify">'
            '<kw><msg>&lt;a href="selenium-screenshot-1.png"&gt;'
            '&lt;img src="selenium-screenshot-1.png"&gt;'
            '&lt;/a&gt;</msg></kw></test></suite></robot>',
            encoding="utf-8",
        )
        self.report_html.write_text(
            "<html><body>Report</body></html>",
            encoding="utf-8",
        )
        (self.output_dir / "selenium-screenshot-1.png").write_bytes(b"png")

        add_screenshot_gallery(self.output_xml, self.report_html)

        report = self.report_html.read_text(encoding="utf-8")
        self.assertIn("Failure screenshots", report)
        self.assertIn("selenium-screenshot-1.png", report)
        self.assertIn("Login &amp; verify", report)

    def test_replaces_existing_gallery_without_duplicating_it(self):
        self.output_xml.write_text(
            '<robot><suite><test name="Login">'
            '<msg>&lt;img src="selenium-screenshot-1.png"&gt;</msg>'
            "</test></suite></robot>",
            encoding="utf-8",
        )
        self.report_html.write_text(
            "<html><body>Report"
            "<!-- Robot screenshot gallery: start -->old gallery"
            "<!-- Robot screenshot gallery: end -->"
            "</body></html>",
            encoding="utf-8",
        )
        (self.output_dir / "selenium-screenshot-1.png").write_bytes(b"png")

        add_screenshot_gallery(self.output_xml, self.report_html)

        report = self.report_html.read_text(encoding="utf-8")
        self.assertEqual(report.count("Failure screenshots"), 1)
        self.assertNotIn("old gallery", report)

    def test_fails_when_output_references_a_missing_screenshot(self):
        self.output_xml.write_text(
            '<robot><suite><test name="Login">'
            '<msg>&lt;img src="selenium-screenshot-1.png"&gt;</msg>'
            "</test></suite></robot>",
            encoding="utf-8",
        )
        self.report_html.write_text(
            "<html><body>Report</body></html>",
            encoding="utf-8",
        )

        with self.assertRaisesRegex(FileNotFoundError, "selenium-screenshot-1.png"):
            add_screenshot_gallery(self.output_xml, self.report_html)

    def test_includes_screenshots_from_suite_setup(self):
        self.output_xml.write_text(
            '<robot><suite name="Accounts">'
            '<kw name="Suite Setup"><msg>'
            '&lt;img src="selenium-screenshot-1.png"&gt;'
            "</msg></kw></suite></robot>",
            encoding="utf-8",
        )
        self.report_html.write_text(
            "<html><body>Report</body></html>",
            encoding="utf-8",
        )
        (self.output_dir / "selenium-screenshot-1.png").write_bytes(b"png")

        add_screenshot_gallery(self.output_xml, self.report_html)

        report = self.report_html.read_text(encoding="utf-8")
        self.assertIn("Suite: Accounts", report)
        self.assertIn("selenium-screenshot-1.png", report)


if __name__ == "__main__":
    unittest.main()
