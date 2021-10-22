#!/usr/bin/env zsh

# Dont currently do anything with submodules, but maybe
git submodule init
git submodule update --recursive

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

# Using rbenv instead of rvm now
# if ! [ -d "$HOME/.rvm" ]; then
# 	echo >&2 'installing rvm and stable ruby+rails...'
# 	gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
# 	curl -sSL https://get.rvm.io | bash -s stable --rails
# 	if [ hash rvm >/dev/null 2>&1 ]
# 	then
# 	  rvm cleanup all
# 	fi
# fi

source symlink.zsh
