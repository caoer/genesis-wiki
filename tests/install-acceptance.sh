#!/usr/bin/env bash
# tests/install-acceptance.sh — acceptance harness for INSTALL.md (minimal-model, contract v1.1).
#
# Genesis-OPERATIONAL, re-runnable, lives at the genesis root under tests/ — like INSTALL.md
# and seeds/README (C49-upstream-layout), it is NEVER shipped to children: `^install` copies only
# `domains/contract/seeds/*` (minus README) + `domains/contract/genesis-contract/*`, so a
# root-level tests/ dir is auto-excluded. Assertion (a) re-confirms this on a born wiki.
#
# Proves the reshaped engine works. Simplified assertion set (per the 2026-07-09 minimal-model
# reframe — NO pin/born-child/history assertions):
#   a  fresh-birth byte-identity (independent render diff + residue + absences + birth commit)
#   b  idempotent re-run (empty diff, no commit, CONVERGE-STATUS: in-sync)
#   c  diff-adjudicate on an existing wiki (CHANGED-ROOT refuse-by-default + field delta; accept-root applies)
#   d  negative paths (non-empty-non-git / dirty tree / missing arg / shallow-clone guard)
#   e  static block lints (no bare `git `; no undeclared env var) — see lint_blocks.py
#
# Fix INSTALL.md, never the assertion. Exit 0 = GREEN gate; 1 = RED.
set -uo pipefail

TESTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GENESIS="$(cd "$TESTS/.." && pwd)"
INSTALL="$GENESIS/INSTALL.md"
SEEDS="$GENESIS/domains/contract/seeds"
CONTRACT="$GENESIS/domains/contract/genesis-contract"
HEAD="$(git -C "$GENESIS" rev-parse HEAD)"

if [ -t 1 ]; then GRN=$'\033[32m'; RED=$'\033[31m'; BLD=$'\033[1m'; RST=$'\033[0m'; else GRN=; RED=; BLD=; RST=; fi

SB="$(mktemp -d)"
KEEP="${1:-}"
cleanup(){ [ "$KEEP" = "--keep" ] || rm -rf "$SB"; }
trap cleanup EXIT

declare -A ST; for L in a b c d e f g; do ST[$L]=pass; done

has(){ case "$2" in *"$1"*) return 0;; *) return 1;; esac; }          # has <needle> <haystack>
ck(){ # ck <letter> <ok:0|1> <desc> [detail]
  local L="$1" okc="$2" desc="$3" detail="${4:-}"
  if [ "$okc" -eq 0 ]; then printf '  %sok  %s[%s] %s\n' "$GRN" "$RST" "$L" "$desc"
  else printf '  %sFAIL%s[%s] %s\n        -> %s\n' "$RED" "$RST" "$L" "$desc" "$detail"; ST[$L]=fail; fi
}
expect(){ if has "$3" "$4"; then ck "$1" 0 "$2"; else ck "$1" 1 "$2" "missing marker: [$3]"; fi; }   # <L> <desc> <needle> <hay>
refute(){ if has "$3" "$4"; then ck "$1" 1 "$2" "unexpected marker: [$3]"; else ck "$1" 0 "$2"; fi; } # <L> <desc> <needle> <hay>
absent(){ if [ ! -e "$2" ]; then ck "$1" 0 "$3"; else ck "$1" 1 "$3" "exists but must be absent: $2"; fi; } # <L> <path> <desc>
present(){ if [ -e "$2" ]; then ck "$1" 0 "$3"; else ck "$1" 1 "$3" "missing: $2"; fi; }                    # <L> <path> <desc>

mdrun(){ # mdrun <task> [args...] — render/install/bootstrap under a scrubbed env, cwd=genesis
  local task="$1"; shift
  local json
  json="$(printf '%s\0' "$INSTALL" "$task" "$@" | python3 -c '
import json,sys
a=[x.decode() for x in sys.stdin.buffer.read().split(b"\0")[:-1]]
print(json.dumps({"file":a[0],"name":a[1],"args":a[2:]}))')"
  ( cd "$GENESIS" && env -i PATH="$PATH" HOME="$HOME" md run "$json" </dev/null 2>&1 )
}
mdcheck(){ # mdcheck <target> [wikipath] — ^check with the one declared env var
  local target="$1" wikipath="${2:-$1}" json
  json="$(python3 -c 'import json,sys; print(json.dumps({"file":sys.argv[1],"name":"check","args":[sys.argv[2]]}))' "$INSTALL" "$target")"
  ( cd "$GENESIS" && env -i PATH="$PATH" HOME="$HOME" CCC_LLM_WIKI_PATH="$wikipath" md run "$json" </dev/null 2>&1 )
}

