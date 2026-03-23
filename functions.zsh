function afk() {
  osascript -e 'tell application "System Events" to keystroke "q" using {command down,control down}'
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
