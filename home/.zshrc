# PATH
export PATH=~/.composer/vendor/bin:$PATH

# oh-my-zsh export
export ZSH="/Users/kellymears/.oh-my-zsh"

# oh-my-zsh theme
ZSH_THEME="spaceship"

# oh-my-zsh plugins
plugins=(git)

# homeshick
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
fpath=($HOME/.homesick/repos/homeshick/completions $fpath)

# source oh-my-zsh
source $ZSH/oh-my-zsh.sh

  # Set Spaceship ZSH as a prompt
  autoload -U promptinit; promptinit
  prompt spaceship
