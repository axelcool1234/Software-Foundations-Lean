#!/usr/bin/env python3

"""Read and update chapter rows in TRANSLATION_STATUS.md."""

from __future__ import annotations

import argparse
from pathlib import Path
import sys


DEFAULT_STATUS_FILE = Path("TRANSLATION_STATUS.md")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Read and update rows in TRANSLATION_STATUS.md."
    )

    subparsers = parser.add_subparsers(dest="command", required=True)

    get_parser = subparsers.add_parser("get", help="Print a chapter row.")
    get_parser.add_argument("chapter", help="Chapter name, e.g. Basics.")
    get_parser.add_argument(
        "--file",
        type=Path,
        default=DEFAULT_STATUS_FILE,
        help="Path to the translation status markdown file.",
    )
    get_parser.add_argument(
        "--field",
        choices=["chapter", "rocq", "lean", "status", "notes", "row"],
        default="row",
        help="Field to print.",
    )

    set_parser = subparsers.add_parser("set", help="Create or update a chapter row.")
    set_parser.add_argument("chapter", help="Chapter name, e.g. Basics.")
    set_parser.add_argument(
        "--file",
        type=Path,
        default=DEFAULT_STATUS_FILE,
        help="Path to the translation status markdown file.",
    )
    set_parser.add_argument("--rocq", required=True, help="Rocq chapter path.")
    set_parser.add_argument("--lean", required=True, help="Lean chapter path.")
    set_parser.add_argument("--status", required=True, help="Chapter status.")
    set_parser.add_argument("--notes", required=True, help="Short chapter notes.")

    return parser.parse_args()


def sanitize_cell(value: str) -> str:
    return " ".join(value.strip().split()).replace("|", r"\|")


def split_row(line: str) -> list[str] | None:
    stripped = line.strip()
    if not (stripped.startswith("|") and stripped.endswith("|")):
        return None
    parts = [part.strip() for part in stripped.split("|")[1:-1]]
    if len(parts) != 5:
        return None
    return parts


def format_row(chapter: str, rocq: str, lean: str, status: str, notes: str) -> str:
    return (
        f"| {sanitize_cell(chapter)} | `{sanitize_cell(rocq)}` | "
        f"`{sanitize_cell(lean)}` | {sanitize_cell(status)} | {sanitize_cell(notes)} |\n"
    )


def load_lines(path: Path) -> list[str]:
    try:
        return path.read_text(encoding="utf-8").splitlines(keepends=True)
    except FileNotFoundError:
        print(f"missing status file: {path}", file=sys.stderr)
        raise SystemExit(1)


def find_table(lines: list[str]) -> tuple[int, int]:
    for idx, line in enumerate(lines):
        cells = split_row(line)
        if cells == ["Chapter", "Rocq", "Lean", "Status", "Notes"]:
            separator_idx = idx + 1
            if separator_idx >= len(lines) or split_row(lines[separator_idx]) is None:
                break
            return idx, separator_idx + 1
    print("could not find translation status table", file=sys.stderr)
    raise SystemExit(1)


def find_row(lines: list[str], chapter: str) -> tuple[int, list[str]] | None:
    _, data_start = find_table(lines)
    for idx in range(data_start, len(lines)):
        cells = split_row(lines[idx])
        if cells is None:
            break
        if cells[0] == chapter:
            return idx, cells
    return None


def get_field(cells: list[str], field: str) -> str:
    mapping = {
        "chapter": cells[0],
        "rocq": cells[1],
        "lean": cells[2],
        "status": cells[3],
        "notes": cells[4],
        "row": f"| {' | '.join(cells)} |",
    }
    return mapping[field]


def cmd_get(path: Path, chapter: str, field: str) -> None:
    lines = load_lines(path)
    row = find_row(lines, chapter)
    if row is None:
        print(f"chapter not found: {chapter}", file=sys.stderr)
        raise SystemExit(1)
    _, cells = row
    print(get_field(cells, field))


def cmd_set(path: Path, chapter: str, rocq: str, lean: str, status: str, notes: str) -> None:
    lines = load_lines(path)
    _, data_start = find_table(lines)
    new_row = format_row(chapter, rocq, lean, status, notes)

    existing = find_row(lines, chapter)
    if existing is not None:
        row_idx, _ = existing
        lines[row_idx] = new_row
    else:
        insert_at = data_start
        while insert_at < len(lines) and split_row(lines[insert_at]) is not None:
            insert_at += 1
        lines.insert(insert_at, new_row)

    path.write_text("".join(lines), encoding="utf-8")
    print(f"updated chapter row: {chapter}")


def main() -> None:
    args = parse_args()
    if args.command == "get":
        cmd_get(args.file, args.chapter, args.field)
        return
    if args.command == "set":
        cmd_set(args.file, args.chapter, args.rocq, args.lean, args.status, args.notes)
        return
    raise AssertionError(f"unexpected command: {args.command}")


if __name__ == "__main__":
    main()
