---
aliases: [wiki-health, enforcement-map]
tags: [meta/health, domain/wiki]
created: 2026-07-08
md-check: "[[HEALTH#^check]]"
lint-ignore: [backticked-wikilink]
description: "Enforcement map for wiki health — every invariant, the mechanism that guards it, its gotchas, and the gaps; carries the llm-wiki skill's health-contract entry point (md run …#check)"
---

# Wiki Health — enforcement map

> [!abstract] What this file is
> The single surface answering: *what does this wiki promise, and where is each promise enforced?*
> The mechanisms sort by **reader**: `meridian.yaml` + `rules/` are read by the `md` binary,
> `health/*.md` literate checks are wiki pages executed via `md run`, `lefthook.yml` is read by git.
> This folder is the readable layer; `rules/` stays at root as pure config.
> The binaries that run these mechanisms are cataloged in [[environment]].

## Mechanisms

| Mechanism | Role | Reader | Trigger |
|---|---|---|---|
| `meridian.yaml` | tool wiring — which rule packs load, what gets scanned | `md` binary | every `md check` |
| `health/rules/contract/` | contract pack — structural invariants, one literate page per rule | `md` binary | every `md check` |
| `health/rules/local/` | local overlay — this wiki's conventions, one literate page per rule | `md` binary | every `md check` |
| `health/rules/effects/` | effect-contract pack — pin verification for the effects layer (repos resolve at `$CCC_LLM_WIKI_REPOS_ROOT/<slug>`) | `md` binary | every `md check` |
| [[domain-home-unique]], [[wikilink-residue-classes]] | literate aggregate checks — invariants per-file rules cannot express | `md run` | pre-push |
| `lefthook.yml` | when enforcement fires (also carries non-wiki jobs: secrets-scan, session-drift-guard) | git | hooks |

## Rules

**Every rule is a literate page** under `health/rules/<pack>/<id>.md`: doc prose + gotcha up top,
the rule yaml in a `^rule`-anchored fence, addressed by `md-rule:` frontmatter.
The rule ID is the filename stem; the page IS the rule.

**The catalog is computed, not maintained** — every rule page carries `description:` frontmatter:

```bash
md rules ls                                # loaded rules: id, check, severity, scope
rg '^description:' health/rules -g '*.md'  # one-line purpose per rule page
```

Status exceptions:

| Rule | Status |
|---|---|
| `decision-page-schema`, `foreign-body-link-warn`, `tier-downgrade`, `wikilink-canonicalize` | check exists only on meridian's `llm-wiki-v2` line; an older installed binary reports `CHECK_NOT_REGISTERED` and skips |
| [[broken-wikilink]] + [[broken-wikilink-immutable]] | the immutable-dir two-rule split: error on curated layers, warn on `logs/` + `sources/` |

### Literate checks (`health/*.md`)

| Check | Guards | Why not a rule |
|---|---|---|
| [[domain-home-unique]] | exactly one `type/domain-index` per real domain folder | per-folder cardinality — per-file rules can't see siblings |
| [[wikilink-residue-classes]] | `.md`-suffixed / external-path body links | `.md`-suffixed links *resolve fine* by basename — `broken-wikilink` stays silent |
| [[repos-root]] | `$CCC_LLM_WIKI_REPOS_ROOT/<slug>` address layer — `link` materializes, `check` runs the doctor | machine-state ops, not content lint — host-invoked, not a git hook |

## Gotchas

- **A resolving link can still be wrong.** `[[foo.md]]` resolves by basename, so `broken-wikilink`
  never fires on it — only [[wikilink-residue-classes]] catches the class.
- **The gate only blocks on errors.** Warn-severity violations accumulate silently between audits.
- **Rules die with the model they validate.** Scope-dead rules are debt: retire or repoint, never
  leave them matching nothing.

## Skill contract (`^check`)

The skill-load entry point is the root contract [[LLM_WIKI]]
(`LLM_WIKI.md#load-skill`), which delegates here:

```bash
md run '{"file":"health/HEALTH.md","name":"check"}'
```

What the check covers is wiki-side and free to evolve. Today it delegates to
the [[environment]] toolchain doctor: every needed binary verified, `MISSING` +
fix per absent tool, `DRIFT` upgrade prompt on version mismatch against the
pins in [[environment]].

```bash
# check: llm-wiki skill health contract — delegate to the executable tool
# manifest. Add further load-time invariants here, never in the skill.
md run '{"file":"health/environment.md","name":"check"}'
```

^check

## Operations

```bash
md check                                                    # all loaded rules
md run '{"file":"health/HEALTH.md","name":"check"}'         # skill health contract (toolchain doctor)
md run '{"file":"health/domain-home-unique.md","name":"check"}'
md run '{"file":"health/wikilink-residue-classes.md","name":"check"}'
md run '{"file":"health/repos-root.md","name":"link"}'      # materialize repos-root symlinks
md run '{"file":"health/repos-root.md","name":"check"}'     # llm-wiki repos-root doctor
lefthook run pre-push                                       # the full gate
```

## Effect-contract lint (`health/rules/effects/`)

Four checks per effect-page pin (`repo`/`branch`/`commit`/`location`/`checksum` frontmatter;
the **commit is the pin** — tombstones without a commit are unpinned, not malformed):

| Rule | Guards | Severity |
|---|---|---|
| [[effect-pin-resolves]] | commit exists in the repo; also reports malformed pins (single-reporter) | error |
| [[effect-pin-on-origin]] | commit is pushed — on `origin/<branch>` | error |
| [[effect-checksum-reproduces]] | `git rev-parse <commit>:<location>` == pinned checksum — the ONLY sanctioned method | error |
| [[effect-pin-stale]] | origin advanced past the pin and content drifted → re-pin prompt | warn |
| [[effect-unpinned]] | `type/effect` page with no commit pin and no `status: retired\|pending` — silence must be earned | warn |

Absent local checkouts skip by default (`absent-repo: report` to surface) — repo presence is
the repos-root doctor's territory, pin rot is ours.
