#!/bin/bash
set -euo pipefail
# SQWR Hook — Contract Compliance Check
# Source: All active contracts in contracts/
# Trigger: PostToolUse on Write (source files)
# Action: WARN (exit 0) with specific contract violations detected in written files

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null || echo "")
CONTENT=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('content',''))" 2>/dev/null || echo "")

# Only act on source files
if ! echo "$FILE_PATH" | grep -qE "\.(ts|tsx|js|jsx|py|swift|go|rs)$"; then
  exit 0
fi

WARNINGS=()

IS_TS=false
IS_TSX=false
echo "$FILE_PATH" | grep -qE "\.(ts|tsx|js|jsx)$" && IS_TS=true
echo "$FILE_PATH" | grep -qE "\.(tsx|jsx)$" && IS_TSX=true

# --- TypeScript/JS checks ---
if $IS_TS; then
  # Count explicit `any` type annotations (: any, <any>, as any)
  ANY_COUNT=$(echo "$CONTENT" | grep -oE "(: any|<any>| as any)" | wc -l | tr -d ' ')
  if [ "$ANY_COUNT" -gt 3 ]; then
    WARNINGS+=("$FILE_PATH: $ANY_COUNT occurrences of 'any' type detected (threshold: 3) — TypeScript strict mode required. Ref: AUDIT-DEPLOYMENT.md (TypeScript strict — no any error)")
  fi

  # @ts-ignore without explanatory comment on the same line
  while IFS= read -r line; do
    if echo "$line" | grep -q "@ts-ignore"; then
      if ! echo "$line" | grep -qE "@ts-ignore\s*:?\s*\S+"; then
        WARNINGS+=("$FILE_PATH: @ts-ignore used without an explanatory comment — add a reason on the same line")
        break
      fi
    fi
  done <<< "$CONTENT"

  # console.log in non-debug/test files
  FILE_LOWER=$(echo "$FILE_PATH" | tr '[:upper:]' '[:lower:]')
  if ! echo "$FILE_LOWER" | grep -qE "(debug|test|spec|story|mock|fixture)"; then
    if echo "$CONTENT" | grep -q "console\.log"; then
      WARNINGS+=("$FILE_PATH: console.log detected in production source file — remove before committing. Ref: AUDIT-DEPLOYMENT.md (No debug console.log)")
    fi
  fi
fi

# --- TSX/JSX: img without alt ---
if $IS_TSX; then
  if echo "$CONTENT" | grep -qE "<img\b" && echo "$CONTENT" | grep -E "<img\b" | grep -qv "alt="; then
    WARNINGS+=("$FILE_PATH: <img> element without alt attribute detected — required for accessibility (Lighthouse Accessibility ≥90). Ref: AUDIT-DEPLOYMENT.md")
  fi
fi

# --- All files: TODO / FIXME / HACK comments ---
TODO_COUNT=$(echo "$CONTENT" | grep -cE "(TODO|FIXME|HACK)\b" || true)
if [ "$TODO_COUNT" -gt 0 ]; then
  WARNINGS+=("$FILE_PATH: $TODO_COUNT TODO/FIXME/HACK comment(s) found — track in issue tracker before merging to main")
fi

# Output warnings if any
if [ ${#WARNINGS[@]} -gt 0 ]; then
  echo ""
  echo "SQWR HOOK WARNING — Contract compliance issues in written file"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  for w in "${WARNINGS[@]}"; do
    echo "  • $w"
  done
  echo ""
fi

# Advisory only — never block
exit 0
