# Framework — Estimation de Projet

> Sources : US Navy PERT (1957), Daniel Kahneman & Amos Tversky (Prix Nobel Économie 2002),
> Joel Spolsky Evidence-Based Scheduling (joelonsoftware.com, 2007),
> UK Department for Transport Reference Class Forecasting (gov.uk, 2004).
> À utiliser : avant tout engagement de délai avec un client ou soi-même.

---

## Le problème fondamental : la Planning Fallacy

Kahneman & Tversky ont nommé ce phénomène en 1979 : la **planning fallacy** est la tendance
systématique à sous-estimer le temps, le coût et les risques d'une tâche future, tout en
surestimant ses bénéfices — même en sachant qu'on a systématiquement sous-estimé par le passé.

Ce n'est pas un défaut de caractère. C'est un biais cognitif universel, documenté sur
des milliers de projets, des rénovations domestiques aux tunnels ferroviaires.

**Données concrètes :**
- Le UK Department for Transport introduit le Reference Class Forecasting en 2004.
  Résultat : les dépassements de budget passent de **38% à 5%** sur les grands projets.
- Les développeurs sous-estiment systématiquement de **40-200%** selon le type de tâche.

### La règle SQWR : ×1.5 systématique pour solo+IA

Le contexte Claude Code introduit un optimisme artificiel supplémentaire :
- Claude génère un prototype en 30 min → donne l'illusion que la feature est finie
- La réalité : debugging, edge cases, tests, intégration avec le code existant multiplient par 2-3
- **Règle empirique SQWR : multiplier TOUTE estimation par ×1.5 avant de s'engager**

```
Estimation intuitive : 4 heures
PERT calculé        : 5.3 heures
Ajustement ×1.5     : 8 heures → 1 journée de travail
```

---

## Méthode 1 — PERT (US Navy, Programme Polaris, 1957)

### La formule

PERT (Program Evaluation and Review Technique) force à penser en trois scénarios :

```
Estimation PERT = (O + 4M + P) / 6

O = Optimiste       (tout se passe parfaitement, aucun imprévu)
M = Most Likely     (scénario normal avec quelques frictions typiques)
P = Pessimiste      (les complications prennent plus de temps que prévu)
```

**Pourquoi 4×M ?** La formule vient de la distribution Beta. Le cas le plus probable
est pondéré 4 fois car il est empiriquement le plus représentatif de la réalité —
avec des limites pour éviter les optimismes extrêmes.

### Déviation standard — mesurer l'incertitude

```
σ = (P - O) / 6
```

Plus σ est grand, plus la tâche est incertaine. σ > 2h sur une tâche estimée à 4h
signifie une incertitude élevée → creuser les Rabbit Holes avant de s'engager.

### Table d'exemples SQWR

| Tâche | O | M | P | PERT brut | ×1.5 | Estimation engagement |
|-------|---|---|---|-----------|------|----------------------|
| Page marketing statique (Next.js) | 2h | 4h | 8h | 4.3h | 6.5h | **1 jour** |
| Feature auth complète (Supabase) | 4h | 8h | 20h | 9.3h | 14h | **2 jours** |
| Intégration API tierce (webhook, etc.) | 2h | 6h | 16h | 7h | 10.5h | **1.5 jours** |
| Composant UI réutilisable | 1h | 2h | 5h | 2.3h | 3.5h | **4h ouvrables** |
| Migration base de données (Supabase) | 1h | 3h | 8h | 3.5h | 5.3h | **1 jour** |
| Setup projet from scratch | 2h | 4h | 6h | 4h | 6h | **1 jour** |

---

## Méthode 2 — Reference Class Forecasting (Kahneman)

### Inside view vs Outside view

| Approche | Description | Biais |
|----------|-------------|-------|
| **Inside view** | Estimer *cette* tâche en se concentrant sur ses détails | Ignore comment les tâches similaires se sont réellement passées |
| **Outside view** | Regarder comment des tâches *similaires* se sont passées dans le passé | Corrige le biais d'optimisme avec de la data réelle |

**La Reference Class Forecasting, c'est systématiquement préférer l'Outside view.**

### Application pratique SQWR

1. Identifier la classe de la tâche (ex: "page avec formulaire + API Supabase")
2. Regarder dans l'historique SQWR combien ça a pris les fois précédentes
3. Utiliser la **médiane** (pas la moyenne, trop influencée par les outliers)
4. Ajuster pour les différences connues avec la tâche actuelle

### Registre de référence SQWR — à remplir au fil des projets

