# Audit Accessibilité

> Basé sur WCAG 2.1 AA, Nielsen's 10 Heuristics (NN/G), ARIA Authoring Practices.
> Score : /100 | Seuil recommandé : ≥85

---

## Section 1 — Contrastes et couleurs (20 points)

- [ ] Texte normal : contraste ≥4.5:1 (WCAG AA) ............................. (8)
- [ ] Grand texte (≥18pt) : contraste ≥3:1 ................................. (6)
- [ ] Éléments UI (boutons, icônes, champs) : contraste ≥3:1 ................ (6)

**Outil :** WebAIM Contrast Checker — webaim.org/resources/contrastchecker

**Sous-total : /20**

---

## Section 2 — Navigation et structure (20 points)

- [ ] Skip link présent et fonctionnel ....................................... (5)
- [ ] Un seul `<h1>` par page ................................................ (4)
- [ ] Hiérarchie des titres logique (h1→h2→h3, jamais de saut) .............. (5)
- [ ] Landmarks HTML sémantiques (`<header>`, `<nav>`, `<main>`, `<footer>`) .. (6)

**Sous-total : /20**

---

## Section 3 — Navigation clavier (15 points)

- [ ] Tous les éléments interactifs atteignables au clavier .................. (8)
- [ ] Focus visible sur tous les éléments interactifs ....................... (7)

**Sous-total : /15**

---

## Section 4 — Images et médias (15 points)

- [ ] Toutes les images informatives ont un `alt` descriptif ................. (8)
- [ ] Images décoratives ont `alt=""` (pas d'alt absent) ..................... (4)
- [ ] Icônes avec `aria-label` ou texte visible .............................. (3)

**Sous-total : /15**

---

## Section 5 — Formulaires (15 points)

- [ ] Tous les champs ont un `<label>` associé (`htmlFor`) ................... (6)
- [ ] Erreurs de formulaire : message descriptif + solution suggérée ......... (5)
- [ ] Champs requis marqués (`aria-required`, `required`) .................... (4)

**Sous-total : /15**

---

## Section 6 — Nielsen Heuristics (15 points)

Évaluation rapide des 10 heuristics — 0 (ok) / 1 (mineur) / 2 (majeur) / 3 (critique)

| Heuristique | Violations | Score (/3) |
|------------|-----------|-----------|
| 1. Visibilité du statut système | | /3 |
| 2. Correspondance monde réel | | /3 |
| 3. Contrôle et liberté | | /3 |
| 4. Cohérence et standards | | /3 |
| 5. Prévention des erreurs | | /3 |

Score section 6 = (15 - somme des violations) × 1, minimum 0.

**Sous-total : /15**

---

## Score total : /100

| Section | Score | /Total |
|---------|-------|--------|
| Contrastes | | /20 |
| Navigation/structure | | /20 |
| Clavier | | /15 |
| Images | | /15 |
| Formulaires | | /15 |
| Nielsen Heuristics | | /15 |
| **TOTAL** | | **/100** |

---

## Outils recommandés

```bash
# Automatique (détecte ~30% des problèmes WCAG)
# axe-core dans Playwright / Testing Library
# Lighthouse Accessibility (DevTools)

# Manuel — obligatoire
# VoiceOver macOS : Cmd+F5
# Clavier uniquement : parcourir l'interface sans souris
```
