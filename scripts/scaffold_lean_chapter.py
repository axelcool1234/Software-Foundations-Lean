#!/usr/bin/env python3

"""Generate a first-pass Lean chapter skeleton from Rocq headings."""

from __future__ import annotations

import argparse
from pathlib import Path
import sys


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Create a Lean chapter scaffold from a Rocq chapter's headings."
    )
    parser.add_argument("rocq_file", type=Path, help="Rocq chapter path, e.g. rocq/lf/Basics.v")
    parser.add_argument(
        "lean_file",
        nargs="?",
        type=Path,
        help="Lean output path, defaulting to the matching path under lean/lf/.",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Overwrite the target Lean file if it already exists.",
    )
    return parser.parse_args()


def default_lean_path(rocq_file: Path) -> Path:
    if rocq_file.parts[:2] == ("rocq", "lf"):
        return Path("lean") / "lf" / rocq_file.with_suffix(".lean").name
    return rocq_file.with_suffix(".lean")


def to_lean_heading(line: str) -> str | None:
    stripped = line.strip()
    if not stripped.startswith("(** "):
        return None
    body = stripped.removeprefix("(** ")
    star_count = 0
    while star_count < len(body) and body[star_count] == "*":
        star_count += 1
    if star_count == 0 or star_count >= len(body) or body[star_count] != " ":
        return None
    stars = body[:star_count]
    title = body[star_count + 1 :]
    if title.endswith(" *)"):
        title = title[:-3]
    if stars == "*" and title.endswith("in Rocq"):
        title = title.removesuffix("in Rocq") + "in Lean"
    return f"/- {stars} {title} -/"


def collect_headings(rocq_file: Path) -> list[str]:
    headings: list[str] = []
    for raw_line in rocq_file.read_text(encoding="utf-8").splitlines():
        heading = to_lean_heading(raw_line)
        if heading is not None:
            headings.append(heading)
    return headings


def build_scaffold(rocq_file: Path, headings: list[str]) -> str:
    preamble = [
        "import Std",
        "",
        "set_option autoImplicit false",
        "",
        "/-",
        f"This file is a scaffold translated from `{rocq_file.as_posix()}`.",
        "Preserve the chapter structure, prose, examples, and pedagogical flow",
        "of the original as you fill in the Lean translation.",
        "-/",
        "",
    ]

    body: list[str] = []
    for heading in headings:
        if heading.startswith("/- * "):
            body.append("/- ################################################################# -/")
        elif heading.startswith("/- ** "):
            body.append("/- ================================================================= -/")
        body.append(heading)
        body.append("")

    return "\n".join(preamble + body).rstrip() + "\n"


def main() -> None:
    args = parse_args()
    rocq_file = args.rocq_file
    lean_file = args.lean_file or default_lean_path(rocq_file)

    if not rocq_file.is_file():
        print(f"missing Rocq file: {rocq_file}", file=sys.stderr)
        raise SystemExit(1)

    if lean_file.exists() and not args.force:
        print(f"target Lean file already exists: {lean_file}", file=sys.stderr)
        raise SystemExit(1)

    headings = collect_headings(rocq_file)
    if not headings:
        print(f"no headings found in Rocq file: {rocq_file}", file=sys.stderr)
        raise SystemExit(1)

    lean_file.parent.mkdir(parents=True, exist_ok=True)
    lean_file.write_text(build_scaffold(rocq_file, headings), encoding="utf-8")
    print(f"created Lean scaffold: {lean_file}")


if __name__ == "__main__":
    main()
