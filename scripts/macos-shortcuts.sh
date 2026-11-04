#!/usr/bin/env bash
# What `make macos-shortcuts` runs. Keyboard shortcuts via `defaults`, since
# the prefs plists get rewritten on save and can't be stowed as symlinks.
# Only touches the entries below; safe to rerun.
set -euo pipefail

[ "$(uname)" = Darwin ] || exit 0

# app shortcuts, all apps: Window menu tiling
# @ = cmd, $ = shift. \033 separates menu path segments
defaults write -g NSUserKeyEquivalents -dict-add \
  $'\033Window\033Center' '@$↓' \
  $'\033Window\033Fill' '@$↑' \
  $'\033Window\033Move & Resize\033Left' '@$←' \
  $'\033Window\033Move & Resize\033Right' '@$→'

# lists the domain in System Settings > App Shortcuts
if ! defaults read com.apple.universalaccess com.apple.custommenu.apps 2>/dev/null | grep -q NSGlobalDomain; then
  defaults write com.apple.universalaccess com.apple.custommenu.apps -array-add NSGlobalDomain
fi

# system shortcuts. params: char (65535 = none), keycode, modifier mask
hotkey() {
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$1" \
    "<dict><key>enabled</key><true/><key>value</key><dict><key>type</key><string>standard</string><key>parameters</key><array><integer>$2</integer><integer>$3</integer><integer>$4</integer></array></dict></dict>"
}
hotkey 32  65535 126 11534336 # mission control: cmd+up
hotkey 34  65535 126 11665408 #   shift variant
hotkey 33  65535 125 11534336 # application windows: cmd+down
hotkey 35  65535 125 11665408 #   shift variant
hotkey 118 65535 18  262144   # desktop 1: ctrl+1
hotkey 119 65535 19  262144   # desktop 2: ctrl+2

# apply without logging out. not guaranteed, a re-login always works
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true
