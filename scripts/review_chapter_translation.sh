#!/usr/bin/env sh
set -eu

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <rocq-file> <lean-file>" >&2
  exit 1
fi

rocq_file=$1
lean_file=$2

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$repo_root"

if [ ! -f "$rocq_file" ]; then
  echo "missing Rocq file: $rocq_file" >&2
  exit 1
fi

if [ ! -f "$lean_file" ]; then
  echo "missing Lean file: $lean_file" >&2
  exit 1
fi

echo "== Heading comparison =="
scripts/compare_chapter_headings.sh "$rocq_file" "$lean_file"

echo
echo "== Lean typecheck =="
scripts/check_lean_chapter.sh "$lean_file"

echo
echo "== Reminder =="
echo "Do a reading-quality pass after reviewing this output."
echo "Check subsection prose, proof pedagogy, and Lean-specific notes, not just compilation."
