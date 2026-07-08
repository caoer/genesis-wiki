---
tags: [domain/wiki, type/reference]
created: 2026-07-06
md-rule: "[[source#^rule]]"
description: "source pages point at their raw input"
---

# source — source pages point at their raw input

Every `sources/` page keeps its provenance link (`source:` wikilink to the `inbox/` file or external repo), resolution-checked.

```yaml
property: source
on: "sources/**"
required: true
severity: warn
wikilink:
  resolve: file_exists
```

^rule
