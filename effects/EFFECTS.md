---
tags: [domain/wiki, type/index]
created: 2026-07-08
lint-ignore: [backticked-wikilink]
---

# Effects

> [!abstract] What this layer is
> **Effects = everything by which the wiki affects the world.** The `effects/` tier holds **descriptors**: one pin-verified page per effect. The wiki keeps the *why* and the verifiable address; the artifact's home repo keeps the *what*. Deploy is verification (pin ↔ repo ↔ installed artifact), never copying.

## The five kinds

Each effect page carries `type/effect` + an `effect/<kind>` tag. `bases/EFFECTS.base` filters on it.

| Kind | Tag | Where content lives |
|---|---|---|
| skill | `effect/skill` | its home repo (pinned) or this wiki (colocated) |
| agent | `effect/agent` | its home repo (pinned) or this wiki (colocated) |
| prompt | `effect/prompt` | this wiki (owned, colocated fragments + md-run composer) |
| site | `effect/site` | the site's own repo (runbook points; content synced) |
| document | `effect/document` | this wiki (owned, colocated) |

## Point or own, never copy

The invariant of the layer. An effect page is **either**:

- **Point** — content is homed in another repo; the page pins it (`repo` + `commit` + `location` + `checksum`) and is the canonical in-wiki *address* for it: `[[effects/skills/<slug>]]` is the wiki's stable handle for content that lives elsewhere.
- **Own** — content is homed in the wiki, colocated under the effect's folder (`effects/<kind>/<slug>/…`); `repo:` names this wiki, self-pinned.

Never both. The layer never duplicates artifact content.

## The pin contract (four parts)

The effect page frontmatter is a **lintable contract**:

1. **`repo` + `commit`** — pins the *content*. `repo` is a `sources/git/` catalog slug (resolves via the repos-root contract); may be this wiki itself.
2. **`location` (files + folders) + `checksum`** — pins the *claim*. Checksum is the git object id of the location at the commit:
   ```bash
   git -C <repo> rev-parse <commit>:<location>     # tree SHA for a dir, blob SHA for a file
   ```
   Reproducible from the pin alone (repo + commit + location) — content-addressed by git, identical on every clone. NOT a working-tree `find|shasum` (varies by `.DS_Store`/untracked/order).
3. **`branch`** — tracking anchor; ensures changes land in the right place.
4. **Lint** — pin resolves; checksum over the location-set matches; `branch` HEAD moved past `commit` → **staleness warning**. `draws-from` carries provenance; `description` is the wiki's view of the effect, not the artifact's trigger text. **The commit IS the pin** — a page with no `commit` is unpinned: silent when `status: retired|pending` (tombstone semantics), otherwise `effect-unpinned` warns.

Every meaningful artifact change bumps the pin + a changelog entry on the page — the friction *is* the changelog discipline.

## The md-run self-deploy convention

An artifact carries its own automation as frontmatter-addressed task blocks
(`md-check` / `md-deploy` / `md-all`, block-ref wikilinks to `^id` bash/python
blocks), executed by `md run '{"file":"…","name":"…"}'`. By-kind `DEPLOY.md`
md-run docs are the host's deploy surface, wired into `just setup` as the wiki
grows effects.

## Navigating

- **Catalog** — `bases/EFFECTS.base` (computed over `type/effect`), grouped by `effect/<kind>`.
- **By kind** — `effects/skills/`, `effects/agents/`, `effects/prompts/`, `effects/sites/`, `effects/documents/`.
