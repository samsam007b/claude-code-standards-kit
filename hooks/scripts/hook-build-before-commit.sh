#!/bin/bash
set -euo pipefail
# SQWR Hook — Build Before Commit
# Source: AUDIT-DEPLOYMENT.md — Pre-deployment gate (Blocking section)
# Trigger: PreToolUse on Bash (git commit)
# Action: BLOCK if npm run lint or npm run build fails
# Escape hatch: set SQWR_SKIP_BUILD_CHECK=1 to bypass

INPUT=$(cat)

COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

# Only act on git commit commands
if ! echo "$COMMAND" | grep -q "git commit"; then
  exit 0
fi

# Escape hatch
if [ "${SQWR_SKIP_BUILD_CHECK:-0}" = "1" ]; then
  echo "SQWR HOOK: Build/lint check bypassed (SQWR_SKIP_BUILD_CHECK=1)"
  exit 0
fi

# Only run if package.json is present
if [ ! -f "package.json" ]; then
  exit 0
fi

# --- Lint check ---
if npm run lint --silent 2>/dev/null; then
  : # lint passed
else
  echo ""
  echo "SQWR HOOK BLOCKED — ESLint errors detected"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  npm run lint failed. Fix all ESLint errors before committing."
  echo ""
  echo "  Bypass (emergency only): SQWR_SKIP_BUILD_CHECK=1 git commit ..."
  echo "  Ref: AUDIT-DEPLOYMENT.md — Blocking section (npm run lint passes with 0 errors)"
  echo ""
  exit 2
fi

# --- Build / type-check ---
# Prefer type-check if available (faster), fall back to build
if node -e "const p=require('./package.json'); process.exit(p.scripts && p.scripts['type-check'] ? 0 : 1)" 2>/dev/null; then
  BUILD_CMD="type-check"
else
  BUILD_CMD="build"
fi

if npm run "$BUILD_CMD" --silent 2>/dev/null; then
  : # build passed
else
  echo ""
  echo "SQWR HOOK BLOCKED — Build failed (npm run $BUILD_CMD)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Fix all TypeScript / build errors before committing."
  echo ""
  echo "  Bypass (emergency only): SQWR_SKIP_BUILD_CHECK=1 git commit ..."
  echo "  Ref: AUDIT-DEPLOYMENT.md — Blocking section (npm run build passes without errors)"
  echo ""
  exit 2
fi

exit 0
