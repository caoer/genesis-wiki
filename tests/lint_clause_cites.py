#!/usr/bin/env python3
"""Clause-citation lint (assertion g) — contract C39-clause-citation.

A clause identifier is ONE word: `C<n>-<slug>`. This lint walks every genesis
markdown surface and fails on:

f1 — a bare `C<n>` (number with no slug fused on). Bare numbers are exactly the
     degradation C39-clause-citation exists to kill: agents copy what documents model.
f2 — a fused token whose number->slug pair does not match the contract's clause
     table (typo'd or stale slug).

Exemptions (append-only history, C39-clause-citation): contract-v1.md's frontmatter
version/status history and everything from "## Drafting rulings" down keep their
as-of-drafting spellings.

Both detectors are self-tested against synthetic bad/good lines first, so a green
result cannot be a vacuous no-match. Exit 0 = pass; 1 = a lint or self-test failed.
"""
import re
import sys
from pathlib import Path

ROOT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent
CONTRACT = ROOT / "domains/contract/genesis-contract/contract-v1.md"

BARE = re.compile(r"(?<![\w-])C(\d+)\b(?!-[a-z])(?!>)")
FUSED = re.compile(r"(?<![\w-])C(\d+)-([a-z0-9]+(?:-[a-z0-9]+)*)")


def clause_table(text):
    return dict(re.findall(r"\*\*`C(\d+)-([a-z0-9-]+)`", text))


def lintable_lines(path, text):
    """Yield (lineno, line) for the lines this file is judged on."""
    lines = text.splitlines()
    if path.resolve() == CONTRACT.resolve():
        historical = False
        in_frontmatter = False
        for i, ln in enumerate(lines, 1):
            if i == 1 and ln == "---":
                in_frontmatter = True
                continue
            if in_frontmatter:
                if ln == "---":
                    in_frontmatter = False
                continue
            if ln.startswith("## Drafting rulings"):
                historical = True
            if not historical:
                yield i, ln
    else:
        yield from enumerate(lines, 1)


def lint_file(path, slugmap):
    findings = []
    text = path.read_text(errors="ignore")
    for lineno, ln in lintable_lines(path, text):
        for m in BARE.finditer(ln):
            findings.append((path, lineno, f"g1 bare clause number C{m.group(1)} — cite the fused identifier C{m.group(1)}-{slugmap.get(m.group(1), '<slug>')}"))
        for m in FUSED.finditer(ln):
            n, slug = m.group(1), m.group(2)
            expect = slugmap.get(n)
            if expect is None:
                findings.append((path, lineno, f"g2 unknown clause number in fused token C{n}-{slug}"))
            elif expect != slug and not expect.startswith(slug):
                findings.append((path, lineno, f"g2 wrong slug: C{n}-{slug} (contract says C{n}-{expect})"))
    return findings


def self_test(slugmap):
    bad = ["the queue lapses per C34, see above", "(C11, C12)", "superseded by C50"]
    good = [
        "per C34-decision-queue-lapse the window closed",
        "water at 93C, grind coarser",
        "a retired clause is marked `RETIRED (superseded by C<n>-<slug>)`",
        "(contract C45-role-selects-lint-pack)",
    ]
    for s in bad:
        if not BARE.search(s):
            return f"self-test: bare detector missed: {s!r}"
    for s in good:
        if BARE.search(s):
            return f"self-test: bare detector false-positive: {s!r}"
    if FUSED.search("C34-decision-queue-lapse").group(2) != "decision-queue-lapse":
        return "self-test: fused tokenizer wrong"
    if slugmap.get("34") != "decision-queue-lapse":
        return "self-test: clause table wrong"
    return None


def main():
    slugmap = clause_table(CONTRACT.read_text())
    if len(slugmap) < 50:
        print(f"FAIL: clause table extracted {len(slugmap)} clauses (< 50) from {CONTRACT}")
        return 1
    err = self_test(slugmap)
    if err:
        print(f"FAIL: {err}")
        return 1
    findings = []
    for p in sorted(ROOT.rglob("*.md")):
        if ".git" in p.parts:
            continue
        findings.extend(lint_file(p, slugmap))
    for path, lineno, msg in findings:
        print(f"  {path.relative_to(ROOT)}:{lineno}: {msg}")
    if findings:
        print(f"G: FAIL — {len(findings)} clause-citation violation(s)")
        return 1
    print("G: pass — every clause cite is a fused C<n>-<slug> token (self-tested)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
