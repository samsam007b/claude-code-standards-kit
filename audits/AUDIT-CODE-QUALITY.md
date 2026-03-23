# Audit Qualité Code

> Basé sur Robert C. Martin (Clean Code), SOLID, Google Engineering Practices, ISO/IEC 25010.
> Score : /100 | Seuil recommandé : ≥75

**Règle de scoring N/A (ISO/IEC 25010) :**
```
Score = (points obtenus / points applicables) × 100
```
Un critère marqué `[-]` N/A est exclu du numérateur ET du dénominateur.
Exemple : Si Section 1 = N/A → score sur 75 pts applicables, pas 100.

---

## Section 1 — TypeScript strict (25 points)

> **⚠️ Applicabilité** : Cette section est `[-] N/A` pour les projets non-TypeScript
> (bash scripts, documentation, Python pur, kits markdown).
> Dans ce cas, le score est calculé sur 75 points applicables (Sections 2+3+4).

- [ ] `strict: true` dans `tsconfig.json` .................................... (10)
- [ ] Zéro erreur `any` dans le code source (sauf hors-contrôle) ............. (8)
- [ ] Aucun `@ts-ignore` sans commentaire justificatif ....................... (4)
- [ ] Types Supabase générés et utilisés ..................................... (3)

**Sous-total : /25** *(ou N/A si projet non-TypeScript)*

---

## Section 2 — Tests et couverture (30 points)

- [ ] Coverage global ≥80% ................................................... (12)
- [ ] Coverage sur les chemins auth ≥100% ................................... (8)
- [ ] Tests unitaires présents pour la logique métier ....................... (5)
- [ ] Tests d'intégration sur vraie DB (pas mockée) ......................... (5)

**Commande :** `npm run test:coverage`

**Sous-total : /30**

---

## Section 3 — Clean Code & SOLID (25 points)

- [ ] Fonctions ≤20 lignes (hors cas justifiés) ............................. (5)
- [ ] Complexité cyclomatique ≤10 par fonction ............................... (5)
- [ ] Pas de duplication évidente (DRY respecté) ............................ (5)
- [ ] Nommage explicite (pas de `data`, `temp`, `x`, `res`) .................. (5)
- [ ] Single Responsibility respecté (pas de God Components) ................. (5)

**Sous-total : /25**

---

## Section 4 — Build et lint (20 points)

- [ ] `npm run build` passe sans erreur ....................................... (8)
- [ ] `npm run lint` passe avec 0 erreur ..................................... (7)
- [ ] Aucun `console.log` de debug oublié .................................... (5)

**Commandes :**
```bash
npm run build
npm run lint
grep -r "console.log" src/ --include="*.ts" --include="*.tsx"
```

**Sous-total : /20**

---

## Score total : /100

| Section | Score | /Total | N/A ? |
|---------|-------|--------|-------|
| TypeScript strict | | /25 | Oui si non-TS |
| Tests & coverage | | /30 | — |
| Clean Code & SOLID | | /25 | — |
| Build & lint | | /20 | — |
| **TOTAL** | | **/100** | |

**Calcul si TypeScript N/A :**
```
Score = (Section2 + Section3 + Section4) / 75 × 100
```
Exemple : 30/30 + 25/25 + 20/20 = 75/75 → **100/100**

**Calcul standard (projet TypeScript) :**
```
Score = (Section1 + Section2 + Section3 + Section4) / 100
```

---

## Google Code Review Checklist (pre-merge)

Avant tout merge sur `main` :

- [ ] **Design** : Le code est bien conçu et approprié pour le système
- [ ] **Functionality** : Fait ce qu'il doit faire, bon pour les utilisateurs
- [ ] **Complexity** : Aussi simple que possible
- [ ] **Tests** : Corrects, exhaustifs, bien conçus
- [ ] **Naming** : Noms clairs et descriptifs
- [ ] **Documentation** : README et commentaires à jour si nécessaire
