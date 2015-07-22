# A collection of useful aliases to make terminal life bliss
# Unix
alias ll="ls -la"
alias ln="ln -v"
alias mkdir="mkdir -p"
alias e="$EDITOR"
alias v="$VISUAL"
alias open='xdg-open'

# checks if on linux for open command
function open () {
if uname | grep -i 'Linux')
    then
        alias open='xdg-open'
    else
        command $0 "$@"
    fi
}

# top
alias cpu='top -o %CPU'
alias mem='top -o %MEM'

# copy the working directory path
alias cpwd='pwd|tr -d "\n"|pbcopy'

# Get your current public IP
alias ip="curl icanhazip.com"

# list TODO/FIX lines from the current project
alias todos="ag --nogroup '(TODO|FIX(ME)?):'"

# Python
alias py='python'

# Bundler
alias b="bundle"
alias bi="bundle install"
alias be="bundle exec"
alias bu="bundle update"

# Rails
alias migrate="rake db:migrate db:rollback && rake db:migrate"
alias s="rspec"
alias rk="rake"
alias rc="rails c"
alias rs="rails s"
alias gi="gem install"

# Pretty print the path
alias path='echo $PATH | tr -s ":" "\n"'
