#!/bin/bash
set -euo pipefail
# SQWR Hook — Audit Before Push
# Source: AUDIT-INDEX.md — sequencing and gates
# Trigger: PreToolUse on Bash (git push)
# Action: WARN (exit 0) — reminds to run audit agents if not recently done

INPUT=$(cat)

COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

# Only act on git push commands
if ! echo "$COMMAND" | grep -q "git push"; then
  exit 0
fi

AUDIT_FILE=".sqwr-last-audit"
AUDIT_MAX_AGE_SECONDS=86400  # 24 hours

if [ -f "$AUDIT_FILE" ]; then
  # Get file modification time in epoch seconds (macOS compatible)
  FILE_MTIME=$(stat -f "%m" "$AUDIT_FILE" 2>/dev/null || stat -c "%Y" "$AUDIT_FILE" 2>/dev/null || echo 0)
  NOW=$(date +%s)
  AGE=$(( NOW - FILE_MTIME ))

  if [ "$AGE" -lt "$AUDIT_MAX_AGE_SECONDS" ]; then
    # Audit is recent — silent pass
    exit 0
  fi
fi

echo ""
echo "SQWR HOOK REMINDER — No recent audit detected before push"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Last audit: $([ -f "$AUDIT_FILE" ] && date -r "$AUDIT_FILE" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "never")"
echo ""
echo "  Recommended: run a full audit before pushing to main."
echo "  Agent: agents/AGENT-FULL-AUDIT.md"
echo ""
echo "  Once the audit is complete, mark it as done:"
echo "    touch .sqwr-last-audit"
echo ""
echo "  This is advisory — push is not blocked."
echo ""

# Advisory only — do not block
exit 0
