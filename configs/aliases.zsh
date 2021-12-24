alias vim=nvim
alias vimrc='vim ~/.config/nvim/init.vim'
alias zshrc='vim ~/.zshrc'
alias zshreload='source ~/.zshrc'
alias ealias='vim ~/.aliases.zsh'
alias fv='vim $(fzf --height 40%)'
alias "sudoedit"='function _sudoedit(){sudo -e "$1";};_sudoedit'

# Docker-Compose Commands
alias dce='docker-compose exec --user $(id -u):$(id -g)'
alias dc='docker-compose'

# list TODO/FIX lines from the current project
alias todos="ag --nogroup '(TODO|FIX(ME)?):'"

alias luamake=/usr/local/share/lua-language-server/3rd/luamake/luamake

# Ruby App aliases
alias startredis="brew services start redis"
alias stopredis="brew services stop redis"

alias startpg="brew services start postgresql"
alias stoppg="brew services stop postgresql"

alias startapi="bundle exec puma -v -C config/puma.rb config.ru -p 7777"
alias startsidekiq="bundle exec sidekiq -r ./config/environment.rb -C ./config/sidekiq.yml"

alias rubocop="bundle exec rubocop --parallel"

alias resettestdb="RACK_ENV=test rake db:reset && RACK_ENV=test rake db:seed"
alias runalltests="RACK_ENV=test rake db:prepare; rspec"

# Docker Aliases
alias dc-dev-b='docker-compose -f docker/dev/docker-compose.yml build api_dev'
alias dc-dev-u='docker-compose -f docker/dev/docker-compose.yml up api_dev'
alias dc-dev-r='docker-compose -f docker/dev/docker-compose.yml run api_dev'
alias dc-dev-e='docker-compose -f docker/dev/docker-compose.yml exec api_dev'
 
alias dc-test-b='docker-compose -f docker/test/docker-compose.yml build api_test'
alias dc-test-u='docker-compose -f docker/test/docker-compose.yml up api_test'
alias dc-test-r='docker-compose -f docker/test/docker-compose.yml run api_test'
alias dc-test-e='docker-compose -f docker/test/docker-compose.yml exec api_test'

# Wireguard

alias wgu="wg-quick up /usr/local/etc/wireguard/wireguard.conf"
alias wgd="wg-quick down /usr/local/etc/wireguard/wireguard.conf"

alias cddev='cd ~/Development/'

# Alias Directory loading
# for f in ~/.aliases.d/*; do source $f; done
