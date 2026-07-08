---
tags: [domain/wiki, type/reference]
created: 2026-07-08
md-check: "[[repos-root#^check]]"
md-link: "[[repos-root#^link]]"
md-all: "link,check"
lint-ignore: [heading-structure]
description: "Repos-root address layer ops — materialize $CCC_LLM_WIKI_REPOS_ROOT/<slug> symlinks from the sources/git catalog (link) and run the md llm-wiki doctor (check)"
---

# repos-root — address-layer materialize + doctor

The repos-root invariant: every cataloged repo resolves at
`$CCC_LLM_WIKI_REPOS_ROOT/<slug>` — a plain dir of symlinks into physical
checkouts. The wiki carries only repo *identity* (`sources/git/<slug>/`
masters); where each repo lives locally is machine truth. This page carries the
two host-side operations:

- **link** — discovery-based materializer. Indexes physical checkouts by git
  remote, matches each cataloged slug's `remote:`, creates/re-points
  `$ROOT/<slug> → <physical>`. Machine-local, regenerated per machine, never
  committed. Move a checkout physically → re-run → the symlink follows.
- **check** — the doctor (`md llm-wiki check`): env var sane, root is a plain
  dir, every cataloged slug resolves with matching git identity. **Absent is a
  normal state** (deinit'd pointer) — reported as info, never a failure.

Discovery scope is the machine's physical-layout convention:
`$CCC_LLM_WIKI_DISCOVERY_ROOTS` (colon-separated dirs, default
`/Users/Shared/projects`), each root scanned at three depths
(`<root>/<repo>`, `<root>/<container>/<nest>`, `<root>/<container>/repos/<nest>`).
Forks: keep grab-bag folders (stray same-remote checkouts) OUT of the discovery
roots — "later wins" indexing would mislink them.

## Usage

```bash
md run '{"file":"health/repos-root.md","name":"link"}'    # materialize (from wiki root)
md run '{"file":"health/repos-root.md","name":"check"}'   # doctor
md run '{"file":"health/repos-root.md","name":"all"}'     # link, then check
```

## Tasks

```bash
# link: materialize $ROOT/<slug> symlinks for every cataloged repo.
root="${CCC_LLM_WIKI_REPOS_ROOT:?repos-root link: CCC_LLM_WIKI_REPOS_ROOT not set — see llm-wiki setup/env-repos-root.md}"
catalog=""; for c in sources/git wiki/sources/git; do [ -d "$c" ] && { catalog="$c"; break; }; done
[ -n "$catalog" ] || { echo "repos-root link: no catalog (sources/git) from $(pwd) — skipping" >&2; exit 0; }
mkdir -p "$root"
[ -e "$root/.git" ] && { echo "repos-root link: $root is a git repo — repos root must be a plain dir" >&2; exit 1; }
# Normalize a git remote URL to host/path identity (mirrors meridian
# NormalizeGitURL: drop scheme/user/port/.git/#frag, lowercase host only).
norm() {
    local u="${1%%#*}"; u="${u%/}"; u="${u%.git}"
    if [[ "$u" == *"://"* ]]; then
        local rest="${u#*://}"; rest="${rest#*@}"
        local host="${rest%%/*}"; host="${host%%:*}"
        local path="${rest#*/}"
        [[ "$rest" == */* ]] && printf '%s/%s' "$(tr '[:upper:]' '[:lower:]' <<<"$host")" "$path" || tr '[:upper:]' '[:lower:]' <<<"$host"
    elif [[ "$u" == *"@"*:* ]]; then
        local au="${u#*@}"; local host="${au%%:*}"; local path="${au#*:}"
        printf '%s/%s' "$(tr '[:upper:]' '[:lower:]' <<<"$host")" "$path"
    elif [[ "$u" == */* ]]; then
        printf '%s/%s' "$(tr '[:upper:]' '[:lower:]' <<<"${u%%/*}")" "${u#*/}"
    else
        tr '[:upper:]' '[:lower:]' <<<"$u"
    fi
}
# Index physical checkouts by every configured remote -> absolute path.
# Discovery roots: colon-separated dirs; each scanned at three depths.
IFS=':' read -ra roots <<< "${CCC_LLM_WIKI_DISCOVERY_ROOTS:-/Users/Shared/projects}"
declare -A idx
shopt -s nullglob
globs=()
for R in "${roots[@]}"; do
    globs+=("$R"/*/.git "$R"/*/*/.git "$R"/*/repos/*/.git)
done
for gd in "${globs[@]}"; do
    d="${gd%/.git}"
    # Index only REAL checkouts — symlinked dirs would form cycles back into $ROOT.
    [ -L "$d" ] && continue
    while read -r url; do
        [ -n "$url" ] || continue
        idx["$(norm "$url")"]="$d"
    done < <(git -C "$d" remote get-url --all origin 2>/dev/null; git -C "$d" config --get-regexp '^remote\..*\.url$' 2>/dev/null | awk '{print $2}')
done
linked=()
for page in "$catalog"/*/; do
    slug="$(basename "$page")"
    [ "$slug" = "GIT.base" ] && continue
    target="$root/$slug"
    remote="$(grep -m1 -h -E '^remote:' "$page"*.md 2>/dev/null | head -1 | sed -E 's/^remote:[[:space:]]*//' | tr -d '"' || true)"
    [ -n "$remote" ] || continue
    d="${idx[$(norm "$remote")]:-}"
    # Existing entry: leave real checkouts alone; re-point stale symlinks.
    if [ -e "$target" ] && [ ! -L "$target" ]; then continue; fi
    if [ -L "$target" ] && [ "$(readlink "$target")" = "${d:-}" ]; then continue; fi
    [ -n "$d" ] || { [ -L "$target" ] && [ ! -e "$target" ] && { rm "$target"; echo "removed broken: $slug"; }; continue; }
    ln -sfn "$d" "$target"
    linked+=("$slug")
    echo "linked: $slug -> $d"
done
total=0
for page in "$catalog"/*/; do
    [ -L "$root/$(basename "$page")" ] && total=$((total+1))
done
echo "repos-root link: ${#linked[@]} new/re-pointed, $total total root symlink(s) at $root"
```

^link

```bash
# check: the llm-wiki repos-root doctor. Absent repos are info (normal state);
# env / broken-symlink / wrong-remote failures exit non-zero.
md llm-wiki check
```

^check
