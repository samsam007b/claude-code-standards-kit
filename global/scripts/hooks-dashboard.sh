#!/usr/bin/env bash
# hooks-dashboard.sh: what hooks are configured, per event, and which ones can block.
#
# Reads $CLAUDE_DIR/settings.json (default ~/.claude/settings.json), lists every hook group
# by event and matcher, and tags a hook script "blocking" when its source contains `exit 2`
# (the Claude Code "block this action" exit code) or a JSON "decision":"block".
#
# Usage: hooks-dashboard.sh [path/to/settings.json]
# Dependencies: python3

set -uo pipefail

SETTINGS="${1:-${CLAUDE_DIR:-$HOME/.claude}/settings.json}"

echo "Hooks dashboard"
echo "==============="
echo

if [ ! -f "$SETTINGS" ]; then
  echo "settings file not found: $SETTINGS" >&2
  exit 1
fi

python3 - "$SETTINGS" <<'PY'
import json, os, re, sys

settings = json.load(open(sys.argv[1]))
hooks = settings.get("hooks", {})
events = ["UserPromptSubmit", "PreToolUse", "PostToolUse", "SessionStart", "SessionEnd",
          "PreCompact", "Stop", "SubagentStop", "PermissionRequest", "Notification"]
events += [e for e in hooks if e not in events]

total = 0
for event in events:
    entries = hooks.get(event, [])
    if not entries:
        continue
    print("\n%s (%d group(s))" % (event, len(entries)))
    for entry in entries:
        matcher = entry.get("matcher", "*")
        for h in entry.get("hooks", []):
            total += 1
            cmd = h.get("command", "")
            tok = next((t for t in cmd.split() if re.search(r"\.(sh|js|mjs|py)$", t)), None)
            path = os.path.expandvars(os.path.expanduser(tok.strip("\"'"))) if tok else None
            blocking = False
            if path and os.path.exists(path):
                name = os.path.basename(path)
                try:
                    src = open(path, errors="replace").read()
                    blocking = bool(re.search(r"exit 2|exit\(2\)|process\.exit\(2\)|\"decision\"\s*:\s*\"block\"", src))
                except OSError:
                    pass
            else:
                name = (cmd[:40] if cmd else "?")
            tag = "BLOCKING" if blocking else "informational"
            print("  [%-22s] %-42s %s" % (matcher[:22], name[:42], tag))

print("\nTotal: %d hook(s) across %d event(s)" % (total, len([e for e in hooks if hooks[e]])))
PY

echo
echo "Source: $SETTINGS"
