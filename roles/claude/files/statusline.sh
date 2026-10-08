#!/usr/bin/env bash
# Claude Code statusLine script. Reads the status JSON on stdin and prints two
# lines, each shed of detail until it fits the pane:
#
#   1. Place: repo, worktree, branch, dirt, ahead/behind.
#   2. Session: model, effort, context until auto-compact, rate limits, cache.
#
# Missing fields are omitted. Normal values are dim and alerts run yellow then
# red, never against green.

DIM='\033[2m'
BOLD='\033[1m'
CYAN='\033[1;36m'
BLUE='\033[1;34m'
MAGENTA='\033[0;35m'
YELLOW='\033[0;33m'
BRIGHT_YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

SEP="${DIM} · ${RESET}"

input=$(cat)

# Extract every field we care about in a single jq pass. @sh quotes each value
# so the eval is safe even if a field contains spaces or shell metacharacters.
eval "$(printf '%s' "$input" | jq -r '
  @sh "model=\(.model.display_name // "")",
  @sh "ctx_size=\(.context_window.context_window_size // 0)",
  @sh "ctx_tokens=\(.context_window.total_input_tokens // 0)",
  @sh "effort=\(.effort.level // "")",
  # jq: `false // x` yields x, so these two booleans must be tested explicitly
  # rather than defaulted with `//`.
  @sh "fast=\(.fast_mode == true)",
  @sh "thinking=\(.thinking.enabled != false)",
  @sh "cwd=\(.cwd // "")",
  @sh "session_id=\(.session_id // "")",
  @sh "repo=\(.workspace.repo.name // "")",
  @sh "worktree=\(.worktree.name // .workspace.git_worktree // "")",
  @sh "cache_cold=\(.prompt_cache.caching_observed == true and .prompt_cache.warm == false)",
  @sh "rate5=\(.rate_limits.five_hour.used_percentage // "")",
  @sh "reset5=\(.rate_limits.five_hour.resets_at // "")",
  @sh "rate7=\(.rate_limits.seven_day.used_percentage // "")",
  @sh "reset7=\(.rate_limits.seven_day.resets_at // "")"
' 2>/dev/null)"

# Fitting the lines below measures them with ${#str}, which counts BYTES unless
# the locale is UTF-8. The separators and markers are all multi-byte, so pin a
# UTF-8 locale when the inherited one isn't; otherwise the lines shrink far
# earlier than they need to.
case "$(locale charmap 2>/dev/null)" in
  UTF-8|utf8|UTF8) ;;
  *) for l in C.UTF-8 en_US.UTF-8; do
       if locale -a 2>/dev/null | grep -qxF "$l"; then export LC_ALL="$l"; break; fi
     done ;;
esac

# Terminal width. stdout is a pipe here, but tput falls back to the tty on
# stderr, so this is usually accurate; assume a comfortable width if not.
# One column is held back: a few of the markers are "ambiguous width" and some
# terminals render them double-wide.
cols=$(tput cols 2>/dev/null)
[ -n "$cols" ] && [ "$cols" -gt 0 ] 2>/dev/null || cols=100
cols=$((cols - 1))
[ "$cols" -lt 12 ] && cols=12

# Colorize a usage percentage: red at >=90, amber at >=70, otherwise a base color.
usage_color() {
  local pct="$1" base="$2"
  if [ "${pct%%.*}" -ge 90 ] 2>/dev/null; then
    printf '%b' "$RED"
  elif [ "${pct%%.*}" -ge 70 ] 2>/dev/null; then
    printf '%b' "$BRIGHT_YELLOW"
  else
    printf '%b' "$base"
  fi
}

# Round a percentage to a whole number.
fmt_pct() { printf '%.0f' "$1" 2>/dev/null || printf '%s' "$1"; }

# Compact "time until" for a unix timestamp: 3h, 47m, 6d.
until_short() {
  local target="$1" now delta
  now=$(date +%s)
  delta=$((target - now))
  [ "$delta" -le 0 ] 2>/dev/null && { printf 'now'; return; }
  if [ "$delta" -ge 86400 ]; then printf '%dd' "$((delta / 86400))"
  elif [ "$delta" -ge 3600 ]; then printf '%dh' "$((delta / 3600))"
  else printf '%dm' "$(((delta + 59) / 60))"
  fi
}

# Compact token count: 420k, 1M, 1.5M.
fmt_tokens() {
  if [ "$1" -ge 1000000 ]; then
    awk -v n="$1" 'BEGIN { s = sprintf("%.1f", n / 1000000); sub(/\.0$/, "", s); printf "%sM", s }'
  else
    printf '%dk' "$(($1 / 1000))"
  fi
}

# Truncate a string to max chars, cutting from the middle so the tail survives
# ("feat/billing-v2" vs "feat/billing-v3"). Very small budgets keep the head.
shorten() {
  local s="$1" max="$2"
  [ "$max" -lt 4 ] && max=4
  [ "${#s}" -le "$max" ] && { printf '%s' "$s"; return; }
  if [ "$max" -lt 9 ]; then
    printf '%s…' "${s:0:$((max - 1))}"
  else
    printf '%s…%s' "${s:0:$((max - 5))}" "${s: -4}"
  fi
}

