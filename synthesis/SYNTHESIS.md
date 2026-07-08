---
tags: [domain/wiki, type/index]
created: 2026-07-08
lint-ignore: [backticked-wikilink]
---

# Synthesis

Producing guidelines derived from wiki sources — cross-cutting **analyses**:
decisions, designs, comparisons, inspiration. Organized into sub-buckets by
kind. Each bucket has an uppercase entry page carrying `type: bucket` +
`class: analysis`, so the bucket list below is queryable data — not a
hand-maintained table. Leaf filenames stay globally unique — wikilinks resolve
by basename regardless of bucket.

Artifact build recipes do NOT live here — an effect page under
[[effects/EFFECTS|effects/]] is the compilation surface for anything the wiki
ships.

## Buckets

![[SYNTHESIS.base#Buckets]]

## Recent

![[SYNTHESIS.base#Recent]]

## Views

- [[SYNTHESIS.base]] — Buckets / By bucket / Recent / Gaps
- Each bucket master embeds `#Folder`, a `this`-scoped view of its own pages

> [!important] Adding or renaming a bucket
> Create the uppercase master `synthesis/<bucket>/<BUCKET>.md` with `type: bucket`,
> `class: analysis`, `bucket:`, `description:`, and `![[SYNTHESIS.base#Folder]]`
> in the body — it then appears in **Buckets** automatically.