| Classe de tâche | Exemples passés | Médianne réelle | Ajustement |
|----------------|-----------------|-----------------|-----------|
| Page statique marketing | La Villa, SQWR, Villa Coladeira | [à remplir] | |
| Page avec auth Supabase | izzico login, CozyGrowth dashboard | [à remplir] | |
| Composant UI réutilisable | [liste des composants créés] | [à remplir] | |
| Feature CRUD complète | [liste] | [à remplir] | |
| Intégration service tiers | [liste] | [à remplir] | |
| Setup projet from scratch | [liste] | [à remplir] | |

**Instruction :** Après chaque projet, noter [estimation initiale, durée réelle] dans ce tableau.
En 3-4 projets, les médianes deviennent statistiquement fiables.

---

## Méthode 3 — Evidence-Based Scheduling (Joel Spolsky, 2007)

### Principe

> *"Instead of pulling a date out of thin air, you use your actual historical velocity
> to produce a probability distribution of ship dates."* — Joel Spolsky

**Velocity individuelle = temps estimé / temps réel**

```
Si tu estimes "4h" et ça prend "6h" → velocity = 4/6 = 0.67
Pour corriger : estimation future × (1 / 0.67) = × 1.5

Si tu estimes "4h" et ça prend "3h" → velocity = 4/3 = 1.33
Pour corriger : estimation future × (1 / 1.33) = × 0.75
```

### Comment tracker sa velocity SQWR

| Mois | Tâche | Estimé | Réel | Ratio |
|------|-------|--------|------|-------|
| [mois] | [tâche] | [Xh] | [Yh] | [X/Y] |
| | | | | |
| | | | | |
| **Moyenne** | | | | **[calculer]** |

**Multiplicateur personnel = 1 / (moyenne des ratios)**

*Exemple : si ta moyenne est 0.7 → tu divises par 0.7 = tu multiplies par ×1.43.
C'est très proche du ×1.5 empirique de la règle SQWR — ce n'est pas une coïncidence.*

---

## Template d'estimation SQWR

```markdown
## Estimation — [Feature / Projet]

**Date :** [JJ/MM/AAAA]
**Projet :** [nom]
**Décrit dans le Pitch :** [lien ou description courte]

### Décomposition des tâches

| # | Tâche | O | M | P | PERT brut |
|---|-------|---|---|---|-----------|
| 1 | [tâche] | | | | |
| 2 | [tâche] | | | | |
| 3 | [tâche] | | | | |
| **Total** | | | | | **[somme]h** |

### Ajustements

| Ajustement | Facteur | Résultat |
|-----------|---------|----------|
| Total PERT brut | 1.0 | [X]h |
| Multiplicateur solo+IA | ×1.5 | [X × 1.5]h |
| Ajustement velocity personnelle | ×[ton ratio] | [résultat]h |
| **Estimation finale** | | **[résultat]h → [X] jours** |

### Reference Class

Tâche la plus similaire dans l'historique SQWR : [description]
Durée réelle de cette tâche : [X]h / [X] jours

### Engagements de livraison

| Confiance | Date |
|-----------|------|
| 50% (optimiste) | [JJ/MM/AAAA] |
| **85% (à communiquer)** | **[JJ/MM/AAAA]** |

**Règle SQWR : toujours communiquer la date à 85% de confiance au client.
Ne jamais communiquer la date optimiste comme date de livraison.**
```

---

## Checklist Estimation

- [ ] Tâche décomposée en sous-tâches (chaque sous-tâche ≤ 4h)
- [ ] Formule PERT appliquée sur chaque sous-tâche (O, M, P remplis)
- [ ] Reference Class consultée (a-t-on fait quelque chose de similaire avant ?)
- [ ] Multiplicateur ×1.5 (solo+IA) appliqué sur le total
- [ ] Vélocité personnelle prise en compte si historique disponible
- [ ] Rabbit Holes identifiés (→ voir `frameworks/PROJECT-SCOPING.md`)
- [ ] **Date à 85% de confiance communiquée — jamais la date optimiste**

---

## Sources

| Référence | Lien |
|-----------|------|
| PERT — US Navy Polaris Program (1957) | wikipedia.org/wiki/Program_evaluation_and_review_technique |
| Planning Fallacy — Kahneman & Tversky | scholar.princeton.edu (Nobel Prize 2002 — Judgment under Uncertainty) |
| Reference Class Forecasting — UK DfT (2004) | gov.uk/government/publications/reference-class-forecasting |
| Evidence-Based Scheduling — Joel Spolsky (2007) | joelonsoftware.com/2007/10/26/evidence-based-scheduling |
| Thinking, Fast and Slow — Daniel Kahneman (2011) | penguin.co.uk/books/thinking-fast-and-slow |
