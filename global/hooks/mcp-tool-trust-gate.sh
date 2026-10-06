#!/usr/bin/env bash
# PreToolUse hook: mcp-tool-trust-gate   (BLOCKING, security guard)
#
# Closes the "plugin marketplace = MCP server" blind spot: plugin-script-exec-guard sees
# nothing when a third-party plugin exposes its capabilities through an MCP server instead of
# a shell script. This hook gates the use of any mcp__* tool whose server is not marked with a
# check mark (U+2705) in TRUST-REGISTRY.md.
#
# The trusted list is read dynamically from the registry (never hardcoded here): to trust a
# server, edit the registry, never this script. Registry format: see lib/trust-registry-check.py.
#
# Event / matcher : PreToolUse / mcp__.*                (timeout 340 in settings)
# Exit codes      : 0 allow, 2 block.
# Flow            : unknown server -> native OS dialog -> physical click on "Confirm" allows
#                   (fails closed when no dialog is available). A missing registry file means
#                   "nothing is trusted": every MCP tool goes through the dialog.
# Bypass          : none by environment variable. Add the server to the registry once vetted.
# Env             : CLAUDE_HOME (default ~/.claude), CLAUDE_TRUST_REGISTRY (registry path).

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
source "$HOOK_DIR/lib/human-confirm-dialog.sh"
source "$HOOK_DIR/lib/hook-input.sh"
REGISTRY="${CLAUDE_TRUST_REGISTRY:-$CLAUDE_HOME/skills/marketplace-vetting/TRUST-REGISTRY.md}"

hook_read_input
TOOL_NAME="$(hook_get tool_name)"
[[ "$TOOL_NAME" == mcp__* ]] || exit 0

# Server slug: mcp__<slug>__<tool>. The slug itself may contain underscores
# (mcp___my-server__tool -> slug "_my-server"), hence the rsplit on the LAST "__".
SERVER_SLUG=$(python3 -c '
import sys
rest = sys.argv[1][len("mcp__"):]
parts = rest.rsplit("__", 1)
print(parts[0] if len(parts) == 2 else rest)
' "$TOOL_NAME" 2>/dev/null)

IS_TRUSTED=$(python3 "$HOOK_DIR/lib/trust-registry-check.py" "$SERVER_SLUG" "$REGISTRY" 2>/dev/null)
[[ "$IS_TRUSTED" == "true" ]] && exit 0

if human_confirm_dialog "mcp-tool-trust-gate: call to an unvetted MCP tool ($TOOL_NAME, server '$SERVER_SLUG'). Confirm only if you trust this server." 300; then
  exit 0
fi

{
  echo "BLOCKED by mcp-tool-trust-gate: call to an MCP tool ($TOOL_NAME, server '$SERVER_SLUG') that is not marked as trusted in the registry (dialog not confirmed, expired, or unavailable)."
  echo ""
  echo "If this server comes from a third-party marketplace plugin: run the marketplace-vetting skill before first use, then add the slug '$SERVER_SLUG' with a check mark to $REGISTRY."
} >&2
exit 2
