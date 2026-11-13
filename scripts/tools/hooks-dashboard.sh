#!/bin/bash
# hooks-dashboard.sh — Visibilité temps réel sur les hooks configurés et leur activité récente.
# Pattern repris de experiments/team-coordination/team-status.sh (lecture d'état, zéro dépendance).
# Usage: ~/.claude/scripts/hooks-dashboard.sh

SETTINGS="$HOME/.claude/settings.json"
LOG_DIR="$HOME/.claude/logs"

echo "🪝 Hooks Dashboard"
echo "=================="
echo ""

if [ ! -f "$SETTINGS" ]; then
  echo "Status: settings.json introuvable ($SETTINGS)"
  exit 1
fi

echo "📋 Hooks configurés par événement"
echo "----------------------------------"
python3 - "$SETTINGS" <<'PYEOF'
import json, sys, os

settings = json.load(open(sys.argv[1]))
hooks = settings.get("hooks", {})

for event in ["UserPromptSubmit", "PreToolUse", "PostToolUse", "SessionStart", "SessionEnd", "PreCompact", "Stop", "PermissionRequest"]:
    entries = hooks.get(event, [])
    if not entries:
        continue
    print(f"\n{event} ({len(entries)} groupe(s))")
    for entry in entries:
        matcher = entry.get("matcher", "*")
        for h in entry.get("hooks", []):
            cmd = h.get("command", "")
            script_path = next((tok for tok in cmd.split() if tok.endswith(".sh") or tok.endswith(".js")), None)
            if script_path and os.path.exists(script_path):
                name = os.path.basename(script_path)
                blocking = "exit 2" in open(script_path).read()
            else:
                name = cmd[:40] if cmd else "?"
                blocking = False
            tag = "🛑 bloquant" if blocking else "ℹ️  informatif"
            print(f"  [{matcher:20s}] {name:40s} {tag}")

total = sum(len(v) for v in hooks.values())
print(f"\nTotal : {total} groupe(s) de hooks sur {len(hooks)} événement(s)")
PYEOF

echo ""
echo "📊 Activité récente"
echo "--------------------"

FRUSTRATION_LOG="$LOG_DIR/frustration-signals.jsonl"
if [ -f "$FRUSTRATION_LOG" ]; then
  COUNT=$(wc -l < "$FRUSTRATION_LOG" | tr -d ' ')
  LAST=$(tail -1 "$FRUSTRATION_LOG" | python3 -c "import json,sys; e=json.load(sys.stdin); print(f\"{e['timestamp']} (score {e['score']}) — {e['signals'].strip()}\")" 2>/dev/null)
  echo "Signaux de frustration capturés : $COUNT"
  [ -n "$LAST" ] && echo "  Dernier : $LAST"
else
  echo "Signaux de frustration capturés : 0 (aucun log)"
fi

MEMORY_SYNC_LOG="$LOG_DIR/memory-sync-cron.log"
if [ -f "$MEMORY_SYNC_LOG" ]; then
  LAST_RUN=$(grep "démarré" "$MEMORY_SYNC_LOG" | tail -1)
  echo "memory-sync — dernier run : ${LAST_RUN:-jamais}"
else
  echo "memory-sync — dernier run : jamais (log absent, cron pas encore déclenché)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Source : $SETTINGS · Logs : $LOG_DIR"