join() {
  local out="" seg
  for seg in "$@"; do
    [ -z "$seg" ] && continue
    if [ -z "$out" ]; then out="$seg"; else out="${out}${SEP}${seg}"; fi
  done
  printf '%s' "$out"
}

# Same join, but on the undecorated text, so the result can be measured against
# the pane width (the colored one is full of invisible escape bytes).
join_plain() {
  local out="" seg
  for seg in "$@"; do
    [ -z "$seg" ] && continue
    if [ -z "$out" ]; then out="$seg"; else out="${out} · ${seg}"; fi
  done
  printf '%s' "$out"
}

# ---------------------------------------------------------------------------
# Git: one porcelain=v2 call gives branch, dirt, and ahead/behind together.
# ---------------------------------------------------------------------------
branch=""; dirty=""; ahead=0; behind=0
if [ -n "$cwd" ] && command -v git >/dev/null 2>&1; then
  while IFS= read -r ln; do
    case "$ln" in
      '# branch.head '*) branch="${ln#\# branch.head }" ;;
      '# branch.ab '*)
        ab="${ln#\# branch.ab }"
        ahead="${ab%% *}"; ahead="${ahead#+}"
        behind="${ab##* }"; behind="${behind#-}"
        ;;
      '#'*) ;;
      ?*) dirty=1 ;;
    esac
  done < <(git -C "$cwd" --no-optional-locks status --porcelain=v2 --branch 2>/dev/null)
  [ "$branch" = "(detached)" ] && branch=""
fi

# ---------------------------------------------------------------------------
# Line 1: place.
# ---------------------------------------------------------------------------
loc="$repo"
[ -z "$loc" ] && [ -n "$cwd" ] && loc=$(basename "$cwd")

# Divergence from upstream, only when there is any.
sync=""
[ "${ahead:-0}" -gt 0 ] 2>/dev/null && sync="${sync}↑${ahead}"
[ "${behind:-0}" -gt 0 ] 2>/dev/null && sync="${sync}${sync:+ }↓${behind}"

# Build the place line at a given level of detail, producing the colored string
# and a plain twin for measurement. The ⧉ marker means "this is a linked
# worktree, not the main checkout". It collapses onto the branch when the
# worktree directory adds nothing over the branch name.
build_place() {
  local repo_max=$1 show_wt=$2 branch_max=$3
  local p=() c=() wt_prefix="" r w b pl co

  # repo_max of 0 drops the repo name entirely: at that width the branch is the
  # only thing that still distinguishes one pane from another.
  if [ -n "$loc" ] && [ "$repo_max" -gt 0 ]; then
    r=$(shorten "$loc" "$repo_max")
    p+=("$r"); c+=("${BLUE}${r}${RESET}")
  fi

  if [ -n "$worktree" ] && [ "$worktree" != "$loc" ]; then
    if [ "$show_wt" -eq 1 ] && [ "$worktree" != "$branch" ]; then
      w=$(shorten "$worktree" 20)
      p+=("⧉ $w"); c+=("${BRIGHT_YELLOW}⧉ ${w}${RESET}")
    else
      wt_prefix=1
    fi
  fi

  if [ -n "$branch" ]; then
    b=$(shorten "$branch" "$branch_max")
    if [ -n "$dirty" ]; then
      pl="${b}*"; co="${YELLOW}${b}*${RESET}"
    else
      pl="$b"; co="${MAGENTA}${b}${RESET}"
    fi
    [ -n "$wt_prefix" ] && { pl="⧉ $pl"; co="${BRIGHT_YELLOW}⧉ ${RESET}${co}"; }
    p+=("$pl"); c+=("$co")
  fi

  [ -n "$sync" ] && { p+=("$sync"); c+=("${DIM}${sync}${RESET}"); }

  PLACE_PLAIN=$(join_plain "${p[@]}")
  PLACE_COLOR=$(join "${c[@]}")
}

# Try progressively tighter layouts and keep the first that fits the pane.
# Detail is shed in order of least value: branch length first, then the
# separate worktree-directory segment, then the repo name.
for attempt in "24 1 40" "24 1 28" "20 1 18" "18 0 24" "14 0 16" "10 0 10" "0 0 14" "0 0 8"; do
  # shellcheck disable=SC2086
  build_place $attempt
  [ "${#PLACE_PLAIN}" -le "$cols" ] && break
done

# ---------------------------------------------------------------------------
# Line 2: session.
# ---------------------------------------------------------------------------
# Effort as a single compact token: L M H XH MAX.
case "$effort" in
  low) effort_short=L ;; medium) effort_short=M ;; high) effort_short=H ;;
  xhigh) effort_short=XH ;; max) effort_short=MAX ;;
  "") effort_short="" ;;
  *) effort_short=$(printf '%s' "$effort" | tr '[:lower:]' '[:upper:]') ;;
esac

