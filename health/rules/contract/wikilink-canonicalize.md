---
tags: [domain/wiki, type/reference]
created: 2026-07-06
md-rule: "[[wikilink-canonicalize#^rule]]"
description: "links use shortest-unambiguous form"
---

# wikilink-canonicalize — links use shortest-unambiguous form

Contract §3a canonical form; `md fix --rules wikilink-canonicalize` normalizes. **DEAD in the installed binary** — check + fixer live on `llm-wiki-v2` (fixer build cb92bc6, applied in the M4 bulk canonicalization with resolvedLinks authority). Until the P2b merge to meridian main and a release binary, `md check` skips the rule with a CHECK_NOT_REGISTERED warning; the worst residue class (`.md`-suffixed links that resolve silently) is guarded by [[wikilink-residue-classes]].

**Hook path:** the pre-push hook (`lefthook.yml`) runs `md fix` in `stage_fixed` mode — the canonicalize fixer is registered only in llm-wiki-v2 builds or later; the frozen baseline binary (8852cd3) lacks it. **End-state:** P3 release binary + P2b merge → `md check` + pre-push hook enforce canonical form automatically. **Gap for M6 merge-back:** hook binary must be updated to a build carrying P2b. (Moved from SCHEMA.md § Canonical-clean requirement, 2026-07-07 — status lives here, the rule page; SCHEMA carries only the requirement.)

```yaml
check: wikilink-canonicalize
message: 'wikilink [[{{.Target}}]] is not in canonical shortest-unambiguous form;
  canonical: [[{{.Canonical}}]]'
'on': '**'
# resolved_links snapshot removed 2026-07-05 (domain-cluster-move): it was a stale
# path-keyed capture from the M4 bulk-canonicalize apply — every key went stale the
# moment files moved. The P2b check implementation derives resolution live from
# __scanned_paths; it never needed the snapshot. (P4 hygiene debt, RESOLVED-domain-reorg §5.)
roots:
- '**'
severity: warn
skip-prefixes:
- foreign/
- http
```

^rule
