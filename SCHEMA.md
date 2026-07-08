---
aliases: [wiki-schema, wiki-conventions]
tags: [meta/schema, domain/wiki]
contract-version: 3
created: 2026-07-08
lint-ignore: [backticked-wikilink]
---

# Wiki Schema — genesis-wiki

> [!abstract] What this file is
> Local overlay for this wiki — pins the contract version, declares the wiki-specific extensions.
> **genesis-wiki is a template**: fork it, rename the identity strings (`genesis-wiki` here, in
> `LLM_WIKI.md`, `CLAUDE.md`, `README.md`), replace the seed domains, and start ingesting.

## Contract

This wiki is bound by **contract v3** (`contract-version: 3` above), which ships with the llm-wiki skill and defines the machine-checkable specification: layout, frontmatter minima, addressing, decision queue, log/synthesis/check contracts, the effects/descriptor tier, leaf-repo constraint. This overlay extends it — shallow merge, local wins (`md schema` semantics).

Key contract invariants restated (normative here because forks read this file first):

1. **Layout**: domain dirs live under `domains/[<cluster>/]<domain>/`. The cluster level is a **MAY** — a flat `domains/<domain>/` wiki stays conformant. Cluster dirs are **pure containers**: no `.md` directly under `domains/<cluster>/`, no cluster entry/index pages. Leaf domain dir names stay **globally unique** — together these two invariants guarantee any cluster re-cut changes zero canonical wikilinks (shortest-unambiguous addressing never encodes the cluster).
2. **Naming**: domain entry pages use the UPPERCASE **domain name** (e.g. `WIKI.md`), never `INDEX.md`.
3. **Catalogs are computed, never maintained**: the content catalog is `bases/DOMAINS.base` (all `type/domain-index` pages, rendered from their `description:` frontmatter — the domain page is the single source of truth); the standing decision surface is `bases/DIGEST.base`. Humans open the `.base` in Obsidian; agents run `obsidian base:query path="bases/DOMAINS.base" view="By cluster" format=md`; headless fallback is frontmatter grep (`rg '^description:' domains`). **Prescription is authored, description is computed** — no domain roster or tag enumeration lives in this file.
4. **Effects are descriptors**: the `effects/` tier carries one pin-verified page per effect (`type/effect` + `effect/<kind>`); point-or-own with a four-part pin contract (`repo`+`commit` / `location`+`checksum`). See [[effects/EFFECTS|EFFECTS]].

### Canonical-clean requirement

This wiki must pass `md check --rules wikilink-canonicalize` clean (zero non-canonical links) — contract §3a shortest-unambiguous addressing.

## Architecture

Five layers, each with an immutability boundary:

| Layer | Directory | Owner | Purpose | Immutability |
|---|---|---|---|---|
| Raw inputs | `inbox/` | Human | Articles, gists, daily notes, sessions | Never modified after drop |
| Sources | `sources/` | LLM | Honest interpretation of raw inputs | Immutable once written |
| Domains | `domains/<cluster>/<domain>/` | LLM | Our reasoning — why things matter to us | Evolving |
| Synthesis | `synthesis/` | LLM | Producing guidelines — how to make outputs | Evolving |
| Effects | `effects/` | LLM | Descriptor pages — one pin-verified page per effect | Descriptor; content homed in its repo or colocated in-wiki |
| Schema | `SCHEMA.md` | Co-evolved | This file — conventions and workflows | — |

Information flows downstream: raw inputs → sources → domains/synthesis → effects. An effect page describes an artifact and either **points** to content homed in a repo (`repo`+`commit` / `location`+`checksum`) or **owns** content colocated — point or own, never copy. Deploy is verification: check the pin against the installed artifact rather than copying content.

Session artifacts (multi-agent orchestration work logs) live in `sessions/` at wiki root (§ Session artifacts); valuable insights get compiled into domain or synthesis pages.

## Directory Structure

Sub-structure is prescribed per page type (§ Page Types); what exists inside each dir is computed, not listed here.

