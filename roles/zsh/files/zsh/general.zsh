# System / Environment
alias vim=nvim
alias vimrc='vim ~/.config/nvim/init.vim'
alias zshrc='vim ~/.zshrc'
alias zshreload='source ~/.zshrc'
alias fv='vim $(fzf --height 40%)'
alias la='ls -lah'
# list TODO/FIX lines from the current project
alias todos="ag --nogroup '(TODO|FIX(ME)?):'"

alias fjson='pbpaste | python3 -m json.tool | pbcopy'

# Hugo
alias hnp='f(){ hugo new posts/"$1".md;  unset -f f; }; f'

# Alias Directory loading
# for f in ~/.aliases.d/*; do source $f; done
