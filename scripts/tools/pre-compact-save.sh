#!/bin/bash
# PreCompact hook — sauvegarde l'état GSD avant compaction
# Évite de perdre le contexte d'un PLAN.md actif lors d'une compaction automatique

DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M:%S)
CWD="$PWD"
STATE_FILE="$HOME/.claude/session-env/pre-compact-state.md"

mkdir -p "$HOME/.claude/session-env"

# Détecter si un projet GSD est actif
PLANNING_DIR="$CWD/.planning"
ACTIVE_PLAN=""
ACTIVE_PHASE=""

if [ -d "$PLANNING_DIR" ]; then
  # Trouver le dernier PLAN.md modifié
  ACTIVE_PLAN=$(find "$PLANNING_DIR/phases" -name "*PLAN.md" 2>/dev/null | xargs ls -t 2>/dev/null | head -1)
  # Trouver la phase active dans STATE.md
  if [ -f "$PLANNING_DIR/STATE.md" ]; then
    ACTIVE_PHASE=$(grep -m1 "current_phase\|phase_active\|Phase en cours" "$PLANNING_DIR/STATE.md" 2>/dev/null | head -1)
  fi
fi

# Trouver les todos en cours
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

# Écrire l'état
cat > "$STATE_FILE" << EOF
# État pré-compaction — $DATE $TIME

## Projet actif
**Répertoire** : $CWD

## GSD — Plan actif
$([ -n "$ACTIVE_PLAN" ] && echo "**Plan** : $ACTIVE_PLAN" || echo "Aucun plan GSD détecté")
$([ -n "$ACTIVE_PHASE" ] && echo "**Phase** : $ACTIVE_PHASE" || echo "")

## Todos en cours
$([ -n "$TODOS_IN_PROGRESS" ] && echo "$TODOS_IN_PROGRESS" || echo "Aucun todo en cours")

## Rappel post-compaction
Après compaction, lire ce fichier pour reprendre le contexte :
\`cat ~/.claude/session-env/pre-compact-state.md\`
EOF

# Injection dans le contexte via stdout (lu par Claude après compaction)
echo "🗜️ Compaction en cours. État sauvegardé dans ~/.claude/session-env/pre-compact-state.md"
echo "Projet: $CWD | Plan: ${ACTIVE_PLAN:-aucun}"

exit 0
