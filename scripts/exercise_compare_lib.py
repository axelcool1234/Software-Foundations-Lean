#!/usr/bin/env python3

"""Shared exercise parsing and comparison helpers for chapter review scripts."""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
import re


ROCQ_HEADING_RE = re.compile(r"^\(\*\* \*")
LEAN_HEADING_RE = re.compile(r"^/- \*")
ROCQ_EXERCISE_START_RE = re.compile(r"^\(\*\* \*{4} Exercise: .*?\(([^()]+)\)")
LEAN_EXERCISE_START_RE = re.compile(r"^/- \*{4} Exercise: .*?\(([^()]+)\)")

ROCQ_DECL_RE = re.compile(
    r"^(Theorem|Lemma|Example|Fixpoint|Definition|Inductive)\s+([A-Za-z_][A-Za-z0-9_']*)"
)
LEAN_DECL_RE = re.compile(
    r"^(theorem|lemma|example|def|inductive)\s+([A-Za-z_][A-Za-z0-9_']*|«[^»]+»)"
)

TRIVIAL_PROPOSITIONS = {"True", "False", "PUnit", "Unit", "Prop"}


@dataclass
class Declaration:
    kind: str
    name: str
    line: int
    signature: str | None = None


@dataclass
class Exercise:
    name: str
    line: int
    declarations: list[Declaration] = field(default_factory=list)


def normalize_name(raw: str) -> str:
    return raw.removeprefix("«").removesuffix("»")


def normalize_kind(raw: str) -> str:
    lowered = raw.lower()
    if lowered in {"theorem", "lemma", "example"}:
        return "proposition"
    if lowered in {"definition", "def", "fixpoint"}:
        return "definition"
    return lowered


def normalize_text(text: str | None) -> str | None:
    if text is None:
        return None
    normalized = " ".join(text.split())
    if normalized.startswith(":"):
        normalized = normalized[1:].strip()
    return normalized or None


def extract_rocq_signature(lines: list[str], start: int, first_line: str, decl_prefix: str) -> str | None:
    remainder = first_line[len(decl_prefix):].strip()
    if ":" not in remainder:
        return None
    first_piece = remainder
    if ":=" in first_piece:
        first_piece = first_piece.split(":=", 1)[0].strip()
    pieces = [first_piece]
    if first_line.rstrip().endswith("."):
        return normalize_text(" ".join(pieces).rstrip("."))
    idx = start + 1
    comment_depth = 0
    while idx < len(lines):
        stripped, comment_depth = strip_comments(lines[idx], "rocq", comment_depth)
        if not stripped:
            idx += 1
            continue
        if ROCQ_DECL_RE.match(stripped) or ROCQ_HEADING_RE.match(stripped) or stripped == "(** [] *)":
            break
        if stripped.startswith("Proof.") or stripped.startswith("Admitted.") or stripped.endswith("Admitted."):
            break
        if ":=" in stripped:
            stripped = stripped.split(":=", 1)[0].strip()
        pieces.append(stripped)
        if stripped.endswith("."):
            break
        idx += 1
    text = " ".join(pieces).rstrip(".")
    if text == "...":
        return None
    return normalize_text(text)


def extract_lean_signature(lines: list[str], start: int, first_line: str, decl_prefix: str) -> str | None:
    remainder = first_line[len(decl_prefix):].strip()
    if ":" not in remainder:
        return None
    pieces = [remainder]
    idx = start + 1
    comment_depth = 0
    while idx < len(lines):
        stripped, comment_depth = strip_comments(lines[idx], "lean", comment_depth)
        if LEAN_DECL_RE.match(stripped) or LEAN_HEADING_RE.match(stripped):
            break
        if ":=" in pieces[-1]:
            break
        if ":=" in stripped:
            pieces.append(stripped)
            break
        if not stripped:
            idx += 1
            continue
        pieces.append(stripped)
        idx += 1
    text = " ".join(pieces)
    if ":=" in text:
        text = text.split(":=", 1)[0].strip()
    return normalize_text(text)


def strip_comments(raw_line: str, language: str, depth: int) -> tuple[str, int]:
    if language == "rocq":
        block_start = "(*"
        block_end = "*)"
        line_comment = None
    else:
        block_start = "/-"
        block_end = "-/"
        line_comment = "--"

    code_chars: list[str] = []
    i = 0
    while i < len(raw_line):
        if depth > 0:
            if raw_line.startswith(block_start, i):
                depth += 1
                i += len(block_start)
            elif raw_line.startswith(block_end, i):
                depth -= 1
                i += len(block_end)
            else:
                i += 1
            continue

        if line_comment is not None and raw_line.startswith(line_comment, i):
            break
        if raw_line.startswith(block_start, i):
            depth += 1
            i += len(block_start)
            continue
        code_chars.append(raw_line[i])
        i += 1
    return "".join(code_chars).strip(), depth


