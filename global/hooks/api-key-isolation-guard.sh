#!/usr/bin/env bash
# PreToolUse hook: api-key-isolation-guard   (BLOCKING, fail-open on parse error)
#
# Keeps a given credential out of a given project. Typical use: you have a personal API key and a
# client or employer project, and legal or billing separation requires that the key never ends up
# in that project's files. The hook blocks Edit/Write whose target is inside a configured
# directory and whose content mentions the configured pattern.
#
# DOES NOTHING until CLAUDE_KEY_ISOLATION_DIRS is set (a no-op by default).
#
# Event / matcher : PreToolUse / Edit|Write            (timeout 3)
# Exit codes      : 0 allow, 2 block.
# Env:
#   CLAUDE_KEY_ISOLATION_DIRS     colon-separated path substrings to protect, e.g.
#                                 "/work/client-a/:/work/client-b/"
#   CLAUDE_KEY_ISOLATION_PATTERN  extended regex to refuse in written content
#                                 (default: ANTHROPIC_API_KEY|OPENAI_API_KEY)
#   CLAUDE_KEY_ISOLATION_OVERRIDE=1  bypass (document it in the commit message).

[[ -n "${CLAUDE_KEY_ISOLATION_DIRS:-}" ]] || exit 0
[[ "${CLAUDE_KEY_ISOLATION_OVERRIDE:-0}" == "1" ]] && exit 0

PATTERN="${CLAUDE_KEY_ISOLATION_PATTERN:-ANTHROPIC_API_KEY|OPENAI_API_KEY}"
INPUT="$(cat)"

FILE="$(printf '%s' "$INPUT" | python3 -c '
import sys, json
try:
    i = json.load(sys.stdin).get("tool_input", {}) or {}
    print(i.get("file_path") or i.get("path") or "")
except Exception:
    print("")' 2>/dev/null)"

CONTENT="$(printf '%s' "$INPUT" | python3 -c '
import sys, json
try:
    i = json.load(sys.stdin).get("tool_input", {}) or {}
    print(i.get("content") or i.get("new_string") or "")
except Exception:
    print("")' 2>/dev/null)"

IN_SCOPE=false
IFS=':' read -r -a DIRS <<< "$CLAUDE_KEY_ISOLATION_DIRS"
for d in "${DIRS[@]}"; do
  [[ -n "$d" && "$FILE" == *"$d"* ]] && { IN_SCOPE=true; break; }
done
[[ "$IN_SCOPE" == "true" ]] || exit 0

if printf '%s' "$CONTENT" | grep -qE "$PATTERN"; then
  echo "BLOCKED by api-key-isolation-guard: content matching '$PATTERN' cannot be written to $FILE (this directory is key-isolated). Override: CLAUDE_KEY_ISOLATION_OVERRIDE=1" >&2
  exit 2
fi

exit 0
