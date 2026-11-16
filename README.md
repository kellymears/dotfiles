# dootfiles 🎺

My personal dotfiles repo. macOS laptop + `cachy` (CachyOS / Arch).

## Installing (macOS)

1. Clone to `~/.dotfiles`.
1. `brew bundle --file ~/.dotfiles/Brewfile` — a deliberately small set; the
   commented blocks at the bottom list things to add back when missed.
1. `zsh ./setup/macos.zsh` to configure macOS defaults.
1. Optionally create `./env/secret.zsh` for sensitive envvars (gitignored).
1. `zsh ./setup/link.zsh` to symlink into `~` and `~/.config`. It only links
   configs for tools that are installed, so re-run it after installing more.
1. `gh auth login`, then create a signing key:
   `ssh-keygen -t ed25519 && gh ssh-key add ~/.ssh/id_ed25519.pub --type signing`
   (and `--type authentication` if it's also your push key). Delete
   `~/.gitconfig.local` and re-run `link.zsh` to turn commit signing on.

## Installing (Linux / cachy)

`zsh ./setup/linux.zsh`. Machine-specific git settings go in the untracked
`~/.gitconfig.local`, which the script writes if missing.