# shared birth params. NO SLUG token: the engine derives slug = basename(target), honoring the
# slug=foldername invariant (C20-slug-identity / C22-realpath-coherence) — so every fixture dir is
# named as its own valid slug. Single-line identity + [] reference-wikis keep the re-run idempotent
# (the engine re-reads these from LLM_WIKI.md via head -1 / single-line awk).
ROLE=private; BORN=2026-07-09; REF='[]'
IDENT='Fixture wiki born by the acceptance harness to prove render byte-identity.'
FORKURL='git@github.com:acme/acme-wiki.git'
UPURL="$(git -C "$GENESIS" remote get-url upstream 2>/dev/null || echo 'git@github.com:caoer/genesis-wiki')"
slugof(){ basename "$1"; }
upof(){ printf '%s' "$1" | tr '[:lower:]' '[:upper:]'; }
mkparams(){ cat > "$1" <<EOF
ROLE=$ROLE
FORK_REMOTE_URL=$FORKURL
GENESIS_UPSTREAM_URL=$UPURL
BORN_DATE=$BORN
REFERENCE_WIKIS=$REF
IDENTITY=$IDENT
EOF
}

echo "${BLD}INSTALL.md acceptance harness${RST}  genesis@${HEAD:0:12}  ($(date +%FT%T))"
echo "sandbox: $SB"
echo

# ============================ (a) fresh-birth byte-identity ============================
echo "${BLD}(a) fresh-birth byte-identity${RST}"
A="$SB/acme-alpha"; slugA="$(slugof "$A")"; upA="$(upof "$slugA")"; P="$SB/params"; mkparams "$P"
outA="$(mdrun bootstrap "$A" "$P")"; rcA=$?
[ "$rcA" -eq 0 ] && ck a 0 "bootstrap exits 0" || ck a 1 "bootstrap exits 0" "rc=$rcA :: $(printf '%s' "$outA" | tail -2)"
expect a "prints birth-provenance line (prose, names genesis sha)" "BOOTSTRAP: born $slugA from genesis@$HEAD" "$outA"

# birth commit: exactly one, correct subject, NO pin trailer
nA="$(git -C "$A" rev-list --count HEAD 2>/dev/null || echo -1)"
[ "$nA" = "1" ] && ck a 0 "exactly one birth commit" || ck a 1 "exactly one birth commit" "rev-list count=$nA"
subjA="$(git -C "$A" log -1 --format=%s 2>/dev/null)"
[ "$subjA" = "birth: $slugA from genesis@$HEAD" ] && ck a 0 "birth commit subject is the C6-manifest prose" \
  || ck a 1 "birth commit subject is the C6-manifest prose" "got: [$subjA]"
bodyA="$(git -C "$A" log -1 --format=%B 2>/dev/null)"
refute a "no Genesis-Wiki-Pin trailer on the birth commit" "Genesis-Wiki-Pin" "$bodyA"

