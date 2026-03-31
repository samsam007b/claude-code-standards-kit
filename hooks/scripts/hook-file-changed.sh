#!/usr/bin/env bash
set -euo pipefail
# SQWR Hook: FileChanged — Check contract compliance on modified file

LOG="$HOME/.sqwr-hook-log"
CHANGED_FILE="${CLAUDE_FILE_PATH:-}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [FileChanged] $CHANGED_FILE" >> "$LOG"

if [ -z "$CHANGED_FILE" ] || [ ! -f "$CHANGED_FILE" ]; then
  exit 0
fi

# Check for console.log in TypeScript/JavaScript files
if echo "$CHANGED_FILE" | grep -qE "\.(ts|tsx|js|jsx)$"; then
  if grep -n "console\.log" "$CHANGED_FILE" 2>/dev/null | grep -v "// sqwr:allow" | head -5; then
    echo "[SQWR WARNING] console.log detected in $CHANGED_FILE. Use structured logging per CONTRACT-OBSERVABILITY.md."
  fi
fi

exit 0
