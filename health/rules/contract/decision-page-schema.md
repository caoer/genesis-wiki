---
tags: [domain/wiki, type/reference]
created: 2026-07-06
md-rule: "[[decision-page-schema#^rule]]"
description: "decision pages carry the decision schema"
---

# decision-page-schema — decision pages carry the decision schema

Every page under `decisions/` needs `type`/`status`/`created`/`tags` with a valid status (pending/approved/rejected). **DEAD in the installed binary** — the check implementation exists only on meridian's unmerged `llm-wiki-v2` branch; the loader reports CHECK_NOT_REGISTERED and skips.

```yaml
# Check not registered until a future unit builds it.
# Loader emits CHECK_NOT_REGISTERED warning and skips; no fatal error.
check: decision-page-schema
on: "decisions/**"
severity: error
message: "decision page: {{.Issue}}"
required-fields:
  - type
  - status
  - created
  - tags
valid-status:
  - pending
  - approved
  - rejected
```

^rule
