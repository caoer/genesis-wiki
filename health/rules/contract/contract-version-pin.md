---
tags: [domain/wiki, type/reference]
created: 2026-07-06
md-rule: "[[contract-version-pin#^rule]]"
description: "SCHEMA.md pins its contract version"
---

# contract-version-pin — SCHEMA.md pins its contract version

Guards silent contract drift: `SCHEMA.md` must carry an explicit `contract-version` frontmatter field so a contract bump is always a deliberate, reviewable edit.

```yaml
property: contract-version
on: "SCHEMA.md"
required: true
severity: error
message: "SCHEMA.md: {{.Message}}"
```

^rule
