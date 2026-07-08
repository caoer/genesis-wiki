---
tags: [domain/wiki, type/reference]
created: 2026-07-06
md-rule: "[[broken-wikilink-immutable#^rule]]"
description: "immutable layers report dangles as warnings"
---

# broken-wikilink-immutable — immutable layers report dangles as warnings

The warn half of the immutable-dir downgrade: `logs/` and `sources/` pages are written once and keep references valid at write-time, so a dangling link there is historical record, not breakage to fix. Severity is per-rule in meridian, hence two rules sharing the `broken-wikilink` check: [[broken-wikilink]] (error) excludes these dirs; this rule covers them at warn.

```yaml
check: broken-wikilink
# Warn half of the immutable-dir downgrade — see broken-wikilink for the error half.
on: ["logs/**", "sources/**"]
severity: warn
message: "{{.Type}} wikilink: [[{{.Target}}]] (immutable layer — historical record)"
roots: ["**"]
skip-prefixes:
  - "foreign/"
  - "http"
```

^rule
