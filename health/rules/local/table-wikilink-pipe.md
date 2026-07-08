---
tags: [domain/wiki, type/reference]
created: 2026-07-06
lint-ignore: [backticked-wikilink]
md-rule: "[[table-wikilink-pipe#^rule]]"
description: "unescaped | in table wikilinks breaks columns"
---

# table-wikilink-pipe — unescaped | in table wikilinks breaks columns

Agents write `[[target|display]]` naturally; inside a markdown table the pipe splits the column. Auto-fixable — meridian escapes it.

```yaml
# Auto-fix: escapes | inside [[target|display]] wikilinks in markdown tables
# to prevent column misalignment. Agents write wikilinks naturally; meridian fixes.
check: table-wikilink-pipe
on: "**"
severity: warn
message: "table column misalignment: expected {{.Expected}} columns, got {{.Actual}} (wikilinks: {{.Wikilinks}})"
```

^rule
