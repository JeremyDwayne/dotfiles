# Check if z tool is installed
if ! [ -d "$HOME/.zdir" ]; then
  echo >&2 "z is not installed, fixing that..."
  git clone https://github.com/rupa/z.git $HOME/.zdir
fi

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
