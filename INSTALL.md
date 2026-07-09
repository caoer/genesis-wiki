---
md-check: "[[INSTALL#^check]]"
md-check-args: "target"
md-check-env: "CCC_LLM_WIKI_PATH"
md-install: "[[INSTALL#^install]]"
md-install-args: "target"
md-bootstrap: "[[INSTALL#^bootstrap]]"
md-bootstrap-args: "target"
tags: [domain/contract, type/reference]
created: 2026-07-09
description: "The genesis birth+install engine as one md-run literate page — renders the genesis template into a target folder: birth into an empty dir, adjudicated per-file diff into an existing wiki, re-run to update. No compiled code, no pin chain."
---

# INSTALL — genesis birth + install engine

This page **is** the install executor. It renders the genesis template into a
target folder: an empty/missing target gets a clean birth (`^bootstrap`), an
existing wiki gets an adjudicated per-file diff (`^install`), and `^check`
inspects a target read-only — all as `md run` tasks, no compiled code.
**Re-run to update**: every run re-renders and re-diffs from scratch.

## Model (contract-anchored)

- **Payload = two trees.** `domains/contract/seeds/*` (minus its own `README.md`)
  → the target **root**; `domains/contract/genesis-contract/*` → the target at
  `domains/contract/genesis-contract/*` **mirrored 1:1** (contract C49-upstream-layout
  `upstream-layout`). This page and the genesis-clone's own operational files
  are never copied.
- **cwd is the genesis clone, never the target.** Every `git` invocation is
  `git -C <dir>`; every target path is absolute. Blocks run as `bash -euo
  pipefail` temp scripts (`md run`), `args` arrive as `$1 $2 …`.
- **No pin chain.** A wiki's genesis provenance is the human-readable birth
  commit message (`birth: <slug> from genesis@<sha>`) — reference prose for a
  reader, never a detection mechanism. Nothing walks history; nothing is ever
  proposed for removal — files in the target that the template does not ship
  are the wiki's own instance content, full stop.
- **Install is agent-adjudicated for existing wikis.** `^install` renders →
  diffs → copies the safe classes → **holds back the diverged-root class
  (refuse-by-default)** → installs hooks → prints instructions. It **never
  commits**: the adjudicating agent reviews the dirty tree and commits. An
  abandoned run is just a dirty tree the guard reports.
- **Exit convention.** `0` ok · `1` task-failed. Never `2` (reserved by `md`
  for resolution-failure — do not overload). The end-state is the final line
  `CONVERGE-STATUS: in-sync | pending-adjudication`.

## Usage

````bash
# read-only doctor (declare the operating wiki via CCC_LLM_WIKI_PATH — shadowing guard)
env -i PATH="$PATH" HOME="$HOME" CCC_LLM_WIKI_PATH=/abs/target \
  md run '{"file":"/abs/genesis/INSTALL.md","name":"check","args":["/abs/target"]}'

# install into an existing wiki (adjudicated; nothing committed)
env -i PATH="$PATH" HOME="$HOME" \
  md run '{"file":"/abs/genesis/INSTALL.md","name":"install","args":["/abs/target"]}'
#   args: [target, params-file?, accept-root-list?]

# birth a fresh wiki into an empty/new dir, then the birth commit
env -i PATH="$PATH" HOME="$HOME" \
  md run '{"file":"/abs/genesis/INSTALL.md","name":"bootstrap","args":["/abs/new-wiki"]}'
#   args: [target, params-file?]
````

