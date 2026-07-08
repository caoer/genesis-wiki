# genesis-wiki

Barebone llm-wiki — the template layer a personal or org knowledge wiki forks from. It carries the **conventions, enforcement machinery, computed catalogs, and seed structure** of a layered LLM-operated knowledge system; it carries no knowledge of its own.

## The model

Five layers, each with an immutability boundary (full spec: `SCHEMA.md`):

```
inbox/      raw inputs         human-owned, immutable after drop
sources/    interpretations    LLM-written, immutable once written
domains/    our reasoning      evolving, clustered: domains/<cluster>/<domain>/
synthesis/  analyses           evolving, 4 buckets
effects/    descriptors        one pin-verified page per shipped artifact
```

Information flows downstream. Effects **point or own, never copy**: an effect page pins content homed in another repo (`repo`+`commit`+`location`+`checksum`) or owns it colocated — deploy is pin *verification*, never content copying.

**Prescription is authored, description is computed.** `SCHEMA.md` carries rules; catalogs are Obsidian Bases (`bases/*.base`) computed from frontmatter — no hand-maintained index files anywhere.

## What's inside

- `SCHEMA.md` — the local overlay: layers, page types, tag taxonomy, linking rules (contract v3)
- `LLM_WIKI.md` — root contract: what the `/llm-wiki` skill injects at load time
- `bases/` — computed catalogs: DOMAINS, DIGEST, SOURCES, SYNTHESIS, INBOX, LOG, EFFECTS, DECISIONS, GIT
- `health/` — enforcement: `HEALTH.md` map, executable tool manifest, literate lint rule packs (`contract/`, `local/`, `effects/`), aggregate checks
- `lefthook.yml` + `.gitleaks.toml` — git-hook gate: secrets scan, wiki lint, session-drift guard
- `domains/{knowledge,research,agents}/` — seed clusters, one example domain each (replace with your own)
- Vault-ready: repo root = Obsidian vault root

## Getting started

1. Fork/copy, rename identity strings (`SCHEMA.md`, `CLAUDE.md`, `README.md`).
2. Replace the seed domains under `domains/` with your first real domains.
3. `just setup` — git hooks + repos-root address layer.
4. Operate it with the `llm-wiki` skill (Claude Code): ingest, build, seek, evolve, harvest.

## Tooling

| Tool | Role |
|---|---|
| `md` (meridian) | wiki lint, literate checks (`md run`), fixers |
| `lefthook` | git hook runner |
| `gitleaks` | pre-commit secrets scan |
| Obsidian | human surface; Bases render the computed catalogs |

Full manifest with fixes per tool: `health/environment.md` (executable — the llm-wiki skill runs it at every load).
