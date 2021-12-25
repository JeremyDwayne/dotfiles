#!/usr/bin/env zsh

# Dont currently do anything with submodules, but maybe
git submodule init
git submodule update --recursive

npm i -g typescript typescript-language-server prettier yarn
if [ hash brew >/dev/null 2>&1 ]
then
  echo 'installing brew...'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
brew bundle

# Check if z tool is installed
if ! [ -d "$HOME/.zdir" ]; then
  echo >&2 "installing z..."
  git clone https://github.com/rupa/z.git $HOME/.zdir
fi

if ! [ -d "$HOME/.oh-my-zsh/" ]; then
	echo >&2 "installing oh-my-zsh..."
	curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh

	echo >&2 "installing a few OMZ plugins while we're here"
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	# Install ZSH Packages
	echo >&2 "Setting ZSH as default shell"
	chsh -s /bin/zsh
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  if ! [ -d "$HOME/.local/kitty.app" ]; then
    echo >&2 "Installing kitty terminal"
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    # Create a symbolic link to add kitty to PATH (assuming ~/.local/bin is in
    # your PATH)
    ln -s ~/.local/kitty.app/bin/kitty ~/.local/bin/
    # Place the kitty.desktop file somewhere it can be found by the OS
    cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
    # Update the path to the kitty icon in the kitty.desktop file
    sed -i "s|Icon=kitty|Icon=/home/$USER/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty.desktop
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  if ! [ -d "/Applications/kitty.app" ]; then
    echo >&2 "Installing kitty terminal"
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
  fi
fi

echo >&2 "Installing nvim plugins"
nvim +PlugInstall +qall > /dev/null

# source symlink.zsh
