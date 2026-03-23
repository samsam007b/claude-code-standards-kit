# Audit Design

> Basé sur WCAG 2.1, Itten/Munsell (couleur), Bringhurst (typographie), Wertheimer (Gestalt), Baymard Institute.
> Score : /100 | Seuil recommandé : ≥80

---

## Section 1 — Couleurs et contrastes (30 points)

- [ ] Texte normal : contraste ≥4.5:1 vérifié sur toutes les combinaisons .... (10)
- [ ] Grand texte et éléments UI : contraste ≥3:1 ........................... (8)
- [ ] Palette cohérente : rôles définis (dominant/secondaire/accent) ......... (7)
- [ ] Système d'harmonie couleur respecté (complémentaire/analogique/triadique) (5)

**Outil :** WebAIM Contrast Checker

**Sous-total : /30**

---

## Section 2 — Typographie (25 points)

| Critère | Valeur mesurée | Seuil | OK ? | Points |
|---------|----------------|-------|------|--------|
| Taille corps minimum | ___px | ≥16px | | /8 |
| Longueur de ligne | ___ CPL | 50-75 | | /8 |
| Interligne | ___ | ≥1.5 | | /5 |
| Échelle typographique | ratio: ___ | modular scale | | /4 |

**Sous-total : /25**

---

## Section 3 — Gestalt et hiérarchie visuelle (25 points)

Application des 7 lois — noter les violations conscientes ou non justifiées :

| Loi | Appliquée ? | Violations | Points |
|-----|------------|-----------|--------|
| Proximité (éléments liés groupés) | | | /4 |
| Similarité (même style = même fonction) | | | /4 |
| Continuité (flux visuel cohérent) | | | /4 |
| Figure-fond (contraste fond/contenu) | | | /4 |
| Symétrie (layouts équilibrés) | | | /4 |
| Fermeture (icônes lisibles) | | | /3 |
| Destin commun (animations groupées) | | | /2 |

**Sous-total : /25**

---

## Section 4 — Design System (20 points)

- [ ] Design tokens centralisés (`tailwind.config.ts` ou `design-system.ts`) .. (8)
- [ ] Espacement systématique (base 8px ou 4px, pas de valeurs arbitraires) .. (6)
- [ ] `prefers-reduced-motion` respecté sur toutes les animations ............ (6)

**Sous-total : /20**

---

## Score total : /100

| Section | Score | /Total |
|---------|-------|--------|
| Couleurs & contrastes | | /30 |
| Typographie | | /25 |
| Gestalt & hiérarchie | | /25 |
| Design System | | /20 |
| **TOTAL** | | **/100** |

---

## Sources de référence

- Johannes Itten — Systèmes d'harmonie couleur
- WCAG 2.1 SC 1.4.3 — Contrastes
- Baymard Institute — CPL 50-75
- Bringhurst — Modular scale
- Wertheimer, Koffka, Köhler — 7 lois Gestalt
