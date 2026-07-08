---
tags: [domain/llm-wiki, type/reference]
created: 2026-07-06
md-check: "[[domain-home-unique#^check]]"
lint-ignore: [heading-structure]
---

# domain-home-unique — exactly one `type/domain-index` per domain folder

An aggregate (cross-file) invariant that `md check`'s per-file rules cannot express, run via
`md run`. See [[SCHEMA]] two-tier domain markers.

Run: `md run '{"file":"health/domain-home-unique.md","name":"check"}'` (from the wiki root; cwd is set
to the git toplevel automatically). Exit 1 + printed violations on failure, 0 when clean.

## Check

```python
#!/usr/bin/env python3
"""Assert exactly one type/domain-index per real domain folder under domains/."""
import os, re, sys

DOMAINS, INDEX, CASE_STUDY = "domains", "type/domain-index", "type/case-study"

def norm(s):
    return s.upper().replace("_", "").replace("-", "")

def read_tags(path):
    try:
        txt = open(path, encoding="utf-8").read()
    except OSError:
        return []
    m = re.match(r"^---\n(.*?)\n---", txt, re.S)
    if not m:
        return []
    fm = m.group(1)
    inline = re.search(r"^tags:\s*\[(.*?)\]", fm, re.M)
    if inline:
        return [t.strip() for t in inline.group(1).split(",") if t.strip()]
    block = re.search(r"^tags:\s*$", fm, re.M)
    if block:
        out = []
        for line in fm[block.end():].splitlines():
            item = re.match(r"\s*-\s*(\S+)", line)
            if item:
                out.append(item.group(1))
            elif line.strip() and not line[0].isspace():
                break
        return out
    return []

if not os.path.isdir(DOMAINS):
    sys.exit(f"domain-home-unique: '{DOMAINS}/' not found — run from the wiki root")

errors = []
for root, _dirs, files in os.walk(DOMAINS):
    leaf = os.path.basename(root)
    mds = [f for f in files if f.endswith(".md")]
    if not mds:
        continue
    tags = {f: read_tags(os.path.join(root, f)) for f in mds}
    index_pages = [f for f in mds if INDEX in tags[f]]

    # (1) Upper bound — applies to EVERY folder.
    if len(index_pages) > 1:
        errors.append(f"{root}: {len(index_pages)} type/domain-index pages "
                      f"({', '.join(sorted(index_pages))}) — exactly one allowed")

    # Real-domain detection: name-home (non-case-study) OR tag-home.
    name_home = [f for f in mds
                 if norm(f[:-3]) == norm(leaf) and CASE_STUDY not in tags[f]]
    tag_home = [f for f in mds if ("domain/" + leaf) in tags[f]]
    if not (name_home or tag_home):
        continue  # org sub-folder / case-study / container — no home expected

    # (2) Completeness.
    if len(index_pages) == 0:
        cand = (name_home or tag_home)[0]
        errors.append(f"{root}: real domain has no type/domain-index home "
                      f"(front page candidate: {cand})")
        continue
    if len(index_pages) != 1:
        continue  # duplicate already reported by (1)

    home = index_pages[0]
    # (3) Positional — only meaningful when a name-anchored home exists.
    if name_home and home not in name_home:
        errors.append(f"{root}: type/domain-index on '{home}' but the folder home is "
                      f"'{name_home[0]}' — mark the home page, not a leaf")
    # (4) Tag consistency: the home's domain/ tag must name the leaf OR a domain
    #     ancestor. Nested sub-domains conventionally carry the parent domain tag
    #     (e.g. <domain>/technical -> domain/<domain>)
    #     because generic leaf names (technical, strategy) are not globally unique.
    parts = root.split(os.sep)
    allowed = set(parts[2:]) if len(parts) > 2 else {leaf}  # domain-path components, below the cluster
    dom_tags = [t for t in tags[home] if t.startswith("domain/")]
    if not any(t[len("domain/"):] in allowed for t in dom_tags):
        errors.append(f"{root}: home '{home}' carries {dom_tags or 'no domain/ tag'}, "
                      f"expected domain/<{' | '.join(sorted(allowed))}>")

if errors:
    print(f"domain-home-unique: FAIL ({len(errors)} violation(s))", file=sys.stderr)
    for e in errors:
        print("  x " + e, file=sys.stderr)
    sys.exit(1)
print("domain-home-unique: OK")
```

^check
