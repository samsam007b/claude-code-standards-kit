#!/bin/bash
# PreCompact hook: saves GSD state before compaction
# Avoids losing the context of an active PLAN.md during automatic compaction

DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M:%S)
CWD="$PWD"
STATE_FILE="$HOME/.claude/session-env/pre-compact-state.md"

mkdir -p "$HOME/.claude/session-env"

# Detect whether a GSD project is active
PLANNING_DIR="$CWD/.planning"
ACTIVE_PLAN=""
ACTIVE_PHASE=""

if [ -d "$PLANNING_DIR" ]; then
  # Find the most recently modified PLAN.md
  ACTIVE_PLAN=$(find "$PLANNING_DIR/phases" -name "*PLAN.md" 2>/dev/null | xargs ls -t 2>/dev/null | head -1)
  # Find the active phase in STATE.md
  if [ -f "$PLANNING_DIR/STATE.md" ]; then
    ACTIVE_PHASE=$(grep -m1 "current_phase\|phase_active\|Phase en cours" "$PLANNING_DIR/STATE.md" 2>/dev/null | head -1)
  fi
fi

# Find in-progress todos
TODOS_IN_PROGRESS=$(cat "$HOME/.claude/todos/"*.json 2>/dev/null | python3 -c "
import sys, json
try:
    for line in sys.stdin:
        data = json.loads(line)
        if isinstance(data, list):
            for t in data:
                if t.get('status') == 'in_progress':
                    print('- ' + t.get('content', ''))
except: pass
" 2>/dev/null)

# Write the state
cat > "$STATE_FILE" << EOF
# Pre-compaction state: $DATE $TIME

## Active project
**Directory**: $CWD

## GSD: active plan
$([ -n "$ACTIVE_PLAN" ] && echo "**Plan**: $ACTIVE_PLAN" || echo "No GSD plan detected")
$([ -n "$ACTIVE_PHASE" ] && echo "**Phase**: $ACTIVE_PHASE" || echo "")

## In-progress todos
$([ -n "$TODOS_IN_PROGRESS" ] && echo "$TODOS_IN_PROGRESS" || echo "No in-progress todo")

## Post-compaction reminder
After compaction, read this file to resume context:
\`cat ~/.claude/session-env/pre-compact-state.md\`
EOF

# Inject into context via stdout (read by Claude after compaction)
echo "🗜️ Compaction in progress. State saved to ~/.claude/session-env/pre-compact-state.md"
echo "Project: $CWD | Plan: ${ACTIVE_PLAN:-none}"

exit 0
