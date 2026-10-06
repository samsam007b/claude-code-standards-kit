#!/usr/bin/env bash
# check-subagent-output.sh: warn when a subagent returns an oversized result.
#
# Event/matcher : PostToolUse on Agent (reads the hook JSON on stdin).
# Exit codes    : always 0 (informational, never blocks). FAIL-OPEN on any internal error.
# Effect        : when the result exceeds SUBAGENT_MAX_WORDS, injects a reminder into the
#                 model context (additionalContext) to keep subagent output short, so raw
#                 dumps do not pollute the main context.
# Environment   : SUBAGENT_MAX_WORDS (default 800, about 1100 tokens)
#
# Dependencies: jq

set -uo pipefail

command -v jq >/dev/null 2>&1 || exit 0
MAX="${SUBAGENT_MAX_WORDS:-800}"

input=$(cat 2>/dev/null || true)
[ -n "$input" ] || exit 0
[ "$(jq -r '.tool_name // empty' <<<"$input" 2>/dev/null)" = "Agent" ] || exit 0

# The result field name varies across versions (tool_response vs tool_output), and may be
# a string or an object with text blocks.
output=$(jq -r '
  (.tool_response // .tool_output // empty)
  | if type == "string" then .
    elif type == "object" then ([.content[]? | .text? // empty] | join(" ")) // (.result // "")
    elif type == "array" then ([.[] | .text? // empty] | join(" "))
    else "" end' <<<"$input" 2>/dev/null || true)
[ -n "$output" ] || exit 0

words=$(printf '%s' "$output" | wc -w | tr -d ' ')
if [ "$words" -gt "$MAX" ]; then
  msg="TOKEN ECONOMY: the subagent returned about ${words} words (about $((words * 4 / 3)) tokens). Delegated work should return a short summary plus a table of what to dig into, not a full dump. Ask for a tighter report next time."
  jq -n --arg m "$msg" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $m}}'
fi
exit 0
