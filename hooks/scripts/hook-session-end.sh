#!/bin/bash
# Source: METHODOLOGY.md §Plugin System — session continuity
# Event: SessionEnd (fires when Claude Code session ends)
# Role: Persist session state to .sqwr-last-state.sh for continuity across sessions

set -uo pipefail

# Read SessionEnd input
INPUT=$(cat)

# Detect project root
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

SESSION_DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)
CURRENT_BRANCH=$(git -C "$PROJECT_ROOT" branch --show-current 2>/dev/null || echo "unknown")

# Persist minimal state to .sqwr-last-state.sh
STATE_FILE="$PROJECT_ROOT/.sqwr-last-state.sh"

# Only write if file doesn't already exist with a more recent timestamp
cat > "$STATE_FILE" << STATEEOF
# SQWR Session State — persisted by hook-session-end.sh
# Generated: $SESSION_DATE
export SQWR_LAST_SESSION_DATE="$SESSION_DATE"
export SQWR_LAST_SESSION_BRANCH="$CURRENT_BRANCH"
STATEEOF

# Ensure .sqwr-last-state.sh is gitignored
GITIGNORE="$PROJECT_ROOT/.gitignore"
if [ -f "$GITIGNORE" ] && ! grep -q "\.sqwr-last-state\.sh" "$GITIGNORE" 2>/dev/null; then
  echo ".sqwr-last-state.sh" >> "$GITIGNORE"
fi

exit 0
