eval "$(/opt/homebrew/bin/brew shellenv)"

# FNM_PATH="$HOME/Library/Application Support/fnm"
# if [ -d "$FNM_PATH" ]; then
#   export PATH="$HOME/Library/Application Support/fnm:$PATH"
#   eval "$(fnm env)"
# fi
eval "$(fnm env)"

# creates a ~/.path file with some osx specific paths if it doesn't exist
if [ ! -e $HOME/.path ]; then
  echo -n "
/opt/homebrew/bin
/usr/local/bin
/usr/local/sbin
$HOME/.local/bin
" >$HOME/.path

  for i in $(echo -n "
/usr/local/opt
/opt/homebrew/opt
"); do
    if [ -d $i ]; then
      find -L $i -type d -name '*bin' |
        grep -v '/node_modules/' |
        grep -v '/gems/' |
        sort \
          >>$HOME/.path
    fi
  done
fi

# We add all the paths from ~/.path to the PATH variable
if [ -e $HOME/.path ]; then
  for i in $(nl $HOME/.path | sort -nr | cut -f 2-); do
    if [ -e $i ]; then
      PATH=$i:$PATH
    fi
  done
fi
export PATH
