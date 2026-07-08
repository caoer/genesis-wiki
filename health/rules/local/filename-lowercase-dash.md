---
tags: [domain/wiki, type/reference]
created: 2026-07-06
md-rule: "[[filename-lowercase-dash#^rule]]"
description: "filenames are lowercase-dash or UPPERCASE entry pages"
---

# filename-lowercase-dash — filenames are lowercase-dash or UPPERCASE entry pages

Two legal shapes: `lowercase-dash.md` leaves and `UPPERCASE.md` entry/hub pages (`SCHEMA.md`, `SYSTEM_CARD.md` are explicit excludes with their own naming history).

```yaml
# Path-level check — NOT a property rule
check: pattern
on: ["**", "!**/SCHEMA.md", "!**/SYSTEM_CARD.md", "!**/*.generated.md"]
severity: warn
target: filename
match: "^[a-z0-9][a-z0-9-]*\\.md$|^[A-Z][A-Z0-9_-]*\\.md$"
message: "Filename must be lowercase-dash or UPPERCASE: {{.Filename}}"
```

^rule
