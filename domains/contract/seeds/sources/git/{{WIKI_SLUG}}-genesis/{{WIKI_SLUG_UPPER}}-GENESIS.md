---
type: repo
name: {{WIKI_SLUG}}-genesis
role: genesis-upstream
ownership: forked
remote: "{{FORK_REMOTE_URL}}"
upstream: "{{GENESIS_UPSTREAM_URL}}"
upstream-branch: main
why-here: "This wiki's own fork of genesis — the operative law (contract C4 `fork-residence`); every llm-wiki child registers its fork as a git source."
delta: "None at birth — fork == upstream merge-base; law changes land here first (contract C11 `fork-first-amendment`)."
map: "[[contract-v1]] (materialized law), [[architecture-block]]"
captures: "domains/contract/genesis-contract/* materialized at birth; seeds tree consumed at birth."
description: "Genesis fork — operative law source. No commit:/branch: fields by design — genesis provenance is the birth commit message (contract C6, C38 `point-or-own`)."
tags: [type/repo]
created: {{YYYY-MM-DD}}
---

# {{WIKI_SLUG}}-genesis

The child's own fork of the genesis upstream. Checkout: `repos_root/{{WIKI_SLUG}}-genesis`. Absorbs upstream via ordinary `git merge` (contract C3 `two-repo-rule`); the wiki takes updates as adjudicated install re-runs — rendered files only, never git history (contract C50 `minimal-install`).
