#!/bin/bash
# file-history-rotate.sh: rotation of ~/.claude/file-history (item 2.9 of PLAN-AUDIT-360).
#
# Context: 511 MB / 23,821 files / 403 session folders on 2026-08-09, with no
# rotation policy since the store was put in service. It is the store that
# feeds /rewind; a session older than a few weeks is never rewound,
# so the space is lost for nothing. On a machine whose disk stayed
# below 25 GB free continuously from 06/22 to 08/09 (248 alerts, backup broken as
# a knock-on effect), half a dormant gigabyte is not neutral.
#
# Two criteria, applied in this order:
#   1. age: any session folder older than RETENTION_DAYS goes;
#   2. budget: if the total is still above BUDGET_MB, the oldest folders are removed
#      one by one until it falls back under budget.
# Criterion 2 exists because age alone is not enough here: on 08/09, cutting at 30
# days only freed 225 MB out of 511, most of the volume being in recent, heavy
# sessions. An age-only policy would have silently missed its target,
# which is precisely the recurring pattern of the 08/08 audit.
#
# Always kept: at least KEEP_MIN folders, whatever the age and
# budget, so /rewind is never made unusable on the current session.

set -uo pipefail

HIST="$HOME/.claude/file-history"
RETENTION_DAYS=30
BUDGET_MB=250
KEEP_MIN=40
LOG="$HOME/Library/Logs/file-history-rotate.log"

[ -d "$HIST" ] || exit 0

size_mb() { du -sk "$HIST" 2>/dev/null | awk '{print int($1/1024)}'; }

BEFORE=$(size_mb)
BEFORE_N=$(find "$HIST" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')

# --- Criterion 1: age ---
# Never go below KEEP_MIN, even if everything is old.
while IFS= read -r d; do
  [ "$(find "$HIST" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')" -le "$KEEP_MIN" ] && break
  rm -rf "$d"
done < <(find "$HIST" -mindepth 1 -maxdepth 1 -type d -mtime +"$RETENTION_DAYS" 2>/dev/null)

# --- Criterion 2: budget ---
# Sorted by ascending modification date: the oldest go first.
while [ "$(size_mb)" -gt "$BUDGET_MB" ]; do
  N=$(find "$HIST" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
  [ "$N" -le "$KEEP_MIN" ] && break
  OLDEST=$(find "$HIST" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null \
    | xargs -0 stat -f '%m %N' 2>/dev/null | sort -n | head -1 | cut -d' ' -f2-)
  [ -n "$OLDEST" ] && [ -d "$OLDEST" ] || break
  rm -rf "$OLDEST"
done

AFTER=$(size_mb)
AFTER_N=$(find "$HIST" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
echo "$(date '+%F %T') file-history: ${BEFORE}MB/${BEFORE_N}dirs -> ${AFTER}MB/${AFTER_N}dirs (retention ${RETENTION_DAYS}d, budget ${BUDGET_MB}MB)" >> "$LOG"

# Heartbeat (item 0.5): emitted no matter what, even if nothing was deleted.
# A rotation job that stops running is otherwise invisible, and that is exactly
# the failure mode the canary exists to catch.
"$HOME/.claude/scripts/lib/heartbeat.sh" file-history-rotate 2>/dev/null || true
