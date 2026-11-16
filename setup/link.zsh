#!/usr/bin/env zsh
# link.zsh — macOS symlinks. Safe to re-run: install something new, run this
# again, and its config gets linked.
set -euo pipefail

[[ -z "$HOME" ]] && { echo "ERROR: \$HOME is not set"; exit 1 }

dotfiles_dir="$HOME/.dotfiles"
config_src="$dotfiles_dir/config"
config_dest="$HOME/.config"
vscode_user_dir="$HOME/Library/Application Support/Code/User"

link() {
  local src="$1"
  local dest="$2"

  if [[ ! -e "$src" ]]; then
    echo "SKIP: source does not exist: $src"
    return 0
  fi

  if [[ -e "$dest" && ! -L "$dest" ]]; then
    echo "REFUSE: $dest exists and is not a symlink — remove it manually first"
    return 0
  fi

  ln -sfn "$src" "$dest"
  echo "LINK: $dest -> $src"
}

# ── home ─────────────────────────────────────────────────────────────
link "$dotfiles_dir/.zshrc"              "$HOME/.zshrc"
link "$dotfiles_dir/.zshenv"             "$HOME/.zshenv"
link "$config_src/.gitconfig"            "$HOME/.gitconfig"
link "$config_src/gitignore_global"      "$HOME/.gitignore"
link "$config_src/.hushlogin"            "$HOME/.hushlogin"

source "$dotfiles_dir/setup/gitconfig-local.zsh"
write_gitconfig_local

# ── ~/.config ────────────────────────────────────────────────────────
# A real directory, same as Linux. Only configs for tools that are actually
# installed get linked, so the Brewfile stays the single list of what's on
# this machine. Format: <config dir>:<command that must exist>.
mkdir -p "$config_dest"

typeset -a tools=(
  bat:bat
  mise:mise
  atuin:atuin
  btop:btop
  glow:glow
  lazygit:lazygit
  nvim:nvim
  tmux:tmux
  yazi:yazi
  k9s:k9s
)

for entry in $tools; do
  name=${entry%%:*}
  cmd=${entry#*:}
  if (( $+commands[$cmd] )); then
    link "$config_src/$name" "$config_dest/$name"
  else
    echo "SKIP: $name ($cmd not installed)"
  fi
done

# gh: link the config file only. gh writes hosts.yml (with the OAuth token)
# next to it, so the directory itself must not live in the repo.
mkdir -p "$config_dest/gh"
link "$config_src/gh/config.yml" "$config_dest/gh/config.yml"

# Ghostty reads ~/.config/ghostty/config even when launched from the Dock.
# `shaders` sits next to it because shared.conf resolves paths relative to
# the config's own directory. The directory stays real so Ghostty can drop
# its own files in it.
mkdir -p "$config_dest/ghostty"
link "$config_src/ghostty/config"      "$config_dest/ghostty/config"
link "$config_src/ghostty/shared.conf" "$config_dest/ghostty/shared.conf"
link "$config_src/ghostty/shaders"     "$config_dest/ghostty/shaders"

# ── VS Code ──────────────────────────────────────────────────────────
# Created up front so the links land before VS Code's first launch.
mkdir -p "$vscode_user_dir"
link "$config_src/vscode/settings.json"    "$vscode_user_dir/settings.json"
link "$config_src/vscode/keybindings.json" "$vscode_user_dir/keybindings.json"

echo
echo "Done. REFUSE lines are pre-existing files — move them aside and re-run."
