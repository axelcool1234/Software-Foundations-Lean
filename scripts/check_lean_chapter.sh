#!/usr/bin/env sh
set -eu

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <lean-file>" >&2
  exit 1
fi

lean_file=$1

if [ ! -f "$lean_file" ]; then
  echo "missing Lean file: $lean_file" >&2
  exit 1
fi

if ! command -v lean >/dev/null 2>&1; then
  echo "lean not found in PATH; install elan or enter the nix dev shell" >&2
  exit 1
fi

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$repo_root"

echo "Checking $lean_file with the repository Lean toolchain..."
lean "$lean_file"
