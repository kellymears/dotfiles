# darwin.zsh — macOS-only environment.
# Sourced from .zshrc when $OSTYPE is darwin*.

typeset -U PATH path
export path=(
  /Library/Apple/usr/bin
  /System/Cryptexes/App/usr/bin
  /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin
  /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin
  /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin
  /Library/Frameworks/Mono.framework/Versions/Current/Commands

  /opt/homebrew/opt/rustup/bin
  /opt/homebrew/bin
  /opt/homebrew/sbin
  /usr/local/MacGPG2/bin

  /usr/local/bin
  /usr/bin
  /bin
  /usr/sbin
  /sbin

  $HOME/.local/bin
  $HOME/.cargo/bin
)

# Config lives in the repo and XDG_CONFIG_HOME points at it directly, so
# nothing needs symlinking. This works on macOS because every consumer here
# is launched from a shell. Linux can't do this — see env/linux.zsh.
export CONFIG=$HOME/.dotfiles/config
export XDG_CONFIG_HOME=$CONFIG
export RIPGREP_CONFIG_PATH=$CONFIG/.ripgreprc

# Directory containing antidote.zsh and functions/. Homebrew nests these
# under share/antidote; a git checkout has them at the root (see linux.zsh).
antidote_home=/opt/homebrew/opt/antidote/share/antidote

source $HOME/.dotfiles/brew.zsh

# OrbStack: command-line tools and integration
source $HOME/.orbstack/shell/init.zsh 2>/dev/null || :
