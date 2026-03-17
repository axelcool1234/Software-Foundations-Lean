#!/usr/bin/env python3

"""Print exercise declarations and statements side by side for manual review."""

from __future__ import annotations

import argparse
from pathlib import Path
import sys
import textwrap

from exercise_compare_lib import Exercise, load_exercises


COL_WIDTH = 56


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Print Rocq and Lean exercise declarations side by side for manual review."
    )
    parser.add_argument("rocq_file", type=Path)
    parser.add_argument("lean_file", type=Path)
    parser.add_argument(
        "--exercise",
        help="Show only the named exercise.",
    )
    return parser.parse_args()


def format_decl(exercise: Exercise) -> list[str]:
    lines: list[str] = []
    for decl in exercise.declarations:
        header = f"L{decl.line} {decl.kind} {decl.name}"
        body = decl.signature if decl.signature is not None else "<no statement extracted>"
        lines.extend(textwrap.wrap(header, width=COL_WIDTH) or [header])
        wrapped_body = textwrap.wrap(body, width=COL_WIDTH - 2) or [body]
        lines.extend(f"  {part}" for part in wrapped_body)
    if not lines:
        lines.append("<no declarations in exercise block>")
    return lines


def print_side_by_side(left: list[str], right: list[str]) -> None:
    max_len = max(len(left), len(right))
    padded_left = left + [""] * (max_len - len(left))
    padded_right = right + [""] * (max_len - len(right))
    for left_line, right_line in zip(padded_left, padded_right):
        print(f"{left_line:<{COL_WIDTH}}  {right_line}")


def main() -> None:
    args = parse_args()
    if not args.rocq_file.is_file():
        print(f"missing Rocq file: {args.rocq_file}", file=sys.stderr)
        raise SystemExit(1)
    if not args.lean_file.is_file():
        print(f"missing Lean file: {args.lean_file}", file=sys.stderr)
        raise SystemExit(1)

    rocq_exercises, lean_exercises = load_exercises(args.rocq_file, args.lean_file)
    rocq_by_name = {exercise.name: exercise for exercise in rocq_exercises}
    lean_by_name = {exercise.name: exercise for exercise in lean_exercises}
    names = sorted(rocq_by_name.keys() | lean_by_name.keys())
    if args.exercise is not None:
        names = [name for name in names if name == args.exercise]
        if not names:
            print(f"exercise not found: {args.exercise}", file=sys.stderr)
            raise SystemExit(1)

    print(f"Rocq: {args.rocq_file}")
    print(f"Lean: {args.lean_file}")
    print()

    for idx, name in enumerate(names):
        rocq_exercise = rocq_by_name.get(name)
        lean_exercise = lean_by_name.get(name)
        print(f"Exercise: {name}")
        print(f"{'Rocq':<{COL_WIDTH}}  Lean")
        print(f"{'-' * COL_WIDTH}  {'-' * COL_WIDTH}")
        left_lines = (
            format_decl(rocq_exercise)
            if rocq_exercise is not None
            else ["<missing exercise heading>"]
        )
        right_lines = (
            format_decl(lean_exercise)
            if lean_exercise is not None
            else ["<missing exercise heading>"]
        )
        print_side_by_side(left_lines, right_lines)
        if idx + 1 < len(names):
            print()


if __name__ == "__main__":
    main()
