#!/usr/bin/env bash
set -euo pipefail
# SQWR Hook: WorktreeCreate — Copy SQWR config into new worktree
# Source: CONTRACT-CICD.md (git branching strategy)

LOG="$HOME/.sqwr-hook-log"
WORKTREE_PATH="${CLAUDE_WORKTREE_PATH:-}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WorktreeCreate] $WORKTREE_PATH" >> "$LOG"

if [ -z "$WORKTREE_PATH" ] || [ ! -d "$WORKTREE_PATH" ]; then
  exit 0
fi

# Copy last state to worktree if exists
if [ -f ".sqwr-last-state.sh" ]; then
  cp ".sqwr-last-state.sh" "$WORKTREE_PATH/.sqwr-last-state.sh"
  echo "[SQWR] Copied .sqwr-last-state.sh to worktree: $WORKTREE_PATH"
fi

exit 0
