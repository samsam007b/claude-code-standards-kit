#!/usr/bin/env bash
set -euo pipefail
# SQWR Hook: PostCompact — Restore context after conversation compression
# Reads .sqwr-last-state.sh and echoes its content to help Claude restore context
# Source: AUDIT-RISK-SCORE.md (context persistence after compression)

LOG="$HOME/.sqwr-hook-log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [PostCompact] Restoring SQWR context" >> "$LOG"

STATE_FILE=".sqwr-last-state.sh"
if [ -f "$STATE_FILE" ]; then
  echo "=== SQWR Context Restored After Compact ==="
  cat "$STATE_FILE"
  echo "==========================================="
else
  echo "[SQWR] No previous state found. Starting fresh session."
fi
exit 0
