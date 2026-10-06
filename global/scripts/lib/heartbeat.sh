#!/usr/bin/env bash
# heartbeat.sh: one heartbeat per job, all in a single TSV file.
#
# Pattern: every automation (cron, LaunchAgent, systemd timer, CI job) records a
# heartbeat when it runs. ONE watchdog (heartbeat-watchdog.sh) reads the file and
# compares it with an expected registry. One watchdog per job reproduces the original
# problem (the watchdog itself dies silently); one file read by one controller does not.
#
# WHERE to place the call (the lesson that matters):
#   "only at the end of a successful run" is wrong for many jobs. A heartbeat placed
#   at the end of the file only fires on the longest path, yet most jobs spend their
#   life on a short, healthy path ("nothing to do today", "disk under threshold",
#   "today's archive already written"). The heartbeat then goes quiet precisely on the
#   days everything is fine, the opposite of the signal you want. So:
#     - place it AFTER whatever proves the script started healthy (variables read,
#       input found, measurement done),
#     - but BEFORE early exits that are normal operation,
#     - and NEVER on an error path already reported elsewhere: a courtesy heartbeat on
#       an `exit 1` hides the failure instead of surfacing it.
#
# Usage:
#   source "$HOME/.claude/scripts/lib/heartbeat.sh"; heartbeat my-backup
#   or directly: "$HOME/.claude/scripts/lib/heartbeat.sh" my-backup
#
# Environment: HEARTBEAT_FILE (default $HOME/.claude/state/heartbeats.tsv)
# File format: <job>\t<UTC ISO-8601 timestamp>   (one line per job, sorted)

HEARTBEAT_FILE="${HEARTBEAT_FILE:-$HOME/.claude/state/heartbeats.tsv}"

heartbeat() {
  local job="${1:-}"
  [ -n "$job" ] || return 1
  mkdir -p "$(dirname "$HEARTBEAT_FILE")"
  local now tmp
  now=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
  # Atomic rewrite: jobs may beat in parallel. A plain append leaves duplicates and a
  # partial write leaves a truncated file.
  tmp=$(mktemp "${HEARTBEAT_FILE}.XXXXXX") || return 1
  if [ -f "$HEARTBEAT_FILE" ]; then
    awk -F'\t' -v j="$job" '$1 != j' "$HEARTBEAT_FILE" > "$tmp" 2>/dev/null || true
  fi
  printf '%s\t%s\n' "$job" "$now" >> "$tmp"
  LC_ALL=C sort -o "$tmp" "$tmp"
  mv "$tmp" "$HEARTBEAT_FILE"
}

# Direct execution rather than sourcing.
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  heartbeat "$@"
fi