# Context is measured against the auto-compact window when one is set below the
# model's window, since that is where the session actually compacts.
ctx_limit=${ctx_size:-0}
compact_window=${CLAUDE_CODE_AUTO_COMPACT_WINDOW:-}
if [[ "$compact_window" =~ ^[0-9]+$ ]] && [ "$compact_window" -gt 0 ] && \
   { [ "$ctx_limit" -eq 0 ] || [ "$compact_window" -lt "$ctx_limit" ]; }; then
  ctx_limit=$compact_window
fi
ctx_int=""; ctx_used=""
if [ "${ctx_tokens:-0}" -gt 0 ] 2>/dev/null && [ "$ctx_limit" -gt 0 ]; then
  ctx_int=$((ctx_tokens * 100 / ctx_limit))
  ctx_used="$(fmt_tokens "$ctx_tokens")/$(fmt_tokens "$ctx_limit")"
fi
r5=""; [ -n "$rate5" ] && r5=$(fmt_pct "$rate5")
r7=""; [ -n "$rate7" ] && r7=$(fmt_pct "$rate7")

# Build the session line at a given level of detail. Higher level = tighter.
# Model, effort, context, and both rate-limit windows survive to the last level;
# labels, token counts, the 1M marker, and reset countdowns are what get shed.
build_session() {
  local level=$1
  local p=() c=() seg_p seg_c color

  if [ -n "$model" ]; then
    # "Opus 5 (1M context)" -> "Opus 5" plus a dim 1M marker.
    local m="${model/ (1M context)/}"
    [ "$level" -ge 5 ] && m="${m%% *}"
    seg_p="$m"; seg_c="${CYAN}${m}${RESET}"
    if [ "$level" -lt 3 ] && [ "${ctx_size:-0}" -ge 1000000 ] 2>/dev/null; then
      seg_p="${seg_p}·1M"; seg_c="${seg_c}${DIM}·1M${RESET}"
    fi
    if [ -n "$effort_short" ]; then
      seg_p="${seg_p} ${effort_short}"; seg_c="${seg_c} ${BOLD}${effort_short}${RESET}"
    fi
    # Shown only when they differ from the defaults, so they read as alerts.
    if [ "$fast" = "true" ]; then
      seg_p="${seg_p} !"; seg_c="${seg_c} ${BRIGHT_YELLOW}⚡${RESET}"
    fi
    if [ "$thinking" = "false" ]; then
      if [ "$level" -ge 2 ]; then
        seg_p="${seg_p} nt"; seg_c="${seg_c} ${DIM}nt${RESET}"
      else
        seg_p="${seg_p} no-think"; seg_c="${seg_c} ${DIM}no-think${RESET}"
      fi
    fi
    p+=("$seg_p"); c+=("$seg_c")
  fi

  if [ -n "$ctx_int" ]; then
    color=$(usage_color "$ctx_int" "$DIM")
    if [ "$level" -ge 2 ]; then seg_p="${ctx_int}%"
    elif [ "$level" -ge 1 ]; then seg_p="ctx ${ctx_int}%"
    else seg_p="ctx ${ctx_used}"; fi
    p+=("$seg_p"); c+=("${color}${seg_p}${RESET}")
  fi

  # A cold cache means the next message re-caches the whole context.
  if [ "$cache_cold" = "true" ]; then
    if [ "$level" -ge 2 ]; then seg_p="cold"; else seg_p="cache cold"; fi
    p+=("$seg_p"); c+=("${YELLOW}${seg_p}${RESET}")
  fi

  if [ "$level" -ge 4 ]; then
    # Both windows collapsed into one token once the pane is genuinely tiny.
    if [ -n "$r5" ] || [ -n "$r7" ]; then
      seg_p="${r5:-–}/${r7:-–}%"
      color=$(usage_color "${r5:-0}" "$DIM")
      p+=("$seg_p"); c+=("${color}${seg_p}${RESET}")
    fi
  else
    # Dim while there's headroom, escalating to amber then red. The reset
    # countdown appears only once a window is actually worth worrying about.
    local label pct reset
    for pair in "5h|$r5|$reset5" "7d|$r7|$reset7"; do
      label="${pair%%|*}"; rest="${pair#*|}"
      pct="${rest%%|*}"; reset="${rest#*|}"
      [ -z "$pct" ] && continue
      seg_p="${label} ${pct}%"
      if [ "$level" -lt 3 ] && [ "$pct" -ge 70 ] 2>/dev/null && [ -n "$reset" ]; then
        seg_p="${seg_p} $(until_short "$reset")"
      fi
      color=$(usage_color "$pct" "$DIM")
      p+=("$seg_p"); c+=("${color}${seg_p}${RESET}")
    done
  fi

  SESSION_PLAIN=$(join_plain "${p[@]}")
  SESSION_COLOR=$(join "${c[@]}")
}

for level in 0 1 2 3 4 5; do
  build_session "$level"
  [ "${#SESSION_PLAIN}" -le "$cols" ] && break
done

printf "%b\n%b\n" "$PLACE_COLOR" "$SESSION_COLOR"
