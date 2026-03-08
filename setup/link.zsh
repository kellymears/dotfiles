#!/usr/bin/env zsh
set -euo pipefail

[[ -z "$HOME" ]] && { echo "ERROR: \$HOME is not set"; exit 1 }

dotfiles_dir="$HOME/.dotfiles"
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
    return 1
  fi

  ln -sf "$src" "$dest"
  echo "LINK: $dest -> $src"
}

link "$dotfiles_dir/.zshrc"                         "$HOME/.zshrc"
link "$dotfiles_dir/config/.gitconfig"              "$HOME/.gitconfig"
link "$dotfiles_dir/config/gitignore_global"         "$HOME/.gitignore"
link "$dotfiles_dir/config/.hushlogin"              "$HOME/.hushlogin"

if [[ -d "$vscode_user_dir" ]]; then
  link "$dotfiles_dir/config/vscode/settings.json"    "$vscode_user_dir/settings.json"
  link "$dotfiles_dir/config/vscode/keybindings.json" "$vscode_user_dir/keybindings.json"
else
  echo "SKIP: VS Code user directory not found"
fi
