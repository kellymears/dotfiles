export GPG_TTY=$(tty)
export EDITOR=nvim
export PAGER=less
export VISUAL=code

# $CONFIG, $XDG_CONFIG_HOME, and $RIPGREP_CONFIG_PATH are set per-OS —
# see env/darwin.zsh and env/linux.zsh. The two platforms resolve config
# differently and can't share one definition.

# Data dirs — NOT in repo
export COMPOSER_HOME=$HOME/.local/share/composer

# Claude Code
export CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1
export CLAUDE_CODE_NO_FLICKER=1
