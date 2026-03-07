# Lean Translation Style

This repository's Lean chapters are meant to be good learning material for Lean
proofs, not merely faithful ports of Rocq code.

## Core principle

Lean translations are educational documents first, code artifacts second.
Prefer proofs and commentary that teach the chapter's method, even when shorter
or more automated Lean proofs exist.

At the same time, prefer idiomatic Lean when it does not sacrifice pedagogy.
The goal is not to imitate Rocq for its own sake; the goal is to help the
reader learn to think and prove well in Lean.

## What to preserve from Rocq

- Section and subsection structure.
- Exercise names and nearby instructions.
- The overall pedagogical flow of each chapter.
- Small executable examples when they help the reader.
- Commentary that introduces definitions, explains examples, or frames the next
  proof technique.

## What may change in Lean

- Proof scripts may become more idiomatic Lean.
- Paragraphs may be rewritten when the Lean code differs meaningfully from the
  Rocq version.
- Lean-specific notes are encouraged where they help explain notation,
  tactics, proof style, or library differences.
- The exact proof shape may differ if the Lean version is clearer and better
  for learning.

## Proof style guidance

For early chapters, prefer:

- `rfl`
- `simp`
- `rw`
- `cases`
- `induction`
- short term-style proofs when they are clearer than tactics

Use more powerful tools only when they help the reader understand the method of
the section, not merely because they solve the goal quickly.

Avoid:

- heavy automation that hides the proof idea
- large jumps to advanced library lemmas without explanation
- proofs that are technically elegant but pedagogically opaque

## Good Lean-specific note

Good:

> Rocq's `if` can branch on any two-constructor inductive type, while Lean's
> `if` is specialized to booleans and decidable propositions, so we use pattern
> matching here instead.

This keeps the spirit of the original section while teaching something real
about Lean.

## Good proof adaptation

Good:

> The Rocq proof uses `rewrite`; in Lean the everyday equivalent is `rw`, so we
> phrase the discussion in those terms and use a small idiomatic Lean proof.

This preserves the pedagogical point of the section while supporting Lean-first
learning.

## Reading-quality questions

Before finishing a chapter, ask:

- Would a learner understand the chapter if they only read the Lean version?
- Do the proofs demonstrate good Lean habits for the level of the material?
- Are Lean-specific differences explained when they matter?
- Is the chapter still pleasant to read as prose, not just valid as code?
