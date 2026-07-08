---
tags: [domain/wiki, type/index]
type: index
domain: decisions
created: 2026-07-08
---

# Decisions

Decision queue for this wiki. Pages here track choices that need resolution. The live view is [[bases/DECISIONS.base|DECISIONS.base]] — sorting and filtering are computed, never encoded in filenames.

> [!note] Name collision
> `synthesis/decisions/DECISIONS.md` (the synthesis bucket page) shares this filename. Always link path-qualified: [[decisions/DECISIONS]] vs [[synthesis/decisions/DECISIONS]].

## Status values

- **pending** — awaiting decision
- **approved** — resolved, applied
- **rejected** — resolved, not applied

## Layout

Cluster folders, mirroring `domains/` — cluster dirs are pure containers, this hub is the only entry page:

```
decisions/
├── DECISIONS.md        ← this hub
├── ambig/              ← machine stubs: ambiguous-link queue
└── <cluster>/          ← human + ID-keyed decisions, by domain
```

## Convention

One file per decision. Required frontmatter: `type: decision`, `status:`, `created:`, `confidence:`.

**Naming — keyed by identity, not date** (dates live in `created:` frontmatter; Bases sorts):

- **Human-authored decisions**: plain slug — `<cluster>/<slug>.md`.
- **Decision-ID pages**: `dNN-<slug>.md` — the D-number is the stable citable handle.
- **`ambig/` machine stubs**: `ambig-<slug>.md`, content-addressed — the slug **is** the unresolved link (`ambig-agent-teams` ⇄ the link `agent-teams`), a deterministic dedup key so bulk re-runs never forge duplicates. Filenames are never changed.
