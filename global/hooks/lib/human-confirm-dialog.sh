#!/usr/bin/env bash
# lib/human-confirm-dialog.sh
# Shared function: ask a human to confirm an action through a native OS dialog that
# blocks until a physical click or an internal timeout. Sourced by the marketplace-vetting
# hooks (plugin-script-exec-guard, marketplace-add-guard, mcp-tool-trust-gate,
# guard-file-tamper-guard).
#
# Why a dialog and not a flag file: a flag created with `touch` can be created by any Bash
# call, including one the agent issues by itself with no human involved. A native dialog
# needs a physical interaction on the machine.
#
# Usage:  human_confirm_dialog "message" [timeout_seconds]   # returns 0 = confirmed, 1 = refused
#
# FAILS CLOSED, always: no GUI, no dialog tool, timeout, or any error returns 1 (refuse).
#   - macOS : osascript "display dialog"
#   - Linux : zenity or kdialog (needs a graphical session: DISPLAY or WAYLAND_DISPLAY)
#   - other / headless : prints a clear message on stderr and refuses
#
# IMPORTANT (hook timeout semantics): a PreToolUse hook that times out or crashes is treated
# by Claude Code as a NON-BLOCKING error, so the action is silently ALLOWED. The dialog
# timeout (default 300s) must therefore stay strictly below the "timeout" of the hook entry
# in settings.json (340s in settings-hooks.json, a 40s margin). Otherwise the harness kills
# the hook before it can exit 2, which is a silent fail-open on a security guard.
#
# Test mode: CLAUDE_HOOK_TEST_MODE=1 makes the function refuse immediately without showing
# anything. It can only refuse, never confirm, so it opens no bypass.

human_confirm_dialog() {
  local msg="$1"
  local dialog_timeout="${2:-300}"

  if [[ "${CLAUDE_HOOK_TEST_MODE:-}" == "1" ]]; then
    return 1
  fi

  local os
  os="$(uname -s 2>/dev/null || echo unknown)"

  if [[ "$os" == "Darwin" ]] && command -v osascript >/dev/null 2>&1; then
    # mktemp on BSD/macOS requires the X's to END the template, so create a directory and
    # put the .applescript file inside it.
    local script_dir script_file esc_msg btn
    script_dir=$(mktemp -d "${TMPDIR:-/tmp}/claude-confirm-dialog.XXXXXX") || return 1
    script_file="$script_dir/dialog.applescript"
    # Escape backslashes and quotes, flatten newlines so the dialog stays on one view.
    esc_msg=$(printf '%s' "$msg" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n' ' ')
    cat > "$script_file" <<APPLESCRIPT_EOF
set theResult to display dialog "$esc_msg" buttons {"Block", "Confirm"} default button "Block" with icon caution giving up after $dialog_timeout
if gave up of theResult then
	return "TIMEOUT"
else
	return button returned of theResult
end if
APPLESCRIPT_EOF
    btn=$(osascript "$script_file" 2>/dev/null)
    rm -rf "$script_dir"
    [[ "$btn" == "Confirm" ]] && return 0
    return 1
  fi

  if [[ "$os" == "Linux" && ( -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ) ]]; then
    if command -v zenity >/dev/null 2>&1; then
      zenity --question --title="Claude Code hook" --text="$msg" \
        --ok-label="Confirm" --cancel-label="Block" --timeout="$dialog_timeout" 2>/dev/null
      return $?   # 0 = Confirm; 1 = Block; 5 = timeout (non-zero, so refused)
    fi
    if command -v kdialog >/dev/null 2>&1; then
      kdialog --yesno "$msg" --yes-label "Confirm" --no-label "Block" 2>/dev/null
      return $?
    fi
  fi

  echo "[human-confirm-dialog] No supported confirmation dialog on this system (needs macOS osascript, or zenity/kdialog in a graphical session). Refusing by default (fail closed). To allow this action, perform it yourself outside Claude Code, or temporarily remove the guard hook from settings.json." >&2
  return 1
}