**Env posture (decision #17).** Install blocks are meant to run under a
**scrubbed** env (`env -i PATH=… HOME=… <declared vars>`), never full
inheritance — the only declared variable is `CCC_LLM_WIKI_PATH` (`^check` only).
`--no-verify` is banned: `^install` activates the role's hook and the birth
commit passes through it.

**Named gaps.** Install into an existing wiki **requires an interactive
adjudicating agent**; headless/CI invocation is out of scope. Executed blocks
have no content-level sandbox — the env scrub + the invoking agent's permission
scope bound egress.

## `^check` — read-only doctor

Reports posture; writes nothing. Fails (`exit 1`) only when a precondition makes
install untrustworthy (missing tool, bad target, shallow clone). Everything
else is a `WARN`/posture line at `exit 0`.

````bash
# ^check — read-only doctor for an install/birth target. args: [target]
target="${1:?FAIL[check]: missing required arg: target (absolute path)}"
case "$target" in /*) : ;; *) echo "FAIL[check]: target must be absolute: $target" >&2; exit 1 ;; esac
genesis="$(git -C . rev-parse --show-toplevel)"           # cwd = the genesis clone
seeds="$genesis/domains/contract/seeds"
fails=0

# 1. tools — git+md are hard requirements; lefthook/gitleaks are role-dependent (report only)
for t in md git; do command -v "$t" >/dev/null 2>&1 || { echo "FAIL[check]: required tool missing: $t" >&2; fails=$((fails+1)); }; done
for t in lefthook gitleaks; do command -v "$t" >/dev/null 2>&1 && echo "tool: $t present" || echo "tool: $t ABSENT (needed for team/public hooks)"; done

# 2. target shape + clean-tree probe (untracked counts as dirty)
if [ ! -e "$target" ]; then echo "target: does not exist yet (birth candidate)";
elif [ ! -e "$target/.git" ]; then
  [ -z "$(ls -A "$target" 2>/dev/null)" ] && echo "target: empty non-git dir (birth candidate)" || { echo "FAIL[check]: target non-empty and not a git repo" >&2; fails=$((fails+1)); }
else
  # 3. shallow guard — a shallow clone has incomplete history; unshallow before operating on it
  if [ "$(git -C "$target" rev-parse --is-shallow-repository 2>/dev/null)" = "true" ]; then
    echo "FAIL[check]: target is a shallow clone — unshallow before install" >&2; fails=$((fails+1))
  fi
  dirty="$(git -C "$target" status --porcelain 2>/dev/null)"
  [ -z "$dirty" ] && echo "tree: clean" || printf 'WARN[check]: target tree is DIRTY (install refuses until clean):\n%s\n' "$dirty"

  # 4. security config presence — .gitleaks.toml/.gitignore ship in the template; lefthook.yml is role-owned
  for f in .gitleaks.toml .gitignore; do
    [ -f "$seeds/$f" ] || continue
    [ -f "$target/$f" ] && echo "posture: $f present" || echo "POSTURE[check]: $f ABSENT in target (template ships it) — security config missing"
  done
  [ -f "$target/lefthook.yml" ] && echo "posture: lefthook.yml present (role-owned)" || echo "posture: lefthook.yml absent (private role, or hooks not yet installed)"
fi

# 5. env printout — CCC_LLM_WIKI_PATH shadowing (multi-wiki host; R13/R14 recurrence)
if [ "$(cd "${CCC_LLM_WIKI_PATH:-}" 2>/dev/null && pwd -P)" = "$(cd "$target" 2>/dev/null && pwd -P)" ]; then
  echo "env: CCC_LLM_WIKI_PATH resolves to target — nested md calls hit the right wiki"
else
  echo "WARN[check]: CCC_LLM_WIKI_PATH=${CCC_LLM_WIKI_PATH:-<unset>} does NOT resolve to target $target — nested md calls would shadow onto the wrong wiki"
fi

[ "$fails" -eq 0 ] && { echo "CHECK: ok (warnings are non-fatal)"; exit 0; } || { echo "CHECK: $fails hard failure(s)" >&2; exit 1; }
````

^check

## `^install` — render, diff, install (no commit)

Birth (empty/missing target) or update (existing clean wiki). Renders the
template into a `0700` tmp dir, diffs against the target, prints the grouped
summary, copies the safe classes, holds back the diverged-root class, installs
the role hook. **Never commits.**

`args: [target, params-file?, accept-root-list?]` — `params-file` supplies
birth tokens (empty target); `accept-root-list` is a space-separated set of
diverged-root paths to accept this run.

**Crash recovery.** A run that dies mid-copy leaves a dirty tree and no commit;
the next run's guard refuses until it is clean. Undo the partial copy **scoped to
the paths the diff summary listed** — never a bare `git clean`, which would eat
the wiki's own untracked instance content: revert modified template files with
`git -C "$target" checkout -- <changed paths>` and delete only the summary's
`ADDED` paths (`git -C "$target" clean -fd -- <those exact paths>`). Then re-run.

````bash
# ^install — render+diff+install the genesis template into a target; no commit. args: [target, params-file?, accept-root?]
target="${1:?FAIL[install]: missing required arg: target (absolute path)}"
params_file="${2:-}"; accept_root=" ${3:-} "
case "$target" in /*) : ;; *) echo "FAIL[install]: target must be absolute: $target" >&2; exit 1 ;; esac
genesis="$(git -C . rev-parse --show-toplevel)"           # cwd = the genesis clone
seeds="$genesis/domains/contract/seeds"; contract="$genesis/domains/contract/genesis-contract"
genesis_sha="$(git -C "$genesis" rev-parse HEAD)"

# --- target guard: git-init only if empty/missing, else demand a clean tree ---
if [ ! -e "$target" ] || { [ -d "$target" ] && [ -z "$(ls -A "$target" 2>/dev/null)" ]; }; then
  mkdir -p "$target"; [ -e "$target/.git" ] || git -C "$target" init -q
elif [ -e "$target/.git" ]; then
  dirty="$(git -C "$target" status --porcelain 2>/dev/null)"
  [ -n "$dirty" ] && { printf 'FAIL[install]: target tree is DIRTY (commit/stash first; untracked counts):\n%s\n' "$dirty" >&2; exit 1; }
else
  echo "FAIL[install]: target non-empty and not a git repo — refusing: $target" >&2; exit 1
fi

# --- resolve substitution params: existing wiki reads target frontmatter; birth reads params-file / defaults ---
llm="$target/LLM_WIKI.md"
fmval() { sed -n "s/^$1:[[:space:]]*//p" "$2" 2>/dev/null | head -1 | sed -e 's/[[:space:]]*#.*$//' -e 's/^"\(.*\)"$/\1/' -e "s/^'\(.*\)'\$/\1/" -e 's/[[:space:]]*$//'; }
slug=""; role=""; ref_block="[]"; identity=""; fork_url=""; upstream_url=""; born_date="$(date +%F)"
if [ -f "$llm" ]; then
  slug="$(fmval wiki-slug "$llm")"; role="$(fmval wiki-role "$llm")"
  cd="$(fmval created "$llm")"; [ -n "$cd" ] && born_date="$cd"
  # F1 (C20-slug-identity / C22-realpath-coherence): slug == folder name is a HARD invariant.
  # Reading it two ways (frontmatter slug vs folder basename) is exactly the silent-clobber path —
  # guard the ambiguity loudly rather than proceeding on divergent reads (silent chaos is the harm).
  base="$(basename "$target")"
  [ -n "$slug" ] && [ "$slug" != "$base" ] && { echo "FAIL[install]: wiki-slug '$slug' != folder name '$base' — slug==foldername is a hard invariant (contract C20-slug-identity / C22-realpath-coherence); rename the folder or fix wiki-slug, then re-run" >&2; exit 1; }
  # fork/upstream provenance for the <SLUG>-GENESIS.md source page — resolved by the frontmatter slug, never basename
  src="$target/sources/git/${slug}-genesis/$(printf '%s' "$slug" | tr '[:lower:]' '[:upper:]')-GENESIS.md"
  [ -f "$src" ] && { fork_url="$(fmval remote "$src")"; upstream_url="$(fmval upstream "$src")"; }
  # identity + reference-wikis are instance-owned and live only in LLM_WIKI.md, which is excluded from
  # overwrite on an existing wiki (F2, contract C9-schema-governed-exceptions) — NOT read back here; birth reads them from params.
fi
# birth defaults / params-file overrides (KEY=VALUE; *_FILE keys inject multi-line values). No `source` — parsed safely.
# F7: *_FILE contents land in committed wiki content — refuse secret-looking or oversized files (secret-egress guard).
_sf_check() {
  local f="$1" bn; bn="$(basename "$f")"
  [ -f "$f" ] || { echo "FAIL[install]: params *_FILE not found: $f" >&2; return 1; }
  case "$bn" in
    .env|.env.*|*.pem|*.key|id_rsa*|id_ed25519*|*.p12|*.pfx|credentials|credentials.*|*secret*|*.crt)
      echo "FAIL[install]: refusing to inject a secret-looking file into committed wiki content: $f" >&2; return 1 ;;
  esac
  [ "$(wc -c < "$f" 2>/dev/null || echo 0)" -gt 65536 ] && { echo "FAIL[install]: params *_FILE too large (>64KB), refusing: $f" >&2; return 1; }
  return 0
}
if [ -n "$params_file" ] && [ -f "$params_file" ]; then
  while IFS='=' read -r pk pv; do case "$pk" in
    SLUG) slug="$pv";; ROLE) role="$pv";; FORK_REMOTE_URL) fork_url="$pv";; GENESIS_UPSTREAM_URL) upstream_url="$pv";;
    BORN_DATE) born_date="$pv";; REFERENCE_WIKIS) ref_block="$pv";; IDENTITY) identity="$pv";;
    IDENTITY_FILE) _sf_check "$pv" || exit 1; identity="$(< "$pv")";;
    REFERENCE_WIKIS_FILE) _sf_check "$pv" || exit 1; ref_block="$(< "$pv")";;
    ''|\#*) : ;; esac done < "$params_file"
