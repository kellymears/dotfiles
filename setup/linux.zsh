#!/usr/bin/env zsh
set -euo pipefail

[[ -z "$HOME" ]] && { echo "ERROR: \$HOME is not set"; exit 1 }

dotfiles_dir="$HOME/.dotfiles"
config_src="$dotfiles_dir/config"
config_dest="$HOME/.config"
vscode_user_dir="$config_dest/Code/User"

# macOS-only: either the path has no Linux analogue or the tool isn't here.
# ghostty and vscode are handled explicitly below rather than linked as whole
# directories — neither tool reads a directory named after itself.
skip=(homebrew swiftpm configstore intelephense vscode ghostty)

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

# antidote isn't in the Arch repos and we don't want an AUR dependency for
# something this small. env/linux.zsh expects it here.
if [[ ! -d "$HOME/.antidote" ]]; then
  echo "CLONE: antidote -> ~/.antidote"
  git clone --quiet --depth 1 https://github.com/mattmc3/antidote.git "$HOME/.antidote"
fi

mkdir -p "$config_dest"

# Home-level dotfiles. Unlike macOS, XDG_CONFIG_HOME is left pointing at the
# real ~/.config (see env/linux.zsh), so everything below is a genuine symlink
# rather than a redirect.
link "$dotfiles_dir/.zshrc"          "$HOME/.zshrc"
link "$dotfiles_dir/.zshenv"         "$HOME/.zshenv"
link "$config_src/.gitconfig"        "$HOME/.gitconfig"
link "$config_src/gitignore_global"  "$HOME/.gitignore"

# Every config directory except the macOS-only ones.
for src in "$config_src"/*(N/); do
  name="${src:t}"
  if (( ${skip[(Ie)$name]} )); then
    echo "SKIP: $name (macOS-only)"
    continue
  fi
  link "$src" "$config_dest/$name"
done

link "$config_src/starship.toml" "$config_dest/starship.toml"

# Ghostty: linked file-by-file rather than as a directory, for two reasons.
# Ghostty only ever reads a file named `config`, so the Linux entry point is
# linked under that name; and ~/.config/ghostty must stay a real directory
# because noctalia writes generated themes into themes/, which is machine
# state we do not track.
mkdir -p "$config_dest/ghostty"
link "$config_src/ghostty/linux.conf"  "$config_dest/ghostty/config"
link "$config_src/ghostty/shared.conf" "$config_dest/ghostty/shared.conf"
link "$config_src/ghostty/shaders"     "$config_dest/ghostty/shaders"

# VS Code: same two files as macOS, but under ~/.config/Code/User rather than
# Library/Application Support. The directory is created up front so the links
# can land before VS Code's first launch.
mkdir -p "$vscode_user_dir"
link "$config_src/vscode/settings.json"    "$vscode_user_dir/settings.json"
link "$config_src/vscode/keybindings.json" "$vscode_user_dir/keybindings.json"

echo
echo "Done. Any REFUSE lines above are pre-existing configs (CachyOS ships its"
echo "own btop/hypr/kitty). Remove those files deliberately, then re-run."