```
/                ← repo root = vault root
├── SCHEMA.md    ← this file (local overlay)
├── LLM_WIKI.md  ← root contract: skill-load injection (llm-wiki skill preflight)
├── bases/       ← computed catalogs: DOMAINS, DIGEST, SOURCES, SYNTHESIS, INBOX, LOG, EFFECTS (.base)
├── logs/        ← one file per operation (§ Log entries)
├── decisions/   ← lazy-decision queue (contract §4) — DECISIONS.md hub + cluster dirs; slug-keyed, no date prefix
├── sources/     ← immutable interpretations, bucketed (§ Source buckets)
├── synthesis/   ← cross-cutting analyses, 4 sub-buckets (§ Synthesis pages)
├── templates/   ← reusable templates
├── domains/     ← domains/<cluster>/<domain>/ — clusters are pure containers (§ Domain pages)
├── effects/     ← descriptor tier, one dir per kind; EFFECTS.md is the layer index (§ Effect pages)
├── inbox/       ← raw inputs: _unstaged/ drop zone + tool partitions + filed/<cluster>/<lane>/ (§ Inbox)
├── sessions/    ← orchestration artifacts (§ Session artifacts; root: $CCC_SESSION_PATH or $CCC_LLM_WIKI_PATH/sessions)
├── foreign/     ← runtime mount of other wikis (gitignored)
├── .obsidian/   ← Obsidian config (Excluded Files for sessions + foreign/)
└── health/      ← enforcement: HEALTH.md map, environment doctor, literate rule packs
```

## Page Types

Contract §1-§11 defines the base page types (domain, source, synthesis, log, decision). This overlay extends:

### Domain pages (`domains/<cluster>/<domain>/`)
Reference material organized by topic. Each domain has an uppercase entry point named after the domain (e.g. `WIKI.md`, `SKILLS.md`). Never use `INDEX.md` for a domain entry — it's meaningless in Obsidian's graph view. The cluster level exists for the folder pane only: `domain/<name>` tags carry **no** cluster component, and wikilinks never encode it (leaf names are globally unique).

**Granularity**: a domain earns a dir iff it has a stable operating identity OR ≥3 coherent pages — otherwise it's a page in a parent domain. New domains join an existing cluster, or found a new one (8±1 domains per cluster is the target). The live roster is computed (preflight injection + `bases/DOMAINS.base`), never listed here.

**Each domain has EXACTLY ONE home page, marked `type/domain-index`** — the domain's front page. A domain MAY additionally contain `type/index` sub-domain/sub-topic index pages (0..n — real MOCs that index a set of sub-pages) and `type/reference` leaf pages. Organizational sub-folders (`learnings/`, `patterns/`, `_archive/`, …) have no home — that is correct, never invent one. The `type/domain-index` tag — not the filename — is the authoritative home signal.
- **Frontmatter (home page)**: `tags: [domain/<name>, type/domain-index]`, `description: "..."`
- **Frontmatter (leaf page)**: `tags: [domain/<name>, type/reference]`

**Enforcement.** Per-folder cardinality is an aggregate invariant that per-file rules cannot express. It is enforced by [[domain-home-unique]] — a self-contained `md run` script wired into pre-push (`lefthook.yml`).

### Source summaries (`sources/`)
One page per ingested source. Honest interpretation — covers everything in the source, not filtered by what we use. Immutable once written. Lives in a bucket under `sources/` (§ Source buckets), not at the root.
- **Frontmatter**: `tags: [type/source, domain/<relevant>], source: [[path/to/raw]], created: YYYY-MM-DD`
- The `source:` field is a `[[wikilink]]` — points to `inbox/` file or external repo

### Source buckets (`sources/<bucket>/`)
`sources/` is organized into sub-buckets so a browse or a `md check` reads one subject at a time. Two kinds:
- **Entity buckets** — one cohesive multi-page subject, so a whole subject reads in one place.
- **Provenance buckets** — grouped by origin (e.g. `research/`, `docs/`, `sessions/`).

