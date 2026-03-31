#!/bin/bash
# Source: CONTRACT-TYPESCRIPT.md §Debug — no console.log in production code
# Source: CONTRACT-TESTING.md §Code Hygiene — TODO markers require ticket references
# Event: Stop (fires after each Claude Code response)
# Role: Advisory check — detects debug artifacts introduced in the last response
# Mode: async (non-blocking — never delays Claude's response)

set -uo pipefail

# Read Stop event input (contains response metadata)
INPUT=$(cat)

# Detect project root
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Only run in a git repo
if ! git -C "$PROJECT_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  exit 0
fi

# Get modified TypeScript files since last commit
MODIFIED_FILES=$(git -C "$PROJECT_ROOT" diff --name-only HEAD 2>/dev/null | grep -E "\.(ts|tsx|js|jsx)$" || echo "")

if [ -z "$MODIFIED_FILES" ]; then
  exit 0
fi

WARNINGS_FOUND=0

for file in $MODIFIED_FILES; do
  full_path="$PROJECT_ROOT/$file"
  [ ! -f "$full_path" ] && continue

  # Check for console.log additions in new lines only
  if git -C "$PROJECT_ROOT" diff HEAD -- "$file" 2>/dev/null | grep "^+" | grep -qE "console\.(log|debug|info)\(" ; then
    echo "⚠️  SQWR: console.log in $file — remove before commit (CONTRACT-TYPESCRIPT §Debug)" >&2
    WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
  fi

  # Check for TODO without ticket reference
  if git -C "$PROJECT_ROOT" diff HEAD -- "$file" 2>/dev/null | grep "^+" | grep -qE "\bTODO[^(#]" ; then
    echo "⚠️  SQWR: TODO without ticket in $file — use TODO(#issue) format (CONTRACT-TESTING §Tech Debt)" >&2
    WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
  fi
done

# Advisory only — always exit 0 (never block)
exit 0
