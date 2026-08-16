source $HOME/.dotfiles/env/env.zsh
# Not in the repo — absent on a freshly cloned machine.
[[ -f $HOME/.dotfiles/env/secret.zsh ]] && source $HOME/.dotfiles/env/secret.zsh

# ── platform ─────────────────────────────────────────────────────────
# PATH, XDG layout, package-manager glue, and the antidote location all
# differ per OS. Each file is responsible for setting $antidote_dir.
case "$OSTYPE" in
  darwin*) source $HOME/.dotfiles/env/darwin.zsh ;;
  linux*)  source $HOME/.dotfiles/env/linux.zsh  ;;
esac

zsh_plugins=$HOME/.dotfiles/.zsh_plugins

source $antidote_home/antidote.zsh

# Ensure the .zsh_plugins.txt file exists so you can add plugins.
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt

# Lazy-load antidote from its functions directory.
fpath=($antidote_home/functions $fpath)
autoload -Uz antidote

# Generate a new static file whenever .zsh_plugins.txt is updated.
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi

# Source your static plugins file.
source ${zsh_plugins}.zsh
autoload -U promptinit; promptinit
prompt pure

# Ghostty's shell integration inserts OSC 133 marks into PS1 that break
# Pure's prompt_newline pattern matching during async re-renders,
# causing the preprompt (directory) to duplicate. Strip marks before
# Pure processes the prompt.
if [[ -n "$GHOSTTY_RESOURCES_DIR" ]] && (( ! $+functions[_original_prompt_pure_preprompt_render] )); then
  functions[_original_prompt_pure_preprompt_render]=$functions[prompt_pure_preprompt_render]
  prompt_pure_preprompt_render() {
    PROMPT=${PROMPT//$'%{\e]133;A;cl=line\a%}'}
    PROMPT=${PROMPT//$'%{\e]133;A;k=s\a%}'}
    PROMPT=${PROMPT//$'%{\e]133;B\a%}'}
    _original_prompt_pure_preprompt_render "$@"
  }
fi

source $HOME/.dotfiles/alias.zsh;
source $HOME/.dotfiles/functions.zsh;
source $HOME/.dotfiles/completions/init.zsh;

# ── tool runtime manager ─────────────────────────────────────────────
(( $+commands[mise] )) && eval "$(mise activate zsh)"

# ── RPROMPT ──────────────────────────────────────────────────────────
# Cache node version on chpwd (avoids shelling out on every precmd)
_cached_node_version=""
_update_node_version() {
  if (( $+commands[node] )); then
    _cached_node_version="$(node -v)"
  else
    _cached_node_version=""
  fi
}
add-zsh-hook chpwd _update_node_version
_update_node_version

# ── fzf ──────────────────────────────────────────────────────────────
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
(( $+commands[fzf] )) && source <(fzf --zsh)

# ── atuin (after fzf so atuin claims ctrl-r) ─────────────────────────
(( $+commands[atuin] )) && eval "$(atuin init zsh)"

# ── zoxide ───────────────────────────────────────────────────────────
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# ── word movement ────────────────────────────────────────────────────
# zsh picks vi keybindings when $VISUAL/$EDITOR contains "vi" — and "nvim"
# does — so `main` is aliased to `viins`. In vi mode a bare ESC leaves
# insert mode, and Alt+<key> is transmitted as an ESC-prefixed sequence.
# Without bindings for these, zsh eats the ESC, drops to vicmd (Pure flips
# ❯ to ❮) and discards the rest. Binding them keeps insert mode intact.
#
# Only visible on Linux: Ghostty's macos-option-as-alt defaults to false, so
# on macOS Option+arrow never sends a bare ESC in the first place.
#
# Both encodings are bound because terminals disagree: CSI form (xterm-style,
# what Ghostty/kitty send) and the older meta-prefixed form.
bindkey '^[[1;3D' backward-word     # alt+left
bindkey '^[[1;3C' forward-word      # alt+right
bindkey '^[^[[D'  backward-word     # alt+left  (meta-prefixed)
bindkey '^[^[[C'  forward-word      # alt+right (meta-prefixed)
bindkey '^[b'     backward-word     # meta-b
bindkey '^[f'     forward-word      # meta-f
bindkey '^[^?'    backward-kill-word  # alt+backspace — delete previous word

# ── direnv (must be last) ────────────────────────────────────────────
# Hook registers _direnv_hook on precmd+chpwd; override to silence stderr
# (log messages) while preserving stdout (env export commands).
(( $+commands[direnv] )) && {
  eval "$(direnv hook zsh)"
  _direnv_hook() {
    trap -- '' SIGINT
    eval "$(direnv export zsh 2>/dev/null)"
    trap - SIGINT
  }
}

# ── compose RPROMPT (after direnv so DIRENV_DIR is current) ─────────
_compose_rprompt() {
  local parts=()
  [[ -n "$_cached_node_version" ]] && parts+=("%F{green}⬢ $_cached_node_version%f")
  if (( ${#parts} )); then
    RPROMPT=$'%{\e[1A%}'"${(j: :)parts}"$'%{\e[1B%}'
  else
    RPROMPT=""
  fi
}
add-zsh-hook precmd _compose_rprompt

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
