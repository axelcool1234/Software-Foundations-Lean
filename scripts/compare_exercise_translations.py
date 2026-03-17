#!/usr/bin/env python3

"""Compare exercise blocks and exercise-local declarations across chapters."""

from __future__ import annotations

import argparse
from pathlib import Path
import sys

from exercise_compare_lib import compare_exercises, load_exercises


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Compare exercise headings and exercise-local declarations between a Rocq chapter and its Lean translation."
    )
    parser.add_argument("rocq_file", type=Path)
    parser.add_argument("lean_file", type=Path)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if not args.rocq_file.is_file():
        print(f"missing Rocq file: {args.rocq_file}", file=sys.stderr)
        raise SystemExit(1)
    if not args.lean_file.is_file():
        print(f"missing Lean file: {args.lean_file}", file=sys.stderr)
        raise SystemExit(1)

    rocq_exercises, lean_exercises = load_exercises(args.rocq_file, args.lean_file)
    findings = compare_exercises(rocq_exercises, lean_exercises)

    print(f"Rocq exercises: {len(rocq_exercises)}")
    print(f"Lean exercises: {len(lean_exercises)}")
    print()
    if findings:
        print("Findings:")
        for finding in findings:
            print(f"- {finding}")
    else:
        print("No exercise-translation findings.")


if __name__ == "__main__":
    main()
