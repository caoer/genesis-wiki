---
description: Decision queue — one flat directory; state lives in each page's frontmatter status, never in folder location.
tags: [type/tier-index]
---

# decisions/

One flat directory. Each decision page carries frontmatter `status: pending | accepted | rejected | lapsed` — **toggle the attribute, never move the file** (the design of record; folder-moves break links and history).

Semantics: the queue is an objection window over already-applied defaults — silence lapses to `lapsed` (action stands, explicitly unreviewed, never deleted); `severity: high` never lapses (contract C34 `decision-queue-lapse`).
