# Brewfile — macOS only. cachy (Arch) installs through paru instead.
#
# Kept deliberately small: anything heavy (docker stacks, language runtimes
# beyond node/bun, local LLMs, k8s tooling) runs on cachy, not the laptop.
# The commented blocks at the bottom are things that used to live here —
# uncomment when you actually miss one.

# ── shell ────────────────────────────────────────────────────────────
brew "antidote"
brew "bat"
brew "direnv"      # switches CLAUDE_CONFIG_DIR inside ~/code/git/oncarrot
brew "eza"
brew "fd"
brew "fzf"
brew "jq"
brew "mise"        # node + bun, see config/mise/config.toml
brew "ripgrep"
brew "zoxide"

# ── git ──────────────────────────────────────────────────────────────
brew "gh"
brew "git"
brew "git-lfs"
brew "worktrunk"   # `wt`, used by cachy_wt

# ── apps ─────────────────────────────────────────────────────────────
cask "1password"
cask "1password-cli"
cask "ghostty"
cask "raycast"
cask "tailscale-app"
cask "visual-studio-code"

# ── fonts ────────────────────────────────────────────────────────────
cask "font-monaspice-nerd-font"  # Ghostty: MonaspiceNe NFM

# ── vscode ───────────────────────────────────────────────────────────
vscode "aaron-bond.better-comments"
vscode "akarlsten.vscode-snazzy-akarlsten"
vscode "artlaman.chalice-icon-theme"
vscode "bmewburn.vscode-intelephense-client"
vscode "bradlc.vscode-tailwindcss"
vscode "codezombiech.gitignore"
vscode "csstools.postcss"
vscode "davidanson.vscode-markdownlint"
vscode "dbaeumer.vscode-eslint"
vscode "docker.docker"
vscode "editorconfig.editorconfig"
vscode "esbenp.prettier-vscode"
vscode "github.vscode-pull-request-github"
vscode "graphql.vscode-graphql"
vscode "graphql.vscode-graphql-syntax"
vscode "heybourn.headwind"
vscode "ionutvmi.path-autocomplete"
vscode "jkillian.custom-local-formatters"
vscode "jock.svg"
vscode "johnbillion.vscode-wordpress-hooks"
vscode "kellymears.vscode-mago-formatter"
vscode "mikestead.dotenv"
vscode "mkxml.vscode-filesize"
vscode "mquandalle.graphql"
vscode "mrmlnc.vscode-json5"
vscode "ms-vscode.makefile-tools"
vscode "redhat.vscode-xml"
vscode "redhat.vscode-yaml"
vscode "rust-lang.rust-analyzer"
vscode "stylelint.vscode-stylelint"
vscode "sysoev.vscode-open-in-github"
vscode "timonwong.shellcheck"
vscode "tonybaloney.vscode-pets"
vscode "unifiedjs.vscode-mdx"
vscode "vitest.explorer"
vscode "yoavbls.pretty-ts-errors"

# ── later, when missed ───────────────────────────────────────────────
# Everyday apps:
# cask "discord"
# cask "figma"
# cask "google-chrome"
# cask "obsidian"
# cask "signal"
# cask "slack"
# cask "zoom"
#
# Shell nice-to-haves (atuin claims ctrl-r from fzf when installed):
# brew "atuin"
# brew "btop"
# brew "glow"
# brew "lazygit"
# brew "neovim"
# brew "tmux"
#
# Usually better on cachy:
# cask "orbstack"
# cask "ollama-app"
# brew "kubernetes-cli"
# brew "derailed/k9s/k9s"     (needs tap "derailed/k9s")
# brew "php"
# brew "rustup"
# brew "roots/tap/trellis-cli" (needs tap "roots/tap")
# brew "stripe/stripe-cli/stripe" (needs tap "stripe/stripe-cli")
#
# Occasional utilities:
# cask "betterdisplay"
# cask "daisydisk"
# cask "keycastr"
# cask "monodraw"
# cask "tableplus"
# cask "the-unarchiver"
# cask "transmit"
# cask "wispr-flow"
# cask "yaak"
# brew "hyperfine"
# brew "mkcert"
# brew "yt-dlp"
