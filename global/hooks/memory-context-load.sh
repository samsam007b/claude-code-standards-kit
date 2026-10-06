#!/usr/bin/env bash
# SessionStart hook: memory-context-load   (ADVISORY, never blocks)
#
# Injects a light INDEX of the MCP memory graph at session start (just-in-time retrieval): the
# entity names grouped by type, never the full observations. Loading everything causes context
# rot and over-exposes data unrelated to the current conversation. Detail is fetched on demand
# with mcp__memory__search_nodes or open_nodes.
#
# Event / matcher : SessionStart (no matcher)           (timeout 5)
# Exit codes      : always 0. Prints nothing when the memory file does not exist.
# Env:
#   MEMORY_FILE_PATH   the memory server's jsonl store (default $HOME/.claude-memory/memory.jsonl)
#   CLAUDE_MEMORY_INDEX=off   disable the hook

[[ "${CLAUDE_MEMORY_INDEX:-on}" == "off" ]] && exit 0

MEMORY_FILE="${MEMORY_FILE_PATH:-$HOME/.claude-memory/memory.jsonl}"
[[ -f "$MEMORY_FILE" ]] || exit 0

echo "## MCP memory available (index only, load on demand)"
echo ""

python3 - "$MEMORY_FILE" <<'PYEOF'
import json, sys
from collections import defaultdict

path = sys.argv[1]
by_type = defaultdict(list)

try:
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                d = json.loads(line)
            except Exception:
                continue
            if d.get("type") == "entity":
                by_type[d.get("entityType", "?")].append(d.get("name", "?"))
except Exception:
    sys.exit(0)

for etype in sorted(by_type):
    names = by_type[etype]
    print(f"- **{etype}** ({len(names)}): {', '.join(sorted(names))}")

print("")
print("Use `mcp__memory__search_nodes(query)` or `open_nodes([...])` with a keyword of the current "
      "topic to fetch the relevant detail. Do not assume content from the names above.")
PYEOF

echo ""
echo "_(full graph: $MEMORY_FILE, $(wc -l < "$MEMORY_FILE" | tr -d ' ') lines)_"
exit 0
