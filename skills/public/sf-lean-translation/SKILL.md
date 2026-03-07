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
2. If the Lean file already exists, compare the two files subsection-by-
   subsection before editing.
3. Translate definitions, examples, comments, and proof structure in order.
4. Rewrite prose where the Lean version differs materially and explain the Lean
   differences when that helps the reader.
5. Keep executable examples such as `#eval`, `#check`, and small `theorem`
   examples when they support the pedagogy.
6. Typecheck the Lean file.
7. Do a reading-quality pass as if you were learning the chapter from Lean.
8. Update `TRANSLATION_STATUS.md` if the chapter status changed.

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
- `scripts/check_lean_chapter.sh`
- `scripts/review_chapter_translation.sh`

## Common commands

```bash
scripts/check_lean_chapter.sh lean/lf/Basics.lean
```

```bash
scripts/review_chapter_translation.sh rocq/lf/Basics.v lean/lf/Basics.lean
```

## Deliverable

Provide a Lean chapter that compiles, preserves the educational structure, and
reads like a Lean-first teaching document.
