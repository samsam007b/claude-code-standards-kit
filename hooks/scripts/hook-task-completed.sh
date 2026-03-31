#!/usr/bin/env bash
set -euo pipefail
# SQWR Hook: TaskCompleted — Log task completion
# Source: CONTRACT-CICD.md (deployment workflow)

LOG="$HOME/.sqwr-hook-log"
TASK_LOG=".sqwr-task-log"
TASK="${CLAUDE_TASK_TITLE:-unknown task}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [TaskCompleted] $TASK" >> "$LOG"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] COMPLETED: $TASK" >> "$TASK_LOG"
exit 0
