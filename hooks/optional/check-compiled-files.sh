#!/bin/bash
# Bloque toute modification directe des fichiers compilés auto-générés.
# knowledge-bases.ts → modifier via clients/{slug}/knowledge-base.md + sync-kb.js
# system-prompt.ts → modifier via src/lib/system-prompt.ts uniquement si conscient du risque

INPUT=$(cat)
FILE=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null)

if echo "$FILE" | grep -qE "knowledge-bases\.ts$"; then
  echo "🔴 BLOQUÉ — knowledge-bases.ts est auto-généré par sync-kb.js"
  echo "   Modifier la source : clients/{slug}/knowledge-base.md"
  echo "   Puis régénérer    : node scripts/devtools/sync-kb.js --write"
  exit 2
fi

if echo "$FILE" | grep -qE "src/lib/system-prompt\.ts$"; then
  echo "⚠️  ATTENTION — system-prompt.ts contrôle le comportement de TOUS les agents"
  echo "   Toute modification affecte les agents en production."
  echo "   Confirmer que la modification est intentionnelle et testée."
  exit 1
fi

exit 0
