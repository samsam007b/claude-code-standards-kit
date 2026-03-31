#!/usr/bin/env bash
set -euo pipefail
# SQWR Hook: SubagentStart — Log subagent execution start
# Source: CONTRACT-AI-AGENTS.md (agentic execution standards)

LOG="$HOME/.sqwr-hook-log"
AGENT_NAME="${CLAUDE_TOOL_INPUT:-unknown}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SubagentStart] Agent: $AGENT_NAME" >> "$LOG"

if echo "$AGENT_NAME" | grep -qi "AUDIT\|RISK-SCORE"; then
  echo "[SQWR] Audit agent starting. Ensure project is in a clean state."
fi
exit 0
