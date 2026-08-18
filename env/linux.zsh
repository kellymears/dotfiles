# linux.zsh — Linux-only environment.
# Sourced from .zshrc when $OSTYPE is linux*.

typeset -U PATH path
export path=(
  /usr/local/bin
  /usr/local/sbin
  /usr/bin
  /bin
  /usr/sbin
  /sbin

  $HOME/.local/bin
  $HOME/.cargo/bin
)

# Unlike macOS, XDG_CONFIG_HOME is NOT redirected into the repo here.
# Hyprland, the portals, and the rest of the graphical session are started
# by uwsm before any shell runs, so they never see variables exported from
# .zshrc. Instead ~/.config is real and setup/linux.zsh symlinks into it.
export CONFIG=$HOME/.dotfiles/config
export XDG_CONFIG_HOME=$HOME/.config
export RIPGREP_CONFIG_PATH=$CONFIG/.ripgreprc

# antidote isn't packaged in the Arch repos; setup/linux.zsh git-clones it
# here. A checkout keeps antidote.zsh and functions/ at the repo root, unlike
# Homebrew's share/antidote layout.
antidote_home=$HOME/.antidote

# env.zsh points EDITOR and VISUAL at `code --wait`, which is right when
# sitting at the machine but fails over a bare ssh session — there is no
# display to open a window on, so `git commit` would error out instead of
# prompting. Fall back to nvim when no graphical session is attached. Both
# variables have to change: git prefers VISUAL over EDITOR, so leaving VISUAL
# pointed at code would still send every commit message to a window that
# cannot open.
if [[ -z "${WAYLAND_DISPLAY:-}${DISPLAY:-}" ]]; then
  export EDITOR=nvim
  export VISUAL=$EDITOR
fi
