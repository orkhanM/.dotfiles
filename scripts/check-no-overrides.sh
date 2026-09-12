#!/usr/bin/env bash
# Refuse to commit the local override files. They're gitignored, but a
# `git add -f` or a stale index entry can still sneak one in, and they hold
# real tokens and work config.
set -euo pipefail

blocked=(
  "zsh/.config/zsh/secrets.zsh"
  "zsh/.config/zsh/work.zsh"
  "zsh/.config/zsh/local.zsh"
  "git/.gitconfig.local"
  "ssh/.ssh/config.local"
)

staged="$(git diff --cached --name-only --diff-filter=ACMR)"
found=()
while IFS= read -r f; do
  [ -n "$f" ] || continue
  for b in "${blocked[@]}"; do
    [ "$f" = "$b" ] && found+=("$f")
  done
done <<<"$staged"

if [ ${#found[@]} -gt 0 ]; then
  echo "error: these files must never be committed:" >&2
  for f in "${found[@]}"; do echo "  $f" >&2; done
  echo >&2
  echo "unstage with: git restore --staged ${found[*]}" >&2
  exit 1
fi
