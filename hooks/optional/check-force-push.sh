#!/bin/bash
# Bloque git push --force et git push -f sur toute branche.
# Un force push peut écraser du travail en production ou détruire l'historique.

INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null)

if echo "$CMD" | grep -qE "git\s+push" && echo "$CMD" | grep -qE "\-\-force|\-f(\s|$)"; then
  echo "🔴 BLOQUÉ — git push --force est interdit"
  echo "   Risque : écrasement irréversible de l'historique en production."
  echo "   Si vraiment nécessaire : demander confirmation explicite à l'utilisateur."
  exit 2
fi

exit 0
