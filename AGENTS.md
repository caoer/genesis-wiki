---
tags: [meta/schema, domain/wiki]
created: 2026-07-08
---
# Genesis Wiki

Barebone llm-wiki — the template layer both home and org wikis fork from.

## Conventions

- Follow `SCHEMA.md` for all wiki pages
- Use wikilinks (shortest-unambiguous canonical form)
- Frontmatter is for filtering, body is for reading
- `inbox/` is immutable raw input — never edit in place; ingest into domains
- `effects/` is the descriptor tier — one pin-verified page per effect (point or own, never copy); deploy verifies the pin against the installed artifact rather than copying content (see `effects/EFFECTS.md`)
