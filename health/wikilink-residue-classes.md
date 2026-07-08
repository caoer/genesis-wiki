---
tags: [domain/llm-wiki, domain/meridian, type/reference]
created: 2026-07-06
md-check: "[[wikilink-residue-classes#^check]]"
lint-ignore: [heading-structure, backticked-wikilink]
---

# wikilink-residue-classes — catch migration residue links before they reaccumulate

The `md-check-fix` migration-completion (2026-07-06) fixed 3 classes of broken/degenerate body
wikilinks. Two of them **`md check` cannot see**, so a per-file `broken-wikilink` rule can't guard
them — this aggregate check does, run via `md run` and wired into `lefthook.yml` pre-push.

The classes (curated layers only — `sessions/` + `inbox/` are raw/history, excluded, matching
the broken-wikilink scope ruling):

1. **`.md`-suffixed wikilinks** — `[[dir/name.md]]`. If the target exists, `broken-wikilink`
   resolves it by basename and stays **silent**, but the link is non-canonical (the `.md` is never
   correct in a wikilink). This is the invisible class; the release binary has no
   `wikilink-canonicalize` check, so nothing else catches it.
2. **`.repos/` path-wikilinks** — links into external/gitignored checkouts (D3 repos-physical
   migration). Should be a `sources/git/<slug>/` catalog page or inline-code.
3. **`.ucc/sessions/` path-wikilinks** — the retired sessions path. Should be the `sessions/…` hive
   path or inline-code.

Body-only (skips frontmatter, fenced code, and inline-code spans) — same surface `broken-wikilink`
checks — so frontmatter `source:`/`draws-from:` `.md` links (a different, valid resolver) and code
examples never false-positive.

Run: `md run '{"file":"health/wikilink-residue-classes.md","name":"check"}'` (from wiki root).
Exit 1 + printed violations on failure, 0 when clean. Revert: remove the pre-push job in `lefthook.yml`.

## Check

```python
#!/usr/bin/env python3
"""Flag .md-suffixed, .repos/, and .ucc/sessions/ body wikilinks in curated layers."""
import os, re, sys

# Curated layers = everything except raw/history + machinery. sessions/ + inbox/ are raw
# (excluded from broken-wikilink too); foreign/ is a foreign mirror.
SKIP = {".git", ".obsidian", ".claude", "node_modules", ".ucc", ".direnv",
        ".data", ".tmp", "foreign", "dist", "result", "sessions", "inbox"}

WIKILINK = re.compile(r"\[\[([^\]|#]+)(?:[#|][^\]]*)?\]\]")
FENCE = re.compile(r"^\s*(```|~~~)")
INLINE_CODE = re.compile(r"`[^`]+`")

def body_after_frontmatter(text):
    """Return (body_text, start_line_1based) skipping a leading --- frontmatter block."""
    if text.startswith("---\n"):
        end = text.find("\n---", 4)
        if end != -1:
            nl = text.find("\n", end + 1)
            if nl != -1:
                return text[nl + 1:], text[:nl + 1].count("\n") + 1
    return text, 1

def classify(target):
    t = target.strip()
    if t.startswith(".repos/"):
        return "repos-external", "→ link the sources/git/<slug> catalog page, or inline-code the path"
    if t.startswith(".ucc/"):
        return "ucc-retired", "→ link the sessions/… hive path, or inline-code the historical ref"
    if t.endswith(".md"):
        return "md-suffixed", "→ drop the .md; use the shortest-unambiguous wikilink"
    return None, None

errors = []
for root, dirs, files in os.walk("."):
    dirs[:] = [d for d in dirs if d not in SKIP]
    for f in files:
        if not f.endswith(".md"):
            continue
        path = os.path.join(root, f)
        try:
            text = open(path, encoding="utf-8").read()
        except OSError:
            continue
        body, base_line = body_after_frontmatter(text)
        in_fence = False
        for i, line in enumerate(body.split("\n")):
            if FENCE.match(line):
                in_fence = not in_fence
                continue
            if in_fence:
                continue
            stripped = INLINE_CODE.sub("", line)
            for m in WIKILINK.finditer(stripped):
                cls, hint = classify(m.group(1))
                if cls:
                    rel = os.path.relpath(path, ".")
                    errors.append(f"{rel}:{base_line + i}  [{cls}] [[{m.group(1)}]] {hint}")

if errors:
    print(f"wikilink-residue-classes: FAIL ({len(errors)} violation(s))", file=sys.stderr)
    for e in errors:
        print("  x " + e, file=sys.stderr)
    sys.exit(1)
print("wikilink-residue-classes: OK")
```

^check