fi
[ -z "$slug" ] && slug="$(basename "$target")"
slug_upper="$(printf '%s' "$slug" | tr '[:lower:]' '[:upper:]')"
role="$(printf '%s' "$role" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')"   # F6: normalize so 'Public'/' team ' can't slip past the role→hook selector into the no-hook branch
[ -z "$role" ] && role="private"
[ -z "$identity" ] && identity="$slug — identity not yet authored at birth. Edit LLM_WIKI.md to describe this wiki's subject and boundary."
[ -z "$upstream_url" ] && upstream_url="$(git -C "$genesis" remote get-url upstream 2>/dev/null || git -C "$genesis" remote get-url origin 2>/dev/null || echo '')"

# --- render into a 0700 tmp payload; renames + substitution before any diff ---
work="$(mktemp -d)"; chmod 700 "$work"; trap 'rm -rf "$work"' EXIT
payload="$work/payload"; mkdir -p "$payload/domains/contract/genesis-contract"
find "$seeds" -mindepth 1 -maxdepth 1 ! -name README.md -exec cp -R {} "$payload/" \;   # seeds/* (minus README) → root
cp -R "$contract"/. "$payload/domains/contract/genesis-contract/"                        # genesis-contract/* → 1:1
gdir="$payload/sources/git/{{WIKI_SLUG}}-genesis"                                        # {{…}} file/dir renames
if [ -d "$gdir" ]; then mv "$gdir/{{WIKI_SLUG_UPPER}}-GENESIS.md" "$gdir/${slug_upper}-GENESIS.md"; mv "$gdir" "$payload/sources/git/${slug}-genesis"; fi

