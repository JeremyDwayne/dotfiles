# Unix
alias ll="ls -la"
alias ln="ln -v"
alias mkdir="mkdir -p"
alias e="$EDITOR"
alias v="$VISUAL"
alias py='python'

# Bundler
alias b="bundle"

# Rails
alias migrate="rake db:migrate db:rollback && rake db:migrate"
alias s="rspec"

# Pretty print the path
alias path='echo $PATH | tr -s ":" "\n"'

# Include custom aliases
[[ -f ~/.aliases.local ]] && source ~/.aliases.local
