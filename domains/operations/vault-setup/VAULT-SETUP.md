---
tags: [type/domain-index, domain/vault-setup]
description: "Recommended Obsidian vault setup for llm-wiki operators — filename-convention enforcement via the Vault File Renamer plugin: verified config, headless install recipe, pitfalls."
audience: "llm-wiki operators — public"
created: 2026-07-10
---

# Vault Setup — recommended Obsidian baseline

Operational guidance for running an llm-wiki as an Obsidian vault. Recommendations, not law — nothing here is contract-owned or shipped by the install engine; adopt per wiki.

## Filename-convention enforcement (recommended)

llm-wikis depend on stable filenames: wikilink resolution is filename-based, and agents generate lowercase, dash-separated, no-space names by convention. Obsidian has **no native filename-format setting**, so every human-created or human-renamed note is an unenforced exception waiting to break the scheme.

**Recommendation: install the [Vault File Renamer](https://github.com/louanfontenele/obsidian-vault-file-renamer) community plugin** (`vault-file-renamer`, v1.2.2 or later). It hooks Obsidian's create/rename events and standardizes every `.md` filename to lowercase-kebab — spaces to dashes, special characters stripped, accents removed — with wikilinks auto-updated on rename. Existing files are never touched; a manual "Standardize everything now" command sweeps the vault on demand.

> [!warning] Ships disabled by default
> The plugin's compiled default settings carry `enabled: false`. Registering it in `community-plugins.json` and enabling it does **nothing** until its `data.json` sets `"enabled": true`. Verify with a live event (create a note with spaces, check the on-disk name) — never trust "enabled" status alone.

### Working config

`.obsidian/plugins/vault-file-renamer/data.json`:

```json
{
  "enabled": true,
  "targetExtensions": ["md"],
  "excludedExtensions": [],
  "blacklistedFolders": [],
  "blacklistedFiles": [],
  "rules": [
    {"name": "Spaces to Dashes", "pattern": "\\s+", "replace": "-", "active": true, "description": "Replaces all spaces with dashes."},
    {"name": "Remove Special Chars", "pattern": "[^a-z0-9\\-_.]", "replace": "", "active": true, "description": "Removes anything that isn't a letter, number, dash, underscore, or dot."}
  ],
  "useCreationDate": false,
  "dateFormat": "YYYY-MM-DD"
}
```

Lowercasing and accent removal are built-in behavior; the two rules handle spaces and residual special characters.

### Headless install (no UI)

The whole setup is filesystem-only and git-trackable — one commit makes it reproducible for every clone of the wiki:

1. Fetch the release assets `main.js`, `manifest.json`, `styles.css` into `.obsidian/plugins/vault-file-renamer/`
2. Append `"vault-file-renamer"` to `.obsidian/community-plugins.json`
3. Enable: `obsidian vault=<wiki-slug> plugin:install id=vault-file-renamer enable`
4. Write `data.json` (above) with `"enabled": true` — the step that actually turns it on
5. Reload: `obsidian vault=<wiki-slug> plugin:reload id=vault-file-renamer`
6. Verify live: create `Test Note With Spaces.md` in Obsidian, confirm `test-note-with-spaces.md` on disk, delete it
7. Commit `.obsidian/plugins/vault-file-renamer/` + `.obsidian/community-plugins.json`

### Interaction with uppercase hub pages

llm-wiki convention names hub/index pages in uppercase (`SCHEMA.md`, `SOURCES.md`, domain `<DOMAIN>.md` indexes). The plugin never touches existing files, and hubs are normally born from the genesis template or created by agents on the filesystem — both bypass Obsidian's create event — so in practice the conventions coexist. The one collision: a **new** uppercase hub created inside a running Obsidian gets lowercased within seconds. The plugin exempts only exact paths (`blacklistedFiles`) and folders (`blacklistedFolders`), not name patterns — so when hand-authoring a new hub page, create it outside Obsidian (shell, agent), or rename it back after temporarily toggling `enabled`.

### Scope

The plugin fires only inside a running Obsidian. Files created by agents or scripts on the filesystem bypass it entirely — agents follow the naming convention themselves; the plugin closes the human-editing gap.
