# Dotfiles
Here's my collection of dotfiles I use on linux/osx environments.

## Install
`./install.zsh` will run a script that checks if all the necessary programs are 
installed. Once the dependencies are installed, it will run any third party installations

I'm in the process of moving the `install.zsh` script to ansible. After installing dependencies
you can symlink the configs using `./stow-run`.

ZSH and Oh-My-Zsh must be installed:
- http://ohmyz.sh/

**Git**
Make sure to edit the gitconfig and add your credentials instead of mine

**VIM Installation Tips**
I use neovim and vim-plug. So if you're using regular vim you might want to
remove the neovim specific plugins from my vimrc. Also, you might need to run
:PlugClean to remove the plugin directories then run :PlugInstall to reinstall
them.
`vim +PlugInstall +qall > /dev/null`
