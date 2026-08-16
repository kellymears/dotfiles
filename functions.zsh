function afk() {
  osascript -e 'tell application "System Events" to keystroke "q" using {command down,control down}'
}

# ── remote dev box (cachy) ───────────────────────────────────────────
# i9-14900KF / 62GB / RTX 4090 running CachyOS. Preferred host for docker
# stacks, dev servers, test suites, and local LLM inference — it is much
# faster than this laptop and does not drain the battery.
#   ssh cachy      LAN      (192.168.1.12)
#   ssh cachy-ts   Tailscale (works anywhere)

function cachy_wt() {
  # cachy_wt <repo> <branch> — create/switch a worktree on the dev box.
  # -A forwards the ssh agent so git operations there can reach GitHub;
  # no private key is stored on the box.
  local repo="${1:?usage: cachy_wt <repo> <branch>}"
  local branch="${2:?usage: cachy_wt <repo> <branch>}"
  ssh -A cachy "cd ~/code/git/oncarrot/${repo} && wt switch ${(q)branch}"
}

function cachy_fwd() {
  # cachy_fwd <port> [port...] — tunnel dev ports from the box to localhost.
  # Cake assigns every worktree ports above 1024 (app 3100+N, storybook
  # 6106+N, postgres 5432+N), so this needs no sudo and *.cake.localhost
  # still resolves to 127.0.0.1 here.
  (( $# )) || { echo "usage: cachy_fwd <port> [port...]"; return 1 }
  local -a fwd; local p
  for p in "$@"; do fwd+=(-L "${p}:localhost:${p}"); done
  echo "forwarding ${*} from cachy — ctrl-c to stop"
  ssh -N "${fwd[@]}" cachy
}

function cachy_ollama() {
  # Point this shell's OLLAMA_HOST at the box's 4090 instead of local CPU.
  # `cachy` here is the Tailscale MagicDNS name, not the ssh alias. ufw only
  # exposes 11434 on tailscale0, so this needs the Tailscale client running.
  export OLLAMA_HOST="http://cachy:11434"
  echo "OLLAMA_HOST=$OLLAMA_HOST"
}

function carrot_dev () {
  (
    set -e
    source awsume -u
    source awsume carrot-test
    aws eks --profile carrot-test --region us-west-2 update-kubeconfig --name testing-oncarrot
    k9s -n development
  )
}

function carrot_prod () {
  (
    set -e
    source awsume -u
    source awsume carrot
    aws eks --profile carrot --region us-west-2 update-kubeconfig --name production-carrot
    k9s -n prod
  )
}

function dark-mode() {
  osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to not dark mode'
}

function emptytrash() {
  sudo rm -rfv /Volumes/*/.Trashes
  sudo rm -rfv ~/.Trash
  sudo rm -rfv /private/var/log/asl/*.asl
}

function flushdns() {
  sudo dscacheutil -flushcache
  sudo killall -HUP mDNSResponder
}

function forecast() {
  curl 'https://wttr.in/~Winston-Salem'
}

function weather() {
  curl 'https://wttr.in/~Winston-Salem?u&format=1'
}
