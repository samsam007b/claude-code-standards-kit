#!/usr/bin/env bash
# auto-format.sh: run the right formatter on the file Claude just wrote.
#
# Event/matcher : PostToolUse on Edit|Write|MultiEdit (reads the hook JSON on stdin).
# Exit codes    : always 0. FAIL-OPEN by design: a missing or crashing formatter must
#                 never block Claude. Formatting is a convenience, not a guard.
# Bypass        : AUTO_FORMAT_DISABLE=1
#
# Formatter per extension, used only if installed:
#   ts tsx js jsx mjs cjs json css scss html md yaml yml -> prettier
#   py -> ruff format      go -> gofmt      rs -> rustfmt      swift -> swift-format
#
# Install in settings.json:
#   "PostToolUse": [{"matcher": "Edit|Write|MultiEdit",
#     "hooks": [{"type": "command", "command": "$HOME/.claude/scripts/auto-format.sh"}]}]
#
# Dependencies: python3 (JSON parsing) + whichever formatters you want.

set -uo pipefail

[ "${AUTO_FORMAT_DISABLE:-0}" = "1" ] && exit 0

INPUT=$(cat 2>/dev/null || true)

FILE_PATH=$(printf '%s' "$INPUT" | python3 -c "
import json, sys
try:
    print(json.load(sys.stdin).get('tool_input', {}).get('file_path', ''))
except Exception:
    print('')
" 2>/dev/null || echo "")

[ -n "$FILE_PATH" ] && [ -f "$FILE_PATH" ] || exit 0

case "${FILE_PATH##*.}" in
  ts|tsx|js|jsx|mjs|cjs|json|css|scss|html|md|yaml|yml)
    command -v prettier >/dev/null 2>&1 && prettier --write "$FILE_PATH" --log-level silent >/dev/null 2>&1 ;;
  py)
    command -v ruff >/dev/null 2>&1 && ruff format "$FILE_PATH" --quiet >/dev/null 2>&1 ;;
  go)
    command -v gofmt >/dev/null 2>&1 && gofmt -w "$FILE_PATH" >/dev/null 2>&1 ;;
  swift)
    command -v swift-format >/dev/null 2>&1 && swift-format -i "$FILE_PATH" >/dev/null 2>&1 ;;
  rs)
    command -v rustfmt >/dev/null 2>&1 && rustfmt "$FILE_PATH" >/dev/null 2>&1 ;;
esac

exit 0
