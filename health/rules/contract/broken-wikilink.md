---
tags: [domain/wiki, type/reference]
created: 2026-07-06
md-rule: "[[broken-wikilink#^rule]]"
description: "body wikilinks resolve"
---

# broken-wikilink — body wikilinks resolve

The only error-severity link rule — the pre-push gate keys on it. Scope carve-outs: `sessions/` + `inbox/` bodies are raw/history and not link-checked (the broken-wikilink scope ruling (sessions/ + inbox/ are raw/history, excluded)), and `logs/` + `sources/` are immutable layers guarded at warn by [[broken-wikilink-immutable]] instead — the effects migration leaves referent-preserving dangles there by convention (advisor-approved, 2026-07-06). All four stay INDEXED as link targets; only their own bodies are exempt.

```yaml
check: broken-wikilink
# Scoped to curated layers. sessions/ and inbox/ are raw/history bodies — session
# work-logs reference paths valid at write-time (immutable), and inbox captures hold
# [[value, value]]-shaped prose that is not a wikilink. Both remain INDEXED as link
# targets (they are NOT in scan.skip), so curated→raw provenance links still resolve;
# only their own bodies stop being link-checked. Precedent: foreign-body-link-warn
# ships on: ["**", "!foreign/**"]. Decision: the broken-wikilink scope ruling (sessions/ + inbox/ are raw/history, excluded).
# logs/ + sources/ are immutable layers: downgraded to warn via the paired
# broken-wikilink-immutable rule (advisor-approved 2026-07-06, effects migration).
# Revert handle: delete the "!…" globs to restore on: "**".
on: ["**", "!sessions/**", "!inbox/**", "!logs/**", "!sources/**"]
severity: error
message: "{{.Type}} wikilink: [[{{.Target}}]]"
roots: ["**"]
skip-prefixes:
  - "foreign/"
  - "http"
```

^rule
