#!/usr/bin/env bash
# PreCompact hook: pre-compact-save   (ADVISORY, never blocks)
#
# Saves a small state snapshot before a context compaction (working directory, active plan file
# if the project keeps a ".planning/" directory, in-progress todos) and prints a two-line
# reminder on stdout so the model knows where to look after compaction.
#
# Event / matcher : PreCompact (no matcher)             (timeout 5)
# Exit codes      : always 0.
# Env:
#   CLAUDE_HOME             Claude config dir (default $HOME/.claude)
#   CLAUDE_PRECOMPACT_FILE  snapshot path (default $CLAUDE_HOME/session-env/pre-compact-state.md)
#   CLAUDE_PLAN_DIR         project-relative planning dir to inspect (default .planning)
#   CLAUDE_PRECOMPACT=off   disable the hook

[[ "${CLAUDE_PRECOMPACT:-on}" == "off" ]] && exit 0

CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
STATE_FILE="${CLAUDE_PRECOMPACT_FILE:-$CLAUDE_HOME/session-env/pre-compact-state.md}"
PLAN_DIR="${CLAUDE_PLAN_DIR:-.planning}"
CWD="$PWD"
STAMP="$(date '+%Y-%m-%d %H:%M:%S')"

mkdir -p "$(dirname "$STATE_FILE")" 2>/dev/null || exit 0

ACTIVE_PLAN=""
ACTIVE_PHASE=""
if [[ -d "$CWD/$PLAN_DIR" ]]; then
  # Most recently modified PLAN file under the planning dir.
  ACTIVE_PLAN="$(find "$CWD/$PLAN_DIR" -name '*PLAN.md' -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null | head -1)"
  if [[ -f "$CWD/$PLAN_DIR/STATE.md" ]]; then
    ACTIVE_PHASE="$(grep -m1 -iE 'current_phase|phase_active|current phase' "$CWD/$PLAN_DIR/STATE.md" 2>/dev/null)"
  fi
fi

TODOS_IN_PROGRESS="$(cat "$CLAUDE_HOME"/todos/*.json 2>/dev/null | python3 -c '
import sys, json
try:
    for line in sys.stdin:
        data = json.loads(line)
        if isinstance(data, list):
            for t in data:
                if t.get("status") == "in_progress":
                    print("- " + t.get("content", ""))
except Exception:
    pass
' 2>/dev/null)"

{
  echo "# Pre-compaction state ($STAMP)"
  echo
  echo "## Active project"
  echo "**Directory**: $CWD"
  echo
  echo "## Plan"
  if [[ -n "$ACTIVE_PLAN" ]]; then echo "**Plan file**: $ACTIVE_PLAN"; else echo "No plan file detected"; fi
  [[ -n "$ACTIVE_PHASE" ]] && echo "**Phase**: $ACTIVE_PHASE"
  echo
  echo "## In-progress todos"
  if [[ -n "$TODOS_IN_PROGRESS" ]]; then echo "$TODOS_IN_PROGRESS"; else echo "None"; fi
  echo
  echo "## After compaction"
  echo "Read this file to recover context: \`cat $STATE_FILE\`"
} > "$STATE_FILE" 2>/dev/null || exit 0

# Whatever a PreCompact hook prints on stdout is visible to the model afterwards.
echo "Compaction in progress. State saved to $STATE_FILE"
echo "Project: $CWD | Plan: ${ACTIVE_PLAN:-none}"

exit 0
