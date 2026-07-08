#!/usr/bin/env bash
# Claude Code statusLine script
# Reads JSON payload from stdin and prints a single-line status string.

# ANSI color codes
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BRIGHT_GREEN='\033[1;32m'
BRIGHT_YELLOW='\033[1;33m'
RESET='\033[0m'

SEP=" ${RESET}·${RESET} "

input=$(cat)

# 1. Model display name
model=$(printf '%s' "$input" | jq -r '.model.display_name // empty' 2>/dev/null)

# 2. Current directory — basename, with ~ abbreviation for home paths
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
if [ -n "$cwd" ]; then
  home_prefix="$HOME"
  if [ "${cwd#"$home_prefix"}" != "$cwd" ]; then
    cwd_display="~${cwd#"$home_prefix"}"
  else
    cwd_display="$cwd"
  fi
  # Show basename only (last component)
  dir_display=$(basename "$cwd_display")
  # Special-case: if we're exactly at ~, show ~
  if [ "$cwd" = "$HOME" ]; then
    dir_display="~"
  fi
else
  dir_display=""
fi

# 3. Git branch + dirty indicator (run in the actual cwd, suppress all errors)
branch=""
if [ -n "$cwd" ] && command -v git >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ -n "$branch" ] && [ "$branch" != "HEAD" ]; then
    dirty=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
    if [ -n "$dirty" ]; then
      branch="${branch}*"
    fi
  else
    branch=""
  fi
fi

# 4. Context window usage percentage
used_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty' 2>/dev/null)
ctx_display=""
if [ -n "$used_pct" ]; then
  # Round to nearest integer
  used_int=$(printf '%.0f' "$used_pct" 2>/dev/null)
  ctx_display="${used_int}% ctx"
fi

# Assemble the line
line=""

if [ -n "$model" ]; then
  line="${CYAN}${model}${RESET}"
fi

if [ -n "$dir_display" ]; then
  [ -n "$line" ] && line="${line}${SEP}"
  line="${line}${BLUE}${dir_display}${RESET}"
fi

if [ -n "$branch" ]; then
  [ -n "$line" ] && line="${line}${SEP}"
  # Use yellow when dirty (has *), magenta when clean
  if [ "${branch%\*}" != "$branch" ]; then
    line="${line}${YELLOW}${branch}${RESET}"
  else
    line="${line}${MAGENTA}${branch}${RESET}"
  fi
fi

if [ -n "$ctx_display" ]; then
  [ -n "$line" ] && line="${line}${SEP}"
  # Shift to bright yellow/red-ish when above 75%
  if [ -n "$used_int" ] && [ "$used_int" -ge 75 ] 2>/dev/null; then
    line="${line}${BRIGHT_YELLOW}${ctx_display}${RESET}"
  else
    line="${line}${GREEN}${ctx_display}${RESET}"
  fi
fi

printf "%b\n" "$line"
