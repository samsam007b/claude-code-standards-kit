#!/bin/bash
# Source: METHODOLOGY.md §Plugin System — PreCompact hook
# Event: PreCompact (fires before context compression)
# Role: Persist session state to a file BEFORE context is compressed
#       Uses file-based persistence (CLAUDE_ENV_FILE not supported for PreCompact)
# Fix: Writes to .sqwr-last-state.sh instead of CLAUDE_ENV_FILE

set -euo pipefail

# Detect project root (where CLAUDE.md lives)
PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Target state file (will be sourced by SessionStart hook)
STATE_FILE="$PROJECT_ROOT/.sqwr-last-state.sh"

# --- Detect tech stack ---
STACK="unknown"
[ -f "$PROJECT_ROOT/next.config.ts" ] || [ -f "$PROJECT_ROOT/next.config.js" ] || [ -f "$PROJECT_ROOT/next.config.mjs" ] && STACK="nextjs"
[ -f "$PROJECT_ROOT/Package.swift" ] && STACK="ios"
[ -f "$PROJECT_ROOT/build.gradle.kts" ] || [ -f "$PROJECT_ROOT/build.gradle" ] && STACK="android"
[ -f "$PROJECT_ROOT/pyproject.toml" ] || [ -f "$PROJECT_ROOT/requirements.txt" ] && STACK="python"

# --- Extract active contracts from CLAUDE.md ---
ACTIVE_CONTRACTS=""
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"
if [ -f "$CLAUDE_MD" ]; then
  ACTIVE_CONTRACTS=$(grep -E "^\s*-\s*\[x\]" "$CLAUDE_MD" | grep -oE "CONTRACT-[A-Z-]+" | tr '\n' ',' | sed 's/,$//' || echo "")
fi

# --- Detect last audit timestamp ---
LAST_AUDIT_HOURS="never"
AUDIT_MARKER="$PROJECT_ROOT/.sqwr-last-audit"
if [ -f "$AUDIT_MARKER" ]; then
  AUDIT_AGE=$(( ( $(date +%s) - $(date -r "$AUDIT_MARKER" +%s 2>/dev/null || echo 0) ) / 3600 ))
  LAST_AUDIT_HOURS="${AUDIT_AGE}h ago"
fi

# --- Count open tech debt markers ---
OPEN_TODOS=0
if [ -d "$PROJECT_ROOT/src" ]; then
  OPEN_TODOS=$(grep -rn "TODO\|FIXME\|HACK\|XXX" "$PROJECT_ROOT/src" --include="*.ts" --include="*.tsx" --include="*.py" 2>/dev/null | wc -l | tr -d ' ' || echo "0")
fi

# --- Write state to file (sourceable by SessionStart) ---
cat > "$STATE_FILE" << STATEEOF
# SQWR Session State — persisted by hook-pre-compact.sh
# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
export SQWR_STACK="$STACK"
export SQWR_ACTIVE_CONTRACTS="$ACTIVE_CONTRACTS"
export SQWR_LAST_AUDIT="$LAST_AUDIT_HOURS"
export SQWR_OPEN_TODOS="$OPEN_TODOS"
STATEEOF

# Ensure state file is gitignored
GITIGNORE="$PROJECT_ROOT/.gitignore"
if [ -f "$GITIGNORE" ] && ! grep -q "\.sqwr-last-state\.sh" "$GITIGNORE" 2>/dev/null; then
  echo ".sqwr-last-state.sh" >> "$GITIGNORE"
fi

exit 0
