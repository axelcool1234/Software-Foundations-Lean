#!/usr/bin/env python3

"""Build local Lean imports into a repo-local cache directory."""

from __future__ import annotations

import argparse
import os
from pathlib import Path
import subprocess
import sys


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Compile local Lean imports for a chapter into .build/lean/."
    )
    parser.add_argument("lean_file", type=Path, help="Target Lean file to inspect.")
    parser.add_argument(
        "--build-root",
        type=Path,
        default=Path(".build") / "lean",
        help="Directory where compiled .olean/.ilean files should be written.",
    )
    return parser.parse_args()


def read_imports(path: Path) -> list[str]:
    imports: list[str] = []
    block_comment_depth = 0
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        code_chars: list[str] = []
        i = 0
        while i < len(raw_line):
            if block_comment_depth > 0:
                if raw_line.startswith("/-", i):
                    block_comment_depth += 1
                    i += 2
                elif raw_line.startswith("-/", i):
                    block_comment_depth -= 1
                    i += 2
                else:
                    i += 1
                continue

            if raw_line.startswith("--", i):
                break
            if raw_line.startswith("/-", i):
                block_comment_depth += 1
                i += 2
                continue

            code_chars.append(raw_line[i])
            i += 1

        line = "".join(code_chars).strip()
        if not line:
            continue
        if line.startswith("import "):
            imports.extend(part for part in line.split()[1:] if part)
            continue
        break
    return imports


def module_source(repo_root: Path, module_name: str) -> Path | None:
    source = repo_root / "lean" / Path(*module_name.split(".")).with_suffix(".lean")
    if source.is_file():
        return source
    return None


def source_module_name(repo_root: Path, source: Path) -> str:
    relative = source.relative_to(repo_root / "lean")
    return ".".join(relative.with_suffix("").parts)


def output_paths(build_root: Path, module_name: str) -> tuple[Path, Path]:
    base = build_root / Path(*module_name.split("."))
    return base.with_suffix(".olean"), base.with_suffix(".ilean")


def compile_module(
    repo_root: Path,
    build_root: Path,
    source: Path,
    visiting: set[Path],
    built: dict[Path, Path],
) -> Path:
    if source in built:
        return built[source]
    if source in visiting:
        raise RuntimeError(f"cyclic local Lean import involving {source}")

    visiting.add(source)
    dep_outputs: list[Path] = []
    for imported in read_imports(source):
        dep_source = module_source(repo_root, imported)
        if dep_source is None:
            continue
        dep_outputs.append(compile_module(repo_root, build_root, dep_source, visiting, built))

    module_name = source_module_name(repo_root, source)
    olean_path, ilean_path = output_paths(build_root, module_name)
    olean_path.parent.mkdir(parents=True, exist_ok=True)

    source_mtime = source.stat().st_mtime_ns
    dep_mtime = max((path.stat().st_mtime_ns for path in dep_outputs), default=0)
    output_mtime = min(
        olean_path.stat().st_mtime_ns if olean_path.exists() else -1,
        ilean_path.stat().st_mtime_ns if ilean_path.exists() else -1,
    )

    if output_mtime < max(source_mtime, dep_mtime):
        env = os.environ.copy()
        existing_path = env.get("LEAN_PATH")
        env["LEAN_PATH"] = (
            str(build_root)
            if not existing_path
            else f"{build_root}:{existing_path}"
        )
        subprocess.run(
            [
                "lean",
                "-R",
                "lean",
                "-o",
                str(olean_path),
                "-i",
                str(ilean_path),
                str(source),
            ],
            check=True,
            cwd=repo_root,
            env=env,
        )

    visiting.remove(source)
    built[source] = olean_path
    return olean_path


def main() -> None:
    args = parse_args()
    repo_root = Path.cwd()
    lean_file = args.lean_file
    if not lean_file.is_absolute():
        lean_file = repo_root / lean_file
    if not lean_file.is_file():
        print(f"missing Lean file: {lean_file}", file=sys.stderr)
        raise SystemExit(1)

    build_root = args.build_root
    if not build_root.is_absolute():
        build_root = repo_root / build_root

    built: dict[Path, Path] = {}
    visiting: set[Path] = set()
    for imported in read_imports(lean_file):
        dep_source = module_source(repo_root, imported)
        if dep_source is None:
            continue
        compile_module(repo_root, build_root, dep_source, visiting, built)


if __name__ == "__main__":
    main()
