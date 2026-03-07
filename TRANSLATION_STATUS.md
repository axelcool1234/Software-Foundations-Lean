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

## Chapters

| Chapter | Rocq | Lean | Status | Notes |
| --- | --- | --- | --- | --- |
| Basics | `rocq/lf/Basics.v` | `lean/lf/Basics.lean` | needs reading-quality pass | Compiles; prose and structure were restored, but a final learner-focused pass is still worthwhile. |
