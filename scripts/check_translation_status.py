#!/usr/bin/env python3

"""Validate TRANSLATION_STATUS.md against the repository tree."""

from __future__ import annotations

import argparse
from pathlib import Path
import sys


VALID_STATUSES = {
    "not started",
    "draft translated",
    "needs comparison review",
    "needs reading-quality pass",
    "ready to study",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Check TRANSLATION_STATUS.md for stale or inconsistent rows."
    )
    parser.add_argument(
        "--file",
        type=Path,
        default=Path("TRANSLATION_STATUS.md"),
        help="Path to the translation status markdown file.",
    )
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=Path("."),
        help="Repository root used to validate referenced files.",
    )
    return parser.parse_args()


def split_row(line: str) -> list[str] | None:
    stripped = line.strip()
    if not (stripped.startswith("|") and stripped.endswith("|")):
        return None
    cells = [part.strip() for part in stripped.split("|")[1:-1]]
    if len(cells) != 5:
        return None
    return cells


def strip_code(cell: str) -> str:
    if cell.startswith("`") and cell.endswith("`") and len(cell) >= 2:
        return cell[1:-1]
    return cell


def load_lines(path: Path) -> list[str]:
    try:
        return path.read_text(encoding="utf-8").splitlines()
    except FileNotFoundError:
        print(f"missing status file: {path}", file=sys.stderr)
        raise SystemExit(1)


def parse_rows(path: Path) -> list[dict[str, str]]:
    lines = load_lines(path)
    header_seen = False
    rows: list[dict[str, str]] = []

    for line in lines:
        cells = split_row(line)
        if cells == ["Chapter", "Rocq", "Lean", "Status", "Notes"]:
            header_seen = True
            continue
        if not header_seen:
            continue
        if cells is None:
            if rows:
                break
            continue
        if cells[0] == "---":
            continue
        rows.append(
            {
                "chapter": cells[0],
                "rocq": strip_code(cells[1]),
                "lean": strip_code(cells[2]),
                "status": cells[3],
                "notes": cells[4],
            }
        )

    if not header_seen:
        print("could not find translation status table", file=sys.stderr)
        raise SystemExit(1)
    return rows


def chapter_name_from_path(path_str: str, suffix: str) -> str:
    path = Path(path_str)
    return path.name.removesuffix(suffix)


def main() -> None:
    args = parse_args()
    repo_root = args.repo_root.resolve()
    rows = parse_rows(args.file)
    errors: list[str] = []

    seen_chapters: set[str] = set()
    lean_rows: dict[str, dict[str, str]] = {}

    for row in rows:
        chapter = row["chapter"]
        rocq_path = repo_root / row["rocq"]
        lean_path = repo_root / row["lean"]
        status = row["status"]
        notes = row["notes"]

        if chapter in seen_chapters:
            errors.append(f"duplicate chapter row: {chapter}")
        seen_chapters.add(chapter)

        if status not in VALID_STATUSES:
            errors.append(f"{chapter}: invalid status '{status}'")

        if not notes:
            errors.append(f"{chapter}: notes should not be empty")

        if not rocq_path.is_file():
            errors.append(f"{chapter}: missing Rocq file {row['rocq']}")

        if chapter_name_from_path(row["rocq"], ".v") != chapter:
            errors.append(f"{chapter}: Rocq path basename does not match chapter name")

        if chapter_name_from_path(row["lean"], ".lean") != chapter:
            errors.append(f"{chapter}: Lean path basename does not match chapter name")

        if status == "not started":
            if lean_path.exists():
                errors.append(f"{chapter}: status is 'not started' but Lean file exists")
        else:
            if not lean_path.is_file():
                errors.append(
                    f"{chapter}: status is '{status}' but Lean file is missing: {row['lean']}"
                )

        if row["lean"] in lean_rows:
            errors.append(f"duplicate Lean path in status table: {row['lean']}")
        lean_rows[row["lean"]] = row

    for lean_file in sorted((repo_root / "lean/lf").glob("*.lean")):
        rel = lean_file.relative_to(repo_root).as_posix()
        if rel not in lean_rows:
            errors.append(f"missing status row for Lean chapter {rel}")

    if errors:
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        raise SystemExit(1)

    print(f"Translation status table OK: {len(rows)} chapter row(s) checked.")


if __name__ == "__main__":
    main()
