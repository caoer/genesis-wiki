---
tags: [domain/wiki, type/reference]
created: 2026-07-06
md-rule: "[[draws-from#^rule]]"
description: "synthesis stays fresh against its sources"
---

# draws-from — synthesis stays fresh against its sources

`fresh: git` compares mtimes via git history: if a drawn-from source changed after the synthesis page, the synthesis is stale and warns.

```yaml
property: draws-from
on: "synthesis/**"
severity: warn
message: "Stale synthesis: {{.Target}} updated after this file"
wikilink:
  resolve: file_exists
  fresh: git
```

^rule
