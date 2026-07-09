---
wiki-slug: "{{WIKI_SLUG}}"
wiki-role: "{{ROLE}}"        # private | team | public — selects this wiki's lint pack (contract `C45-role-selects-lint-pack`)
reference-wikis: {{REFERENCE_WIKIS_BLOCK}}   # ordered {slug, git, role} entries; [] = standalone is valid (contract `C21-reference-block`)
tags: [type/wiki-identity]
created: {{YYYY-MM-DD}}
md-load-skill: "[[LLM_WIKI#^load-skill]]"
description: "Root contract — load-skill output is injected into every llm-wiki skill load; this wiki decides what goes there (spec: llm-wiki skill setup/wiki-root-contract.md)"
---

# {{WIKI_SLUG}} — identity

{{IDENTITY_PARAGRAPH}}

## load-skill

Claimed by the llm-wiki skill: at every load, it runs
`md run '{"file":"LLM_WIKI.md","name":"load-skill"}'` and inlines the output.
The shared contract ships with the skill — `setup/wiki-root-contract.md`;
only this wiki's injection lives here.

{{WIKI_SLUG}} injects: the identity/version line (mandatory — without it this wiki is
invisible at skill load). The home wiki is the skill's primary expectation; this wiki
injects UNDER it. Add this wiki's delegations (health doctor, pulse, etc.) as further
lines in the block below — never in the skill.

```bash
# load-skill: this wiki's skill-load injection.
sed -n 's/^contract-version:[[:space:]]*/llm-wiki: {{WIKI_SLUG}} · contract v/p' SCHEMA.md | head -1
```

^load-skill
