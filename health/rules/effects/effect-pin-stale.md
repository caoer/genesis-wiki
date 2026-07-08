---
tags: [domain/wiki, type/reference]
created: 2026-07-06
md-rule: "[[effect-pin-stale#^rule]]"
description: "warn when origin advanced past an effect pin and the pinned content drifted"
---

# effect-pin-stale — origin advanced past the pin and content drifted

The staleness surface for effect pins (replaces the `draws-from` freshness idea for the
effects layer): fires when `origin/<branch>` has advanced past the pinned commit AND
`git rev-parse origin/<branch>:<location>` no longer matches the pinned checksum —
the artifact's content changed since the pin was taken. Warn, not error: a stale pin is
a re-pin prompt, not rot. Origin merely advancing without touching the location stays
silent; a pin that isn't an ancestor of origin at all is [[effect-pin-on-origin]]'s
finding.

```yaml
check: effect-pin-stale
on: "effects/**"
severity: warn
message: "effect pin: {{.Reason}}"
absent-repo: skip
```

^rule
