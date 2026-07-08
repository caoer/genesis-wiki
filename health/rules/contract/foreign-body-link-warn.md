---
tags: [domain/wiki, type/reference]
created: 2026-07-06
md-rule: "[[foreign-body-link-warn#^rule]]"
description: "no body links into foreign mirrors"
---

# foreign-body-link-warn — no body links into foreign mirrors

Links into `foreign/` break silently when the foreign wiki reorganizes — reference the local catalog page instead. **DEAD in the installed binary** (llm-wiki-v2 only).

```yaml
# Check not registered until a future unit builds it.
# Loader emits CHECK_NOT_REGISTERED warning and skips; no fatal error.
check: foreign-body-link-warn
on: ["**", "!foreign/**"]
severity: warn
message: "body link into /foreign/: [[{{.Target}}]] — breaks if foreign wiki reorganizes"
```

^rule
