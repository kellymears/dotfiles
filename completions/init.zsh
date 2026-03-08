# completions/init.zsh — zsh completion engine
# Sources: Homebrew site-functions, zsh-completions (via antidote), and custom config

# ── fpath setup ──────────────────────────────────────────────────────
# Homebrew completions must be on fpath before compinit scans them
fpath=(/opt/homebrew/share/zsh/site-functions $fpath)

# ── compinit with daily caching ──────────────────────────────────────
autoload -Uz compinit

# Regenerate dump only when stale (>24h) — keeps shell startup fast
local zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ -n "$zcompdump"(#qN.mh+24) ]]; then
  compinit -d "$zcompdump"
else
  compinit -C -d "$zcompdump"
fi

# ── zstyle: menu selection ───────────────────────────────────────────
zstyle ':completion:*' menu select
zstyle ':completion:*' select-prompt '%SScrolling: %p%s'

# ── zstyle: matching ─────────────────────────────────────────────────
# Case-insensitive, partial-word, then substring matching
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

# ── zstyle: grouping and formatting ─────────────────────────────────
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}── %d ──%f'
zstyle ':completion:*:corrections' format '%F{green}── %d (errors: %e) ──%f'
zstyle ':completion:*:messages' format '%F{purple}── %d ──%f'
zstyle ':completion:*:warnings' format '%F{red}── no matches found ──%f'
zstyle ':completion:*' verbose yes

# ── zstyle: caching ──────────────────────────────────────────────────
zstyle ':completion:*' use-cache on
zstyle ':completion::complete:*' cache-path "${ZDOTDIR:-$HOME}/.zcompcache"

# ── zstyle: file/directory completions ───────────────────────────────
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:*:*:*:default' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' special-dirs true

# ── zstyle: ssh/scp host completion ──────────────────────────────────
zstyle ':completion:*:(ssh|scp|rsync):*' hosts \
  ${(f)"$([ -r "$HOME/.ssh/config" ] && sed -n 's/^Host[[:space:]]\+\([^*?]*\)$/\1/p' "$HOME/.ssh/config")"}
zstyle ':completion:*:(ssh|scp|rsync):*:hosts' ignored-patterns \
  'ip6-*' 'localhost*' 'loopback'

# ── zstyle: process completion (kill/killall) ────────────────────────
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
zstyle ':completion:*:*:killall:*' menu yes select

# ── zstyle: git ──────────────────────────────────────────────────────
zstyle ':completion:*:*:git:*' script /opt/homebrew/share/zsh/site-functions/_git
zstyle ':completion:*:git-checkout:*' sort false

# ── AWS CLI completer ────────────────────────────────────────────────
if (( $+commands[aws_completer] )); then
  autoload -Uz bashcompinit && bashcompinit
  complete -C aws_completer aws
fi
