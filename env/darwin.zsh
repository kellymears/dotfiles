# darwin.zsh — macOS-only environment.
# Sourced from .zshrc when $OSTYPE is darwin*.

# Homebrew first: `brew shellenv` prepends /opt/homebrew/{bin,sbin} to the
# PATH that /etc/zprofile's path_helper already built, plus MANPATH etc.
source $HOME/.dotfiles/brew.zsh

typeset -U PATH path
path=($HOME/.local/bin $path)

# Same layout as Linux: ~/.config is a real directory and setup/link.zsh
# symlinks individual configs into it. XDG_CONFIG_HOME used to point at the
# repo itself, which meant every tool that *writes* config (gh's hosts.yml
# with its OAuth token, for one) wrote it into the working tree.
export CONFIG=$HOME/.dotfiles/config
export XDG_CONFIG_HOME=$HOME/.config
export RIPGREP_CONFIG_PATH=$CONFIG/.ripgreprc

# Directory containing antidote.zsh and functions/. Homebrew nests these
# under share/antidote; a git checkout has them at the root (see linux.zsh).
antidote_home=/opt/homebrew/opt/antidote/share/antidote

# OrbStack: command-line tools and integration (only if installed)
[[ -f $HOME/.orbstack/shell/init.zsh ]] && source $HOME/.orbstack/shell/init.zsh
