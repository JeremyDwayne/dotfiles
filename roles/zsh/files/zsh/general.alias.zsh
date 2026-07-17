# System / Environment
alias vim=nvim
alias vimrc='vim ~/.config/nvim'
alias zshrc='vim ~/.zshrc'
alias zshreload='source ~/.zshrc'
alias fv='vim $(fzf --height 40%)'
alias la='ls -lah'
# list TODO/FIX lines from the current project
alias todos="ag --nogroup '(TODO|FIX(ME)?):'"

alias fjson='pbpaste | python3 -m json.tool | pbcopy'

# Hugo
alias hnp='f(){ hugo new posts/"$1".md;  unset -f f; }; f'

# Go Migrate
alias cmigrate='f(){ migrate create -ext sql -dir db/migrations -seq "$1" }; f'

# Alias Directory loading
# for f in ~/.aliases.d/*; do source $f; done

# Git
alias glp='git log --pretty=format:"%C(yellow)%h%Creset - %C(green)%an%Creset, %ar : %s"'
alias gs='git status --short'
alias ga='git add -A'
alias gc='git commit -m'
alias commit='claude "stage and commit all changes"'
alias gp='git push'
alias gpl='git pull'

# Commit staged changes with a generated message (haiku, no review step).
# Lockfiles are excluded from the prompt (still committed); diff capped at 60KB.
gcai() {
  git diff --cached --quiet && { echo "nothing staged" >&2; return 1 }
  local msg
  msg=$(git diff --cached -- ':!*.lock' ':!package-lock.json' ':!yarn.lock' ':!pnpm-lock.yaml' \
    | head -c 60000 | claude -p --model haiku \
    "Write a git commit message for this staged diff.
First line: imperative mood, <=72 chars, no trailing period.
Add a short body (wrapped at 72) only if the change genuinely needs explanation.
Output only the raw commit message - no quotes, no markdown, no preamble.") || return 1
  [[ -z "$msg" ]] && { echo "empty message from claude, aborting" >&2; return 1 }
  git commit -m "$msg"
}