Plus two special buckets with their own conventions: `git/` (the repo catalog — `type: repo` masters keyed by `bases/GIT.base`) and `compound/` (below).

Each bucket has an **uppercase master** `sources/<bucket>/<BUCKET>.md` — the folder's entry point:
- **Frontmatter**: `tags: [domain/wiki, type/index]`, `type: bucket`, `class: entity|provenance`, `bucket: <name>`, `description: "..."`, `source: ""`, `created`
- **Body**: title + one-line description + `![[SOURCES.base#Folder]]` — a `this`-scoped Bases view listing that folder's own pages

Bucket masters keep `type/index` — buckets are not domains. A bucket master MAY share a basename with a domain page: `sources/**` is excluded from the wikilink-resolution roots, so the bare link resolves to the domain; the bucket master is reached by path or via the Bases view.

The bucket list is queryable data (`bases/SOURCES.base`, embedded by [[SOURCES]]), never a hand-maintained table. Adding a bucket = creating the uppercase master (+ one `class`-formula clause if entity).

### Compound sources (`sources/compound/`)
Knowledge graduated from work sessions via ccc-compound. One file per compound operation. Immutable after creation.
- **Frontmatter**: `tags: [type/source, domain/<relevant>]`, `compound-type: knowledge`, `source: [[session-path]]`, `origin: <session-path>`, `created: YYYY-MM-DD`
- **Naming**: `YYYY-MM-DD-<slug>.md`

### Inbox (`inbox/`)
Three classes, explicit per folder:

- **Staging** — `inbox/_unstaged/`: the only human drop zone. No rules; triaged out.
- **Tool archives** — `inbox/<tool>/<partition>/`: tool-written captures. Wikilinkable. Immutable once written. Partitioned by a **structural key** (repo, host, date), never by topic.
- **Filed** — `inbox/filed/<cluster>/<lane>/`: triaged manual notes, the destination of `_unstaged` triage. Clusters mirror the `domains/` cluster names and are **pure containers** (no `.md` directly under `inbox/filed/<cluster>/`); lane names stay globally unique within `filed/`. A lane names the domain the content would ingest into; topic goes in the slug, never in a new directory level.

Typical tool archive partitions (create on first use):

| Subfolder | Partition | Frontmatter |
|---|---|---|
| `inbox/scraped/<repo-slug>/` | source repo (no org) | `source-uri: "git://..."`, `agent: "<session-id>"`, `scraped: YYYY-MM-DD`, `tags: [type/scraped]` |
| `inbox/clipper/<host>/` | source hostname | `source: "<url>"`, `title: "..."`, `created: YYYY-MM-DD`, `tags: [type/clip]` |

### Session artifacts (`sessions/`)
Multi-agent orchestration work logs. Hive-partitioned: `sessions/year=YYYY/month=MM/<DD>-<HH>-<name>/` (DD-HH = UTC day+hour).
- **Frontmatter**: `tags: [type/session, domain/<topic>]`
- **Identity fields** (omit-when-absent): `claude-session-id:`, `effort:`, `transcript:`
- **Durability**: other agents run git ops on this checkout — uncommitted session state can be clobbered by checkouts, merges, or resets. **Commit session-dir writes promptly** — in the same work-block, not deferred. A `post-checkout` + `post-merge` guard in `lefthook.yml` warns on uncommitted `sessions/` drift.

### Log entries (`logs/`)
One file per wiki operation. Aggregated views via `bases/LOG.base`.
- **Frontmatter**: `tags: [meta/log, domain/wiki]`, `type: log`, `op: <op>`, `date: YYYY-MM-DD`, `created: YYYY-MM-DD`
- **Naming**: `YYYY-MM-DD-<slug>.md`
- **`op` values**: `ingest`, `compile`, `query`, `synthesis`, `create`, `rewrite`, `restructure`, `review`, `migration`, `setup`, `audit`, `domain`, `user-feedback`

