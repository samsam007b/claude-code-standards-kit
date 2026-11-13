#!/bin/bash
# file-history-rotate.sh — rotation de ~/.claude/file-history (item 2.9 du PLAN-AUDIT-360).
#
# Contexte : 511 Mo / 23 821 fichiers / 403 dossiers de session au 2026-08-09, sans
# aucune politique de rotation depuis la mise en service. C'est le magasin qui
# alimente /rewind ; une session de plus de quelques semaines n'est jamais rembobinée,
# donc l'espace est perdu sans contrepartie. Sur une machine dont le disque est resté
# sous les 25 Go libres en continu du 22/06 au 09/08 (248 alertes, backup cassé par
# ricochet), un demi-giga dormant n'est pas neutre.
#
# Deux critères, appliqués dans cet ordre :
#   1. âge  — tout dossier de session plus vieux que RETENTION_DAYS part ;
#   2. budget — si le total reste au-dessus de BUDGET_MB, on retire les dossiers les
#      plus anciens un par un jusqu'à repasser sous le budget.
# Le critère 2 existe parce que l'âge seul ne suffit pas ici : au 09/08, couper à 30
# jours ne rendait que 225 Mo sur 511, l'essentiel du volume étant dans des sessions
# récentes et lourdes. Une politique fondée sur le seul âge aurait donc raté sa cible
# en silence, ce qui est précisément le motif récurrent de l'audit du 08/08.
#
# Toujours conservé : au minimum KEEP_MIN dossiers, quels que soient l'âge et le
# budget, pour ne jamais rendre /rewind inutilisable sur la session en cours.

set -uo pipefail

HIST="$HOME/.claude/file-history"
RETENTION_DAYS=30
BUDGET_MB=250
KEEP_MIN=40
LOG="$HOME/Library/Logs/file-history-rotate.log"

[ -d "$HIST" ] || exit 0

size_mb() { du -sk "$HIST" 2>/dev/null | awk '{print int($1/1024)}'; }

BEFORE=$(size_mb)
BEFORE_N=$(find "$HIST" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')

# --- Critère 1 : âge ---
# On ne descend jamais sous KEEP_MIN, même si tout est vieux.
while IFS= read -r d; do
  [ "$(find "$HIST" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')" -le "$KEEP_MIN" ] && break
  rm -rf "$d"
done < <(find "$HIST" -mindepth 1 -maxdepth 1 -type d -mtime +"$RETENTION_DAYS" 2>/dev/null)

# --- Critère 2 : budget ---
# Tri par date de modification croissante : les plus anciens partent en premier.
while [ "$(size_mb)" -gt "$BUDGET_MB" ]; do
  N=$(find "$HIST" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
  [ "$N" -le "$KEEP_MIN" ] && break
  OLDEST=$(find "$HIST" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null \
    | xargs -0 stat -f '%m %N' 2>/dev/null | sort -n | head -1 | cut -d' ' -f2-)
  [ -n "$OLDEST" ] && [ -d "$OLDEST" ] || break
  rm -rf "$OLDEST"
done

AFTER=$(size_mb)
AFTER_N=$(find "$HIST" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
echo "$(date '+%F %T') file-history: ${BEFORE}Mo/${BEFORE_N}dirs -> ${AFTER}Mo/${AFTER_N}dirs (retention ${RETENTION_DAYS}j, budget ${BUDGET_MB}Mo)" >> "$LOG"

# Battement (item 0.5) : émis quoi qu'il arrive, y compris si rien n'a été supprimé.
# Un job de rotation qui ne tourne plus est invisible autrement, et c'est exactement
# le mode de panne que le canari existe pour attraper.
"$HOME/.claude/scripts/lib/heartbeat.sh" file-history-rotate 2>/dev/null || true
