---
aliases: [llm-wiki-root, load-skill-contract]
tags: [meta/schema, domain/wiki]
created: 2026-07-08
md-load-skill: "[[LLM_WIKI#^load-skill]]"
description: "Root contract — load-skill output is injected into every llm-wiki skill load; this wiki decides what goes there (spec: llm-wiki skill setup/wiki-root-contract.md)"
---

# LLM_WIKI — root contract

Claimed by the llm-wiki skill: at every load, preflight runs
`md run '{"file":"LLM_WIKI.md","name":"load-skill"}'` and inlines the output.
The shared contract (path-is-the-interface, identity handshake, lean output,
fix lines) ships with the skill — `setup/wiki-root-contract.md`; only this
wiki's injection lives here.

This wiki injects: the identity/version line, then the
[[health/HEALTH|health contract]] (toolchain doctor via [[environment]] —
`MISSING` + fix per absent binary, `DRIFT` upgrade prompt on version mismatch).

Forks: the identity line below derives from the repo dir name — no edit needed
beyond renaming the checkout.

```bash
# load-skill: this wiki's skill-load injection.
printf 'llm-wiki: %s · ' "$(basename "$(git rev-parse --show-toplevel)")"
sed -n 's/^contract-version:[[:space:]]*/contract v/p' SCHEMA.md | head -1
md run '{"file":"health/HEALTH.md","name":"check"}'
```

^load-skill
