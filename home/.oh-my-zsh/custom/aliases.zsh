# cli replacements
alias cat="bat"
alias exa="ls"

# cli shortcuts
alias screenfetch='screenfetch -E'
alias img="imgcat"
alias status="http-status-check scan"

# applications
alias code="open -a 'Visual Studio Code'"
alias md="open -a 'Macdown'"

# composer
alias composer="php /usr/local/bin/composer.phar"

# docker
alias dockers="docker ps -a"
alias dcu="docker compose up"
alias dcud="docker compose up -d"

# git
alias ga="git for-each-ref refs/remotes/ --format='%(authorname) %(refname)' --sort=authorname"
alias gc="git clone"
alias gf="git fetch"
alias gco="git checkout"
alias gcm="git checkout master"
alias gcs="git checkout staging"
alias gcd="git checkout development"
alias gs="git status"
alias grh="git reset --hard origin/$(current_branch)"

# gitmoji
alias gc="gitmoji -c"

# ansible
alias provision="ansible-playbook server.yml -e"
alias deploy="ansible-playbook deploy.yml -e"

# util
eval $(thefuck --alias fuck)
alias flushdns="sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
alias restart="source ~/.zshrc && clear"
