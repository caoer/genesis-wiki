---
type: literate-block
block-id: genesis-architecture
owner: genesis
budget: 320
render-once: true
md-architecture: "[[architecture-block#^architecture]]"
source-of-truth: "THIS file — genesis wiki, contract domain (C40-contract-domain-home)"
lane-inputs: "R12 genesis + meridian lanes (authoring session, home wiki — referenced by name, not link)"
tags: [type/literate-block, domain/contract]
---

# Architecture block — genesis contract page (literate source)

F1 resolution (2026-07-08, genesis pick = trim): original text measured ~452 tokens vs
declared 250. Trim rule applied — 'is' column keeps only what orients a cold agent, clause
restatements cut to bare C-ref (C38-point-or-own applied to the block itself), write-column phrasing
tightened, 13 rows kept (user-required/load-bearing; the GENESIS.md manifest row retired in v1.1). Landed ~293; budget declared 320 —
trimmed to floor FIRST, then declared honestly (a budget that lies is worse than none — same
law as the pins).

Rationale (maintainer surface — never rendered): this block is contract-static and
genesis-owned. It materializes into every child via the adjudicated install diff (C7-hash-gate); genesis
updates it via ordinary amendment; children take it on an install re-run (C50-minimal-install) and NEVER restate it — a child SCHEMA.md carries no
architecture/directory section at all (C38-point-or-own applied to injected surfaces; the
duplicate has no home to come back to). Version mechanics never appear here — they belong to
the handshake block (S4). Clause refs are number+slug pointers (C39-clause-citation), not restatements.

Render-once mechanics (LOCKED, meridian × genesis lanes): `md run --once-per-context`, dedupe key
= (block-id `genesis-architecture`, rev = blob SHA of the materialized page as it currently
stands). State is FILE-BASED, never daemon: `${XDG_CACHE_HOME:-~/.cache}/meridian/render-context/
<context-key>/`, marker per (block-id, rev), TTL-GC ~48h; context key from
`$CLAUDE_SESSION_ID` (or `--context-key`). First load renders the block; same (id, rev) later
→ one line: `architecture: inherited (genesis@<short-rev>, already in context)`. Differing
rev → one skew line, never a second block. State unavailable → full render (degrade toward
repetition, never toward silence). 1 home + 10 children = 1 block + 10 one-liners.

```markdown
--- architecture (genesis-owned, contract-static — rendered once per context) ---
Flow: `inbox → sources → domains → synthesis → effects`.

| dir | is | you write? |
|---|---|---|
| `inbox/` | raw drop zone; `_unstaged/` = unsorted | drop + triage |
| `sources/` | ingested material, immutable | create only |
| `domains/<cluster>/<domain>/` | curated knowledge; clusters = containers | yes — main surface |
| `synthesis/` | cross-domain products | yes |
| `effects/` | pin-verified page per artifact (C37-effect-pin-lifecycle) | effect lifecycle |
| `decisions/` | decision queue (C34-decision-queue-lapse) | file, never delete |
| `bases/` | computed views (C27-prescription-authored) | yes; contract rows diff-adjudicated (C7-hash-gate) |
| `logs/` | operational records | append only |
| `templates/` | page templates | yes |
| `foreign/` | stays empty (C23-no-mounts); cross-wiki `wiki://` (C24-reference-classes) | never |
| sessions | **not in wiki** — `<slug>-sessions` companion (C44-claimed-trio, C48-companion-addressability) | session tools |
| `SCHEMA.md` | this wiki's contract entry | amendment flow (C11-fork-first-amendment) |
| `LLM_WIKI.md` | identity + reference-wikis block (C21-reference-block) | body; block via `wiki add` |
```

^architecture
