#!/usr/bin/env bash
set -euo pipefail
# SQWR Hook: TeammateIdle — Log teammate idle state for agent team coordination
# Source: CONTRACT-AI-AGENTS.md (multi-agent coordination)

LOG="$HOME/.sqwr-hook-log"
TEAMMATE="${CLAUDE_TEAMMATE_NAME:-unknown}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [TeammateIdle] $TEAMMATE is idle" >> "$LOG"

# Check task log for pending tasks
if [ -f ".sqwr-task-log" ]; then
  PENDING=$(grep "CREATED:" ".sqwr-task-log" | wc -l)
  COMPLETED=$(grep "COMPLETED:" ".sqwr-task-log" | wc -l)
  REMAINING=$((PENDING - COMPLETED))
  if [ "$REMAINING" -gt 0 ]; then
    echo "[SQWR] $REMAINING tasks remaining in queue. Teammate $TEAMMATE can pick up work."
  fi
fi

exit 0
