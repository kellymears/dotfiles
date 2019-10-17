# PATH
export PATH=$HOME/.composer/vendor/bin:$PATH

# MacPorts
export PATH=/opt/local/bin:/opt/local/sbin:$PATH

# yarn
export PATH="/opt/yarn-1.17.3/bin:$PATH"
export PATH="`yarn global bin`:$PATH"

#gettext
export PATH="/usr/local/opt/gettext/bin:$PATH"

# oh-my-zsh export
export ZSH="/Users/kellymears/.oh-my-zsh"

# xdebug
XDEBUG_CONFIG="idekey=VSCODE"

# oh-my-zsh theme
ZSH_THEME="spaceship"

# oh-my-zsh plugins
plugins=(
  brew
  cask
  composer
  docker
  git
  node
  nvm
  vagrant
  vscode
  yarn
)

# homeshick
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
fpath=($HOME/.homesick/repos/homeshick/completions $fpath)

# source oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Set Spaceship ZSH as a prompt
autoload -U promptinit
promptinit
prompt spaceship

# iTerm2 Shell Integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/ruby/bin:$PATH"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
