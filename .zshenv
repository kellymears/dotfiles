# .zshenv — read by EVERY zsh, including non-interactive ones.
#
# `ssh host 'some-command'` runs a non-interactive shell, which never sources
# .zshrc, so anything installed under ~/.local/bin is invisible to it. That
# breaks remote automation against this machine.
#
# Deliberately minimal. The full PATH is still built per-OS in
# env/darwin.zsh and env/linux.zsh for interactive shells — macOS runs
# path_helper from /etc/zprofile *after* this file and reorders PATH, so
# building the real PATH here would not survive anyway.

typeset -U path
path=($HOME/.local/bin $HOME/.cargo/bin $path)
export PATH
