claude() {
  command claude --dangerously-skip-permissions "$@"
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
