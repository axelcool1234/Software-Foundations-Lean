# Repository Guidelines

## Project Structure & Module Organization
This repository has two main trees:

- `rocq/`: the original Software Foundations sources in Rocq/Coq, plus generated HTML and chapter test files such as `BasicsTest.v`.
- `lean/`: Lean translations and experiments. Keep chapter files parallel to the Rocq names when possible, e.g. `lean/Basics.lean` for `rocq/Basics.v`.

Top-level tooling lives in `flake.nix`, `flake.lock`, and `lean-toolchain`. Shared web assets for the HTML export are under `rocq/common/`. Translation workflow helpers live under `scripts/`, longer translation guidance under `docs/`, chapter progress tracking in `TRANSLATION_STATUS.md`, and repo-local reusable Codex skills under `skills/public/`.

## Build, Test, and Development Commands
- `nix develop`: enter the dev shell with `elan` and `rocq-core` available.
- `cd rocq && make build`: generate `Makefile.coq` and compile all listed Rocq chapters.
- `cd rocq && make clean`: remove generated Rocq build artifacts.
- `cd rocq && rocq compile -Q . LF Basics.v`: compile a single chapter.
- `cd rocq && rocq compile -Q . LF BasicsTest.v`: run the matching chapter test file.
- `lean lean/lf/Basics.lean`: check a Lean file in this workspace using the repository's `lean-toolchain`.
- `scripts/check_lean_chapter.sh lean/lf/Basics.lean`: wrapper around the repo's Lean chapter typecheck.
- `scripts/compare_chapter_headings.sh rocq/lf/Basics.v lean/lf/Basics.lean`: print the heading structure of a Rocq chapter and its Lean translation side by side for review.
- `scripts/review_chapter_translation.sh rocq/lf/Basics.v lean/lf/Basics.lean`: run the basic structural comparison and Lean typecheck together.

## Coding Style & Naming Conventions
Use ASCII by default. Prefer 2-space indentation in proofs and pattern matches to match the existing Rocq style. Preserve chapter names and theorem/exercise identifiers from Software Foundations unless the translation requires a Lean-specific spelling. In Lean, prefer `namespace` over ad hoc prefixes and use `theorem` for named examples.

## Testing Guidelines
For Rocq, chapter tests live beside the source as `*Test.v`; run the chapter and its test file together. For Lean, at minimum typecheck the edited file with `lean`. Keep translations executable: `#eval`, `#check`, and small theorem statements are preferred over dead snippets.

## Commit & Pull Request Guidelines
Git history is available in this checkout, so inspect recent commits when helpful to match the repository's style and scope. Use short, imperative commit titles such as `Add Lean translation for Basics` or `Clarify LateDays proofs`. Pull requests should describe the chapter touched, whether the change is a direct translation or an idiomatic adaptation, and which Rocq/Lean commands were run to validate it.

## Contributor Notes
When translating chapters, keep the file literate: preserve the long explanatory prose, adapt it to Lean where needed, and leave student exercises as `sorry` unless the task explicitly asks for completed solutions. See `docs/translation-style.md` for the preferred pedagogical and proof-style conventions.

## Lean Translation Expectations
When translating a Rocq chapter into Lean, preserve the chapter as a textbook chapter, not just as a bag of definitions and theorems. Lean translations are educational documents first, code artifacts second.

- Keep the section and subsection structure parallel to the Rocq source. If `rocq/lf/Basics.v` has subsections such as `Days of the Week`, `Booleans`, `Proof by Rewriting`, etc., the Lean file should normally have the same subsection headings in the same order.
- Preserve the prose between code blocks, not just the headings. Explanatory comments that introduce examples, explain what a definition is doing, or narrate the proof style are part of the translation and should usually remain in the Lean version.
- Do not collapse nearby Rocq subsections into one Lean subsection just because the code is short. The prose structure matters.
- When Rocq uses textbook-style commentary around a tiny example, keep that commentary in Lean too. Small examples such as `day`, `next_working_day`, boolean truth tables, and proof walkthroughs should still read like a lesson.
- Adapt prose where Lean genuinely differs from Rocq, but do so in service of learning Lean well. When Lean code or proofs diverge materially, it is encouraged to rewrite the surrounding paragraphs so they explain the Lean version clearly rather than mechanically copying Rocq-oriented prose.
- It is encouraged to add brief section-local notes explaining where the Lean translation intentionally differs from the Rocq original and why the Lean version is more idiomatic or more educational.
- Prefer subsection-by-subsection comparison while translating. Before considering a chapter done, scan the Rocq and Lean files in parallel and check that each Rocq subsection has corresponding Lean commentary and code.
- Keep student exercises in place and leave them as `sorry` unless the task explicitly asks for solutions. Preserve exercise names and nearby instructions/comments.
- If you must rename a heading or restructure a subsection for Lean, do it sparingly and only when the Rocq wording would be misleading in Lean.
- Preserve executable pedagogy: keep `#eval`, `#check`, and small theorem examples when they correspond to `Compute`, `Check`, and `Example` material in the Rocq chapter.
- A good translation should still be skimmable as prose. Someone reading only the comments should still recognize the flow of the original chapter.

