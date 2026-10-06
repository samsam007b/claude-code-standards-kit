#!/usr/bin/env bash
# PreToolUse hook: marketplace-add-guard   (BLOCKING, security guard)
#
# Puts a stop sign in front of adding a new third-party source: a Claude Code plugin
# marketplace, a plugin install (which can pull a not-yet-vetted marketplace implicitly), or a
# git clone into ~/.claude/plugins/marketplaces/. The source should be vetted first with the
# marketplace-vetting skill. This is a checkpoint, not a permanent ban.
#
# Event / matcher : PreToolUse / Bash                   (timeout 340 in settings)
# Exit codes      : 0 allow, 2 block.
# Flow            : hook blocks -> native OS dialog -> physical click on "Confirm" allows
#                   (fails closed when no dialog is available, see lib/human-confirm-dialog.sh).
# Bypass          : none by environment variable. Confirm the dialog, or remove the hook.
# Env             : CLAUDE_HOME (default ~/.claude).

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
source "$HOOK_DIR/lib/human-confirm-dialog.sh"
source "$HOOK_DIR/lib/hook-input.sh"

hook_read_input
[[ "$(hook_get tool_name)" == "Bash" ]] || exit 0
CMD="$(hook_get tool_input.command)"

IS_MARKETPLACE_ADD=false
# Syntax confirmed with `claude plugin --help`: alias plugin|plugins, install|i for a plugin.
printf '%s' "$CMD" | grep -qE 'claude\s+plugins?\s+marketplace\s+add' && IS_MARKETPLACE_ADD=true
printf '%s' "$CMD" | grep -qE 'claude\s+plugins?\s+(install|i)\s' && IS_MARKETPLACE_ADD=true
printf '%s' "$CMD" | grep -qE 'git\s+clone.*\.claude/plugins/marketplaces/' && IS_MARKETPLACE_ADD=true

[[ "$IS_MARKETPLACE_ADD" == "true" ]] || exit 0

if human_confirm_dialog "marketplace-add-guard: adding a new third-party marketplace/plugin: $CMD. Confirm only if the source is already vetted (see TRUST-REGISTRY.md)." 300; then
  exit 0
fi

{
  echo "BLOCKED by marketplace-add-guard: adding a new third-party marketplace/plugin was detected (dialog not confirmed, expired, or unavailable)."
  echo "Command: $CMD"
  echo ""
  echo "Before adding: check $CLAUDE_HOME/skills/marketplace-vetting/TRUST-REGISTRY.md (already vetted?) or run the marketplace-vetting skill on this source."
} >&2
exit 2
