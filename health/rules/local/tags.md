---
tags: [domain/wiki, type/reference]
created: 2026-07-06
md-rule: "[[tags#^rule]]"
description: "tags use the known prefix taxonomy"
---

# tags — tags use the known prefix taxonomy

Tag prefixes are a closed set (domain, type, status, meta, …) — evolve the set in this rule *first*, then tag pages (see the evolve SOP). Kanban board pages are excluded by path: `on:` can't filter on frontmatter.

```yaml
property: tags
on:
  - "**"
  # Generated files are machine-written; hand-editing them is false-success.
  - "!**/*.generated.md"
  # README.md + CLAUDE.md are repo-facing (GitHub/harness), not wiki pages.
  - "!README.md"
  - "!CLAUDE.md"
  # Obsidian Kanban boards (kanban-plugin: board) are UI artifacts, not knowledge
  # pages. on: can't filter on frontmatter — exclude boards by path here.
required: true
severity: warn
message: "Missing or invalid tags"
tag:
  prefix:
    in: [domain, type, status, topic, meta, project,
         harvest-source, source, use, do, role, session, agent,
         convention, has, plugin, round, priority, effect]
```

^rule
