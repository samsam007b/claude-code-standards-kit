#!/bin/bash
# SQWR Hook — Session Context Loader
# Source: METHODOLOGY.md — "search first, implement after" principle
# Trigger: SessionStart
# Action: Detect project stack and surface active contracts to the AI context

set -euo pipefail

# Only write to env file if available
ENV_FILE="${CLAUDE_ENV_FILE:-}"

# Detect project root
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# --- Restore previous session state if available ---
PREV_STATE="$PROJECT_ROOT/.sqwr-last-state.sh"
if [ -f "$PREV_STATE" ]; then
  # shellcheck disable=SC1090
  source "$PREV_STATE" 2>/dev/null || true
fi

# ─── Stack detection ─────────────────────────────────────────────
DETECTED_STACK="unknown"

if [ -f "next.config.ts" ] || [ -f "next.config.js" ] || [ -f "next.config.mjs" ]; then
  DETECTED_STACK="nextjs"
  if grep -qiE "(supabase|@supabase)" package.json 2>/dev/null; then
    DETECTED_STACK="nextjs-supabase"
  fi
elif [ -f "Package.swift" ]; then
  DETECTED_STACK="ios"
elif [ -f "build.gradle.kts" ] || [ -f "build.gradle" ]; then
  DETECTED_STACK="android"
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
  DETECTED_STACK="python"
elif [ -f "package.json" ]; then
  DETECTED_STACK="node"
fi

# ─── Active contracts from CLAUDE.md ────────────────────────────
ACTIVE_CONTRACTS=""
if [ -f "CLAUDE.md" ]; then
  # Extract checked contracts (lines with [x] CONTRACT-)
  ACTIVE_CONTRACTS=$(grep -oE "\[x\] \`CONTRACT-[A-Z0-9-]+\.md\`" CLAUDE.md 2>/dev/null | grep -oE "CONTRACT-[A-Z0-9-]+" | tr '\n' ',' | sed 's/,$//' || echo "")
fi

# ─── Last audit score ────────────────────────────────────────────
LAST_AUDIT_AGE="no audit on record"
if [ -f ".sqwr-last-audit" ]; then
  LAST_AUDIT_MTIME=$(stat -f "%m" .sqwr-last-audit 2>/dev/null || stat -c "%Y" .sqwr-last-audit 2>/dev/null || echo 0)
  NOW=$(date +%s)
  AGE_HOURS=$(( (NOW - LAST_AUDIT_MTIME) / 3600 ))
  if [ "$AGE_HOURS" -lt 24 ]; then
    LAST_AUDIT_AGE="${AGE_HOURS}h ago"
  else
    AGE_DAYS=$(( AGE_HOURS / 24 ))
    LAST_AUDIT_AGE="${AGE_DAYS}d ago"
  fi
fi

# ─── Write to env file ───────────────────────────────────────────
if [ -n "$ENV_FILE" ]; then
  echo "SQWR_STACK=$DETECTED_STACK" >> "$ENV_FILE"
  if [ -n "$ACTIVE_CONTRACTS" ]; then
    echo "SQWR_ACTIVE_CONTRACTS=$ACTIVE_CONTRACTS" >> "$ENV_FILE"
  fi
  echo "SQWR_LAST_AUDIT=$LAST_AUDIT_AGE" >> "$ENV_FILE"
fi

# ─── Output context reminder ─────────────────────────────────────
echo ""
echo "SQWR Standards Kit — Session initialized"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Stack detected  : $DETECTED_STACK"
if [ -n "$ACTIVE_CONTRACTS" ]; then
  echo "  Active contracts: $ACTIVE_CONTRACTS"
else
  echo "  Active contracts: none (check CLAUDE.md [x] items)"
fi
echo "  Last audit      : $LAST_AUDIT_AGE"
echo ""
echo "  Tip: Run /full-audit or ask Claude to run AGENT-FULL-AUDIT.md"
echo ""

exit 0
