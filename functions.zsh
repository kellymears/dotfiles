function afk() {
  osascript -e 'tell application "System Events" to keystroke "q" using {command down,control down}'
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

function ssh-add-keychain() {
  ssh-add --apple-use-keychain
}

function forecast() {
  curl 'https://wttr.in/~Winston-Salem'
}

function weather() {
  curl 'https://wttr.in/~Winston-Salem?u&format=1'
}