### Synthesis pages (`synthesis/`)
Cross-cutting analyses, organized into 4 sub-buckets by kind: `decisions/`, `designs/`, `comparisons/`, `inspiration/` — all **analysis** buckets. Each bucket has an uppercase entry page with `type: bucket` + `class: analysis` frontmatter. `bases/SYNTHESIS.base` provides queryable views. Artifact build recipes belong on effect pages, not here.

### Effect pages (`effects/<kind>/`)
One page per effect — the **descriptor tier**. Points to content homed in a repo, or owns content colocated under the effect's folder — never both. See [[effects/EFFECTS|EFFECTS]] for the full model.
- **Frontmatter**: `name`, `description` (the wiki's view, not the trigger text), `repo`, `branch`, `commit`, `location: [files+folders]`, `checksum`, `draws-from`, `tags: [domain/<area>, type/effect, effect/<kind>]` (kinds: § Tag Taxonomy), `created_at`/`updated_at`
- **Checksum**: `git rev-parse <commit>:<location>` — tree SHA for a dir, blob SHA for a file; reproducible from the pin alone
- **Lint**: pin resolves; checksum over the location-set matches; `branch` HEAD moved past `commit` → staleness warning

## Tag Taxonomy

The **prefix set is closed** and owned by the lint rule [[local/tags|tags]] — evolve it there first (see the evolve.tag SOP). **Values within open prefixes are computed, never enumerated here** — the pages carrying a prefix ARE its live value set (`rg -o '\btopic/[a-z0-9-]+'` or the relevant `.base`). This section carries prefix semantics only; closed value sets are marked.

### domain/ — subject area

One tag per domain, named after the domain (or sub-domain) dir; cluster names never appear in tags. A `domain/<name>` tag is current iff a `type/domain-index` page carries it — list live via the preflight roster, `bases/DOMAINS.base`, or headless `rg '^description:' domains`. (Retired domains keep their tag on archived pages — history stays addressable.)

### type/ — page kind

Open set (`type/reference`, `type/source`, `type/session`, `type/index`, `type/domain-index`, …). Reuse an existing kind before minting a new one.

### type/effect + effect/ — effect pages

Effect pages carry `type/effect` plus exactly one `effect/<kind>`. Kinds are a **closed set** owned by the effects layout: `skill`, `agent`, `prompt`, `site`, `document`. `bases/EFFECTS.base` filters on `type/effect`, grouped by kind.

### Other prefixes

| Prefix | Semantics | Values |
|---|---|---|
| `topic/` | narrow subject within a domain | open |
| `plugin/` | Obsidian plugin identifier | open |
| `harvest-source/` | harvest source slug, one per source family | open |
| `source/` | provenance (team/channel) | open |
| `round/` | session artifact round marker (`round/1`, …) | open |
| `agent/` | agent identity | open |
| `priority/` | editorial importance | closed: `critical`, `high` |
| `status/` | lifecycle (optional) | closed: `active`, `archived`, `draft`, `retired` |
| `use/` | tool-preference hints | closed: `ask-user-questions`, `ask-questions`, `auto` |
| `do/` | action signals (protocol triggers) | closed: `curate-session`, `forkme`, `handoff`, `send-message` |
| `has/` | open-question markers | closed: `open-question` |
| `meta/` | meta pages | closed: `schema`, `log`, `health` |

## Linking Rules

- Always use `[[wikilinks]]`, never `[text](path.md)`
- Use display text when the page name isn't clear in context: `[[WIKI|the wiki domain]]`
- **Never wrap a real wikilink in inline-code backticks.** Lint enforces via `backticked-wikilink`.
- Cross-link between domains freely
- **Canonical form**: shortest-unambiguous (contract §3a). `md fix --rules wikilink-canonicalize` normalizes.

## Lint

Rule packs are literate pages under `health/rules/{contract,local,effects}/` — one page per rule, wired in `meridian.yaml`. Enforcement map: [[health/HEALTH|HEALTH]].

**Whole-file opt-out** — frontmatter `lint-ignore: [<rule-name>, ...]`. Reserve for pages demonstrating violations as content.
