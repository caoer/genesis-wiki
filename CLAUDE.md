# Genesis Wiki

Barebone llm-wiki — the template both home-wiki and org wikis (e.g. coscene-wiki) fork from. Carries the conventions, health machinery, computed catalogs, and seed structure; carries no knowledge of its own.

## LLM wiki

This repo carries an llm-wiki — a layered knowledge system (inbox → sources → domains → synthesis → effects) operated by the `/llm-wiki` skill. Entry: `SCHEMA.md`. The skill resolves its wiki as `$CCC_LLM_WIKI_PATH` (env override, validates `SCHEMA.md`) → `<git-toplevel>/` (derive, requires `SCHEMA.md`) → fail loud.

## Structure

- `domains/<cluster>/<domain>/` — all domain dirs, one grouping level (contract v3; clusters are pure containers). Seed clusters: `knowledge/`, `research/`, `agents/` — each holds one example domain; replace with your own.
- `inbox/` — raw inputs, drop zone at `inbox/_unstaged/`
- `sessions/` — multi-agent session artifacts (sessions root: `$CCC_SESSION_PATH` or derived `$CCC_LLM_WIKI_PATH/sessions`)
- `effects/` — descriptor tier: one pin-verified page per effect (skills, agents, prompts, sites, documents)
- `decisions/` — decision queue (pending/accepted/rejected)
- `foreign/` — gitignored mount point for foreign wiki mirrors

## Obsidian

Vault root = repo root. Excluded Files: `sessions` (except `*/agents/*`), `foreign`.

## Conventions

See `SCHEMA.md` for wiki conventions. The domain catalog is computed, not maintained: `bases/DOMAINS.base` (content catalog, grouped by cluster) and `bases/DIGEST.base` (standing decision surface — open questions, new, stale). Agents query live:

```bash
obsidian base:query path="bases/DOMAINS.base" view="By cluster" format=md
obsidian base:query path="bases/DIGEST.base" view="Open questions" format=md
```

Headless fallback (Obsidian not running): `rg '^description:' domains` — the catalog data is `description:` frontmatter on `type/domain-index` pages.

## Forking this template

1. Fork/copy the repo, rename identity strings: `SCHEMA.md` title, this file, `README.md`.
2. Replace the seed domains under `domains/` with your first real domains.
3. `just setup` — installs git hooks, materializes the repos-root address layer.
4. Pin tool versions in `health/environment.md` as your machines stabilize.
