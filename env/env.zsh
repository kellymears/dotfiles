export GPG_TTY=$(tty)
export PAGER=less

# VS Code is the default editor everywhere. `--wait` is required: without it
# `code` returns immediately and git/fc/crontab think you saved an empty file.
# Linux overrides this back to nvim in a headless session — see env/linux.zsh.
export VISUAL='code --wait'
export EDITOR=$VISUAL

# $CONFIG, $XDG_CONFIG_HOME, and $RIPGREP_CONFIG_PATH are set per-OS —
# see env/darwin.zsh and env/linux.zsh. The two platforms resolve config
# differently and can't share one definition.

# Data dirs — NOT in repo
export COMPOSER_HOME=$HOME/.local/share/composer

# Claude Code
export CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=1
export CLAUDE_CODE_NO_FLICKER=1
