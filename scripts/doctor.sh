#!/usr/bin/env bash
# What `make doctor` runs. Reports installed tools, then checks every stow
# package is actually stowed from this repo. Exits non-zero on a problem.
# Runs standalone too: ./scripts/doctor.sh
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# name and the command that prints its version. curated, not exhaustive:
# a MISSING here is reported but doesn't fail the run, since skipping a tool
# on a given machine is a normal thing to do.
TOOLS=(
  "nvim:nvim --version | head -1"
  "go:go version"
  "rustc:rustc --version"
  "fnm:fnm --version"
  "node:node --version"
  "kitty:kitty --version 2>&1"
  "wezterm:wezterm --version 2>&1"
  "kubectl:kubectl version --client 2>/dev/null | head -1"
  "helm:helm version --short 2>/dev/null"
  "bun:bun --version"
  "lazygit:lazygit --version 2>&1 | head -1"
  "uv:uv --version"
  "ptpython:ptpython --version 2>&1"
)

echo "=== Installed Tools ==="
for entry in "${TOOLS[@]}"; do
  name="${entry%%:*}"
  cmd="${entry#*:}"
  if command -v "$name" >/dev/null 2>&1; then
    printf "  %-12s %s\n" "$name:" "$(eval "$cmd")"
  else
    printf "  %-12s %s\n" "$name:" "MISSING"
  fi
done

echo
echo "=== Symlinks ==="

# Ask stow, don't reimplement it. A dry run prints nothing when a package is
# already correctly stowed and prints what it would do otherwise, so silence
# is the pass. That covers not-stowed, half-stowed, links into a different
# repo, and anything in the way -- and it treats stow's folded and unfolded
# layouts as equally correct, because stow does.
#
# Nothing below parses stow's wording: 2.3.1 and 2.4.1 phrase conflicts
# differently, which is what broke the backup logic in stow.mk.
#
# The gap: removing a file from a package leaves a stale link that a dry run
# has no reason to mention. `make restow` clears those.

# parsed from stow.mk rather than duplicated, so the two lists can't drift
EXCLUDES=$(sed -n 's/^STOW_EXCLUDES[[:space:]]*:\{0,1\}=[[:space:]]*//p' "$REPO/mk/stow.mk" 2>/dev/null)
EXCLUDES=${EXCLUDES:-mk scripts tart}

packages=()
for dir in "$REPO"/*/; do
  pkg=$(basename "$dir")
  case " $EXCLUDES " in *" $pkg "*) continue ;; esac
  packages+=("$pkg")
done

if [ ${#packages[@]} -eq 0 ]; then
  echo "  no packages found in $REPO"
  exit 1
fi

fail=0
for pkg in "${packages[@]}"; do
  out=$(stow -n -v -t "$HOME" -d "$REPO" "$pkg" 2>&1 | grep -v 'simulation mode')
  if [ -z "$out" ]; then
    printf "  %-10s OK\n" "$pkg"
  else
    printf "  %-10s PROBLEM\n" "$pkg"
    echo "$out" | sed 's/^/      /'
    fail=1
  fi
done

echo
if [ "$fail" -eq 0 ]; then
  echo "  all packages stowed from $REPO"
else
  echo "  run 'make stow' (or 'make restow' after deleting package files)"
fi
exit "$fail"
