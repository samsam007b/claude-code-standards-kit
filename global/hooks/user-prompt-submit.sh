#!/usr/bin/env bash
# UserPromptSubmit hook: user-prompt-submit   (ADVISORY, never blocks, fail-open)
#
# Two jobs:
#   1. Arm the external-send-guard confirmation flag when the user types a short, explicit
#      confirmation message ("confirm send", "go send", "send now"...). This is the ONLY
#      thing that can create the flag: it comes from a message the human typed, never from a
#      tool call. See external-send-guard.sh for the full flow.
#   2. Optional prompt audit trail (OFF by default, it can capture secrets pasted in prompts):
#      CLAUDE_PROMPT_LOG=1 appends the first 500 characters of each prompt, with the cwd, to
#      ~/.claude/logs/prompts/YYYY-MM-DD.jsonl.
#
# Event / matcher : UserPromptSubmit (no matcher)     (timeout 3)
# Exit codes      : always 0.
# Env             : CLAUDE_SEND_CONFIRM_REGEX  full-message regex (extended, case-insensitive) that counts as
#                                              a confirmation. Default: explicit send phrases only.
#                                              Looser example: '^(confirm send|go|yes|ok|proceed)[!. ]*$'
#                                              (looser = the flag can be armed by an unrelated "ok").
#                   CLAUDE_PROMPT_LOG=1        enable the audit trail.
#                   CLAUDE_HOME                default ~/.claude (log location).

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HOOK_DIR/lib/send-guard-flag.sh"
source "$HOOK_DIR/lib/hook-input.sh"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"

hook_read_input
PROMPT="$(hook_get prompt)"
[[ -n "$PROMPT" ]] || PROMPT="$(hook_get user_message)"

if [[ "${CLAUDE_PROMPT_LOG:-0}" == "1" ]]; then
  LOG_DIR="$CLAUDE_HOME/logs/prompts"
  mkdir -p "$LOG_DIR" 2>/dev/null
  PROMPT_TEXT="$PROMPT" python3 -c '
import json, os, datetime
print(json.dumps({"ts": datetime.datetime.now().isoformat(timespec="seconds"),
                  "cwd": os.getcwd(), "prompt": os.environ.get("PROMPT_TEXT", "")[:500]},
                 ensure_ascii=False))
' >> "$LOG_DIR/$(date +%Y-%m-%d).jsonl" 2>/dev/null
fi

CONFIRM_REGEX="${CLAUDE_SEND_CONFIRM_REGEX:-^[[:space:]]*(confirm send|go send|yes send|send now|send it)[[:space:]]*[!.]*[[:space:]]*$}"
if printf '%s' "$PROMPT" | grep -qiE "$CONFIRM_REGEX"; then
  ( umask 077; touch "$SEND_GUARD_FLAG" ) 2>/dev/null
fi

exit 0
