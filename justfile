# Wiki setup — just | just --list
# Fork note: extend `setup` with your deploy effects (effects/*/DEPLOY.md md-run
# docs) as the wiki grows them.

set shell := ["bash", "-euo", "pipefail", "-c"]

root := justfile_directory()

# Bootstrap: address layer → doctor → git hooks
setup: repos-link wiki-repos-check-soft lefthook-install

# Materialize the $CCC_LLM_WIKI_REPOS_ROOT/<slug> address layer (health/repos-root.md)
repos-link:
    md run '{"file":"health/repos-root.md","name":"link"}'

# Run the llm-wiki repos-root doctor
wiki-repos-check:
    @md run '{"file":"health/repos-root.md","name":"check"}'

# Non-blocking doctor for the setup chain (fresh-machine env may lag)
[private]
wiki-repos-check-soft:
    @md run '{"file":"health/repos-root.md","name":"check"}' || echo "wiki-repos-check: issues found (non-blocking in setup) — run 'just wiki-repos-check' for detail" >&2

# The full lint gate, same as pre-push
check:
    md check
    md run '{"file":"health/domain-home-unique.md","name":"check"}'
    md run '{"file":"health/wikilink-residue-classes.md","name":"check"}'

[private]
lefthook-install:
    @command -v lefthook >/dev/null 2>&1 && lefthook install --force 2>/dev/null || echo "WARN: lefthook not on PATH, hooks not installed" >&2
