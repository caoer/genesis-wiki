---
tags: [domain/wiki, type/reference]
created: 2026-07-06
lint-ignore: [backticked-wikilink]
md-rule: "[[ambiguous-wikilink#^rule]]"
description: "a wikilink resolves to exactly one file"
---

# ambiguous-wikilink — a wikilink resolves to exactly one file

Canonical form is shortest-unambiguous (contract §3a). Gotcha: ambiguity is *retroactive* — adding a new file can break existing clean links elsewhere; path-qualify the older links when it happens.

```yaml
check: ambiguous-wikilink
on: "**"
severity: warn
message: "ambiguous wikilink [[{{.Target}}]] resolves to {{.Count}} files: {{.Paths}}"
roots:
  - "**"
skip-prefixes:
  - "foreign/"
  - "http"
```

^rule
