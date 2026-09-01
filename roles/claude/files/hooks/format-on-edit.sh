#!/usr/bin/env bash
# PostToolUse hook (Edit|Write): run the repo's formatter on the file just changed.
# Uses whichever formatter the project already ships. Never fails the tool call.
set -u

file=$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))' 2>/dev/null)
[ -n "$file" ] && [ -f "$file" ] || exit 0

root=$(git -C "$(dirname "$file")" rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" || exit 0

case "$file" in
  *.py)
    if [ -x .venv/bin/ruff ]; then .venv/bin/ruff format --quiet "$file"
    elif command -v ruff >/dev/null; then ruff format --quiet "$file"
    elif [ -x .venv/bin/black ]; then .venv/bin/black --quiet "$file"
    fi ;;
  *.ts|*.tsx|*.js|*.jsx|*.json|*.css|*.md|*.html)
    if [ -x node_modules/.bin/biome ]; then node_modules/.bin/biome format --write "$file" >/dev/null 2>&1
    elif [ -x node_modules/.bin/prettier ]; then node_modules/.bin/prettier --log-level silent --write "$file"
    fi ;;
  *.rb)
    if [ -x bin/rubocop ]; then bin/rubocop -A --format quiet "$file" >/dev/null 2>&1; fi ;;
  *.go)
    command -v gofmt >/dev/null && gofmt -w "$file" ;;
esac
exit 0
