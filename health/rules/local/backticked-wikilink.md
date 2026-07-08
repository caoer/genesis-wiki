---
tags: [domain/wiki, type/reference]
created: 2026-07-06
lint-ignore: [backticked-wikilink]
md-rule: "[[backticked-wikilink#^rule]]"
description: "wikilinks inside backticks don't render"
---

# backticked-wikilink — wikilinks inside backticks don't render

`[[x]]` inside inline code is plain text in Obsidian — either it should be a real link (drop the backticks) or it is an intentional example (add `lint-ignore: [backticked-wikilink]` to that page's frontmatter, as `health/HEALTH.md` does).

```yaml
# Body-level check — NOT a property rule
check: backticked-wikilink
on: "**"
severity: warn
message: "Wikilink inside backticks won't render: {{.Match}}"
```

^rule
