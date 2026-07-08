---
aliases: [wiki-environment, tool-manifest]
tags: [meta/health, domain/wiki]
created: 2026-07-08
md-check: "[[environment#^check]]"
description: "Executable tool manifest — every binary the wiki's machinery needs, who provisions it, and how to stand up a fresh machine; pin versions in the check block as your fleet stabilizes"
---

# Wiki Environment — tool manifest

> [!abstract] What this file is
> The single surface answering: *what must be installed for this wiki to operate?*
> The [[health/HEALTH|enforcement map]] says what each mechanism guards; this page says what
> binary runs it and where that binary comes from. The manifest is **executable**:
> the check block below is run by `md run` (the llm-wiki skill preflight invokes it at
> every load, so agents see missing tools + fixes immediately). Upgrading a tool means
> updating its pin here — nowhere else. Forks: pin exact versions (`chk <bin> <cmd> <pin> <fix>`)
> once your machines stabilize; genesis ships presence-only checks.

## Tools

| Tool | Role | Reads |
|---|---|---|
| `md` (meridian) | wiki lint (`md check`), literate checks (`md run`), fixers (`md fix`) | `meridian.yaml`, `health/rules/` |
| `lefthook` | git hook runner — fires every enforcement trigger | `lefthook.yml` |
| `gitleaks` | pre-commit secrets-scan (default ~180-rule set + entropy) | `.gitleaks.toml` |
| `obsidian` CLI | computed catalog — `obsidian base:query` over `bases/*.base` | `bases/DOMAINS.base`, `bases/DIGEST.base` |
| `rg` | headless catalog fallback (`rg '^description:' domains`) | — |
| `python3` | interpreter for `health/*.md` literate check bodies | — |
| `git` | everything | — |

## Fresh machine

1. Provision `lefthook`, `gitleaks`, `rg`, `git`, `python3` via your package manager
   (nix, brew, apt — declare them in your machine config, not by hand).
2. Build `md` from the meridian repo (llm-wiki-v2 line) and place it at `~/.local/bin/md`.
   Older builds skip unregistered checks with `CHECK_NOT_REGISTERED` — a skip, not a failure,
   so the gate stays green while enforcing less.
3. `lefthook install` from the wiki root — wires pre-commit, pre-push, post-checkout, post-merge.
4. Install Obsidian.app and open the vault once so `obsidian base:query` resolves;
   headless hosts fall back to `rg`.

## Gotchas

- **`md` is typically the one unprovisioned binary.** It is hand-built and version-drifts
  silently between machines — pin its build hash in the check block for exactly this reason.
- **`obsidian base:query` needs the app running.** Hooks never depend on it; only
  interactive catalog queries do. The `rg` fallback is always available.
- **gitleaks path exemptions live in `.gitleaks.toml`, not `lefthook.yml`.**

## Usage

```bash
md run '{"file":"health/environment.md","name":"check"}'   # toolchain doctor (from wiki root)
```

The llm-wiki skill preflight runs this at every load via the [[LLM_WIKI]] root
contract (`LLM_WIKI.md#load-skill` → [[health/HEALTH|HEALTH]]`#check` → delegates
here). If `md` itself is missing or below the skill's version floor, preflight
prints that fix instead.

## Tasks

```bash
# check: toolchain doctor. The chk lines below ARE the version manifest —
# upgrade a tool → update its pin here, nowhere else.
# Output contract: one "ok:" line for healthy tools; "MISSING <tool>" + fix per
# absent binary (exit 1 — the actionable failure); "DRIFT <tool>" + fix on
# version mismatch (exit 0 — loud, never blocking).
fail=0; ok=""
chk() { # chk <bin> <version-cmd> <pin-substring|-> <fix>
    local bin="$1" vcmd="$2" pin="$3" fix="$4" out
    if ! command -v "$bin" >/dev/null 2>&1; then
        echo "MISSING $bin"
        echo "  Fix: $fix"
        fail=1
        return
    fi
    if [ "$pin" = "-" ]; then # presence-only tool
        ok="${ok:+$ok · }$bin"
        return
    fi
    out="$(eval "$vcmd" 2>/dev/null | tr '\n' ' ')"
    case "$out" in
        *"$pin"*) ok="${ok:+$ok · }$bin($pin)" ;;
        *)
            echo "DRIFT $bin: manifest pins '$pin', got: $(printf '%s' "$out" | head -c 80)"
            echo "  Fix: align the tool, or update the pin in health/environment.md"
            ;;
    esac
}
# Presence-only pins ("-") by default; forks pin versions as the fleet stabilizes,
# e.g.: chk md "md version" "build: <hash>" "build meridian (llm-wiki-v2 line) → ~/.local/bin/md"
chk md       "-" "-" "build meridian (llm-wiki-v2 line) → ~/.local/bin/md — see Fresh machine step 2"
chk python3  "-" "-" "install via your package manager"
chk lefthook "-" "-" "install via your package manager"
chk gitleaks "-" "-" "install via your package manager"
chk rg       "-" "-" "install via your package manager"
chk obsidian "-" "-" "install Obsidian.app, symlink CLI: ln -s /Applications/Obsidian.app/Contents/MacOS/Obsidian /usr/local/bin/obsidian"
chk git      "-" "-" "install via your package manager"
[ -n "$ok" ] && echo "ok: $ok"
exit $fail
```

^check
