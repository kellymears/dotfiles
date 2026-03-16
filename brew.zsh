# brew.zsh — Homebrew environment (Apple Silicon)
local brew_prefix="/opt/homebrew"

eval "$($brew_prefix/bin/brew shellenv)"

export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_NO_ANALYTICS=1

# command-not-found handler
local cnf_handler="$brew_prefix/Library/Homebrew/command-not-found/handler.sh"
[[ -f "$cnf_handler" ]] && source "$cnf_handler"