## Lean Proof Style Expectations
The goal of these translations is to help the user learn to prove things in Lean well.

- Prefer idiomatic Lean when it does not sacrifice pedagogy.
- When idiomatic Lean and Rocq fidelity pull in different directions, choose the style that best teaches the method of the section in Lean.
- For early chapters, prefer simple Lean proof tools such as `rfl`, `simp`, `rw`, `cases`, `induction`, `constructor`, and short structured term proofs.
- Avoid heavy automation, opaque one-liners, or advanced library lemmas when they would hide the proof idea that the chapter is trying to teach.
- Do not force a Rocq proof shape onto Lean if the result reads awkwardly or teaches bad Lean habits.
- If a proof is substantially more idiomatic in Lean than in Rocq, prefer the idiomatic Lean proof and add a brief note in the surrounding prose when that helps the reader.
- Keep proofs readable to a learner. Shorter is not always better; favor clarity over golfing.
- Preserve the pedagogical arc of the chapter: early sections should use beginner-friendly proof patterns, and more advanced Lean techniques should appear only when the surrounding text prepares the reader for them.

## Chapter Completion Checklist
Before calling a translated chapter done, verify all of the following.

- The Lean file typechecks with the workspace's documented `elan run ... lean ...` command.
- The section and subsection headings are present and in the same overall order as the Rocq chapter, unless a Lean-specific restructuring is clearly justified.
- Each Rocq subsection has corresponding Lean commentary, not just corresponding code.
- Definitions, theorems, examples, and exercises appear in the expected places.
- Exercises are still present and left as `sorry` unless the task explicitly asked for solutions.
- `#eval`, `#check`, and tiny theorem examples are preserved where they help the reader.
- The proof style is appropriate for learning Lean in the context of that chapter.
- A quick Rocq-vs-Lean subsection comparison has been performed before finishing.

## Reading Quality Pass
After a Lean chapter compiles, do a final reading-quality pass.

- Read the Lean file as a learner, not just as a compiler.
- Check whether the comments still explain the chapter's flow, examples, and proof method.
- Check whether the proofs model good Lean habits for the level of the chapter.
- Check whether Lean-specific differences are explained where they matter pedagogically.
- If the file is technically correct but would be confusing or unhelpful to read as a lesson, keep editing.

## Chapter Comparison Workflow
If the user asks to compare a Rocq chapter and its Lean translation before starting new work on that chapter, treat this as a structured translation review.

- Compare the two files directly, usually subsection-by-subsection, instead of giving a high-level impression.
- Use `scripts/compare_chapter_headings.sh` when helpful to get a quick structural view before doing the deeper review.
- Check both code and commentary. The review should cover definitions, theorem/exercise names, ordering, omitted material, and the presence or absence of textbook-style prose.
- Distinguish clearly between acceptable Lean adaptations and actual translation gaps. Lean-specific changes in notation, namespace usage, or proof style are good when they improve the Lean version pedagogically.
- Call out missing subsections, merged subsections, or sections whose headings remain but whose explanatory prose has been dropped.
- Check whether exercises are preserved in place and still marked with `sorry` when appropriate.
- Verify that executable examples from the Rocq chapter have Lean counterparts where practical, such as `#eval`, `#check`, or tiny `theorem` examples.
- Evaluate proof pedagogy too: ask not only "is this faithful enough?" but also "would this teach a learner good Lean proof style for this section?"
- When useful, report findings in order of importance: missing structure, missing prose, missing code, poor proof pedagogy, naming drift, then smaller idiomatic differences.
- If the user wants a go/no-go judgment before they begin working from the Lean chapter, end with a concise verdict such as `ready to use`, `needs prose restoration`, or `needs structural cleanup first`.
- If the user asks for this comparison and fixes in the same request, first compare, then patch the Lean file to address the gaps, then rerun the Lean typecheck.
- If the user asks only for the comparison, default to a review mindset: findings first, brief summary second.
