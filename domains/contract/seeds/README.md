---
description: The seed tree — laid out exactly as it lands relative to a child wiki's root (contract C49 `upstream-layout`, pending ratification). Birth = verbatim copy + placeholder fill.
tags: [type/tier-index]
---

# seeds/ — the birth tree

Copy this tree verbatim to the child root, then fill every `{{PLACEHOLDER}}`. Different agents following this must produce almost identical results — that is the acceptance test.

**Fill rules:**
- `{{WIKI_SLUG}}` — the child's slug: repo name = folder name = vault name (contract C22 `realpath-coherence`).
- `GENESIS.md` frontmatter — machine block; at birth the `wiki init` verb fills it (until it ships: fill by hand, record a C14 `pin-writes-cli-owned` necessity-violation memo).
- `LLM_WIKI.md § load-skill` — REQUIRED; copy the canonical shape from the llm-wiki skill's `setup/wiki-root-contract.md`, or the wiki is invisible at skill load.

**Deliberate absences (do NOT "fix" these — they are contract design):**
- No `sessions/` dir — sessions live in the `{{WIKI_SLUG}}-sessions` companion repo (contract C44 `claimed-trio`), addressed as `wiki://{{WIKI_SLUG}}-sessions/…` (contract C48 `companion-addressability`).
- No `lefthook.yml` — run `ccc-cli wiki hook install` after filling `wiki-role:`; it writes the role-selected hook (private = none; verify and record). Contract C45 `role-selects-lint-pack`.
- No `foreign/` dir — reserved namespace, stays absent/empty (contract C23 `no-mounts`).
- `health/rules/contract/` arrives by materialization from genesis, not from seeds.
- Delete `domains/example/` after your first real domain exists.
