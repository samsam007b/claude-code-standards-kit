#!/usr/bin/env bash
# lib/send-guard-flag.sh
# Shared by external-send-guard.sh (consumes the flag) and user-prompt-submit.sh (sets it),
# so both always agree on the flag location and lifetime.
#
#   CLAUDE_SEND_GUARD_FLAG  path of the confirmation flag (default /tmp/claude-send-guard-confirmed-<uid>)
#   CLAUDE_SEND_GUARD_TTL   seconds a flag stays valid (default 120)

SEND_GUARD_FLAG="${CLAUDE_SEND_GUARD_FLAG:-/tmp/claude-send-guard-confirmed-$(id -u)}"
SEND_GUARD_TTL="${CLAUDE_SEND_GUARD_TTL:-120}"

# Age of a file in seconds (portable across macOS and Linux, via python). Prints 999999 if unreadable.
send_guard_file_age() {
  python3 -c 'import os,sys,time
try:
    print(int(time.time() - os.path.getmtime(sys.argv[1])))
except Exception:
    print(999999)' "$1" 2>/dev/null || echo 999999
}
