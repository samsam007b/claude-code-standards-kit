#!/usr/bin/env bash
# lib/hook-input.sh
# Tiny helper sourced by hooks: read the JSON payload once, then extract fields.
#
#   hook_read_input                 # reads stdin into $HOOK_INPUT
#   hook_get tool_name              # top-level string field
#   hook_get tool_input.command     # nested string field (dot path)
#
# Always parse the JSON, never grep the raw text: a literal grep on '"tool_name":"Bash"'
# only matches one exact spacing of the payload and silently disables the whole hook on any
# other formatting (a real bug found in an early version of the marketplace guards).
# Returns an empty string on any parse error or non-string value.

hook_read_input() {
  HOOK_INPUT="$(cat)"
}

hook_get() {
  printf '%s' "${HOOK_INPUT:-}" | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
    for k in sys.argv[1].split("."):
        d = d.get(k, "") if isinstance(d, dict) else ""
    print(d if isinstance(d, str) else "")
except Exception:
    print("")
' "$1" 2>/dev/null
}
