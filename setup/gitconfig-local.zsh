# gitconfig-local.zsh — sourced by setup/link.zsh and setup/linux.zsh.
#
# Writes ~/.gitconfig.local (included last by config/.gitconfig) with the
# paths that differ per machine. Never overwrites an existing file — edit it
# by hand if the key changes.

write_gitconfig_local() {
  local local_cfg="$HOME/.gitconfig.local"
  local pubkey="$HOME/.ssh/id_ed25519.pub"
  local signers="$HOME/.config/git/allowed_signers"
  local email

  if [[ -e "$local_cfg" ]]; then
    echo "KEEP: $local_cfg already exists"
    return 0
  fi

  if [[ -f "$pubkey" ]]; then
    email=$(git config --file "$HOME/.dotfiles/config/.gitconfig" user.email)
    mkdir -p "${signers:h}"
    [[ -f "$signers" ]] || print -r -- "$email $(<$pubkey)" > "$signers"

    cat > "$local_cfg" <<EOF
[user]
	signingkey = $pubkey
[gpg "ssh"]
	allowedSignersFile = $signers
EOF
    echo "WROTE: $local_cfg (signing with $pubkey)"
  else
    # commit.gpgsign = true with no key makes every commit fail, so turn
    # signing off until a key exists. Delete this file and re-run setup once
    # the key is created and added to GitHub as a *signing* key.
    cat > "$local_cfg" <<EOF
# No $pubkey yet — signing disabled. Delete this file and re-run setup
# after: ssh-keygen -t ed25519 && gh ssh-key add $pubkey --type signing
[commit]
	gpgsign = false
[tag]
	gpgsign = false
EOF
    echo "WARN: no $pubkey — wrote $local_cfg with signing DISABLED"
  fi
}
