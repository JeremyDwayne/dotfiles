#!/bin/bash
# A script for installing dependencies and setting up needed Symbolic Links

# Check if ZSH is installed
hash zsh 2>/dev/null || { 
    echo >&2 "ZSH Not installed. Installing oh-my-zsh while we're at it!"; 
    curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
}

# Check if Git is installed
hash git 2>/dev/null || {
    echo >&2 "git not installed. Please install then re-run this script!";
    if [ head -n10 /etc/*-release | grep -i "ubuntu" ]
    then
        sudo apt-get install git
    elif [ head -n10 /etc/*-release | grep -i "arch" ]
    then
        sudo pacman -S git
    else
        echo >&2 "I'm not smart enough to detect your OS. Install git manually";
        echo >&2 "If you're on OSX, I recommend Homebrew";
    fi
    exit 1;
}

# Check if Oh My ZSH is installed
if [ -d "$HOME/.oh-my-zsh/" ]; then
    ln -sv ~/dotfiles/aliases.zsh  ~/.oh-my-zsh/custom/aliases.zsh
else
    echo >&2 "oh-my-zsh is not installed, installing...";
    curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
fi

# Check if the Ultimate VimRC is installed
if [ -d "$HOME/.vim_runtime/" ]; then
    ln -sv ~/dotfiles/my_configs.vim ~/.vim_runtime/
else
    echo >&2 "Ultimate Vim RC not found. installing...";
    git clone git://github.com/amix/vimrc.git ~/.vim_runtime
    sh ~/.vim_runtime/install_awesome_vimrc.sh
fi

# Make symlinks to home directory for common files
ln -sv ~/dotfiles/agignore ~/.agignore
ln -sv ~/dotfiles/gitconfig ~/.gitconfig
ln -sv ~/dotfiles/gitignore ~/.gitignore
ln -sv ~/dotfiles/gitmessage ~/.gitmessage
ln -sv ~/dotfiles/gemrc ~/.gemrc
ln -sv ~/dotfiles/rspec ~/.rspec
ln -sv ~/dotfiles/zshrc ~/.zshrc
ln -sv ~/dotfiles/tmux.conf ~/.tmux.conf
