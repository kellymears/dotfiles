# dootfiles 🎺

My personal dotfiles repo.

## Installing

1. Create `./setup/secret.zsh` to house sensitive envvars.
1. From this directory: `brew bundle` to install homebrew packages.
1. Run `zsh ./setup/link.zsh` to create symbolic links in 🏡 directory.
1. Run `zsh ./setup/macos.zsh` to configure macos.

## Notes

| File              | Description                                           |
| ----------------- | ----------------------------------------------------- |
| function.zsh      | handy lil zsh functions                               |
| Brewfile          | homebrew packages. run `brew bundle dump` to rebuild. |
| brew.zsh          | Homebrew initialization                               |
| alias.zsh         | Command aliases                                       |
| .zshrc            | zsh config. 🔗                                        |
| .zsh_plugins.txt  | antidote plugin file                                  |
| setup/link.zsh    | creates symlinks                                      |
| setup/macos.zsh   | macos setup file                                      |
| env/env.zsh       | non-sensitive envvars                                 |
| env/secret.zsh    | sensitive envvars (not tracked in vcs)                |
| config/vscode     | vscode settings                                       |
| config/.ackrc     | ack config. 🔗                                        |
| config/.gitconfig | global gitconfig. 🔗                                  |
| config/.gitignore | global gitignore. 🔗                                  |
| config/.skhdrc    | skhd config. 🔗                                       |
| config/.yabairc   | yabai config. 🔗                                      |
