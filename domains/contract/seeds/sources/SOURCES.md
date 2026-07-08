---
description: Immutable ingested source material — every entry carries the required ingestion fields in frontmatter.
tags: [type/tier-index]
---

# sources/

Ingested material is immutable after ingest. Every ingestion — any tier, including `sources/git/` repo masters — carries the **required ingestion fields** in frontmatter (canonical key names, fixed here once; the lint reads them as pack data):

- `why-here:` — why this source is in the wiki at all
- `delta:` — what it adds over what the wiki already had
- `map:` — relations: which domains/pages this source feeds
- `captures:` — what was actually taken from it

Git-repo sources additionally carry `remote:` + `commit:` (+ optional `branch:`, legal only when the branch actually exists), and the bucket master page (`git.md`) must reference its base (`GIT.base`).
