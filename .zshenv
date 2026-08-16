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

# On the Linux dev box, 1Password holds both the personal (tinypixel) and work
# (team-carrot) accounts, and tinypixel was added first — so it is op's default.
# oncarrot/account-manager-ui's scripts/setup-env.sh runs `op inject` with no
# --account, which then resolves against the wrong account and fails with
# "Eng-Contractors isn't a vault in this account". account-manager's Makefile
# passes --account explicitly, so only some projects break, which makes it
# look like a repo bug rather than machine state.
#
# Set here rather than in env/linux.zsh so non-interactive shells get it too —
# `ssh cachy 'make'` never sources .zshrc.
#
# Personal vaults are still reachable with --account tinypixel.1password.com.
[[ "$OSTYPE" == linux* ]] && export OP_ACCOUNT=team-carrot.1password.com
