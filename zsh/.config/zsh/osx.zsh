eval "$(/opt/homebrew/bin/brew shellenv)"

# FNM_PATH="$HOME/Library/Application Support/fnm"
# if [ -d "$FNM_PATH" ]; then
#   export PATH="$HOME/Library/Application Support/fnm:$PATH"
#   eval "$(fnm env)"
# fi
eval "$(fnm env)"

brew_bins=(
  /opt/homebrew/opt/*/libexec/gnubin(N)
  /opt/homebrew/opt/*/bin(N)
  /opt/homebrew/opt/*/sbin(N)
)
if ((${#brew_bins})); then
  PATH="${(j.:.)brew_bins}:$PATH"
fi
unset brew_bins

export PATH