def parse_exercises(lines: list[str], language: str) -> list[Exercise]:
    if language == "rocq":
        heading_re = ROCQ_HEADING_RE
        exercise_start_re = ROCQ_EXERCISE_START_RE
        decl_re = ROCQ_DECL_RE
        signature_fn = extract_rocq_signature
        terminator = "(** [] *)"
        heading_end = "*)"
    else:
        heading_re = LEAN_HEADING_RE
        exercise_start_re = LEAN_EXERCISE_START_RE
        decl_re = LEAN_DECL_RE
        signature_fn = extract_lean_signature
        terminator = None
        heading_end = "-/"

    exercises: list[Exercise] = []
    current: Exercise | None = None
    comment_depth = 0

    idx = 0
    while idx < len(lines):
        line = lines[idx]
        stripped = line.strip()

        heading_match = exercise_start_re.match(stripped)
        if heading_match is not None:
            current = Exercise(name=heading_match.group(1), line=idx + 1)
            exercises.append(current)
            while heading_end not in stripped and idx + 1 < len(lines):
                idx += 1
                stripped = f"{stripped} {lines[idx].strip()}"
            idx += 1
            continue

        if terminator is not None and stripped == terminator:
            current = None
            idx += 1
            continue

        if current is not None and heading_re.match(stripped):
            current = None
            idx += 1
            continue

        code_stripped, comment_depth = strip_comments(line, language, comment_depth)
        if current is None:
            idx += 1
            continue

        decl_match = decl_re.match(code_stripped)
        if decl_match is not None:
            kind, raw_name = decl_match.groups()
            normalized_name = normalize_name(raw_name)
            if normalized_name.startswith("manual_grade_for_"):
                idx += 1
                continue
            decl_prefix = decl_match.group(0)
            current.declarations.append(
                Declaration(
                    kind=normalize_kind(kind),
                    name=normalized_name,
                    line=idx + 1,
                    signature=signature_fn(lines, idx, code_stripped, decl_prefix),
                )
            )
        idx += 1

    return exercises


def load_exercises(rocq_file: Path, lean_file: Path) -> tuple[list[Exercise], list[Exercise]]:
    rocq_lines = rocq_file.read_text(encoding="utf-8").splitlines()
    lean_lines = lean_file.read_text(encoding="utf-8").splitlines()
    return parse_exercises(rocq_lines, "rocq"), parse_exercises(lean_lines, "lean")


def compare_exercises(rocq: list[Exercise], lean: list[Exercise]) -> list[str]:
    findings: list[str] = []
    rocq_by_name = {exercise.name: exercise for exercise in rocq}
    lean_by_name = {exercise.name: exercise for exercise in lean}

    for name in rocq_by_name.keys() - lean_by_name.keys():
        exercise = rocq_by_name[name]
        findings.append(
            f"Missing Lean exercise heading `{name}` from Rocq line {exercise.line}."
        )

    for name in lean_by_name.keys() - rocq_by_name.keys():
        exercise = lean_by_name[name]
        findings.append(
            f"Extra Lean exercise heading `{name}` at Lean line {exercise.line}."
        )

    for name in rocq_by_name.keys() & lean_by_name.keys():
        rocq_exercise = rocq_by_name[name]
        lean_exercise = lean_by_name[name]
        rocq_decls = {decl.name: decl for decl in rocq_exercise.declarations}
        lean_decls = {decl.name: decl for decl in lean_exercise.declarations}

        for decl_name in rocq_decls.keys() - lean_decls.keys():
            decl = rocq_decls[decl_name]
            findings.append(
                f"Exercise `{name}` is missing Lean declaration `{decl_name}` ({decl.kind}) from Rocq line {decl.line}."
            )

        for decl_name in rocq_decls.keys() & lean_decls.keys():
            rocq_decl = rocq_decls[decl_name]
            lean_decl = lean_decls[decl_name]
            if rocq_decl.kind != lean_decl.kind:
                findings.append(
                    f"Exercise `{name}` changes `{decl_name}` from {rocq_decl.kind} to {lean_decl.kind}."
                )
            if (
                lean_decl.kind == "proposition"
                and lean_decl.signature in TRIVIAL_PROPOSITIONS
            ):
                findings.append(
                    f"Exercise `{name}` has suspiciously trivial Lean statement for `{decl_name}`: `{lean_decl.signature}`."
                )

    return sorted(findings)
