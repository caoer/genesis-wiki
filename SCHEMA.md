---
title: genesis-wiki schema
tags: [type/schema]
created: 2026-07-08
---

# SCHEMA — genesis-wiki

Genesis is itself an llm-wiki; normal llm-wiki conventions apply here too (contract `C40-contract-domain-home`). This file is the wiki's entry point for tools and agents.

## What this wiki is

The thin living upstream (`C1-thin-upstream`) for the llm-wiki fleet. Its shipped payload is the contract and nothing else: contract text, checks, computed-surface definitions. Knowledge about *how to run wikis* lives here — the contract domain plus operational guidance ([[VAULT-SETUP|domains/operations/]], recommendations, never law); knowledge about anything else belongs in a child wiki.

## Where things are

- `domains/contract/genesis-contract/` — the contract domain: the ratified law ([[contract-v1]]), the genesis-owned architecture block ([[architecture-block]]), and future contract-static literate pages.
- `domains/operations/vault-setup/` — recommended Obsidian vault baseline for llm-wiki operators ([[VAULT-SETUP]]): filename-convention enforcement via the Vault File Renamer plugin. Guidance, not contract — nothing here ships in the install payload.
- `inbox/_unstaged/` — drop zone (raw tier, `C30-raw-tier-exemption`).
- `decisions/{pending,accepted,rejected}/` — decision queue (`C34-decision-queue-lapse`).
- Amendments to anything contract-owned follow the fork-first flow (`C11-fork-first-amendment`) with commit trailers (`C12-no-change-note-no-merge`).

No architecture/directory section is restated here — the canonical block lives in the contract domain and renders via `md run` (`C38-point-or-own`, R12).