mapf="$work/subs.map"; : > "$mapf"                                                       # tab-separated, base64 values (multi-line safe)
emit() { printf '%s\t%s\n' "$1" "$(printf '%s' "$2" | base64 | tr -d '\n')" >> "$mapf"; }
emit '{{WIKI_SLUG}}' "$slug"; emit '{{WIKI_SLUG_UPPER}}' "$slug_upper"; emit '{{ROLE}}' "$role"
emit '{{YYYY-MM-DD}}' "$born_date"; emit '{{REFERENCE_WIKIS_BLOCK}}' "$ref_block"; emit '{{IDENTITY_PARAGRAPH}}' "$identity"
emit '{{FORK_REMOTE_URL}}' "$fork_url"; emit '{{GENESIS_UPSTREAM_URL}}' "$upstream_url"
python3 - "$mapf" "$payload" <<'PY'
import sys, os, base64
mapfile, root = sys.argv[1], sys.argv[2]
subs = []
for line in open(mapfile, encoding='utf-8'):
    line = line.rstrip('\n')
    if not line: continue
    k, v = line.split('\t', 1); subs.append((k, base64.b64decode(v).decode('utf-8')))
EXTS = ('.md', '.yaml', '.yml', '.toml')
for dp, _, files in os.walk(root):
    for fn in files:
        p = os.path.join(dp, fn)
        if not p.endswith(EXTS): continue
        rel = os.path.relpath(p, root)
        text = open(p, encoding='utf-8').read()
        for k, v in subs:
            if k == '{{YYYY-MM-DD}}' and rel.startswith('domains' + os.sep + 'example' + os.sep):
                continue                                                                 # teaching markers stay verbatim (regression-locked)
            text = text.replace(k, v)
        open(p, 'w', encoding='utf-8').write(text)
PY

