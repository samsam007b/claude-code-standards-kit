#!/bin/bash
# PreToolUse hook: team-git-guard
# Protects against dangerous git operations in multi-agent collaboration.
# Silent no-op as long as .claude/team-registry.md does not exist in the repo
# (i.e. team-init.sh was never run on this project): available capability, never forced.
# Ported from experiments/team-coordination/ (the $TOOL_INPUT/JSON status contract
# is incompatible with the real hook system) to the stdin JSON + exit code contract.

INPUT=$(cat)

read -r TOOL_NAME CMD <<< "$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    name = d.get('tool_name', '')
    cmd = d.get('tool_input', {}).get('command', '').replace(chr(10), ' ')
    print(name, cmd[:200])
except Exception:
    print('', '')
" 2>/dev/null)"

[[ "$TOOL_NAME" != "Bash" ]] && exit 0
echo "$CMD" | grep -qE '^\s*git\s+' || exit 0

GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
[[ -z "$GIT_ROOT" ]] && exit 0

REGISTRY_FILE="$GIT_ROOT/.claude/team-registry.md"
[[ ! -f "$REGISTRY_FILE" ]] && exit 0

CMD_FULL=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    print(json.load(sys.stdin).get('tool_input', {}).get('command', ''))
except Exception:
    print('')
" 2>/dev/null)

block() {
  echo "TEAM GUARD: $1" >&2
  exit 2
}

# --- Hard blocks ---
echo "$CMD_FULL" | grep -qE 'git\s+add\s+(\.|--all|-A)\s*$' && \
  block "'git add .' is forbidden in a multi-agent project. Stage specific files: git add path/to/file. Check .claude/team-registry.md."

echo "$CMD_FULL" | grep -qE 'git\s+push\b.*(--force|\s-f\b|\s\+[^ ]+)' && \
  block "Forced push forbidden: it could destroy other agents' work."

echo "$CMD_FULL" | grep -qE 'git\s+reset\s+--hard' && \
  block "Hard reset forbidden: it would destroy other agents' uncommitted work."

echo "$CMD_FULL" | grep -qE 'git\s+clean\s+-[fd]' && \
  block "git clean forbidden: it would delete other agents' untracked files."

# --- Soft checks (warning, non-blocking) ---
ACTIVE_AGENTS=$(grep -cE '^\| agent-[a-z0-9]+-[0-9]+' "$REGISTRY_FILE" 2>/dev/null)
ACTIVE_AGENTS=${ACTIVE_AGENTS:-0}

if [[ "$ACTIVE_AGENTS" -gt "0" ]] && echo "$CMD_FULL" | grep -qE 'git\s+commit'; then
  echo "TEAM GUARD (info) : $ACTIVE_AGENTS active agent(s) in the registry. Check that only your claimed files are staged before committing." >&2
fi

if [[ "$ACTIVE_AGENTS" -gt "0" ]] && echo "$CMD_FULL" | grep -qE 'git\s+(merge|rebase)'; then
  echo "TEAM GUARD (info) : $ACTIVE_AGENTS active agent(s): merge/rebase may conflict with uncommitted work. Coordinate first via .claude/team-registry.md." >&2
fi

exit 0
