#!/usr/bin/env bash
set -euo pipefail
# SQWR Hook: InstructionsLoaded — Inject SQWR context when project instructions load
# Supported: InstructionsLoaded can write to CLAUDE_ENV_FILE
# Source: CONTRACT-AI-PROMPTING.md (session context injection)

LOG="$HOME/.sqwr-hook-log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [InstructionsLoaded] Injecting SQWR context" >> "$LOG"

# Inject SQWR version info if CLAUDE_ENV_FILE is available
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "SQWR_KIT_VERSION=3.1.0" >> "$CLAUDE_ENV_FILE"
  echo "SQWR_AUDIT_THRESHOLD=85" >> "$CLAUDE_ENV_FILE"

  # Detect stack
  if [ -f "next.config.ts" ] || [ -f "next.config.js" ] || [ -f "next.config.mjs" ]; then
    echo "SQWR_STACK=nextjs" >> "$CLAUDE_ENV_FILE"
  elif [ -f "package.json" ]; then
    echo "SQWR_STACK=nodejs" >> "$CLAUDE_ENV_FILE"
  elif [ -f "Package.swift" ]; then
    echo "SQWR_STACK=swift" >> "$CLAUDE_ENV_FILE"
  fi
fi

exit 0
