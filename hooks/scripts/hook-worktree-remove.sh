#!/usr/bin/env bash
set -euo pipefail
# SQWR Hook: WorktreeRemove — Archive audit results before worktree removal
# Source: CONTRACT-CICD.md (git branching strategy)

LOG="$HOME/.sqwr-hook-log"
WORKTREE_PATH="${CLAUDE_WORKTREE_PATH:-}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WorktreeRemove] $WORKTREE_PATH" >> "$LOG"

if [ -z "$WORKTREE_PATH" ] || [ ! -d "$WORKTREE_PATH" ]; then
  exit 0
fi

# Archive any audit results
if [ -f "$WORKTREE_PATH/.sqwr-last-state.sh" ]; then
  ARCHIVE_DIR=".sqwr-worktree-archives"
  mkdir -p "$ARCHIVE_DIR"
  BRANCH=$(basename "$WORKTREE_PATH")
  cp "$WORKTREE_PATH/.sqwr-last-state.sh" "$ARCHIVE_DIR/${BRANCH}-$(date '+%Y%m%d-%H%M%S').sh"
  echo "[SQWR] Archived worktree state for: $BRANCH"
fi

exit 0
