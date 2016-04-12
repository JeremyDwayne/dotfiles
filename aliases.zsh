# A collection of useful aliases to make terminal life bliss
# Unix
alias ll="ls -la"
alias ln="ln -v"
alias mkdir="mkdir -p"
alias e="$EDITOR"
alias v="$VISUAL"
alias tmux='tmux -u'

# checks if on linux or OSX for open command
if [ "$(uname)" = "Linux" ]; then
  alias open="xdg-open"
  alias say='echo "$*" | espeak -s 120 2>/dev/null'
  alias cpwd='pwd|tr -d "\n"|xclip'
else
  alias cpwd='pwd|tr -d "\n"|pbcopy'
fi

# top
alias cpu='top -o %CPU'
alias mem='top -o %MEM'

# copy the working directory path osx
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

# CD Aliases
alias cdcs='cd ~/Documents/school/'
alias cdrmi='cd ~/Documents/school/cs355/rmi/'

# Scripts Aliases
alias tmpc='source ~/.scripts/CTemplate.sh'
alias tdev='source ~/.tmux-dev.sh'
alias project='source ~/.scripts/ProjectLayout.sh'
alias mdtopdf='source ~/.scripts/MDtoPDF.sh'

# Configuration Reloads
alias zshreload='source ~/.zshrc'

# SSH
alias sshwork='ssh winterjd@10.34.3.227'

# ANTLR
alias antlr4='java -Xmx500M -cp "/usr/local/lib/antlr-4.5-complete.jar:$CLASSPATH" org.antlr.v4.Tool'
alias grun='java org.antlr.v4.runtime.misc.TestRig'
