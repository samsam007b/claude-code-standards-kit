#!/usr/bin/env bash
# PreToolUse hook: plugin-script-exec-guard   (BLOCKING, security guard)
#
# Blocks the execution of scripts or binaries located inside unaudited third-party content
# (~/.claude/plugins/marketplaces/*, ~/.claude/plugins/cache/*). Reading and inspecting
# (cat, grep, ls, find, head, tail) is always allowed.
#
# Why: a third-party marketplace repo can ship an ops script (for example one that bulk-copies
# .env, GPG or SSH files). Nothing technically stops the agent from running it if a prompt or a
# file pushes it to (injection, hallucination, typo in a path). This hook closes that hole.
#
# Event / matcher : PreToolUse / Bash                   (timeout 340 in settings, see below)
# Exit codes      : 0 allow, 2 block. Internal parse error on a non-Bash payload: allow.
# Flow            : hook blocks -> native OS dialog -> a physical click on "Confirm" allows
#                   (lib/human-confirm-dialog.sh). On a system without a dialog the hook
#                   FAILS CLOSED (refuses) and says why.
# Hard block      : `sudo` + a plugin path is never allowed, even with confirmation.
# Allowlist       : scripts you reviewed once can be listed in plugin-script-exec-allowlist.txt
#                   (shipped empty) to skip the dialog for that exact path.
# Bypass          : none by environment variable (that would defeat the purpose). Remove the
#                   hook entry from settings.json, which is itself protected by
#                   guard-file-tamper-guard.sh.
# Env             : CLAUDE_HOME (default ~/.claude), CLAUDE_PLUGIN_ALLOWLIST (allowlist path).
#
# The harness resets the shell cwd after every Bash call, so a "cd in one call, relative exec
# in the next" bypass cannot happen. The payload exposes a reliable "cwd" field, used here
# read-only, with no persisted state.

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
# shellcheck source=lib/human-confirm-dialog.sh
source "$HOOK_DIR/lib/human-confirm-dialog.sh"
# shellcheck source=lib/hook-input.sh
source "$HOOK_DIR/lib/hook-input.sh"

hook_read_input
[[ "$(hook_get tool_name)" == "Bash" ]] || exit 0

CMD="$(hook_get tool_input.command)"
CWD="$(hook_get cwd)"

PLUGIN_RE='\.claude/plugins/(marketplaces|cache)/'
IN_MARKETPLACE_PATH=false
printf '%s' "$CMD" | grep -qE "$PLUGIN_RE" && IN_MARKETPLACE_PATH=true
printf '%s' "$CWD" | grep -qE "$PLUGIN_RE" && IN_MARKETPLACE_PATH=true
[[ "$IN_MARKETPLACE_PATH" == "true" ]] || exit 0

# sudo + third-party plugin path = hard block, never a silent bypass
if printf '%s' "$CMD" | grep -qE '\bsudo\b'; then
  echo "BLOCKED (hard) by plugin-script-exec-guard: 'sudo' targeting unaudited third-party marketplace content. This is never allowed, even with confirmation. If a legitimate script needs sudo, copy it out of plugins/ and read it fully first." >&2
  exit 2
fi

# Real execution verbs (reading and inspection stay allowed).
# Note: "\./" needs no non-letter after it: script names almost always start with a letter.
if ! printf '%s' "$CMD" | grep -qE '(^|[;&|]|\s)(bash|sh|zsh|python3?|node|npm exec|npx|ruby|perl)\b|(^|[;&|]|\s)\./'; then
  exit 0
fi

# Allowlist: skip the dialog when EVERY plugin path in the command is listed. Only applies
# when the cwd itself is not inside a plugin dir. Vacuity is forbidden (see the python helper).
ALLOWLIST_FILE="${CLAUDE_PLUGIN_ALLOWLIST:-$CLAUDE_HOME/hooks/plugin-script-exec-allowlist.txt}"
if [[ -f "$ALLOWLIST_FILE" && "$CWD" != *".claude/plugins/marketplaces/"* && "$CWD" != *".claude/plugins/cache/"* ]]; then
  if CMD="$CMD" ALLOWLIST_FILE="$ALLOWLIST_FILE" python3 "$HOOK_DIR/lib/plugin-allowlist-check.py"; then
    exit 0
  fi
fi

if human_confirm_dialog "plugin-script-exec-guard: execution requested for a script from unaudited third-party marketplace content: $CMD. Confirm only after reading the script yourself." 300; then
  exit 0
fi

echo "BLOCKED by plugin-script-exec-guard: attempt to execute a script located in third-party marketplace/plugin content that has not been audited individually (dialog not confirmed, expired, or unavailable)." >&2
echo "Command: $CMD" >&2
exit 2
