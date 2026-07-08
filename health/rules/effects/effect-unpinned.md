---
tags: [domain/wiki, type/reference]
created: 2026-07-06
md-rule: "[[effect-unpinned#^rule]]"
description: "a type/effect page with no commit pin must declare status: retired|pending"
---

# effect-unpinned — silence must be earned

The guard behind the tombstone semantics: **the commit is the pin**, so a page tagged
`type/effect` with no `commit:` is either a declared tombstone (`status: retired`, or
`status: pending` mid-authoring) or an accident — this rule surfaces the accident. Warn,
not error: it must not gate a page that is being authored. Tag-scoped on parsed
frontmatter tags, never on path or body text — `EFFECTS.md` (`type/index`) and colocated
artifact content under `effects/` stay silent by construction.

```yaml
check: effect-unpinned
on: "effects/**"
severity: warn
message: "effect pin: {{.Reason}}"
```

^rule
