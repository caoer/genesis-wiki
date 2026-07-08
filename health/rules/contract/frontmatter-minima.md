---
tags: [domain/wiki, type/reference]
created: 2026-07-06
md-rule: "[[frontmatter-minima#^rule]]"
description: "every page carries tags + created"
---

# frontmatter-minima — every page carries tags + created

The contract's minimum viable frontmatter. Generated files are exempt — they are machine-written and hand-editing them is false-success.

```yaml
property: [tags, created]
on: ["**", "!*.generated.md", "!README.md", "!CLAUDE.md"]
required: true
severity: warn
message: "Missing required contract field: {{.Key}}"
```

^rule
