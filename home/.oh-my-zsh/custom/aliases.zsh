# cli replacements
alias cat="bat"
alias exa="ls"

# cli shortcuts
alias screenfetch='screenfetch -E'
alias img="imgcat"
alias status="http-status-check scan"

# applications
alias code="open -a '/Applications/Visual Studio Code.app'"
alias md="open -a 'Macdown'"
alias aircast="~/bin/airconnect/bin/airupnp-osx-multi -l 1000:2000"

# composer
alias composer="php /usr/local/bin/composer.phar"

# docker
alias dockers="docker ps -a"
alias dcu="docker compose up"
alias dcud="docker compose up -d"
alias dcr=alias dcr="docker-compose run --rm"

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
