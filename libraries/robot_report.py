import html
import re
import xml.etree.ElementTree as ET
from pathlib import Path
from urllib.parse import quote, unquote, urlsplit


_SCREENSHOT_PATTERN = re.compile(
    r"""(?:src|href)=["']([^"']*selenium-screenshot-[^"']+\.png)["']"""
)
_GALLERY_START = "<!-- Robot screenshot gallery: start -->"
_GALLERY_END = "<!-- Robot screenshot gallery: end -->"


def add_screenshot_gallery(output_xml: Path, report_html: Path) -> None:
    """Add failure screenshots recorded in output.xml to Robot's summary report."""
    root = ET.parse(output_xml).getroot()
    parents = {
        child: parent
        for parent in root.iter()
        for child in parent
    }
    screenshots_by_context = {}

    for message in root.iter("msg"):
        context = message
        while context is not None and context.tag not in {"test", "suite"}:
            context = parents.get(context)
        if context is None:
            context_name = "Execution"
        else:
            context_name = context.get("name", "Unnamed")
            context_name = f"{context.tag.title()}: {context_name}"

        for link in _SCREENSHOT_PATTERN.findall(message.text or ""):
            filename = Path(unquote(urlsplit(link).path)).name
            if not filename.startswith("selenium-screenshot-"):
                continue
            screenshot = report_html.parent / filename
            if not screenshot.is_file():
                raise FileNotFoundError(
                    f"Screenshot referenced by {context_name!r} is missing: "
                    f"{screenshot}"
                )
            screenshots_by_context.setdefault(context_name, set()).add(filename)

    report = report_html.read_text(encoding="utf-8")
    start = report.find(_GALLERY_START)
    if start >= 0:
        end = report.find(_GALLERY_END, start)
        if end < 0:
            raise ValueError("Robot screenshot gallery marker is incomplete.")
        report = report[:start] + report[end + len(_GALLERY_END) :]

    if screenshots_by_context:
        cards = []
        for context_name, filenames in screenshots_by_context.items():
            for filename in sorted(filenames):
                image_url = quote(filename)
                caption = html.escape(context_name)
                cards.append(
                    '<figure class="robot-screenshot-card">'
                    f'<a href="{image_url}"><img src="{image_url}" '
                    f'alt="Failure screenshot for {caption}" '
                    'loading="lazy"></a>'
                    f"<figcaption>{caption}</figcaption>"
                    "</figure>"
                )
        gallery = (
            f"\n{_GALLERY_START}\n"
            "<section id=\"robot-screenshot-gallery\" "
            "aria-labelledby=\"robot-screenshot-title\">"
            "<style>"
            "#robot-screenshot-gallery{margin:2em 1em;padding:1em;"
            "border:1px solid #ccc;border-radius:4px}"
            "#robot-screenshot-gallery .robot-screenshot-grid{display:grid;"
            "grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:1em}"
            "#robot-screenshot-gallery .robot-screenshot-card{margin:0}"
            "#robot-screenshot-gallery img{display:block;width:100%;height:auto;"
            "border:1px solid #ccc}"
            "#robot-screenshot-gallery figcaption{padding:.5em 0;"
            "overflow-wrap:anywhere}"
            "</style>"
            '<h2 id="robot-screenshot-title">Failure screenshots</h2>'
            '<div class="robot-screenshot-grid">'
            + "".join(cards)
            + "</div></section>\n"
            f"{_GALLERY_END}\n"
        )
        body_end = report.lower().rfind("</body>")
        if body_end < 0:
            raise ValueError("Robot report does not contain a closing body tag.")
        report = report[:body_end] + gallery + report[body_end:]

    report_html.write_text(report, encoding="utf-8")
