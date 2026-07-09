#!/usr/bin/env python3
"""Independent render oracle for the acceptance harness (assertion a — byte-identity).

Re-implements the C50-minimal-install render (seeds/* minus README -> root; genesis-contract/* mirrored;
{{WIKI_SLUG}} file/dir renames; token substitution with the example-domain YYYY-MM-DD
skip) from scratch, so a `diff -r` against a `^bootstrap`ed tree proves the born wiki is
byte-identical to the rendered template. Deliberately does NOT call INSTALL.md — it is the
oracle, not the engine.

usage: render_expected.py SEEDS CONTRACT OUT SLUG SLUG_UPPER ROLE DATE REF IDENTITY FORK UPSTREAM
"""
import os
import shutil
import sys

seeds, contract, out, slug, slug_up, role, date, ref, identity, fork, upstream = sys.argv[1:12]

os.makedirs(out, exist_ok=True)

# seeds/* (minus its own README.md) -> target root
for name in sorted(os.listdir(seeds)):
    if name == "README.md":
        continue
    s = os.path.join(seeds, name)
    d = os.path.join(out, name)
    if os.path.isdir(s):
        shutil.copytree(s, d)
    else:
        shutil.copy2(s, d)

# domains/contract/genesis-contract/* -> mirrored 1:1
dst = os.path.join(out, "domains", "contract", "genesis-contract")
os.makedirs(dst, exist_ok=True)
for name in sorted(os.listdir(contract)):
    s = os.path.join(contract, name)
    d = os.path.join(dst, name)
    if os.path.isdir(s):
        shutil.copytree(s, d)
    else:
        shutil.copy2(s, d)

# {{...}} file/dir renames
gdir = os.path.join(out, "sources", "git", "{{WIKI_SLUG}}-genesis")
if os.path.isdir(gdir):
    os.rename(
        os.path.join(gdir, "{{WIKI_SLUG_UPPER}}-GENESIS.md"),
        os.path.join(gdir, slug_up + "-GENESIS.md"),
    )
    os.rename(gdir, os.path.join(out, "sources", "git", slug + "-genesis"))

# token substitution — mirrors the engine exactly, incl. the example-domain YYYY-MM-DD skip
subs = [
    ("{{WIKI_SLUG}}", slug),
    ("{{WIKI_SLUG_UPPER}}", slug_up),
    ("{{ROLE}}", role),
    ("{{YYYY-MM-DD}}", date),
    ("{{REFERENCE_WIKIS_BLOCK}}", ref),
    ("{{IDENTITY_PARAGRAPH}}", identity),
    ("{{FORK_REMOTE_URL}}", fork),
    ("{{GENESIS_UPSTREAM_URL}}", upstream),
]
EXTS = (".md", ".yaml", ".yml", ".toml")
example_prefix = "domains" + os.sep + "example" + os.sep
for dp, _, files in os.walk(out):
    for fn in files:
        p = os.path.join(dp, fn)
        if not p.endswith(EXTS):
            continue
        rel = os.path.relpath(p, out)
        text = open(p, encoding="utf-8").read()
        for k, v in subs:
            if k == "{{YYYY-MM-DD}}" and rel.startswith(example_prefix):
                continue
            text = text.replace(k, v)
        open(p, "w", encoding="utf-8").write(text)
