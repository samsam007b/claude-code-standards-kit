#!/bin/bash
# PreToolUse hook — nextjs-ssr-bailout-guard
# Détecte `dynamic(..., { ssr: false })` appliqué à un composant qui wrappe {children}.
# Un tel composant ne peut pas être rendu côté serveur, donc Next.js bail-out le rendu
# serveur de TOUT ce qu'il contient (pas seulement lui-même) — le contenu devient
# invisible aux crawlers qui n'exécutent pas le JS (bug réel observé : homepage +
# toutes les pages livraient 63 caractères de HTML visible au lieu de plusieurs milliers,
# cause = un provider de suivi d'erreurs chargé en client-only).
#
# Avisory, non-bloquant (exit 0 + warning stderr) : le pattern légitime (modal/carte/graphique
# en feuille, sans {children}) est bien plus fréquent que le bug réel, un hard block créerait
# trop de faux positifs sur un pattern par ailleurs correct à 95% des usages ssr:false du repo.

INPUT=$(cat)

RESULT=$(echo "$INPUT" | python3 -c "
import sys, json, re

try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)

tool_input = d.get('tool_input', {})
file_path = tool_input.get('file_path', '')

if not re.search(r'\.(tsx|ts)$', file_path):
    sys.exit(0)

# Contenu à inspecter : Write -> content, Edit -> new_string (+ ancien fichier si dispo pour contexte)
new_content = tool_input.get('content') or tool_input.get('new_string') or ''

full_content = new_content
try:
    with open(file_path, encoding='utf-8') as f:
        existing = f.read()
    full_content = existing + '\n' + new_content
except Exception:
    pass

if 'ssr: false' not in full_content and 'ssr:false' not in full_content:
    sys.exit(0)

# Variables assignées via dynamic(...) avec ssr:false dans leur config
risky_names = []
for m in re.finditer(r'const\s+(\w+)\s*=\s*(?:nextDynamic|dynamic)\s*\(', full_content):
    name = m.group(1)
    window = full_content[m.end():m.end()+500]
    if re.search(r'ssr:\s*false', window):
        risky_names.append(name)

if not risky_names:
    sys.exit(0)

flagged = []
for name in risky_names:
    # Wrapping direct : {children} doit être le tout premier enfant JSX rencontré
    # juste après la balise ouvrante (espaces/retours à la ligne tolérés, rien d'autre) —
    # évite les faux positifs où {children} apparaît plus loin dans le fichier pour
    # un tout autre composant.
    # (?<!/) exclut les balises auto-fermantes <Name ... />
    wrap_pattern = re.compile(r'<' + re.escape(name) + r'(?:\s[^>]*)?(?<!/)>\s*\{children\}')
    if wrap_pattern.search(full_content):
        flagged.append(name)

if flagged:
    print('FLAGGED:' + ','.join(dict.fromkeys(flagged)))
" 2>/dev/null)

if [[ "$RESULT" == FLAGGED:* ]]; then
  NAMES="${RESULT#FLAGGED:}"
  echo "" >&2
  echo "⚠️  nextjs-ssr-bailout-guard — dynamic(..., { ssr: false }) semble wrapper {children}" >&2
  echo "" >&2
  echo "  Composant(s) concerné(s) : $NAMES" >&2
  echo "  Un composant ssr:false qui enveloppe {children} bloque le rendu serveur de TOUT ce" >&2
  echo "  qu'il contient — pas seulement lui-même. Si ce composant wrappe une partie de l'app" >&2
  echo "  (provider, layout), les pages en dessous deviennent invisibles aux crawlers non-JS." >&2
  echo "  Bug réel déjà rencontré : un provider de suivi d'erreurs chargé en client-only" >&2
  echo "  (cause de pages non indexées par Google)." >&2
  echo "" >&2
  echo "  Si ce composant n'a pas de raison objective d'être client-only (pas d'API navigateur" >&2
  echo "  au niveau module, pas de lib incompatible SSR), retire ssr:false — dynamic() sans" >&2
  echo "  ssr:false code-split quand même le JS, juste sans bloquer le SSR." >&2
  echo "" >&2
fi

exit 0
