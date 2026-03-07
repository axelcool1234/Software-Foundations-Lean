---
name: sf-chapter-review
description: Use when comparing a Rocq Software Foundations chapter and its Lean translation before starting work, or when reviewing whether the Lean chapter is good learning material.
---

# SF Chapter Review

Use this skill when the user wants a structured review of a Rocq chapter and
its Lean translation, especially before relying on the Lean chapter for study or
further edits.

## Review goals

- Check whether the Lean chapter preserves the structure of the Rocq chapter.
- Check whether explanatory prose is present, not just code.
- Check whether proofs teach good Lean habits for the level of the chapter.
- Distinguish acceptable Lean adaptations from real translation gaps.

## Review workflow

1. Identify the Rocq file and Lean file.
2. Check `TRANSLATION_STATUS.md` for an existing row for the chapter before starting the review.
3. Run the heading comparison helper when useful.
4. Compare the chapter subsection-by-subsection.
5. Review both code and commentary.
6. Evaluate proof pedagogy from a Lean-first learning perspective.
7. Run the Lean typecheck if the task includes verification or fixes.
8. End with a concise verdict on chapter readiness.
9. Update `TRANSLATION_STATUS.md` so the chapter row matches the review outcome.

## Status tracking workflow

Treat `TRANSLATION_STATUS.md` as the canonical chapter-level summary, not as a
full audit log.

- Before reviewing, read the existing chapter row if one exists.
- Prefer `python3 scripts/update_translation_status.py get <Chapter>` over manual table scanning when working from the terminal.
- Use the existing status and notes to understand whether the chapter is still a
  draft, due for comparison, or awaiting a reading-quality pass.
- After the review, update the row for that chapter.
- Prefer `python3 scripts/update_translation_status.py set ...` over manual table editing.
- If the chapter is missing from the table, add a new row.
- Keep the `Notes` field short and current. Replace stale notes instead of
  appending a long running history.

Suggested verdict-to-status mapping:

- `ready to study` -> `ready to study`
- `needs prose restoration` -> `needs reading-quality pass`
- `needs proof-style cleanup` -> `needs reading-quality pass`
- `needs structural cleanup first` -> `needs comparison review`

If the review finds concrete gaps but fixes are not yet applied, prefer the most
conservative status that still reflects the blocker.

## What to look for

- Missing or merged subsections.
- Headings preserved but prose removed.
- Definitions or examples missing from the Lean version.
- Chapters that duplicate earlier Lean definitions even though a direct import
  from a previous chapter would better match the Rocq dependency structure.
- Exercise names drifting or exercises disappearing.
- Proofs that are technically valid but poor for learning Lean.
- Places where a Lean-specific explanatory note would help.

## Reporting style

- Findings first.
- Order findings by importance.
- Focus on structure, prose, code coverage, and proof pedagogy.
- Use a short final verdict such as:
  - `ready to study`
  - `needs prose restoration`
  - `needs structural cleanup first`
  - `needs proof-style cleanup`

## Script roles

- `scripts/review_chapter_translation.sh`: default review entry point when the
  Lean chapter already exists. Use this first unless you specifically need only
  the heading diff.
- `scripts/compare_chapter_headings.sh`: structure-only helper. Use it when you
  want a quick subsection alignment view before or alongside the deeper review.
- `scripts/update_translation_status.py get`: read the current chapter row
  before reviewing.
- `scripts/update_translation_status.py set`: update the chapter row after the
  review is complete and any requested fixes have been verified.
- `scripts/work_on_chapter.sh`: optional convenience wrapper for humans. Useful
  for manual chapter workflow, but this skill should still reason explicitly
  about the review findings rather than relying on the wrapper's output alone.
- `scripts/check_lean_chapter.sh`: import-aware Lean chapter checker. Use it
  when you need direct verification after review findings or fixes; it builds
  local imported chapters into `.build/lean/` before checking the target file.
- `scripts/check_translation_status.py`: repository validation helper, mainly
  for consistency checks and CI. Do not use it as a substitute for chapter
  review.

## Useful repo resources

- `AGENTS.md`
- `docs/translation-style.md`
- `TRANSLATION_STATUS.md`
- `scripts/update_translation_status.py`
- `scripts/compare_chapter_headings.sh`
- `scripts/review_chapter_translation.sh`

## Common commands

```bash
python3 scripts/update_translation_status.py get Basics
```

```bash
scripts/compare_chapter_headings.sh rocq/lf/Basics.v lean/lf/Basics.lean
```

```bash
scripts/review_chapter_translation.sh rocq/lf/Basics.v lean/lf/Basics.lean
```

```bash
python3 scripts/update_translation_status.py set Basics \
  --rocq rocq/lf/Basics.v \
  --lean lean/lf/Basics.lean \
  --status "ready to study" \
  --notes "Comparison review and reading-quality pass completed; structure, prose, and pedagogy are in good shape."
```

## If the user also wants fixes

First do the review, then patch the Lean chapter, then rerun the Lean check.
After the fixes are verified, update `TRANSLATION_STATUS.md` to reflect the new
post-fix verdict rather than the pre-fix review state.
