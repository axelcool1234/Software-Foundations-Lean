# Software Foundations Lean Translation Workflow

This repository contains the original Rocq/Coq sources from Software
Foundations and a growing Lean translation.

The workflow in this repo is set up so you can use agents to:

- translate chapters from Rocq to Lean,
- compare a Lean chapter against the Rocq original before starting work,
- review whether a translated chapter is good learning material,
- and keep the Lean files readable as educational documents.

This README is for humans. The agent-facing rules live in [AGENTS.md](AGENTS.md).

## Repository layout

- `rocq/lf/`: original Software Foundations chapters in Rocq/Coq.
- `lean/lf/`: Lean translations.
- `scripts/`: helper scripts for translation review, chapter scaffolding, status management, and Lean checking.
- `skills/public/`: repo-local Codex skills for translation and chapter review.
- `docs/translation-style.md`: guidance on proof style and pedagogical goals.
- `TRANSLATION_STATUS.md`: chapter-by-chapter status tracker.
- `lean-toolchain`: pins the repository to Lean stable.

## Main idea

The Lean chapters are meant to be good for learning Lean proofs, not just for
being technically faithful ports of the Rocq files.

That means:

- idiomatic Lean is preferred when it helps,
- pedagogical clarity matters more than mechanical fidelity,
- prose and subsection structure matter,
- and each chapter should still read like a chapter, not just a code dump.

## Setup

If you are using Nix:

```bash
nix develop
```

This gives you `elan`, `python3`, and Rocq tools. The repository also has a
[`lean-toolchain`](lean-toolchain), so plain `lean` commands will use the pinned
stable Lean version through `elan`.

## Everyday commands

Check a Lean chapter:

```bash
scripts/check_lean_chapter.sh lean/lf/Basics.lean
```

Compare Rocq and Lean chapter headings:

```bash
scripts/compare_chapter_headings.sh rocq/lf/Basics.v lean/lf/Basics.lean
```

Run the basic chapter review workflow:

```bash
scripts/review_chapter_translation.sh rocq/lf/Basics.v lean/lf/Basics.lean
```

Validate the translation status table and typecheck all Lean chapters:

```bash
scripts/check_translation_workflow.sh
```

Read or update a chapter status row:

```bash
python3 scripts/update_translation_status.py get Basics
python3 scripts/update_translation_status.py set Basics \
  --rocq rocq/lf/Basics.v \
  --lean lean/lf/Basics.lean \
  --status "ready to study" \
  --notes "Comparison review and reading-quality pass completed; structure, prose, and pedagogy are in good shape."
```

Create a Lean scaffold from Rocq headings:

```bash
python3 scripts/scaffold_lean_chapter.py rocq/lf/Induction.v
```

Run the chapter workflow helper:

```bash
scripts/work_on_chapter.sh Basics
scripts/work_on_chapter.sh Induction --scaffold
```

Compile a Rocq chapter and its test:

```bash
cd rocq
rocq compile -Q . LF Basics.v
rocq compile -Q . LF BasicsTest.v
```

## How to use agents

### 1. Before starting a chapter

Ask the agent to compare the Rocq and Lean versions before making changes.

Good prompt:

> Compare `rocq/lf/Basics.v` and `lean/lf/Basics.lean` subsection-by-subsection.
> Focus on missing prose, missing structure, and whether the Lean proofs are
> pedagogically good Lean. Give me findings first and a short verdict at the end.

This is useful when a chapter already exists and you want to know whether it is
ready to study from or needs cleanup first.

### 2. When translating a new chapter

Ask the agent to translate the chapter while preserving the chapter structure
and writing for Lean learners.

Good prompt:

> Translate `rocq/lf/Induction.v` to `lean/lf/Induction.lean`. Preserve the
> textbook structure and prose, but prefer idiomatic Lean when it improves the
> pedagogy. Leave exercises as `sorry` unless already proved in the source.

### 3. When reviewing a translated chapter

Ask the agent to do a reading-quality pass, not just a compile pass.

Good prompt:

> Review `lean/lf/Basics.lean` as learning material. Assume I want to get good
> at Lean proofs. Are the comments, examples, and proof styles good for that?
> Findings first.

### 4. When fixing a chapter after comparison

Ask the agent to compare, patch, and rerun the Lean check.

Good prompt:

> Compare `rocq/lf/Basics.v` and `lean/lf/Basics.lean`, fix any structural or
> pedagogical gaps you find, and rerun the Lean typecheck.

## What the agents are expected to optimize for

The workflow is intentionally tuned for Lean-first learning.

Agents should generally:

- preserve the section and subsection structure from Rocq,
- preserve the prose between code blocks,
- explain Lean-specific differences when they matter,
- prefer idiomatic Lean proof style when it helps the learner,
- avoid clever automation that hides the proof idea,
- keep exercises in place as `sorry` unless asked otherwise.

The detailed policy is in [AGENTS.md](AGENTS.md) and
[docs/translation-style.md](docs/translation-style.md).

## Repo-local skills

This repo also includes two reusable local skills under `skills/public/`:

- `sf-lean-translation`: for translating a Software Foundations chapter into a
  literate, Lean-first chapter.
- `sf-chapter-review`: for comparing a Rocq chapter and a Lean translation and
  judging whether the Lean version is good study material.

These are useful when you want agents to reuse the same structured workflow
instead of relying only on ad hoc prompts.

## Translation status

Use [TRANSLATION_STATUS.md](TRANSLATION_STATUS.md) to track where each chapter
stands.

Suggested meanings:

- `not started`: no Lean file exists.
- `draft translated`: rough Lean translation exists.
- `needs comparison review`: compare Rocq and Lean directly.
- `needs reading-quality pass`: compiles, but needs learner-focused review.
- `ready to study`: good enough to read as Lean learning material.

## Suggested workflow per chapter

1. Start with `scripts/work_on_chapter.sh <Chapter>` to inspect the current status.
2. If no Lean file exists, create a scaffold with `--scaffold` or `scripts/scaffold_lean_chapter.py`.
3. Translate or improve the chapter.
4. Run `scripts/check_lean_chapter.sh`.
5. Run `scripts/review_chapter_translation.sh`.
6. Do a final reading-quality pass.
7. Update the status row with `scripts/update_translation_status.py`.
8. Periodically run `scripts/check_translation_workflow.sh` to catch ledger drift and Lean regressions.

## Notes

- The chapter heading comparison script is a structural aid, not a semantic
  review. It helps catch missing or reordered subsections, but it does not tell
  you whether the prose is good.
- `scripts/check_translation_status.py` only validates the ledger and file
  layout. It does not decide whether a chapter is genuinely ready to study.
- `#check` and `#eval` output in Lean chapters is intentionally kept, since it
  is useful while reading and learning.
- If a chapter differs materially from the Rocq version because Lean has a
  better pedagogical presentation, that is acceptable. The important thing is
  that the Lean file teaches Lean well.
