#!/usr/bin/env bash
set -euo pipefail
# SQWR Hook: UserPromptSubmit — Detect intent and suggest relevant contracts

LOG="$HOME/.sqwr-hook-log"
PROMPT="${CLAUDE_USER_PROMPT:-}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [UserPromptSubmit] Analyzing intent" >> "$LOG"

if [ -z "$PROMPT" ]; then
  exit 0
fi

# Detect security-related intent
if echo "$PROMPT" | grep -qiE "auth|password|secret|token|sql|xss|inject|vuln"; then
  echo "[SQWR] Security-sensitive request detected. CONTRACT-SECURITY.md applies."
fi

# Detect accessibility-related intent
if echo "$PROMPT" | grep -qiE "button|form|image|color|contrast|aria|a11y|wcag"; then
  echo "[SQWR] Accessibility concern detected. CONTRACT-ACCESSIBILITY.md applies."
fi

# Detect performance-related intent
if echo "$PROMPT" | grep -qiE "slow|performa|optim|bundle|lazy|cache|lcp|cls|inp"; then
  echo "[SQWR] Performance concern detected. CONTRACT-PERFORMANCE.md applies."
fi

# Detect API-related intent
if echo "$PROMPT" | grep -qiE "api|endpoint|route|request|response|rest|graphql"; then
  echo "[SQWR] API concern detected. CONTRACT-API.md applies."
fi

# Detect large-scope implementation — suggest brainstorm
if echo "$PROMPT" | grep -qiE "implement|refactor|rewrite|migrate|redesign|overhaul|rebuild"; then
  if echo "$PROMPT" | grep -qiE "all|every|entire|whole|complete|full system|entire codebase"; then
    echo "[SQWR] Large-scope implementation detected. Consider running /brainstorm first. Ref: CONTRACT-ANTI-PATTERNS.md §6 (Context Drift)"
  fi
fi

# Detect anti-rationalization patterns
if echo "$PROMPT" | grep -qiE "just do it|no tests|skip.*(test|check|lint)|ignore.*(error|warning)|force.*(merge|push)|bypass|quick(ly)?.*don.t"; then
  echo "[SQWR] Request to bypass quality standards detected. Ref: CONTRACT-ANTI-PATTERNS.md §2 (Anti-Rationalization)"
fi

# Detect database migration risk
if echo "$PROMPT" | grep -qiE "migrat|schema change|alter table|drop column|rename.*column|add.*column"; then
  echo "[SQWR] Database migration detected. Run /brainstorm first. Ref: CONTRACT-DATABASE-MIGRATIONS.md + CONTRACT-ANTI-PATTERNS.md §6"
fi

exit 0
