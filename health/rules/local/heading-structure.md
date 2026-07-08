---
tags: [domain/wiki, type/reference]
created: 2026-07-06
md-rule: "[[heading-structure#^rule]]"
description: "heading hygiene"
---

# heading-structure — heading hygiene

Body-level heading checks (structure issues surface via `{{.Issue}}`). Check pages that intentionally break structure carry `lint-ignore: [heading-structure]`.

```yaml
# Body-level check — NOT a property rule
check: heading-structure
on: "**"
severity: warn
message: "{{.Issue}}"
```

^rule
