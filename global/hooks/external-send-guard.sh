#!/usr/bin/env bash
# PreToolUse hook: external-send-guard   (BLOCKING, security guard, fails CLOSED)
#
# Blocks any outbound email / chat / social send unless the user explicitly confirmed it in
# the current turn. Provider-agnostic: it recognises send actions by tool slug or tool name
# (GMAIL_SEND_EMAIL, SLACK_SEND_MESSAGE, mcp__<server>__send_email, mcp__<server>__post_tweet...)
# and common Bash vectors (mail CLIs, osascript Mail, curl to chat/social APIs, composio runners).
# The pattern lists live in lib/external-send-classify.py and are overridable by env var.
#
# Event / matcher : PreToolUse / mcp__.*|Bash        (timeout 5)
# Exit codes      : 0 allow, 2 block.
# Fail-closed     : if the payload cannot be parsed, the call is blocked (it cannot be proven safe).
#
# HOW THE CONFIRMATION FLAG WORKS
#   1. The agent tries to send. This hook blocks (exit 2) and says why on stderr.
#   2. The agent shows you what would be sent and asks you to confirm.
#   3. You reply with a short confirmation phrase ("confirm send", "go send", "send now"...).
#   4. user-prompt-submit.sh (UserPromptSubmit hook) sees the phrase and touches the flag file
#      (default /tmp/claude-send-guard-confirmed-<uid>, mode 600).
#   5. The agent retries. This hook finds a flag younger than the TTL (default 120 s), DELETES
#      it (single use) and lets exactly that one send through.
#   An approval from an earlier turn has expired by construction (TTL + single use).
#   The flag is set only by a message YOU typed (UserPromptSubmit), never by a tool call.
#   Accepted phrases are configurable: CLAUDE_SEND_CONFIRM_REGEX (see user-prompt-submit.sh).
#
# Bypass          : CLAUDE_SEND_GUARD=off disables the hook (set it deliberately, per session).
# Env             : CLAUDE_SEND_GUARD_FLAG, CLAUDE_SEND_GUARD_TTL (lib/send-guard-flag.sh),
#                   CLAUDE_SEND_GUARD_REGEX, CLAUDE_SEND_GUARD_EXTRA_REGEX,
#                   CLAUDE_SEND_GUARD_ALLOW_REGEX (lib/external-send-classify.py).

[[ "${CLAUDE_SEND_GUARD:-on}" == "off" ]] && exit 0

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HOOK_DIR/lib/send-guard-flag.sh"

INPUT="$(cat)"

VERDICT="$(printf '%s' "$INPUT" | python3 "$HOOK_DIR/lib/external-send-classify.py" 2>/dev/null)"
RC=$?

if [[ $RC -ne 0 ]]; then
  {
    echo "BLOCKED by external-send-guard (fail-closed): the tool call could not be parsed, so it cannot be shown to be safe."
    echo "If this is a false alarm, retry the call or confirm explicitly."
  } >&2
  exit 2
fi

[[ "$VERDICT" == SEND* ]] || exit 0
DESCRIPTION="${VERDICT#SEND$'\t'}"

# Confirmation flag valid (younger than the TTL): consume it (single use) and allow.
if [[ -f "$SEND_GUARD_FLAG" ]]; then
  AGE="$(send_guard_file_age "$SEND_GUARD_FLAG")"
  rm -f "$SEND_GUARD_FLAG"
  if [[ "$AGE" -lt "$SEND_GUARD_TTL" ]]; then
    exit 0
  fi
fi

{
  echo "BLOCKED by external-send-guard: outbound send without an explicit confirmation in this turn."
  echo ""
  echo "To allow it, show the user what will be sent, then ask them to reply 'confirm send' or 'go send'."
  echo "Action: $DESCRIPTION"
} >&2
exit 2
