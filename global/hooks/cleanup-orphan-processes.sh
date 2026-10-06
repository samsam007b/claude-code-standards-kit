#!/usr/bin/env bash
# SessionEnd hook: cleanup-orphan-processes   (best-effort, never blocks)
#
# Kills node processes that agents commonly leave behind when a session ends: `tsc --noEmit`
# type-check runs and one-shot jest runs (jest in watch mode is left alone). Dev servers are NOT
# killed unless you opt in, because a dev server may belong to another terminal.
#
# WARNING: matching is by command line across the whole machine, not by parent session. Do not
# enable it on a shared box where other people's jobs may match.
#
# Event / matcher : SessionEnd (no matcher)             (timeout 10)
# Exit codes      : always 0.
# Env:
#   CLAUDE_ORPHAN_CLEANUP=off     disable the hook
#   CLAUDE_ORPHAN_PATTERNS        extra pattern for the kill list, in `ps | grep -E` syntax
#                                 (for example "node.*next dev" to also stop leftover dev servers)

[[ "${CLAUDE_ORPHAN_CLEANUP:-on}" == "off" ]] && exit 0

kill_matching() { # kill_matching <grep -E pattern> [exclude pattern]
  local pids
  pids="$(ps -eo pid,command | grep -E "$1" | grep -v 'grep -E' | { if [[ -n "${2:-}" ]]; then grep -vE "$2"; else cat; fi; } | awk '{print $1}')"
  if [[ -n "$pids" ]]; then
    # shellcheck disable=SC2086
    kill $pids 2>/dev/null || true
  fi
}

kill_matching 'node.*tsc --noEmit'
kill_matching 'node.*jest' 'jest.*--?watch'
[[ -n "${CLAUDE_ORPHAN_PATTERNS:-}" ]] && kill_matching "$CLAUDE_ORPHAN_PATTERNS"

exit 0
