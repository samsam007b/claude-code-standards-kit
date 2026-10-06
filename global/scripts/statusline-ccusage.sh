#!/usr/bin/env bash
# statusline-ccusage.sh: Claude Code status line with git state and ccusage costs.
#
# Shows: git branch (+dirty marker and +/- line counts), directory, model,
# session cost / today's cost / active 5h block cost (and time left), session tokens.
#
# Install in ~/.claude/settings.json:
#   "statusLine": { "type": "command", "command": "$HOME/.claude/scripts/statusline-ccusage.sh" }
#
# Claude Code feeds a JSON document on stdin (session_id, model.display_name, workspace.current_dir).
# ccusage calls are slow, so daily/block numbers are cached for STATUSLINE_CACHE_TTL seconds.
#
# Environment: STATUSLINE_CACHE_TTL (default 60)
# Dependencies: jq (required); git, ccusage (optional: costs show 0.00 without it); bc (optional)

set -uo pipefail

GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; PURPLE=$'\033[0;35m'
GRAY=$'\033[0;90m'; LIGHT_GRAY=$'\033[0;37m'; RESET=$'\033[0m'

command -v jq >/dev/null 2>&1 || { echo "statusline: jq required"; exit 0; }

input=$(cat)
session_id=$(jq -r '.session_id // empty' <<<"$input")
model_name=$(jq -r '.model.display_name // empty' <<<"$input")
current_dir=$(jq -r '.workspace.current_dir // .cwd // empty' <<<"$input")
[ -n "$current_dir" ] && cd "$current_dir" 2>/dev/null

# --- Git ---------------------------------------------------------------------------
branch="no-git"
if git rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git branch --show-current 2>/dev/null)
  [ -z "$branch" ] && branch="detached"
  if ! git diff-index --quiet HEAD -- 2>/dev/null || ! git diff-index --quiet --cached HEAD -- 2>/dev/null; then
    read -r added deleted < <( { git diff --numstat; git diff --cached --numstat; } 2>/dev/null \
      | awk '{a+=$1; d+=$2} END {print a+0, d+0}')
    changes=""
    [ "${added:-0}" -gt 0 ] && changes="${GREEN}+$added${RESET}"
    if [ "${deleted:-0}" -gt 0 ]; then
      changes="${changes:+$changes }${RED}-$deleted${RESET}"
    fi
    branch="$branch${PURPLE}*${RESET}${changes:+ ($changes)}"
  fi
fi
dir_name=$(basename "${current_dir:-$PWD}")

format_tokens() {
  local t=$1
  if [ "$t" -ge 1000000 ]; then awk -v t="$t" 'BEGIN{printf "%.1fM", t/1000000}'
  elif [ "$t" -ge 1000 ]; then awk -v t="$t" 'BEGIN{printf "%.1fK", t/1000}'
  else printf "%d" "$t"; fi
}
format_time() {
  local m=$1
  if [ $((m / 60)) -gt 0 ]; then printf "%dh %dm" $((m / 60)) $((m % 60)); else printf "%dm" "$m"; fi
}

session_cost="0.00"; session_tokens=0; daily_cost="0.00"; block_cost="0.00"; remaining_time=""

if command -v ccusage >/dev/null 2>&1; then
  # Session tokens (input + output only: cache tokens are shared across messages).
  if [ -n "$session_id" ]; then
    f=""
    for base in "$HOME/.config/claude/projects" "$HOME/.claude/projects"; do
      [ -d "$base" ] || continue
      f=$(find "$base" -name "${session_id}.jsonl" -type f 2>/dev/null | head -1)
      [ -n "$f" ] && break
    done
    if [ -n "$f" ]; then
      session_tokens=$(jq -s '[.[] | .message.usage? | select(. != null) | (.input_tokens // 0) + (.output_tokens // 0)] | add // 0' "$f" 2>/dev/null || echo 0)
      c=$(ccusage statusline <<<"$input" 2>/dev/null | sed -n 's/.*💰 \([^[:space:]]*\) session.*/\1/p')
      [ -n "$c" ] && [ "$c" != "N/A" ] && session_cost="${c//\$/}"
    fi
  fi

  # Daily + block costs, cached.
  cache="${TMPDIR:-/tmp}/statusline-ccusage-${USER:-u}.cache"
  ttl="${STATUSLINE_CACHE_TTL:-60}"
  fresh=0
  if [ -f "$cache" ]; then
    mt=$(stat -f %m "$cache" 2>/dev/null || stat -c %Y "$cache" 2>/dev/null || echo 0)
    [ $(( $(date +%s) - mt )) -lt "$ttl" ] && fresh=1
  fi
  if [ "$fresh" = 0 ]; then
    today=$(date +%Y%m%d)
    d=$(ccusage daily --json --since "$today" 2>/dev/null | jq -r '.totals.totalCost // 0' 2>/dev/null || echo 0)
    ab=$(ccusage blocks --active --json 2>/dev/null | jq -c '[.blocks[]? | select(.isActive == true)][0] // {}' 2>/dev/null || echo '{}')
    bc_=$(jq -r '.costUSD // 0' <<<"$ab" 2>/dev/null || echo 0)
    rm_=$(jq -r '.projection.remainingMinutes // 0' <<<"$ab" 2>/dev/null || echo 0)
    printf '%s\t%s\t%s\n' "${d:-0}" "${bc_:-0}" "${rm_:-0}" > "$cache" 2>/dev/null || true
  fi
  if [ -f "$cache" ]; then
    IFS=$'\t' read -r daily_cost block_cost rem < "$cache"
    case "${rem%.*}" in ''|0|null) ;; *[!0-9]*) ;; *) remaining_time=$(format_time "${rem%.*}") ;; esac
  fi
fi

printf -v sc "%.2f" "${session_cost:-0}" 2>/dev/null || sc="0.00"
printf -v dc "%.2f" "${daily_cost:-0}" 2>/dev/null || dc="0.00"
printf -v bc "%.2f" "${block_cost:-0}" 2>/dev/null || bc="0.00"

line="${LIGHT_GRAY}$branch ${GRAY}|${LIGHT_GRAY} $dir_name ${GRAY}|${LIGHT_GRAY} $model_name ${GRAY}|${LIGHT_GRAY} session \$$sc ${GRAY}/${LIGHT_GRAY} today \$$dc ${GRAY}/${LIGHT_GRAY} block \$$bc"
[ -n "$remaining_time" ] && line="$line ($remaining_time left)"
line="$line ${GRAY}|${LIGHT_GRAY} $(format_tokens "${session_tokens:-0}") ${GRAY}tokens${RESET}"

printf "%s\n" "$line"
