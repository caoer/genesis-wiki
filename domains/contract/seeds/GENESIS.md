---
# Machine-owned block — everything machine-needed lives in FRONTMATTER (R14 F3 law); body is prose only.
# Written by birth / `ccc-cli wiki init|upgrade` (contract C14 `pin-writes-cli-owned`) — never hand-edited, never sed.
type: genesis-manifest
genesis-pin:
  fork-remote: "{{FORK_REMOTE_URL}}"
  fork-commit: "{{FORK_COMMIT_40HEX}}"
  upstream-merge-base: "{{MERGE_BASE_40HEX}}"
min-ucc: "{{MIN_UCC_SEMVER}}"
born: {{YYYY-MM-DD}}
born-from: "{{UPSTREAM_COMMIT_40HEX}}"
parent-wiki: "{{PARENT_SLUG_OR_none}}"
future-intent: "{{ONE_LINE_INTENT}}"
companions-claimed: ["{{WIKI_SLUG}}-sessions", "{{WIKI_SLUG}}-assets", "{{WIKI_SLUG}}-secrets"]
manifest:
  - {path: SCHEMA.md, class: seed, sha: "{{BIRTH_BLOB_SHA}}"}
  - {path: domains/contract/genesis-contract/contract-v1.md, class: contract, sha: "{{BLOB_SHA}}"}
  - {path: domains/contract/genesis-contract/architecture-block.md, class: contract, sha: "{{BLOB_SHA}}"}
  - {path: health/rules/contract, class: contract, sha: "{{TREE_SHA}}"}
  - {path: meridian.yaml, class: seed, sha: "{{BIRTH_BLOB_SHA}}"}
  - {path: CLAUDE.md, class: seed, sha: "{{BIRTH_BLOB_SHA}}"}
tags: [meta/genesis]
---

# GENESIS.md — this wiki's contract manifest

**What this file is:** the single record of this wiki's relationship to the genesis contract — which fork commit governs it (the pin, in frontmatter above) and which paths the contract owns here (the manifest array). The pin selects which version of the law is in force (contract C13 `pin-selected-authority`); the law itself is materialized in this wiki at `domains/contract/genesis-contract/contract-v1.md`.

**Who consumes the frontmatter** (named consumers — without them the hashes would rot; the list is part of the contract):
1. `md genesis verify` — verifies `class: contract` rows against disk (C7 `hash-gate`, pre-push tier). Seed rows are birth documentation, never verified (C8 `seed-class`).
2. `ccc-cli wiki init` / `wiki upgrade` — the only writers of `genesis-pin` and `manifest` (C14 `pin-writes-cli-owned`). Until the verb ships on your host, any manual pin write must be recorded as a necessity-violation memo.
3. `md run --once-per-context` — a manifest row's `(path, sha)` is the render-once rev for genesis-owned blocks.

**Ownership rule** (self-teaching, C6 `manifest`): listed → contract-owned (upgrades may replace it, hash-gated); unlisted → instance-owned (upgrades never touch it); no third state.

**Growth policy: nothing appends to this file, ever.** Birth facts are the fixed frontmatter fields above, set once. Upgrade history is computed — `git log -- GENESIS.md` IS the record (C27 `prescription-authored`).
