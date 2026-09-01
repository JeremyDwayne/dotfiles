#!/usr/bin/env bash
# PreToolUse hook (Edit|Write): block edits to secret files. Exit 2 denies the tool call.
set -u

file=$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))' 2>/dev/null)
[ -n "$file" ] || exit 0
base=$(basename "$file")

case "$file" in
  */.env|*/.env.*|*/.kamal/secrets*|*/.ssh/*|*.pem|*.key|*/credentials.json|*/service-account*.json)
    # .env.example style templates are fine to edit.
    case "$base" in *.example|*.sample|*.template) exit 0 ;; esac
    echo "Blocked: $file holds secrets. Edit it by hand, not through the agent." >&2
    exit 2 ;;
esac
exit 0
