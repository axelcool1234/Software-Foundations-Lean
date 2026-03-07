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
- `elan run leanprover/lean4-nightly:nightly-2026-03-02 lean lean/Basics.lean`: check a Lean file in this workspace, since no default toolchain is configured.

## Coding Style & Naming Conventions
Use ASCII by default. Prefer 2-space indentation in proofs and pattern matches to match the existing Rocq style. Preserve chapter names and theorem/exercise identifiers from Software Foundations unless the translation requires a Lean-specific spelling. In Lean, prefer `namespace` over ad hoc prefixes and use `theorem` for named examples.

## Testing Guidelines
For Rocq, chapter tests live beside the source as `*Test.v`; run the chapter and its test file together. For Lean, at minimum typecheck the edited file with `lean`. Keep translations executable: `#eval`, `#check`, and small theorem statements are preferred over dead snippets.

## Commit & Pull Request Guidelines
Git history is available in this checkout, so inspect recent commits when helpful to match the repository's style and scope. Use short, imperative commit titles such as `Add Lean translation for Basics` or `Clarify LateDays proofs`. Pull requests should describe the chapter touched, whether the change is a direct translation or an idiomatic adaptation, and which Rocq/Lean commands were run to validate it.

## Contributor Notes
When translating chapters, keep the file literate: preserve the long explanatory prose, adapt it to Lean where needed, and leave student exercises as `sorry` unless the task explicitly asks for completed solutions.
