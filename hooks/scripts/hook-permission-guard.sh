#!/usr/bin/env bash
set -euo pipefail
# SQWR Hook: PermissionRequest — Block dangerous operations
# EXIT 2 = blocking (Claude cannot proceed)
# Source: CONTRACT-SECURITY.md (OWASP least privilege principle)

LOG="$HOME/.sqwr-hook-log"
TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [PermissionRequest] Checking: $TOOL_INPUT" >> "$LOG"

# Block dangerous patterns
DANGEROUS_PATTERNS="rm -rf|sudo rm|chmod 777|chmod -R 777|dd if=|mkfs|DROP TABLE|DELETE FROM.*WHERE 1=1"
if echo "$TOOL_INPUT" | grep -qE "${DANGEROUS_PATTERNS}"; then
  echo "[SQWR BLOCKED] Dangerous operation detected: $TOOL_INPUT"
  echo "This operation requires manual execution. SQWR security policy prevents automated destructive commands."
  exit 2
fi

exit 0
