---
description: Load-time invariants and health checks — the wiki owns its load-time content; the skill is a thin loader.
tags: [type/tier-index]
---

# health/

Add further load-time invariants here, never in the skill. Lint rules live in two packs (see `meridian.yaml`): `rules/contract/` is the materialized law (contract-owned, blind-regenerated on upgrade); `rules/{{WIKI_SLUG}}/` is your overlay (instance-owned, starts near-empty).

Checks run in three tiers — write-time (blocking, touched files), pre-push (blocking, O(delta)), periodic audit (bounded, owned output) — contract C32 `enforcement-tiers`. A check is blocking or it doesn't exist (contract C33 `blocking-or-nonexistent`).
