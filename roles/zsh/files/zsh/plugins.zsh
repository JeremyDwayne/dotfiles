if type zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

if type starship &>/dev/null; then
  export STARSHIP_CONFIG=~/.config/starship/starship.toml
  eval "$(starship init zsh)"
fi

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
