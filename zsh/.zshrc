# Detect platform
platform=$(uname)

# our platform-specific configurations
if [[ "$platform" == "Darwin" ]]; then
  if [ -f $HOME/.config/zsh/osx.zsh ]; then
    source $HOME/.config/zsh/osx.zsh
  fi
elif [[ "$platform" == "Linux" ]]; then
  if [ -f $HOME/.config/zsh/linux.zsh ]; then
    source $HOME/.config/zsh/linux.zsh
  fi
fi

# secrets
if [ -f $HOME/.config/zsh/secrets.zsh ]; then
  source $HOME/.config/zsh/secrets.zsh
fi

# machine-specific bits (PATH entries for ad-hoc installs, etc.)
if [ -f $HOME/.config/zsh/local.zsh ]; then
  source $HOME/.config/zsh/local.zsh
fi

# We get the username
USERNAME="${USER:-${USERNAME:-$(whoami)}}"

# PATH overrides. Only entries for tools this repo actually installs live
# here; anything installed ad hoc belongs in ~/.config/zsh/local.zsh.
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/go/bin:$PATH:/usr/local/go/bin
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

export EDITOR=nvim

### oh-my zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="dpoggi"

# zsh-autosuggestions is installed by `make tools` but not enabled here
plugins=(
  argocd
  gh
  fzf
  git
  direnv
  kubectl
  kubectx
  kube-ps1
  zsh-syntax-highlighting
)
DISABLE_AUTO_TITLE="true"
source $ZSH/oh-my-zsh.sh

# vim motions :party: (after oh-my-zsh, which otherwise resets the keymap)
bindkey -v
# keep handy history keys working in vi insert mode
bindkey '^P' up-line-or-history
bindkey '^N' down-line-or-history

# Alias definitions
alias vim="nvim"
alias vimdiff="nvim -d"
alias ls='ls --color=auto -G'
alias grep='grep --color'

RPROMPT='$(kube_ps1)'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Direnv log format (don't display direnv exports in every command)
export DIRENV_LOG_FORMAT=""

# bun completions
[ -s "$HOME/.oh-my-zsh/completions/_bun" ] && source "$HOME/.oh-my-zsh/completions/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Claude code in tmux breaks w/ fancy tui mode
export CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1

# for tools that only ship a .bash completion. no compinit call here, oh-my-zsh
# already did it above.
autoload -Uz bashcompinit && bashcompinit

# after bashcompinit on purpose: work.zsh sources bash completions, which call
# compdef, and that doesn't exist until oh-my-zsh has run compinit above.
if [ -f $HOME/.config/zsh/work.zsh ]; then
  source $HOME/.config/zsh/work.zsh
fi

# appdirs looks in ~/Library/Application Support on macOS, point it at ~/.config
export PTPYTHON_CONFIG_HOME="$HOME/.config/ptpython"
