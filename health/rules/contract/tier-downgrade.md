---
tags: [domain/wiki, type/reference]
created: 2026-07-06
md-rule: "[[tier-downgrade#^rule]]"
description: "faithfulness tier never silently downgrades"
---

# tier-downgrade — faithfulness tier never silently downgrades

A page must not inherit a lower faithfulness tier from a foreign-touched wiki without the downgrade being explicit. **DEAD in the installed binary** (llm-wiki-v2 only).

```yaml
check: tier-downgrade
on: "**"
severity: error
message: "tier downgrade: page at {{.PageTier}} inherits {{.SourceTier}} from foreign-touched wiki {{.Source}} — {{.Field}}"
```

^rule
