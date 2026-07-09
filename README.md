# genesis-wiki

The thin living upstream for llm-wikis — a public, clonable wiki whose sole subject is the **wiki-of-wikis**.

Every llm-wiki (a layered knowledge repo operated by agents and humans together) is born from or adopted into this repo's contract. Genesis ships contract text, checks, and computed-surface definitions — never content, never a runtime, never shared code.

- **The law:** [domains/contract/genesis-contract/contract-v1.md](domains/contract/genesis-contract/contract-v1.md) — 50 numbered clauses with stable slugs (5 retired to stubs). Start at the glossary; a bare reader with `rg` and that one file can learn the whole shape.
- **How children relate to this repo:** each child wiki pins its **own fork** of genesis; the fork absorbs upstream via ordinary git merge, the wiki ingests file deltas between two fork commits (contract C3 `two-repo-rule`).
- **Posture:** public (contract C41 `genesis-public`) — no private content, ever. Child wikis and their forks may be private; publicity flows one way.

History note: tag `strawman-v0` preserves a pre-design scaffold that was deliberately reset — the contract was designed by a six-lane panel before anything was built.
