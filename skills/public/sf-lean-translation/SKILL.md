---
name: sf-lean-translation
description: Use when translating a Software Foundations chapter from Rocq/Coq to Lean, especially when the Lean file should remain literate, pedagogical, and idiomatic.
---

# SF Lean Translation

Use this skill when the task is to translate a chapter such as
`rocq/lf/Basics.v` into a matching Lean file under `lean/lf/`.

## Goals

- Preserve the chapter as readable learning material.
- Prefer idiomatic Lean when it helps teach Lean well.
- Preserve the chapter's section/subsection structure and educational flow.
- Leave student exercises as `sorry` unless explicitly asked to solve them.

## Workflow

1. Identify the Rocq source file and the target Lean file.
2. Check `TRANSLATION_STATUS.md` for an existing row for the chapter before starting substantial work.
3. If the Lean file already exists, compare the two files subsection-by-
   subsection before editing.
4. Translate definitions, examples, comments, and proof structure in order.
5. Rewrite prose where the Lean version differs materially and explain the Lean
   differences when that helps the reader.
6. Keep executable examples such as `#eval`, `#check`, and small `theorem`
   examples when they support the pedagogy.
7. Typecheck the Lean file.
8. Do a reading-quality pass as if you were learning the chapter from Lean.
9. Update `TRANSLATION_STATUS.md` if the chapter status changed.

## Status tracking workflow

Treat `TRANSLATION_STATUS.md` as the chapter-level summary of translation
readiness.

- Before translating, read the existing chapter row if one exists.
- Prefer `python scripts/update_translation_status.py get <Chapter>` over
  manual table scanning when working from the terminal.
- After translating, update the chapter row with the most accurate current
  state.
- Prefer `python scripts/update_translation_status.py set ...` over manual table
  editing.
- Keep the `Notes` field short and current rather than appending a long history.

Suggested status choices after translation work:

- `draft translated`: the Lean file exists and roughly covers the chapter, but
  substantial translation or structural work remains.
- `needs comparison review`: the translation is present, but the chapter still
  needs a direct Rocq-vs-Lean comparison review.
- `needs reading-quality pass`: the translation compiles and structure is in
  place, but the final learner-focused prose/proof pass is still pending.
- `ready to study`: translation, comparison review, and reading-quality pass are
  all complete.

## Key rules

- Keep headings parallel to the Rocq chapter unless a Lean-specific change is
  clearly better for learning.
- Do not drop subsection-level prose just because the code is short.
- Prefer `rfl`, `simp`, `rw`, `cases`, `induction`, and other chapter-
  appropriate Lean proof tools over heavy automation.
- Use Lean-specific notes when the Lean version intentionally diverges from the
  Rocq presentation.

## Useful repo resources

- `AGENTS.md`
- `docs/translation-style.md`
- `TRANSLATION_STATUS.md`
- `scripts/update_translation_status.py`
- `scripts/check_lean_chapter.sh`
- `scripts/review_chapter_translation.sh`

## Common commands

```bash
python scripts/update_translation_status.py get Basics
```

```bash
scripts/check_lean_chapter.sh lean/lf/Basics.lean
```

```bash
scripts/review_chapter_translation.sh rocq/lf/Basics.v lean/lf/Basics.lean
```

```bash
python scripts/update_translation_status.py set Basics \
  --rocq rocq/lf/Basics.v \
  --lean lean/lf/Basics.lean \
  --status "needs reading-quality pass" \
  --notes "Translation compiles and structure is present; do a final learner-focused pass before marking it ready to study."
```

## Deliverable

Provide a Lean chapter that compiles, preserves the educational structure, and
reads like a Lean-first teaching document.
