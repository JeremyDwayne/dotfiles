# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
# ZSH_THEME="agnoster"
# ZSH_THEME="nicoulaj"
# ZSH_THEME="dracula"
ZSH_THEME="powerlevel9k/powerlevel9k"
DEFAULT_USER="winterjd"

# [ -n "$PS1" ] && sh ~/.nightshell/carbonized-dark ]
# eval `dircolors ~/.nightshell/dircolors`

# export KEYTIMEOUT=1
# #Bracketed past mode
# if [[ $TERM == dumb ]]; then
#     unset zle_bracketed_paste
# else
#     autoload -Uz bracketed-paste-magic
#     zle -N bracketed-paste bracketed-paste-magic
# fi

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
ZSH_DISABLE_COMPFIX=true
plugins=(git zsh-syntax-highlighting)

# User configuration

export PATH="$PATH:$HOME/.cabal/bin:/opt/cabal/1.22/bin:/opt/ghc/7.10.3/bin:$HOME/.rvm/gems:$HOME/.rvm/bin:$HOME/bin:/usr/local/bin:/usr/local/nwjs:/usr/local/var/postgres"

# export MANPATH="/usr/local/man:$MANPATH"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" 

source $ZSH/oh-my-zsh.sh
source $HOME/.dotfiles/aliases.zsh

# Force add ssh keys on terminal startup, and turn on ssh-agent
eval "$(ssh-agent -s)"
ssh-add -A 2>/dev/null;

# You may need to manually set your language environment
#export LANG="en_US"
#export LC_ALL=$LANG.UTF-8

# Set preferred editor
export EDITOR='vim'

KEYTIMEOUT=1

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='vim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
export CPLUS_INCLUDE_PATH=/usr/local/include

# Python Variables
# VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
# source /usr/local/bin/virtualenvwrapper.sh

# Z Quick CD
source ~/.dotfiles/z/z.sh

# brew install zsh-syntax-highlighting
# source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export PATH="/usr/local/opt/mysql@5.6/bin:$PATH"
export PATH="/home/winterjd/.local/bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

function code {
    if [[ $# = 0 ]]
    then
        open -a "Visual Studio Code"
    else
        local argPath="$1"
        [[ $1 = /* ]] && argPath="$1" || argPath="$PWD/${1#./}"
        open -a "Visual Studio Code" "$argPath"
    fi
  }

eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
source /home/winterjd/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
