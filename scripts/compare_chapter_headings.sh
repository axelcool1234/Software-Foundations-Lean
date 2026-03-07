#!/usr/bin/env sh
set -eu

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <rocq-file> <lean-file>" >&2
  exit 1
fi

rocq_file=$1
lean_file=$2

if [ ! -f "$rocq_file" ]; then
  echo "missing Rocq file: $rocq_file" >&2
  exit 1
fi

if [ ! -f "$lean_file" ]; then
  echo "missing Lean file: $lean_file" >&2
  exit 1
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT INT TERM

extract_rocq() {
  awk '
    /^\(\*\* \*/ || /^\(\*\* \*\*/ || /^\(\*\* \*\*\*\*/ {
      line = $0
      sub(/^\(\*\* /, "", line)
      sub(/ \*\)$/, "", line)
      printf "%5d | %s\n", NR, line
    }
  ' "$1"
}

extract_lean() {
  awk '
    /^\/\- \*/ || /^\/\- \*\*/ || /^\/\- \*\*\*\*/ {
      line = $0
      sub(/^\/\- /, "", line)
      sub(/ -\/$/, "", line)
      printf "%5d | %s\n", NR, line
    }
  ' "$1"
}

extract_rocq "$rocq_file" > "$tmpdir/rocq.txt"
extract_lean "$lean_file" > "$tmpdir/lean.txt"

printf 'Rocq: %s\n' "$rocq_file"
printf 'Lean: %s\n\n' "$lean_file"

printf '%-48s %s\n' "Rocq headings" "Lean headings"
printf '%-48s %s\n' "--------------------------------" "--------------------------------"
paste "$tmpdir/rocq.txt" "$tmpdir/lean.txt" | awk -F '\t' '{ printf "%-48s %s\n", $1, $2 }'