# zero non-teaching {{ residue across .md/.yaml/.yml/.toml (.toml = the historical blind-spot)
resA="$(find "$A" -type f \( -name '*.md' -o -name '*.yaml' -o -name '*.yml' -o -name '*.toml' \) \
        -not -path "$A/.git/*" -not -path "$A/domains/example/*" -exec grep -Hn '{{' {} + 2>/dev/null)"
[ -z "$resA" ] && ck a 0 "zero non-teaching {{ residue (.md/.yaml/.yml/.toml, .toml included)" \
  || ck a 1 "zero non-teaching {{ residue" "$(printf '%s' "$resA" | head -4)"

# seeds/README deliberate-absence set + genesis-operational exclusions (confirms harness is unshipped)
absent  a "$A/sessions"                   "no sessions/ (C44-claimed-trio companion)"
absent  a "$A/foreign"                    "no foreign/ (C23-no-mounts reserved)"
absent  a "$A/lefthook.yml"               "no lefthook.yml (role=private, C45-role-selects-lint-pack)"
absent  a "$A/health/rules"               "no health/rules/ (materializes from genesis, not seeds)"
absent  a "$A/INSTALL.md"                 "INSTALL.md not shipped to child (C49-upstream-layout)"
absent  a "$A/README.md"                  "seeds/README not shipped (it documents seeds)"
absent  a "$A/tests"                      "tests/ (this harness) not shipped to child"
present a "$A/domains/example"            "teaching example domain present at birth"
present a "$A/LLM_WIKI.md"                "LLM_WIKI.md present (identity)"
present a "$A/domains/contract/genesis-contract/contract-v1.md" "contract mirrored 1:1 (C49-upstream-layout)"

# byte-identity: independent render (NOT the engine) -> diff -r
EXP="$SB/expected"
python3 "$TESTS/render_expected.py" "$SEEDS" "$CONTRACT" "$EXP" "$slugA" "$upA" "$ROLE" "$BORN" "$REF" "$IDENT" "$FORKURL" "$UPURL"
dA="$(diff -r --exclude=.git "$EXP" "$A" 2>&1)"
[ -z "$dA" ] && ck a 0 "born tree byte-identical to independent render @HEAD" \
  || ck a 1 "born tree byte-identical to independent render @HEAD" "$(printf '%s' "$dA" | head -8)"
echo

# ============================ (b) idempotent re-run ============================
echo "${BLD}(b) idempotent re-run${RST}"
outB="$(mdrun install "$A")"; rcB=$?
[ "$rcB" -eq 0 ] && ck b 0 "re-run install exits 0" || ck b 1 "re-run install exits 0" "rc=$rcB"
expect b "empty diff — ADDED (0)"        "ADDED (0)"        "$outB"
expect b "empty diff — CHANGED (0)"      "CHANGED (0)"      "$outB"
expect b "empty diff — CHANGED-ROOT (0)" "CHANGED-ROOT (0)" "$outB"
expect b "final line CONVERGE-STATUS: in-sync" "CONVERGE-STATUS: in-sync" "$outB"
dirtyB="$(git -C "$A" status --porcelain)"
[ -z "$dirtyB" ] && ck b 0 "working tree untouched (engine copied nothing)" || ck b 1 "working tree untouched" "$dirtyB"
nB="$(git -C "$A" rev-list --count HEAD)"
[ "$nB" = "1" ] && ck b 0 "no new commit (still 1 — engine never commits)" || ck b 1 "no new commit" "count=$nB"
echo

# ============================ (c) diff-adjudicate on an existing wiki ============================
echo "${BLD}(c) diff-adjudicate on an existing wiki${RST}"
C="$SB/acme-charlie"; mdrun bootstrap "$C" "$P" >/dev/null 2>&1
# flip a root-file frontmatter field, then COMMIT (install refuses a dirty tree — see (d))
python3 - "$C/SCHEMA.md" <<'PY'
import re,sys
p=sys.argv[1]; t=open(p).read()
t=re.sub(r'(?m)^contract-version:\s*\d+\s*$','contract-version: 99',t)
open(p,'w').write(t)
PY
git -C "$C" add SCHEMA.md >/dev/null 2>&1
git -C "$C" commit -q -m "test: flip contract-version 1 -> 99" >/dev/null 2>&1
# refuse-by-default run
outC="$(mdrun install "$C")"; rcC=$?
[ "$rcC" -eq 0 ] && ck c 0 "adjudicated install exits 0 (refusal is not an error)" || ck c 1 "adjudicated install exits 0" "rc=$rcC"
expect c "SCHEMA.md surfaces as CHANGED-ROOT (exactly 1)" "CHANGED-ROOT (1)" "$outC"
expect c "  ! SCHEMA.md listed in the refuse class"        "! SCHEMA.md"      "$outC"
expect c "  frontmatter-field delta printed (99 -> 1)"     "contract-version: 99 → 1" "$outC"
expect c "refuse-by-default — held back"                   "root-refused: 1" "$outC"
expect c "end-state pending-adjudication"                  "CONVERGE-STATUS: pending-adjudication" "$outC"
if grep -q '^contract-version: 99' "$C/SCHEMA.md"; then ck c 0 "diverged file NOT clobbered on refusal (still 99)"; else ck c 1 "diverged file NOT clobbered on refusal" "SCHEMA.md no longer 99"; fi
dcClean="$(git -C "$C" status --porcelain)"
[ -z "$dcClean" ] && ck c 0 "refusal copies nothing (tree still clean)" || ck c 1 "refusal copies nothing" "$dcClean"
# accept-root applies the template version
outC2="$(mdrun install "$C" "" "SCHEMA.md")"; rcC2=$?
expect c "with accept-root: root-accepted: SCHEMA.md" "root-accepted: SCHEMA.md" "$outC2"
if grep -q '^contract-version: 1$' "$C/SCHEMA.md"; then ck c 0 "accepted change applied (template's version=1 now in tree)"; else ck c 1 "accepted change applied" "SCHEMA.md not reverted to template"; fi
if git -C "$C" status --porcelain | grep -q 'SCHEMA.md'; then ck c 0 "accept leaves change uncommitted (agent commits, not the engine)"; else ck c 1 "accept leaves change uncommitted" "SCHEMA.md not dirty after accept"; fi
echo

# ============================ (d) negative paths ============================
echo "${BLD}(d) negative paths${RST}"
# d1 non-empty, not a git repo -> refused
D1="$SB/nonempty-nongit"; mkdir -p "$D1"; echo hi > "$D1/f.txt"
outD1="$(mdrun install "$D1")"; rcD1=$?
if [ "$rcD1" -ne 0 ] && has "non-empty and not a git repo" "$outD1"; then ck d 0 "non-empty-non-git target refused (rc=$rcD1)"; else ck d 1 "non-empty-non-git target refused" "rc=$rcD1 :: $(printf '%s' "$outD1" | tail -2)"; fi
# d2 dirty existing wiki -> refused (status --porcelain, untracked counts)
D2="$SB/acme-delta"; mdrun bootstrap "$D2" "$P" >/dev/null 2>&1
echo "uncommitted edit" >> "$D2/SCHEMA.md"
outD2="$(mdrun install "$D2")"; rcD2=$?
if [ "$rcD2" -ne 0 ] && has "DIRTY" "$outD2"; then ck d 0 "dirty-tree existing wiki refused (rc=$rcD2)"; else ck d 1 "dirty-tree existing wiki refused" "rc=$rcD2 :: $(printf '%s' "$outD2" | tail -2)"; fi
# d3 missing target arg -> clean failure (md arg-contract catches it: rc=2, loud)
outD3="$(mdrun install)"; rcD3=$?
if [ "$rcD3" -ne 0 ] && has "requires 1 args (target)" "$outD3"; then ck d 0 "missing target arg fails clean (rc=$rcD3)"; else ck d 1 "missing target arg fails clean" "rc=$rcD3 :: $outD3"; fi
# d4 shallow-clone guard fires loud (^check)
D4S="$SB/acme-echo"; mdrun bootstrap "$D4S" "$P" >/dev/null 2>&1
D4="$SB/shallow"; git clone --depth 1 "file://$D4S" "$D4" >/dev/null 2>&1
outD4="$(mdcheck "$D4")"; rcD4=$?
if [ "$rcD4" -ne 0 ] && has "shallow clone" "$outD4"; then ck d 0 "shallow-clone guard fires loud (rc=$rcD4)"; else ck d 1 "shallow-clone guard fires loud" "rc=$rcD4 :: $(printf '%s' "$outD4" | tail -3)"; fi
echo

# ============================ (e) static block lints ============================
echo "${BLD}(e) static block lints${RST}"
elint="$(python3 "$TESTS/lint_blocks.py" "$INSTALL" 2>&1)"; erc=$?
printf '%s\n' "$elint"
[ "$erc" -eq 0 ] && ST[e]=pass || ST[e]=fail
echo

# ============================ (f) design-fix regressions (F1 slug-guard / F2 LLM_WIKI exclude / F5 symmetric delta) ============================
echo "${BLD}(f) design-fix regressions${RST}"

# F1 — slug != folder name must FAIL loud (born wiki whose dir was renamed but keeps its wiki-slug)
F1="$SB/acme-foxtrot"; mdrun bootstrap "$F1" "$P" >/dev/null 2>&1
mv "$F1" "$SB/renamed-foxtrot"
outF1="$(mdrun install "$SB/renamed-foxtrot")"; rcF1=$?
if [ "$rcF1" -ne 0 ] && has "!= folder name" "$outF1"; then ck f 0 "F1: slug != foldername refused loud (rc=$rcF1)"; else ck f 1 "F1: slug != foldername refused" "rc=$rcF1 :: $(printf '%s' "$outF1" | tail -2)"; fi

# F2 — multi-line identity: written whole at birth; LLM_WIKI.md excluded from overwrite; re-run stays in-sync, identity intact
F2="$SB/acme-golf"; PF2="$SB/params-ml"; IDF="$SB/identity-ml"
printf 'First paragraph of the identity.\n\nSecond paragraph a single-line read would silently drop.\n' > "$IDF"
cat > "$PF2" <<EOF
ROLE=private
BORN_DATE=$BORN
REFERENCE_WIKIS=$REF
IDENTITY_FILE=$IDF
FORK_REMOTE_URL=$FORKURL
GENESIS_UPSTREAM_URL=$UPURL
EOF
mdrun bootstrap "$F2" "$PF2" >/dev/null 2>&1
grep -q "Second paragraph" "$F2/LLM_WIKI.md" && ck f 0 "F2: multi-line identity written whole at birth" || ck f 1 "F2: multi-line identity written whole at birth" "second paragraph missing from LLM_WIKI.md"
outF2="$(mdrun install "$F2")"; rcF2=$?
expect f "F2: re-run in-sync (LLM_WIKI.md not a spurious CHANGED-ROOT)" "CONVERGE-STATUS: in-sync" "$outF2"
refute f "F2: LLM_WIKI.md never surfaces in any diff class"                "LLM_WIKI.md" "$outF2"
grep -q "Second paragraph" "$F2/LLM_WIKI.md" && ck f 0 "F2: multi-line identity intact after re-run" || ck f 1 "F2: multi-line identity intact after re-run" "second paragraph lost on re-run"

# F5 — symmetric delta: an instance-only frontmatter key on a root file shows 'removed by accept', never an empty delta
F5="$SB/acme-hotel"; mdrun bootstrap "$F5" "$P" >/dev/null 2>&1
python3 - "$F5/SCHEMA.md" <<'PY'
import sys
p=sys.argv[1]; t=open(p).read()
t=t.replace('contract-version: 1','contract-version: 1\nextra-instance-key: keepme',1)
open(p,'w').write(t)
PY
git -C "$F5" commit -aqm "test: add an instance-only frontmatter key to SCHEMA.md" >/dev/null 2>&1
outF5="$(mdrun install "$F5")"; rcF5=$?
expect f "F5: instance-only key surfaces as removed-by-accept (symmetric, not empty)" "extra-instance-key: keepme → (removed by accept)" "$outF5"

# F7 — a secret-looking *_FILE injection is refused (secret-egress guard)
F7="$SB/acme-india"; PF7="$SB/params-secret"; SECF="$SB/id_rsa"
printf 'PRIVATE KEY MATERIAL\n' > "$SECF"
cat > "$PF7" <<EOF
ROLE=private
IDENTITY_FILE=$SECF
EOF
outF7="$(mdrun bootstrap "$F7" "$PF7")"; rcF7=$?
if [ "$rcF7" -ne 0 ] && has "secret-looking file" "$outF7"; then ck f 0 "F7: secret-looking IDENTITY_FILE refused (rc=$rcF7)"; else ck f 1 "F7: secret-looking IDENTITY_FILE refused" "rc=$rcF7 :: $(printf '%s' "$outF7" | tail -2)"; fi
echo

# ============================ (g) clause-citation lint ============================
echo "${BLD}(g) clause-citation lint (contract C39-clause-citation)${RST}"
glint="$(python3 "$TESTS/lint_clause_cites.py" "$GENESIS" 2>&1)"; grc=$?
printf '%s\n' "$glint"
[ "$grc" -eq 0 ] && ST[g]=pass || ST[g]=fail
echo

# ============================ summary ============================
echo "${BLD}=== GATE SUMMARY  (INSTALL.md @ genesis ${HEAD:0:12}) ===${RST}"
red=0
for L in a b c d e f g; do
  if [ "${ST[$L]}" = pass ]; then printf '  %s%s: pass%s\n' "$GRN" "$L" "$RST"
  else printf '  %s%s: FAIL%s\n' "$RED" "$L" "$RST"; red=1; fi
done
if [ "$red" -eq 0 ]; then echo "${GRN}${BLD}GATE: GREEN — all automated assertions pass${RST}"; exit 0
else echo "${RED}${BLD}GATE: RED — see FAIL lines above${RST}"; exit 1; fi
