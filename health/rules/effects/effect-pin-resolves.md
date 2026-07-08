---
tags: [domain/wiki, type/reference]
created: 2026-07-06
md-rule: "[[effect-pin-resolves#^rule]]"
description: "an effect page's pinned commit exists in its repo"
---

# effect-pin-resolves — the pinned commit exists in its repo

First of the three effect-contract checks (advisor-ratified 2026-07-06): the pin's
`commit:` must resolve as a commit object in the pinned repo (`git cat-file -t == commit`).
Repos resolve at `$CCC_LLM_WIKI_REPOS_ROOT/<slug>`; an absent local checkout is machine
state, not pin rot — skipped (set `absent-repo: report` to surface it). Also reports
malformed pins: missing fields, or location/checksum lists that don't pair by index.
Unpinned effect pages (no `commit`/`location`/`checksum`) are silent.

```yaml
check: effect-pin-resolves
on: "effects/**"
severity: error
message: "effect pin: {{.Reason}}"
absent-repo: skip
```

^rule
