---
tags: [domain/wiki, type/reference]
created: 2026-07-06
md-rule: "[[effect-pin-on-origin#^rule]]"
description: "an effect page's pinned commit is pushed — on origin/<branch>"
---

# effect-pin-on-origin — the pinned commit is on origin

The pinned commit must be reachable from `origin/<branch>` (`git branch -r --contains`,
local remote-tracking refs — no network). Guards the **pilot-defect class**: a pin that
verifies against a local or stale checkout but was never pushed. Binding rule from the
effects migration: *origin/main is the only canonical comparison + pin-verification
target; installed/working checkouts are never evidence.* Commit-doesn't-resolve is
[[effect-pin-resolves]]'s finding — this rule stays silent there to avoid double-reporting.

```yaml
check: effect-pin-on-origin
on: "effects/**"
severity: error
message: "effect pin: {{.Reason}}"
absent-repo: skip
```

^rule
