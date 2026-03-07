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

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found in PATH; enter the nix dev shell or install Python" >&2
  exit 1
fi

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$repo_root"

build_root=".build/lean"

python3 scripts/build_lean_deps.py "$lean_file" --build-root "$build_root"

echo "Checking $lean_file with the repository Lean toolchain..."
LEAN_PATH="$build_root${LEAN_PATH:+:$LEAN_PATH}" lean -R lean "$lean_file"
