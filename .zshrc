source $HOME/.dotfiles/env/env.zsh
source $HOME/.dotfiles/env/secret.zsh

typeset -U PATH path
path=(
  /Library/Apple/usr/bin
  /System/Cryptexes/App/usr/bin
  /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin
  /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin
  /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin
  /Library/Frameworks/Mono.framework/Versions/Current/Commands

  /opt/homebrew/bin
  /opt/homebrew/sbin
  /usr/local/MacGPG2/bin

  /usr/local/bin
  /usr/bin
  /bin
  /usr/sbin
  /sbin
  $HOME/.local/bin
  $HOME/.config/.cargo/bin
  $HOME/.config/.composer/vendor/bin
  $HOME/.config/.volta/bin
)
export PATH

antidote_dir=$(brew --prefix)/opt/antidote/
zsh_plugins=$HOME/.dotfiles/.zsh_plugins

source $antidote_dir/share/antidote/antidote.zsh

# Ensure the .zsh_plugins.txt file exists so you can add plugins.
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt

# Lazy-load antidote from its functions directory.
fpath=($antidote_dir/share/antidote/functions $fpath)
autoload -Uz antidote

# Generate a new static file whenever .zsh_plugins.txt is updated.
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi

# Source your static plugins file.
source ${zsh_plugins}.zsh

autoload -Uz promptinit && promptinit && prompt pure

source $HOME/.dotfiles/brew.zsh
source $HOME/.dotfiles/alias.zsh
source $HOME/.dotfiles/functions.zsh
