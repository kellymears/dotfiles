source $HOME/.dotfiles/env/env.zsh
source $HOME/.dotfiles/env/secret.zsh

typeset -U PATH path
export path=(
  /Library/Apple/usr/bin
  /System/Cryptexes/App/usr/bin
  /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin
  /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin
  /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin
  /Library/Frameworks/Mono.framework/Versions/Current/Commands

  /opt/homebrew/opt/rustup/bin
  /opt/homebrew/bin
  /opt/homebrew/sbin
  /usr/local/MacGPG2/bin

  /usr/local/bin
  /usr/bin
  /bin
  /usr/sbin
  /sbin

  $HOME/.local/bin
  $HOME/.cargo/bin
)

antidote_dir=/opt/homebrew/opt/antidote
zsh_plugins=$HOME/.dotfiles/.zsh_plugins

source $antidote_dir/share/antidote/antidote.zsh

# Ensure the .zsh_plugins.txt file exists so you can add plugins.
[[ -f ${zsh_plugins}.txt ]] || touch ${zsh_plugins}.txt

# Lazy-load antidote from its functions directory.
fpath=($antidote_dir/share/antidote/functions $fpath)
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

source $HOME/.dotfiles/brew.zsh;
source $HOME/.dotfiles/alias.zsh;
source $HOME/.dotfiles/functions.zsh;
source $HOME/.dotfiles/completions/init.zsh;

# Added by OrbStack: command-line tools and integration
# Comment this line if you don't want it to be added again.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

(( $+commands[fnm] )) && eval "$(fnm env --use-on-cd --shell zsh)"
(( $+commands[rbenv] )) && eval "$(rbenv init - zsh)"
