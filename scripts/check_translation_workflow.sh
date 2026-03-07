#!/usr/bin/env sh
set -eu

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$repo_root"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found in PATH; enter the nix dev shell or install Python" >&2
  exit 1
fi

echo "== Status table =="
python3 scripts/check_translation_status.py
echo

echo "== Lean chapters =="
if [ "$#" -gt 0 ]; then
  for chapter in "$@"; do
    scripts/check_lean_chapter.sh "lean/lf/$chapter.lean"
  done
else
  found_any=false
  for lean_file in lean/lf/*.lean; do
    if [ ! -e "$lean_file" ]; then
      continue
    fi
    found_any=true
    scripts/check_lean_chapter.sh "$lean_file"
  done
  if [ "$found_any" = false ]; then
    echo "No Lean chapters found under lean/lf"
  fi
fi
