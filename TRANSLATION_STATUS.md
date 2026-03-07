# Translation Status

This file tracks the state of the Lean translations as learning material, not
just as code artifacts.

## Status meanings

- `not started`: no Lean chapter exists yet.
- `draft translated`: Lean file exists and roughly covers the chapter.
- `needs comparison review`: compare Rocq and Lean subsection-by-subsection.
- `needs reading-quality pass`: chapter compiles, but still needs a learner-
  focused prose/proof review.
- `ready to study`: chapter compiles, the translation comparison has been done,
  and the reading-quality pass is complete.

## Updating this file

Prefer the helper script over manual table edits when working from the terminal:

```bash
python3 scripts/update_translation_status.py get Basics
python3 scripts/update_translation_status.py set Basics \
  --rocq rocq/lf/Basics.v \
  --lean lean/lf/Basics.lean \
  --status "ready to study" \
  --notes "Comparison review and reading-quality pass completed; structure, prose, and pedagogy are in good shape."
```

Keep `Notes` short and current. Replace stale notes instead of appending a long
history.

## Chapters

| Chapter | Rocq | Lean | Status | Notes |
| --- | --- | --- | --- | --- |
| Basics | `rocq/lf/Basics.v` | `lean/lf/Basics.lean` | ready to study | Comparison review and reading-quality pass completed; structure, prose, and chapter-level pedagogy are in good shape. |
| Induction | `rocq/lf/Induction.v` | `lean/lf/Induction.lean` | ready to study | Structure, prose, and worked proofs are translated; student exercises remain as sorry by design, and the chapter now imports `lf.Basics` like the Rocq original depends on `Basics`. |
