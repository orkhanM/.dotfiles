alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$HOME/.local/share/fnm:$PATH"
  eval "$(fnm env --use-on-cd --shell zsh)"
fi
