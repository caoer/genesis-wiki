---
type: source-bucket
name: git
description: "Repo catalog — one dir per repo, uppercase type: repo master carrying provenance + the required ingestion fields (why-here/delta/map/captures), keyed by GIT.base"
tags: [type/source-bucket]
created: {{YYYY-MM-DD}}
---

# GIT — repo sources

One dir per registered repo; masters carry the required ingestion fields (see [[SOURCES]]). Physical checkouts resolve at `repos_root/<name>` (contract C23 `no-mounts`). Catalog view:

![[GIT.base#Catalog]]
