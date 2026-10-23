import sys
import xml.etree.ElementTree as ET
from pathlib import Path

from robot import run_cli

from libraries.robot_report import add_screenshot_gallery


def _option_value(arguments: list[str], names: tuple[str, ...], default: str) -> str:
    for index, argument in enumerate(arguments):
        for name in names:
            if argument == name:
                if index + 1 >= len(arguments):
                    raise ValueError(f"Missing value for Robot option {name}.")
                return arguments[index + 1]
            if argument.startswith(f"{name}="):
                return argument.partition("=")[2]
    return default


def _report_paths(arguments: list[str]) -> tuple[Path, Path] | None:
    output_dir = Path(_option_value(arguments, ("--outputdir", "-d"), "."))
    output_name = _option_value(arguments, ("--output", "-o"), "output.xml")
    report_name = _option_value(arguments, ("--report", "-r"), "report.html")
    if output_name.upper() == "NONE" or report_name.upper() == "NONE":
        return None
    return output_dir / output_name, output_dir / report_name


def main() -> int:
    arguments = sys.argv[1:]
    robot_status = run_cli(arguments, exit=False)
    try:
        paths = _report_paths(arguments)
        if paths is not None:
            add_screenshot_gallery(*paths)
    except (OSError, ET.ParseError, ValueError) as error:
        print(f"Failed to add screenshots to Robot report: {error}", file=sys.stderr)
        if robot_status == 0:
            return 1
    return robot_status


if __name__ == "__main__":
    raise SystemExit(main())
