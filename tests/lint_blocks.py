#!/usr/bin/env python3
"""Static lints over INSTALL.md's executable task blocks (assertion e).

e1 — no bare `git ` command: every git invocation must be `git -C <dir>`. Anchored on
     COMMAND position, not substring, so legit substrings pass: echo strings like
     "...not a git repo" and the hook string `gitleaks git --staged`.
e2 — no env var referenced outside the declared md-<task>-env contract: the only declared
     env var is `md-check-env: CCC_LLM_WIKI_PATH` (^check). Every other UPPERCASE $VAR must
     be locally assigned (or PATH/HOME baseline).

Both detectors are self-tested against known-bad and known-good synthetic lines first, so a
green result cannot be a vacuous no-match. Exit 0 = all pass; 1 = a lint or self-test failed.
"""
import re
import sys

INSTALL = sys.argv[1]
TASKS = ("check", "install", "bootstrap")
# md-<task>-env contract: the ONLY declared env var, and only for ^check.
DECLARED_ENV = {"check": {"CCC_LLM_WIKI_PATH"}, "install": set(), "bootstrap": set()}
ENV_BASELINE = {"PATH", "HOME"}  # scrubbed-env floor (env -i PATH=.. HOME=..)


def extract_blocks(text):
    """Return {task_id: block_body} for each ^<id> anchored fenced block."""
    lines = text.splitlines()
    blocks = []  # (end_fence_lineno, body)
    i = 0
    while i < len(lines):
        if re.match(r"^`{3,}", lines[i]):
            j = i + 1
            while j < len(lines) and not re.match(r"^`{3,}\s*$", lines[j]):
                j += 1
            blocks.append((j, "\n".join(lines[i + 1:j])))
            i = j + 1
        else:
            i += 1
    out = {}
    for tid in TASKS:
        anchor = next((n for n, ln in enumerate(lines) if ln.strip() == "^" + tid), None)
        if anchor is None:
            continue
        cand = [(end, body) for end, body in blocks if end < anchor]
        if cand:
            out[tid] = max(cand, key=lambda t: t[0])[1]
    return out


# ---- e1: bare-git detector (command-position anchored) --------------------
_CMD_TAIL = re.compile(r"(?:[;|&(){}`]|\$\(|&&|\|\||\b(?:then|do|else))\s*$")


def bare_git_hits(block):
    hits = []
    for lineno, line in enumerate(block.splitlines(), 1):
        for m in re.finditer(r"\bgit\b", line):
            if re.match(r"\s+-C\b", line[m.end():]):
                continue  # `git -C <dir>` — the mandated form
            pre = line[:m.start()]
            if pre.strip() == "" or _CMD_TAIL.search(pre.rstrip()):
                hits.append((lineno, line.strip()))
    return hits


# ---- e2: undeclared-env detector (UPPERCASE $VAR namespace) ---------------
_REF = re.compile(r"\$\{?([A-Z][A-Z0-9_]*)\b")
# re.M so `^` anchors every line-start assignment (e.g. a line-leading `ROOT_CLASS=`),
# not just the block's first char.
_ASSIGN = re.compile(r"(?:^|[;|&(){}`]|&&|\|\||\bdo\b|\bthen\b)\s*([A-Za-z_]\w*)=", re.M)
_FOR = re.compile(r"\bfor\s+([A-Za-z_]\w*)\s+in\b")
_READ = re.compile(r"\bread\b((?:\s+-\w+)*)\s+([A-Za-z_][\w\s]*?)(?:;|<|$)", re.M)


def env_violations(tid, block):
    refs = set(_REF.findall(block))
    assigned = set(_ASSIGN.findall(block)) | set(_FOR.findall(block))
    for _flags, names in _READ.findall(block):
        assigned |= set(names.split())
    env_refs = {v for v in refs if v not in assigned and v not in ENV_BASELINE}
    return sorted(env_refs - DECLARED_ENV.get(tid, set()))


# ---- self-tests: prove the detectors are not vacuous ----------------------
def self_tests():
    fails = []
    # e1 MUST fire on real bare-git commands
    for bad in ["git status", "foo | git push", "x=1\ngit add -A", "$(git rev-parse HEAD)"]:
        if not bare_git_hits(bad):
            fails.append(f"e1 self-test: missed bare-git in {bad!r}")
    # e1 MUST NOT fire on legit forms
    for good in [
        'git -C "$target" init',
        'echo "target non-empty and not a git repo"',
        "run: gitleaks git --staged --pre-commit",
        'genesis="$(git -C . rev-parse --show-toplevel)"',
    ]:
        if bare_git_hits(good):
            fails.append(f"e1 self-test: false-positive on {good!r}")
    # e2 MUST fire on an undeclared env ref
    if not env_violations("install", 'echo "$SECRET_TOKEN"'):
        fails.append("e2 self-test: missed undeclared env $SECRET_TOKEN")
    # e2 MUST NOT fire on locally-assigned or baseline vars
    if env_violations("install", 'ROOT_CLASS=" x "\nprintf "%s" "$ROOT_CLASS"'):
        fails.append("e2 self-test: false-positive on locally-assigned ROOT_CLASS")
    # assignment NOT on the first line — guards the re.M anchor (line-leading assign)
    if env_violations("install", 'x=1\nROOT_CLASS=" y "\nprintf "%s" "$ROOT_CLASS"'):
        fails.append("e2 self-test: false-positive on line-leading ROOT_CLASS (re.M anchor)")
    if env_violations("install", 'echo "$HOME"'):
        fails.append("e2 self-test: false-positive on baseline $HOME")
    # e2 allowed-set MUST matter: CCC_LLM_WIKI_PATH is a violation for install, not for check
    if not env_violations("install", 'cd "$CCC_LLM_WIKI_PATH"'):
        fails.append("e2 self-test: CCC_LLM_WIKI_PATH not flagged for install (allowed-set inert)")
    if env_violations("check", 'cd "$CCC_LLM_WIKI_PATH"'):
        fails.append("e2 self-test: CCC_LLM_WIKI_PATH wrongly flagged for check")
    return fails


def main():
    text = open(INSTALL, encoding="utf-8").read()
    blocks = extract_blocks(text)
    missing = [t for t in TASKS if t not in blocks]
    if missing:
        print(f"E: FAIL — could not extract task block(s): {missing}")
        return 1

    st = self_tests()
    if st:
        for f in st:
            print("  detector self-test FAIL: " + f)
        print("E: FAIL — detector self-tests failed (results untrustworthy)")
        return 1
    print("  detector self-tests: pass (e1/e2 fire on bad, silent on good)")

    ok = True
    # e1
    e1_hits = []
    for tid in TASKS:
        for lineno, ln in bare_git_hits(blocks[tid]):
            e1_hits.append(f"^{tid} L{lineno}: {ln}")
    if e1_hits:
        ok = False
        print("  E1: FAIL — bare `git` (non `git -C`) at command position:")
        for h in e1_hits:
            print("      " + h)
    else:
        print("  E1: pass — every git invocation is `git -C <dir>` (all 3 blocks)")
    # e2
    e2_bad = {}
    for tid in TASKS:
        v = env_violations(tid, blocks[tid])
        if v:
            e2_bad[tid] = v
    if e2_bad:
        ok = False
        print("  E2: FAIL — undeclared env var(s) referenced:")
        for tid, v in e2_bad.items():
            print(f"      ^{tid}: {v}")
    else:
        print("  E2: pass — only declared env var is ^check's CCC_LLM_WIKI_PATH; no undeclared env refs")

    print("E: pass" if ok else "E: FAIL")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
