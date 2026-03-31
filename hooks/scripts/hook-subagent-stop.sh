#!/usr/bin/env bash
set -euo pipefail
# SQWR Hook: SubagentStop — Log subagent execution end and capture audit results

LOG="$HOME/.sqwr-hook-log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SubagentStop] Agent completed" >> "$LOG"

# Check if an audit score was stored
# Source: CONTRACT-AI-AGENTS.md (agentic execution standards)
if [ -f ".sqwr-last-state.sh" ] && grep -q "SQWR_LAST_SCORE" ".sqwr-last-state.sh" 2>/dev/null; then
  SCORE=$(grep "SQWR_LAST_SCORE" ".sqwr-last-state.sh" | cut -d'=' -f2)
  echo "[SQWR] Last audit score: $SCORE/100"
fi
exit 0
