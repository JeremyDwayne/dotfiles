#!/usr/bin/env bash
# Claude Code statusLine script.
# Reads the status JSON payload from stdin and prints a single-line status
# string. Every field is optional — missing data is simply omitted so the line
# degrades gracefully across Claude Code versions and non-git directories.

# ANSI styles
DIM='\033[2m'
CYAN='\033[1;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BRIGHT_YELLOW='\033[1;33m'
RESET='\033[0m'

SEP="${DIM} · ${RESET}"

input=$(cat)

# Extract every field we care about in a single jq pass. @sh quotes each value
# so the eval is safe even if a field contains spaces or shell metacharacters.
eval "$(printf '%s' "$input" | jq -r '
  @sh "model=\(.model.display_name // "")",
  @sh "ctx_size=\(.context_window.context_window_size // 0)",
  @sh "ctx_pct=\(.context_window.used_percentage // "")",
  @sh "fast=\(.fast_mode // false)",
  @sh "effort=\(.effort.level // "")",
  @sh "thinking=\(.thinking.enabled // true)",
  @sh "cwd=\(.cwd // "")",
  @sh "repo=\(.workspace.repo.name // "")",
  @sh "worktree=\(.worktree.name // .workspace.git_worktree // "")",
  @sh "cost=\(.cost.total_cost_usd // 0)",
  @sh "rate5=\(.rate_limits.five_hour.used_percentage // "")",
  @sh "rate7=\(.rate_limits.seven_day.used_percentage // "")"
' 2>/dev/null)"

# Colorize a usage percentage: red at >=90, amber at >=75, otherwise a base color.
usage_color() {
  local pct="$1" base="$2"
  if [ "$pct" -ge 90 ] 2>/dev/null; then
    printf '%b' "$RED"
  elif [ "$pct" -ge 75 ] 2>/dev/null; then
    printf '%b' "$BRIGHT_YELLOW"
  else
    printf '%b' "$base"
  fi
}

segments=()

# 1. Model — compact "(1M context)" to a dim "1M", flag fast mode and off
#    thinking, and append the effort level.
if [ -n "$model" ]; then
  model_short="${model/ (1M context)/}"
  seg="${CYAN}${model_short}${RESET}"
  if [ "${ctx_size:-0}" -ge 1000000 ] 2>/dev/null; then
    seg="${seg} ${DIM}1M${RESET}"
  fi
  [ "$fast" = "true" ] && seg="${seg} ${BRIGHT_YELLOW}⚡${RESET}"
  [ "$thinking" = "false" ] && seg="${seg} ${DIM}no-think${RESET}"
  [ -n "$effort" ] && seg="${seg} ${DIM}${effort}${RESET}"
  segments+=("$seg")
fi

# 2. Location — repo name (falling back to the cwd basename), and the worktree
#    name when inside one, so parallel worktrees are never confused.
loc="$repo"
[ -z "$loc" ] && [ -n "$cwd" ] && loc=$(basename "$cwd")
if [ -n "$loc" ]; then
  seg="${BLUE}${loc}${RESET}"
  if [ -n "$worktree" ] && [ "$worktree" != "$loc" ]; then
    seg="${seg}${DIM}:${RESET}${BLUE}${worktree}${RESET}"
  fi
  segments+=("$seg")
fi

# 3. Git branch + dirty marker, read live from the working tree.
if [ -n "$cwd" ] && command -v git >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ -n "$branch" ] && [ "$branch" != "HEAD" ]; then
    if [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
      segments+=("${YELLOW}${branch}*${RESET}")
    else
      segments+=("${MAGENTA}${branch}${RESET}")
    fi
  fi
fi

# 4. Context window usage.
if [ -n "$ctx_pct" ]; then
  ctx_int=$(printf '%.0f' "$ctx_pct" 2>/dev/null)
  color=$(usage_color "$ctx_int" "$GREEN")
  segments+=("${color}${ctx_int}% ctx${RESET}")
fi

# 5. Rate limits — 5-hour and 7-day windows, each colored by its own urgency.
if [ -n "$rate5" ]; then
  color=$(usage_color "$rate5" "$DIM")
  segments+=("${color}5h ${rate5}%${RESET}")
fi
if [ -n "$rate7" ]; then
  color=$(usage_color "$rate7" "$DIM")
  segments+=("${color}7d ${rate7}%${RESET}")
fi

# 6. Session cost — whole dollars once past $10, otherwise two decimals.
if [ -n "$cost" ] && [ "$cost" != "0" ]; then
  if awk "BEGIN{exit !($cost >= 10)}" 2>/dev/null; then
    cost_display=$(printf '$%.0f' "$cost" 2>/dev/null)
  else
    cost_display=$(printf '$%.2f' "$cost" 2>/dev/null)
  fi
  segments+=("${DIM}${cost_display}${RESET}")
fi

# Join segments with the separator.
line=""
for seg in "${segments[@]}"; do
  if [ -z "$line" ]; then
    line="$seg"
  else
    line="${line}${SEP}${seg}"
  fi
done

printf "%b\n" "$line"
