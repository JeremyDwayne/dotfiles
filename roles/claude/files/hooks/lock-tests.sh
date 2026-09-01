#!/usr/bin/env bash
# PreToolUse hook (Edit|Write): while <repo>/.scratch/lock-tests exists, block edits
# to test files. Used during bug fixes so the failing test stays the judge of the fix.
# The user creates and removes the marker: `touch .scratch/lock-tests`.
set -u

file=$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))' 2>/dev/null)
[ -n "$file" ] || exit 0

root=$(git -C "$(dirname "$file")" rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -f "$root/.scratch/lock-tests" ] || exit 0

case "$file" in
  */test/*|*/tests/*|*/spec/*|*/__tests__/*|*_test.*|*.test.*|*.spec.*|*/test_*.py|*/django_tests/*)
    echo "Blocked: tests are locked for this bug fix (.scratch/lock-tests). Fix the code, not the test. Ask Jeremy to remove the marker if the test itself is wrong." >&2
    exit 2 ;;
esac
exit 0
