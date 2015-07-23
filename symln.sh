#!/bin/bash
# A script for installing dependencies and setting up needed Symbolic Links
# Created by Jeremy Winterberg
# Updated 07/23/2015
# NOTICE: Modify script to your own preferences! This mostly uses default
#         locations, but can be changed to whatever you need.

# Check if ZSH is installed
hash zsh 2>/dev/null || { 
    echo >&2 "ZSH Not installed. Installing oh-my-zsh while we're at it!"; 
    curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
}

# Check if Git is installed
hash git 2>/dev/null || {
    echo >&2 "git not installed. Please install then re-run this script!";
    case $(uname) in
        OpenBSD)
            sudo pkg_add git
            ;;
        FreeBSD)
            cd /usr/ports/devel/git
            sudo make install
            ;;
        Linux)
            if [ head -n10 /etc/*-release | grep -i "ubuntu" ]
            then
                sudo apt-get install git
            elif [ head -n10 /etc/*-release | grep -i "arch" ]
            then
                sudo pacman -S git
            elif [ head -n10 /etc/*-release | grep -i "fedora" ]
            then
                sudo yum install git
            elif [ head -n10 /etc/*-release | grep -i "gentoo" ]
            then
                emerge --ask --verbose dev-vcs/git
            elif [ head -n10 /etc/*-release | grep -i "openSUSE" ]
            then
                sudo zypper install git
            fi
            ;;
        Darwin)
            hash brew 2>/dev/null || {
                echo "You do not have homebrew installed, taking care of that!"
                ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
                brew update
                brew doctor
                brew install git
            }
            brew install git
            ;;
    esac
}

# Check if Oh My ZSH is installed
if [ -d "$HOME/.oh-my-zsh/" ]; then
    ln -sv ~/dotfiles/aliases.zsh  ~/.oh-my-zsh/custom/aliases.zsh
else
    echo >&2 "oh-my-zsh is not installed, installing...";
    curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
    ln -sv ~/dotfiles/aliases.zsh  ~/.oh-my-zsh/custom/aliases.zsh
fi

# Check if the Ultimate VimRC is installed
if [ -d "$HOME/.vim_runtime/" ]; then
    ln -sv ~/dotfiles/my_configs.vim ~/.vim_runtime/
else
    echo >&2 "Ultimate Vim RC not found. installing...";
    git clone git://github.com/amix/vimrc.git ~/.vim_runtime
    sh ~/.vim_runtime/install_awesome_vimrc.sh
    ln -sv ~/dotfiles/my_configs.vim ~/.vim_runtime/
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