# --- residue sweep: zero non-teaching {{ across .md/.yaml/.yml/.toml (.toml = the ce1bdd4 blind-spot) ---
residue="$(find "$payload" -type f \( -name '*.md' -o -name '*.yaml' -o -name '*.yml' -o -name '*.toml' \) -not -path "$payload/domains/example/*" -exec grep -Hn '{{' {} + 2>/dev/null || true)"
[ -n "$residue" ] && { printf 'FAIL[install]: unresolved {{token}} residue after render (aborting before copy):\n%s\n' "$residue" >&2; exit 1; }

# --- diff: classify every template path against the target (target-only files are instance content — never touched, never listed) ---
ROOT_CLASS=" SCHEMA.md CLAUDE.md meridian.yaml .gitignore .gitleaks.toml lefthook.yml "   # LLM_WIKI.md is NOT here — excluded from overwrite (F2/C9-schema-governed-exceptions), handled below
added=(); changed=(); changed_root=()
while IFS= read -r rel; do
  tpath="$target/$rel"
  # F2 (contract C9-schema-governed-exceptions): LLM_WIKI.md is instance-owned identity — on an EXISTING wiki it is never
  # re-rendered or overwritten (birth creates it once; a re-install leaves it entirely alone).
  if [ "$rel" = "LLM_WIKI.md" ] && [ -e "$tpath" ]; then continue; fi
  if [ ! -e "$tpath" ]; then added+=("$rel")
  elif cmp -s "$payload/$rel" "$tpath"; then :                                            # identical — no diff
  elif printf '%s' "$ROOT_CLASS" | grep -q " $rel "; then changed_root+=("$rel")
  else changed+=("$rel"); fi
done < <(cd "$payload" && find . -type f | sed 's|^\./||' | sort)

# --- print the grouped diff summary ---
echo "=== GENESIS INSTALL DIFF — $slug @ genesis ${genesis_sha:0:12} ==="
echo "resolved params: slug=$slug role=$role born=$born_date fork-remote=${fork_url:-<none>}"
echo
echo "ADDED (${#added[@]}):";        for r in "${added[@]}"; do echo "  + $r"; done
echo "CHANGED (${#changed[@]}):";    for r in "${changed[@]}"; do echo "  ~ $r"; done
echo "CHANGED-ROOT (${#changed_root[@]}) — diverged-root class, REFUSE by default, accept each explicitly:"
for r in "${changed_root[@]}"; do
  echo "  ! $r"
  python3 - "$target/$r" "$payload/$r" <<'PY' | sed 's/^/      /'
import sys, re
def parse(path):
    fm = {}
    try: t = open(path, encoding='utf-8', errors='replace').read()
    except OSError: return fm, ''
    m = re.match(r'^---\n(.*?)\n---\n?(.*)$', t, re.S)
    if not m: return fm, t                                                        # no frontmatter → all body
    for line in m.group(1).splitlines():
        mm = re.match(r'^([A-Za-z0-9_-]+):\s?(.*)$', line)
        if mm:
            v = re.sub(r'\s+#.*$', '', mm.group(2).strip()).strip().strip('"\'')
            fm[mm.group(1)] = v
    return fm, m.group(2)
a, abody = parse(sys.argv[1])                                                     # target (installed now)
b, bbody = parse(sys.argv[2])                                                     # template (what an accept would write)
# symmetric: changed / removed-by-accept / added-by-accept — never an empty delta that hides a destructive accept
for k in a:
    if k not in b: print(f"field: {k}: {a[k]} → (removed by accept)")
    elif a[k] != b[k]: print(f"field: {k}: {a[k]} → {b[k]}")
for k in b:
    if k not in a: print(f"field: (absent) → {k}: {b[k]} (added by accept)")
if abody != bbody: print("body: differs — review the full file, not just the fields above")
PY
  case "$accept_root" in *" $r "*) : ;; *) echo "      accept: re-run with accept-root arg containing \"$r\"" ;; esac
done
echo

# --- copy: apply ADDED + CHANGED(non-root) + accepted CHANGED-ROOT; hold back refused root ---
apply() { mkdir -p "$target/$(dirname "$1")"; cp "$payload/$1" "$target/$1"; }
for r in "${added[@]}"   "${changed[@]}"; do apply "$r"; done
held=0
for r in "${changed_root[@]}"; do
  case "$accept_root" in *" $r "*) apply "$r"; echo "root-accepted: $r" ;; *) held=$((held+1)) ;; esac
done
[ "$held" -gt 0 ] && echo "root-refused: $held diverged-root file(s) held back — accept each explicitly, then re-run"

# --- hooks: role-selected (C45-role-selects-lint-pack). team/public get the secrets-scan pre-commit; private gets none. lefthook.yml is role-owned, never clobbered ---
case "$role" in
  team|public)
    if [ ! -f "$target/lefthook.yml" ]; then
      printf '%s\n' \
        '# Git hooks — genesis-managed secrets-scan (team/public pack, contract C45-role-selects-lint-pack).' \
        'output:' '  - failure' 'pre-commit:' '  jobs:' '    - name: secrets-scan' \
        '      run: gitleaks git --staged --pre-commit --no-banner --redact' > "$target/lefthook.yml"
    fi
    # F6 fail-closed: team/public must NEVER reach a commit-able state without the secrets-scan hook (C45-role-selects-lint-pack no-unhooked-window)
    if command -v lefthook >/dev/null 2>&1; then
      ( cd "$target" && lefthook install --force >/dev/null 2>&1 ) \
        && echo "hooks: lefthook secrets-scan active ($role)" \
        || { echo "FAIL[install]: lefthook install failed for role=$role — team/public must not have an unhooked window (C45-role-selects-lint-pack); fix lefthook then re-run" >&2; exit 1; }
    else
      echo "FAIL[install]: lefthook binary absent but role=$role requires the secrets-scan hook (C45-role-selects-lint-pack no-unhooked-window) — install lefthook then re-run" >&2; exit 1
    fi ;;
  private) echo "hooks: role=private — no hooks (C45-role-selects-lint-pack: private keeps secrets in-repo, no scan)" ;;
  *) echo "FAIL[install]: unknown role '$role' — must be private|team|public (C45-role-selects-lint-pack); refusing rather than silently skipping the hook" >&2; exit 1 ;;
esac

# --- end-state ---
total=$(( ${#added[@]} + ${#changed[@]} + ${#changed_root[@]} ))
echo
if [ "$total" -eq 0 ]; then
  echo "CONVERGE-STATUS: in-sync"
else
  echo "Adjudicate: review the CHANGED-ROOT field deltas above; the working tree now carries the safe classes."
  echo "When satisfied, review and commit as the adjudicating agent, e.g.:"
  echo "  git -C \"$target\" add <reviewed paths> && git -C \"$target\" commit -m \"genesis install: update $slug from genesis@${genesis_sha:0:12}\""
  echo "CONVERGE-STATUS: pending-adjudication"
fi
````

^install

## `^bootstrap` — fresh-dir birth + birth commit

Fresh birth only (refuses a non-empty target — use `^install` for an existing
wiki). Delegates scaffolding to `^install` in birth mode, then writes the birth
commit. The commit message names the genesis sha as **human reference prose** —
provenance for a reader, never a detection mechanism. **No `--no-verify`** —
the role hook (if any) runs on the birth tree.

`args: [target, params-file?]` — the params-file carries birth tokens
(`SLUG`, `ROLE`, `FORK_REMOTE_URL`, `IDENTITY_FILE`, `REFERENCE_WIKIS_FILE`, …);
absent, documented defaults apply (`role=private`, `reference-wikis=[]`, slug =
target basename, identity a placeholder, upstream = genesis remote).

````bash
# ^bootstrap — birth a fresh wiki, then the birth commit. args: [target, params-file?]
target="${1:?FAIL[bootstrap]: missing required arg: target (absolute path)}"
params_file="${2:-}"
case "$target" in /*) : ;; *) echo "FAIL[bootstrap]: target must be absolute: $target" >&2; exit 1 ;; esac
if [ -e "$target" ] && [ -n "$(ls -A "$target" 2>/dev/null)" ]; then
  echo "FAIL[bootstrap]: target not empty — use ^install for an existing wiki: $target" >&2; exit 1
fi
genesis="$(git -C . rev-parse --show-toplevel)"           # cwd = the genesis clone
genesis_sha="$(git -C "$genesis" rev-parse HEAD)"
slug="$(basename "$target")"

# delegate scaffolding (repo-init + render + copy + hooks) to ^install in birth mode; </dev/null on the nested md call
json="$(python3 -c 'import json,sys; print(json.dumps({"file":sys.argv[1],"name":"install","args":[sys.argv[2],sys.argv[3]]}))' "$genesis/INSTALL.md" "$target" "$params_file")"
md run "$json" </dev/null || { echo "FAIL[bootstrap]: nested install failed" >&2; exit 1; }

# birth commit — human-reference provenance in the message; no --no-verify (decision #17): the just-installed hook runs
git -C "$target" add -A
git -C "$target" commit -q -m "birth: $slug from genesis@$genesis_sha" \
  || { echo "FAIL[bootstrap]: birth commit failed (hook rejection? fix and re-commit — --no-verify is banned)" >&2; exit 1; }
echo "BOOTSTRAP: born $slug from genesis@$genesis_sha"
echo "next (team/public only): if hooks were not activated, install lefthook and re-run \`md run install\` to activate before the next commit"
````

^bootstrap
