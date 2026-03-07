# Repository Guidelines

## Project Structure & Module Organization
This repository has two main trees:

- `rocq/`: the original Software Foundations sources in Rocq/Coq, plus generated HTML and chapter test files such as `BasicsTest.v`.
- `lean/`: Lean translations and experiments. Keep chapter files parallel to the Rocq names when possible, e.g. `lean/Basics.lean` for `rocq/Basics.v`.

Top-level tooling lives in `flake.nix` and `flake.lock`. Shared web assets for the HTML export are under `rocq/common/`.

## Build, Test, and Development Commands
- `nix develop`: enter the dev shell with `elan` and `rocq-core` available.
- `cd rocq && make build`: generate `Makefile.coq` and compile all listed Rocq chapters.
- `cd rocq && make clean`: remove generated Rocq build artifacts.
- `cd rocq && rocq compile -Q . LF Basics.v`: compile a single chapter.
- `cd rocq && rocq compile -Q . LF BasicsTest.v`: run the matching chapter test file.
- `elan run leanprover/lean4-nightly:nightly-2026-03-02 lean lean/lf/Basics.lean`: check a Lean file in this workspace, since no default toolchain is configured.

## Coding Style & Naming Conventions
Use ASCII by default. Prefer 2-space indentation in proofs and pattern matches to match the existing Rocq style. Preserve chapter names and theorem/exercise identifiers from Software Foundations unless the translation requires a Lean-specific spelling. In Lean, prefer `namespace` over ad hoc prefixes and use `theorem` for named examples.

## Testing Guidelines
For Rocq, chapter tests live beside the source as `*Test.v`; run the chapter and its test file together. For Lean, at minimum typecheck the edited file with `lean`. Keep translations executable: `#eval`, `#check`, and small theorem statements are preferred over dead snippets.

## Commit & Pull Request Guidelines
Git history is available in this checkout, so inspect recent commits when helpful to match the repository's style and scope. Use short, imperative commit titles such as `Add Lean translation for Basics` or `Clarify LateDays proofs`. Pull requests should describe the chapter touched, whether the change is a direct translation or an idiomatic adaptation, and which Rocq/Lean commands were run to validate it.

## Contributor Notes
When translating chapters, keep the file literate: preserve the long explanatory prose, adapt it to Lean where needed, and leave student exercises as `sorry` unless the task explicitly asks for completed solutions.

## Lean Translation Expectations
When translating a Rocq chapter into Lean, preserve the chapter as a textbook chapter, not just as a bag of definitions and theorems.

- Keep the section and subsection structure parallel to the Rocq source. If `rocq/lf/Basics.v` has subsections such as `Days of the Week`, `Booleans`, `Proof by Rewriting`, etc., the Lean file should normally have the same subsection headings in the same order.
- Preserve the prose between code blocks, not just the headings. Explanatory comments that introduce examples, explain what a definition is doing, or narrate the proof style are part of the translation and should usually remain in the Lean version.
- Do not collapse nearby Rocq subsections into one Lean subsection just because the code is short. The prose structure matters.
- When Rocq uses textbook-style commentary around a tiny example, keep that commentary in Lean too. Small examples such as `day`, `next_working_day`, boolean truth tables, and proof walkthroughs should still read like a lesson.
- Adapt prose only where Lean genuinely differs from Rocq. When that happens, keep the surrounding explanation and add a brief Lean-specific note instead of deleting the discussion entirely.
- Prefer subsection-by-subsection comparison while translating. Before considering a chapter done, scan the Rocq and Lean files in parallel and check that each Rocq subsection has corresponding Lean commentary and code.
- Keep student exercises in place and leave them as `sorry` unless the task explicitly asks for solutions. Preserve exercise names and nearby instructions/comments.
- If you must rename a heading or restructure a subsection for Lean, do it sparingly and only when the Rocq wording would be misleading in Lean.
- Preserve executable pedagogy: keep `#eval`, `#check`, and small theorem examples when they correspond to `Compute`, `Check`, and `Example` material in the Rocq chapter.
- A good translation should still be skimmable as prose. Someone reading only the comments should still recognize the flow of the original chapter.

## Chapter Comparison Workflow
If the user asks to compare a Rocq chapter and its Lean translation before starting new work on that chapter, treat this as a structured translation review.

- Compare the two files directly, usually subsection-by-subsection, instead of giving a high-level impression.
- Check both code and commentary. The review should cover definitions, theorem/exercise names, ordering, omitted material, and the presence or absence of textbook-style prose.
- Distinguish clearly between acceptable Lean adaptations and actual translation gaps. Lean-specific changes in notation, namespace usage, or proof style are fine if the surrounding content and pedagogical intent are preserved.
- Call out missing subsections, merged subsections, or sections whose headings remain but whose explanatory prose has been dropped.
- Check whether exercises are preserved in place and still marked with `sorry` when appropriate.
- Verify that executable examples from the Rocq chapter have Lean counterparts where practical, such as `#eval`, `#check`, or tiny `theorem` examples.
- When useful, report findings in order of importance: missing structure, missing prose, missing code, naming drift, then smaller idiomatic differences.
- If the user wants a go/no-go judgment before they begin working from the Lean chapter, end with a concise verdict such as `ready to use`, `needs prose restoration`, or `needs structural cleanup first`.
- If the user asks for this comparison and fixes in the same request, first compare, then patch the Lean file to address the gaps, then rerun the Lean typecheck.
- If the user asks only for the comparison, default to a review mindset: findings first, brief summary second.
