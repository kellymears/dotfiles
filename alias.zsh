claude() {
  command claude --dangerously-skip-permissions "$@"
}

# Account overrides for `claude`. The default account is whatever
# CLAUDE_CONFIG_DIR says — direnv sets it to ~/.claude-carrot inside
# ~/code/git/oncarrot, and it is unset (so ~/.claude) everywhere else.
# These two ignore the current directory and pick an account outright.
claude-personal() {
  CLAUDE_CONFIG_DIR="$HOME/.claude" claude "$@"
}

claude-carrot() {
  CLAUDE_CONFIG_DIR="$HOME/.claude-carrot" claude "$@"
}

alias dc="docker compose"

alias dce="docker compose exec"

alias dcr="docker compose run --rm"

alias dcrn="docker compose run --rm --no-deps"

alias fastfetch="fastfetch -c \$CONFIG/fastfetch/config.jsonc"

j() {
  printf '\033[33m'
  cat <<'EOF'

    ╭──────────────────────────────────╮
    │  ⚡ j is dead, long live z ⚡   │
    ╰──────────────────────────────────╯
        \
         \    ╭━━━╮
              ┃ z ┃  ← this one now
              ╰━━━╯
               / \
              /   \

EOF
  printf '\033[0m'
  z "$@"
}
