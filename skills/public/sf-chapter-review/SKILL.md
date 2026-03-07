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
2. Run the heading comparison helper when useful.
3. Compare the chapter subsection-by-subsection.
4. Review both code and commentary.
5. Evaluate proof pedagogy from a Lean-first learning perspective.
6. Run the Lean typecheck if the task includes verification or fixes.
7. End with a concise verdict on chapter readiness.

## What to look for

- Missing or merged subsections.
- Headings preserved but prose removed.
- Definitions or examples missing from the Lean version.
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

## Useful repo resources

- `AGENTS.md`
- `docs/translation-style.md`
- `TRANSLATION_STATUS.md`
- `scripts/compare_chapter_headings.sh`
- `scripts/review_chapter_translation.sh`

## Common commands

```bash
scripts/compare_chapter_headings.sh rocq/lf/Basics.v lean/lf/Basics.lean
```

```bash
scripts/review_chapter_translation.sh rocq/lf/Basics.v lean/lf/Basics.lean
```

## If the user also wants fixes

First do the review, then patch the Lean chapter, then rerun the Lean check.
