---
tags: [domain/wiki, type/reference]
created: 2026-07-06
md-rule: "[[effect-checksum-reproduces#^rule]]"
description: "an effect page's checksum reproduces from the pin alone via git rev-parse"
---

# effect-checksum-reproduces — the checksum reproduces from the pin alone

Per `location:` entry, `git rev-parse <commit>:<location>` must equal the pinned
`checksum:` — a **tree** sha for directory locations, a **blob** sha for files.
This deterministic method is the ONLY sanctioned one (locked, advisor-ratified,
W2a-pins.md):

- **Rejected — `git archive <commit> <path> | shasum`**: tar framing varies by git
  version; two machines produced different sums at the same commit.
- **Rejected — working-tree `find | shasum`**: contaminated by `.DS_Store`, untracked
  and `.gitignore`d files, ordering, locale — the original pilot-defect gap.

`rev-parse` is content-addressed by git itself: reproducible from the pin
(repo + commit + location) on every clone, identical everywhere.

```yaml
check: effect-checksum-reproduces
on: "effects/**"
severity: error
message: "effect pin: {{.Reason}}"
absent-repo: skip
```

^rule
