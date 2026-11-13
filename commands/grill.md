---
description: Interroge l'utilisateur avant de coder une feature complexe — clarifier scope, ambiguïtés, langage partagé, critères de succès. Pattern Matt Pocock /grill-with-docs.
---

# /grill — Interview avant implémentation

Avant de coder, poser les questions suivantes dans l'ordre. Arrêter dès que tout est clair.

## Phase 1 — Scope & contexte

1. Quel est le **résultat visible** attendu une fois la feature terminée ?
2. Qu'est-ce qui est **explicitement hors scope** ?
3. Est-ce que cette feature existe ailleurs dans le codebase ou a déjà été tentée ?

## Phase 2 — Utilisateurs & cas limites

4. Qui utilise cette feature et dans quel contexte exact ?
5. Quels sont les 2-3 cas limites à gérer absolument ?
6. Qu'est-ce qui doit se passer si ça échoue ?

## Phase 3 — Critères de succès

7. Comment savoir que c'est **fini** ? Quel test ou comportement observable ?
8. Y a-t-il des contraintes techniques non-négociables (perf, sécu, compatibilité) ?

## Phase 4 — Langage partagé

9. Y a-t-il des termes métier spécifiques à ce projet que je dois connaître ?
10. Y a-t-il une doc, un ticket ou un exemple existant à suivre ?

---

## Règles d'utilisation

- Poser max **3 questions par tour** — ne pas tout dumper d'un coup
- Si l'utilisateur dit "vas-y" sans tout clarifier → noter les hypothèses explicitement avant de coder
- Résumer le plan en **5 bullets max** avant d'écrire la première ligne de code
- Créer un critère de succès vérifiable avant de commencer

## Quand l'utiliser

| Situation | Grill ? |
|-----------|---------|
| Feature nouvelle, scope flou | ✅ Obligatoire |
| Bug fix isolé | ❌ Non |
| Refactor >3 fichiers | ✅ Recommandé |
| "Fais X rapidement" avec contexte clair | ❌ Non |
| Feature cross-projet ou avec impact client | ✅ Obligatoire |

---

*Inspiré de mattpocock/skills — /grill-with-docs (56K stars)*
