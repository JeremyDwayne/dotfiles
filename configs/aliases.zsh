alias vim=nvim
alias vimrc='vim ~/.config/nvim/init.vim'
alias zshrc='vim ~/.zshrc'
alias ealias='vim ~/.aliases.zsh'
alias fv='vim $(fzf --height 40%)'

# Docker-Compose Commands
alias dce='docker-compose exec --user $(id -u):$(id -g)'
alias dc='docker-compose'

# list TODO/FIX lines from the current project
alias todos="ag --nogroup '(TODO|FIX(ME)?):'"

alias ide="source ~/.dotfiles/scripts/ide.zsh"
