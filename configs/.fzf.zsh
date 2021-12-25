if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  FZF_PATH="/home/linuxbrew/.linuxbrew"
else
  FZF_PATH="/usr/local"
fi
# Setup fzf
# ---------
if [[ ! "$PATH" == */home/linuxbrew/.linuxbrew/opt/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}$FZF_PATH/opt/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$FZF_PATH/opt/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "$FZF_PATH/opt/fzf/shell/key-bindings.zsh"
