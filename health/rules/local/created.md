---
tags: [domain/wiki, type/reference]
created: 2026-07-06
md-rule: "[[created#^rule]]"
description: "every page dates itself"
---

# created — every page dates itself

`created: YYYY-MM-DD` with date-format validation. The date is what makes staleness queries and the digest's new/stale surfaces computable.

```yaml
property: created
on: ["**", "!**/*.generated.md", "!README.md", "!CLAUDE.md"]
required: true
severity: warn
date: true
```

^rule
