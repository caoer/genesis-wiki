---
tags: [domain/wiki, type/index]
created: 2026-07-08
source: ""
lint-ignore: [backticked-wikilink]
---

# Sources

Compiled wiki pages derived from raw inbox materials. Each source page links
back to its immutable inbox file via the `source:` frontmatter field.

Organized into sub-buckets along **provenance** (where the material came from),
with **entity folders** for cohesive multi-page subjects so a whole subject
reads in one place. Each bucket has an uppercase entry page carrying
`type: bucket` + `class: entity|provenance`, so the bucket list below is
queryable data — not a hand-maintained table. Leaf filenames stay globally
unique — wikilinks resolve by basename regardless of bucket.

Special buckets (create on first use): `git/` (the repo catalog — `type: repo`
masters keyed by `bases/GIT.base`) and `compound/` (knowledge graduated via
ccc-compound) — both keyed off their own frontmatter, outside the bucket masters.

## Buckets

![[SOURCES.base#Buckets]]

## Recent

![[SOURCES.base#Recent]]

## Views

- [[SOURCES.base]] — Buckets / By bucket / Entities / Provenance / Recent / Gaps
- Each bucket master embeds `#Folder`, a `this`-scoped view of its own pages
- [[GIT.base]] — the repo catalog (`git/` subtree)

> [!important] Adding or renaming a bucket
> 1. Create the uppercase master `sources/<bucket>/<BUCKET>.md` with `type: bucket`,
>    `class: entity|provenance`, `bucket:`, `description:`, and `![[SOURCES.base#Folder]]`
>    in the body — it then appears in **Buckets** automatically, grouped by its `class`.
> 2. If it's an **entity** bucket, add its `file.path.contains("sources/<bucket>/")`
>    clause to the `class` formula in `SOURCES.base` — the one place the entity set is
>    defined — so the **Entities** / **Provenance** page views classify it. Provenance
>    buckets are the default and need no formula change.
