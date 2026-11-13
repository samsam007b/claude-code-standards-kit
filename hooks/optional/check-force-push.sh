#!/bin/bash
# Blocks forced pushes (long and short flag) on any branch.
# A forced push can overwrite production work or destroy history.

INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null)

if echo "$CMD" | grep -qE "git\s+push" && echo "$CMD" | grep -qE "\-\-force|\s-[a-zA-Z]*f[a-zA-Z]*(\s|$)|\s\+[A-Za-z0-9_/.-]+"; then
  echo "🔴 BLOCKED: forced push is forbidden"
  echo "   Risk: irreversible overwrite of production history."
  echo "   If truly necessary: ask the user for explicit confirmation."
  exit 2
fi

exit 0
