# showPort
showPort() {
  lsof -i tcp:$1
}

# killPort
kill-port() {
  lsof -i tcp:$1 | awk 'NR!=1 {print $2}' | xargs kill
}

alias killport=killPort
