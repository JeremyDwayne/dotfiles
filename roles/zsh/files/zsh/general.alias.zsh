# System / Environment
alias vim=nvim
alias vimrc='vim ~/.config/nvim'
alias zshrc='vim ~/.zshrc'
alias zshreload='source ~/.zshrc'
alias fv='vim $(fzf --height 40%)'
alias la='ls -lah'
# list TODO/FIX lines from the current project
alias todos="ag --nogroup '(TODO|FIX(ME)?):'"

alias fjson='pbpaste | python3 -m json.tool | pbcopy'

# Hugo
alias hnp='f(){ hugo new posts/"$1".md;  unset -f f; }; f'

# Go Migrate
alias cmigrate='f(){ migrate create -ext sql -dir db/migrations -seq "$1" }; f'

# Alias Directory loading
# for f in ~/.aliases.d/*; do source $f; done

# Git
alias glp='git log --pretty=format:"%C(yellow)%h%Creset - %C(green)%an%Creset, %ar : %s"'
alias gs='git status'
alias ga='git add -A'
alias gc='git commit -m'
alias gp='git push'
alias gpl='git pull'
