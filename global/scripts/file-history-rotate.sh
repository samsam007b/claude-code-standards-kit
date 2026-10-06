#!/usr/bin/env bash
# file-history-rotate.sh: rotate ~/.claude/file-history.
#
# That directory is the store behind /rewind. A session older than a few weeks is never
# rewound, so the space is lost for nothing, and it grows without bound (hundreds of MB
# after a few months).
#
# Two criteria, applied in this order:
#   1. age:    any session folder older than RETENTION_DAYS goes;
#   2. budget: if the total is still above BUDGET_MB, remove the oldest folders one by
#      one until under budget.
# Criterion 2 exists because age alone can silently miss its target: cutting at 30 days
# may free only a fraction of the volume when most of it sits in recent, heavy sessions.
#
# Always kept: at least KEEP_MIN folders, whatever the age and budget, so /rewind never
# becomes unusable on the current session.
#
# Environment: CLAUDE_DIR, RETENTION_DAYS (30), BUDGET_MB (250), KEEP_MIN (40),
#              FILE_HISTORY_LOG (default $CLAUDE_DIR/logs/file-history-rotate.log)
# Emits a heartbeat (lib/heartbeat.sh) when available, even if nothing was removed.

set -uo pipefail

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
HIST="$CLAUDE_DIR/file-history"
RETENTION_DAYS="${RETENTION_DAYS:-30}"
BUDGET_MB="${BUDGET_MB:-250}"
KEEP_MIN="${KEEP_MIN:-40}"
LOG="${FILE_HISTORY_LOG:-$CLAUDE_DIR/logs/file-history-rotate.log}"

[ -d "$HIST" ] || exit 0
mkdir -p "$(dirname "$LOG")"

size_mb() { du -sk "$HIST" 2>/dev/null | awk '{print int($1/1024)}'; }
count_dirs() { find "$HIST" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' '; }
# Portable "mtime<TAB>path" (BSD stat, then GNU stat).
mtime_path() { stat -f '%m %N' "$@" 2>/dev/null || stat -c '%Y %n' "$@" 2>/dev/null; }

BEFORE=$(size_mb); BEFORE_N=$(count_dirs)

# Criterion 1: age.
while IFS= read -r d; do
  [ "$(count_dirs)" -le "$KEEP_MIN" ] && break
  rm -rf "$d"
done < <(find "$HIST" -mindepth 1 -maxdepth 1 -type d -mtime +"$RETENTION_DAYS" 2>/dev/null)

# Criterion 2: budget, oldest first.
while [ "$(size_mb)" -gt "$BUDGET_MB" ]; do
  [ "$(count_dirs)" -le "$KEEP_MIN" ] && break
  OLDEST=$(find "$HIST" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null \
    | xargs -0 stat -f '%m %N' 2>/dev/null | sort -n | head -1 | cut -d' ' -f2-)
  if [ -z "$OLDEST" ]; then
    OLDEST=$(find "$HIST" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null \
      | xargs -0 stat -c '%Y %n' 2>/dev/null | sort -n | head -1 | cut -d' ' -f2-)
  fi
  [ -n "$OLDEST" ] && [ -d "$OLDEST" ] || break
  rm -rf "$OLDEST"
done

AFTER=$(size_mb); AFTER_N=$(count_dirs)
echo "$(date '+%F %T') file-history: ${BEFORE}MB/${BEFORE_N}dirs -> ${AFTER}MB/${AFTER_N}dirs (retention ${RETENTION_DAYS}d, budget ${BUDGET_MB}MB)" >> "$LOG"

HB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/heartbeat.sh"
[ -x "$HB" ] && "$HB" file-history-rotate 2>/dev/null || true
exit 0
