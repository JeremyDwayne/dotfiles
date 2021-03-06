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
    if grep -q microsoft /proc/version; then
        # WSL alias
        alias open="explorer.exe"
    else
        alias open="xdg-open"
    fi

    alias say='echo "$*" | espeak -s 120 2>/dev/null'
    alias cpwd='pwd|tr -d "\n"|xclip'
else
    # OSX
    alias cpwd='pwd|tr -d "\n"|pbcopy'
fi


# top
alias cpu='top -o CPU'
alias mem='top -o MEM'

# Get your current public IP
alias ip="curl icanhazip.com"

# list TODO/FIX lines from the current project
alias todos="ag --nogroup '(TODO|FIX(ME)?):'"

# Python
alias py='python3'
alias py3='python3'
alias pip='pip3'

# Bundler
alias b="bundle"
alias bi="bundle install"
alias be="bundle exec"
alias bu="bundle update"

# Rails
alias migrate="rake db:migrate db:rollback && rake db:migrate"
alias s="rspec"
alias rk="rake"
# alias rc="rails c"
# alias rs="rails s"

# Pretty print the path
alias path='echo $PATH | tr -s ":" "\n"'

# CD Aliases
alias cds='cd ~/Documents/school/'
alias omega='cd /var/www/vhosts/smartcaresoftware.com/httpdocs/app/dev/_omegadev/sc/'

# Scripts Aliases
alias tmpc='source ~/.scripts/CTemplate.sh'
alias project='source ~/.scripts/ProjectLayout.sh'
alias mdtopdf='source ~/.scripts/MDtoPDF.sh'

# Tmux Aliases
alias tdev='source ~/.dotfiles/scripts/tmux-dev.sh'
alias tls='tmux ls'

tnew() {
    if [ "$1" != "" ]
    then
        tmux new -s $1
    else
        tmux
    fi
}

tatt() {
    if [ "$1" != "" ]
    then
        tmux attach -t $1
    else
        tmux attach
    fi
}

# Configuration Reloads
alias tmuxreload='source ~/.tmux.conf'
alias zshreload='source ~/.zshrc'

# ANTLR
alias antlr4='java -Xmx500M -cp "/usr/local/lib/antlr-4.5-complete.jar:$CLASSPATH" org.antlr.v4.Tool'
alias grun='java org.antlr.v4.runtime.misc.TestRig'

# Logbook
lbt() {
    vim -c ":VimwikiMakeDiaryNote"
}

lby() {
    vim -c ":VimwikiMakeYesterdayDiaryNote"
}

lbi() {
    vim -c ":VimwikiDiaryIndex"
}

wiki() {
    vim -c ":VimwikiIndex"
}

swiki() {
    vim -c ":VimwikiSearch $*"
}

# nvim
alias vim=nvim
alias vi=nvim

alias vimrc='vim ~/.config/nvim/init.vim'
alias ealias='vim ~/.dotfiles/aliases.zsh'
alias zshrc='vim ~/.zshrc'
alias ealacritty='vim /mnt/c/Users/winterjd/appdata/Roaming/alacrity/alacritty.yml'

alias gs='git status'

ycmcomp() {
    cp ~/.dotfiles/templates/_ycm_extra_conf.py ./.ycm_extra_conf.py
}

alias fv='vim $(fzf --height 40%)'

alias eclim='/Applications/Eclipse.app/Contents/Eclipse/eclimd  > /dev/null 2>&1 &'

# Docker-Compose Commands
alias dce='docker-compose exec --user $(id -u):$(id -g)'
alias dc='docker-compose'
