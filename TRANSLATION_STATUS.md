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
| Basics | `rocq/lf/Basics.v` | `lean/lf/Basics.lean` | ready to study | Restored chapter-local `+`, `-`, and `*` via Lean arithmetic instances so later chapters now inherit the Rocq-style custom arithmetic. |
| Induction | `rocq/lf/Induction.v` | `lean/lf/Induction.lean` | ready to study | Adjusted the finished proofs to use the chapter-local arithmetic inherited from Basics, matching the Rocq chapter's notation more closely. |
| Lists | `rocq/lf/Lists.v` | `lean/lf/Lists.lean` | ready to study | Review rerun after restoring more learner-facing motivation around generalization and reversal; structure, prose, exercises, and proof pedagogy are in good shape. |
| Poly | `rocq/lf/Poly.v` | `lean/lf/Poly.lean` | draft translated | Translation exists, but the chapter does not currently typecheck: `scripts/check_lean_chapter.sh lean/lf/Poly.lean` hits a maximum recursion depth error at `lean/lf/Poly.lean:532`. |
| Tactics | `rocq/lf/Tactics.v` | `lean/lf/Tactics.lean` | ready to study | Full Lean translation with aligned structure and pedagogy; chapter check and review pass clean except expected student-exercise sorry warnings. |
| Logic | `rocq/lf/Logic.v` | `lean/lf/Logic.lean` | ready to study | Full Lean translation with aligned structure and pedagogy; chapter check and review are clean except expected exercise sorry warnings. |
