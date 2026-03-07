#!/usr/bin/env sh
set -eu

usage() {
  cat <<'EOF' >&2
usage: scripts/work_on_chapter.sh <Chapter> [--scaffold] [--status <status> --notes <notes>]

Examples:
  scripts/work_on_chapter.sh Basics
  scripts/work_on_chapter.sh Induction --scaffold
  scripts/work_on_chapter.sh Basics --status "ready to study" --notes "Comparison review and reading-quality pass completed."
EOF
  exit 1
}

if [ "$#" -lt 1 ]; then
  usage
fi

chapter=$1
shift

scaffold=false
status=''
notes=''

while [ "$#" -gt 0 ]; do
  case "$1" in
    --scaffold)
      scaffold=true
      shift
      ;;
    --status)
      [ "$#" -ge 2 ] || usage
      status=$2
      shift 2
      ;;
    --notes)
      [ "$#" -ge 2 ] || usage
      notes=$2
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$repo_root"

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 not found in PATH; enter the nix dev shell or install Python" >&2
  exit 1
fi

rocq_file="rocq/lf/$chapter.v"
lean_file="lean/lf/$chapter.lean"

if [ ! -f "$rocq_file" ]; then
  echo "missing Rocq chapter: $rocq_file" >&2
  exit 1
fi

echo "== Chapter =="
echo "$chapter"
echo

echo "== Files =="
echo "Rocq: $rocq_file"
echo "Lean: $lean_file"
echo

echo "== Current status =="
if python3 scripts/update_translation_status.py get "$chapter" --field row >/dev/null 2>&1; then
  python3 scripts/update_translation_status.py get "$chapter" --field row
else
  echo "No status row yet for $chapter"
fi
echo

if [ -f "$lean_file" ]; then
  echo "== Review =="
  scripts/review_chapter_translation.sh "$rocq_file" "$lean_file"
  echo
elif [ "$scaffold" = true ]; then
  echo "== Scaffold =="
  python3 scripts/scaffold_lean_chapter.py "$rocq_file" "$lean_file"
  echo
  if [ -z "$status" ]; then
    status='draft translated'
  fi
  if [ -z "$notes" ]; then
    notes='Lean scaffold generated from Rocq headings; translate prose, definitions, examples, and proofs.'
  fi
else
  echo "== Lean file missing =="
  echo "Run this to create a scaffold:"
  echo "python3 scripts/scaffold_lean_chapter.py $rocq_file $lean_file"
  echo
fi

if [ -n "$status" ] && [ -z "$notes" ]; then
  echo "--status requires --notes" >&2
  exit 1
fi

if [ -n "$notes" ] && [ -z "$status" ]; then
  echo "--notes requires --status" >&2
  exit 1
fi

if [ -n "$status" ]; then
  echo "== Updating status =="
  python3 scripts/update_translation_status.py set "$chapter" \
    --rocq "$rocq_file" \
    --lean "$lean_file" \
    --status "$status" \
    --notes "$notes"
else
  echo "== Next step =="
  echo "Update TRANSLATION_STATUS.md with:"
  echo "python3 scripts/update_translation_status.py set $chapter --rocq $rocq_file --lean $lean_file --status \"<status>\" --notes \"<notes>\""
fi
