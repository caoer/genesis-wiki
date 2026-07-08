---
wiki-slug: "{{WIKI_SLUG}}"
wiki-role: "{{ROLE}}"        # private | team | public — selects this wiki's lint pack (contract C45 `role-selects-lint-pack`)
reference-wikis: []          # ordered {slug, git, role} entries; empty = standalone is valid (contract C21 `reference-block`)
tags: [type/wiki-identity]
created: {{YYYY-MM-DD}}
---

# {{WIKI_SLUG}} — identity

{{ONE_PARAGRAPH: what this wiki is for. Writing voice follows the role — private writes freely, team writes for the team, public writes for strangers.}}

## load-skill

<!-- REQUIRED. Without this section the wiki is INVISIBLE at skill load (R14 F1) — the whole design
     depends on it. The home wiki is always the skill's primary expectation; other wikis inject UNDER it.
     Canonical section shape: the llm-wiki skill's setup/wiki-root-contract.md (skill lane owns) —
     copy it verbatim, then fill the injection lines for this wiki. -->
{{LOAD_SKILL_SECTION}}
