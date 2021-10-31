#!/usr/bin/env zsh

# Symlink configs
echo >&2 "Symlinking Configs"
for f in `find ~/.dotfiles/configs -type f`; do
    rm -f ~/."${f##*/}"
    ln -s ~/.dotfiles/configs/"${f##*/}" ~/."${f##*/}"
done

# Neovim symlinks
echo >&2 "Symlinking Neovim Configs"
mkdir -p ~/.config
rm -rf ~/.config/nvim
ln -s ~/.dotfiles/nvim ~/.config/nvim

# Kitty symlinks
echo >&2 "Symlinking Kitty Configs"
mkdir -p ~/.config/kitty
rm -rf ~/.config/kitty
ln -s ~/.dotfiles/kitty ~/.config/kitty
