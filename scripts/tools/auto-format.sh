#!/bin/bash
# auto-format.sh — PostToolUse(Edit/Write) hook
# Runs the appropriate formatter on the file just edited.
# Fails gracefully: exit 0 always so it never blocks Claude.

set -euo pipefail

# Read JSON from stdin
INPUT=$(cat)

# Extract file_path from tool_input
FILE_PATH=$(echo "$INPUT" | python3 -c "
import json, sys
data = json.load(sys.stdin)
path = data.get('tool_input', {}).get('file_path', '')
print(path)
" 2>/dev/null || echo "")

# Exit if no file path or file doesn't exist
if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

EXT="${FILE_PATH##*.}"

case "$EXT" in
  ts|tsx|js|jsx|mjs|cjs|json|css|scss|html|md|yaml|yml)
    if command -v prettier &>/dev/null; then
      prettier --write "$FILE_PATH" --log-level silent 2>/dev/null || true
    fi
    ;;
  py)
    if command -v ruff &>/dev/null; then
      ruff format "$FILE_PATH" --quiet 2>/dev/null || true
    fi
    ;;
  go)
    if command -v gofmt &>/dev/null; then
      gofmt -w "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  swift)
    if command -v swift-format &>/dev/null; then
      swift-format -i "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
  rs)
    if command -v rustfmt &>/dev/null; then
      rustfmt "$FILE_PATH" 2>/dev/null || true
    fi
    ;;
esac

exit 0
