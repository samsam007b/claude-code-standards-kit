# Framework — Audit Concurrentiel

> Module de framework SQWR Project Kit.
> Sources : Nielsen Norman Group — Competitive Usability (nngroup.com/articles/competitive-usability-evaluations), Harvard Business Review — Mystery Shopper methodology, Kim & Mauborgne — Blue Ocean Strategy Canvas (hbr.org/2004/10/blue-ocean-strategy), Baymard Institute — Competitive UX Benchmark.

---

## Quand utiliser ce framework

**Avant tout nouveau projet, produit ou repositionnement de marque**, analyser 3 à 5 concurrents directs et indirects. Un audit concurrentiel prend 2 à 4 heures mais évite de construire quelque chose qui existe déjà ou qui ignore des conventions établies dans le secteur.

> "The best way to differentiate is to know exactly what you're differentiating from." — Nielsen Norman Group

---

## 1. Sélection des Concurrents

### 3 types à analyser

| Type | Définition | Exemples |
|------|------------|---------|
| **Concurrent direct** | Même offre, même cible | Produit A vs Produit B |
| **Concurrent indirect** | Solution alternative au même problème | Alternative workflow différent |
| **Meilleure pratique (hors secteur)** | Leader UX/branding dans un autre domaine | Airbnb pour l'hospitalité, Notion pour la productivité |

**Règle :** inclure toujours au moins **1 concurrent hors secteur** — les meilleures innovations UX viennent souvent d'analogies cross-sectorielles.

**Nombre recommandé : 3–5 concurrents.** Au-delà = analyse trop diffuse. En dessous = biais de confirmation.

> Source : Nielsen Norman Group — [nngroup.com/articles/competitive-usability-evaluations](https://www.nngroup.com/articles/competitive-usability-evaluations/)

---

## 2. Grille d'Analyse — Template

Pour chaque concurrent, évaluer les 6 dimensions suivantes.

### Template par concurrent

```
Concurrent : [Nom]
URL / App : [lien]
Date d'analyse : [date]
Analyste : [nom]

═══════════════════════════════════
DIMENSION 1 — POSITIONNEMENT (20 pts)
═══════════════════════════════════

Proposition de valeur principale :
→ [En 1 phrase — ce qu'ils disent être]

Cible exprimée :
→ [Qui ils ciblent explicitement]

Différenciants revendiqués :
→ [Ce qu'ils disent être uniques]

Score positionement : ___/20
Commentaires : ...

═══════════════════════════════════
DIMENSION 2 — DESIGN & UX (20 pts)
═══════════════════════════════════

Cohérence visuelle (couleurs, typo, espacement) : ___/5
Clarté de la navigation (temps pour trouver X) :  ___/5
Qualité du onboarding (première expérience) :      ___/5
Responsive / Mobile :                              ___/5

Score Design & UX : ___/20

Observations :
→ [Ce qui fonctionne]
→ [Ce qui ne fonctionne pas]
→ [Inspiration possible]

═══════════════════════════════════
DIMENSION 3 — PERFORMANCE (20 pts)
═══════════════════════════════════

LCP (Largest Contentful Paint) :   [Mesurer sur web.dev/measure]
FID / INP :                        [Mesurer sur web.dev/measure]
CLS :                              [Mesurer sur web.dev/measure]
Score Lighthouse Performance :     ___/100

Score Performance : ___/20
(>90 Lighthouse = 20pts | 75-90 = 15pts | 60-75 = 10pts | <60 = 5pts)

═══════════════════════════════════
DIMENSION 4 — ACCESSIBILITÉ (15 pts)
═══════════════════════════════════

Score Lighthouse Accessibility :   ___/100
Navigation clavier fonctionnelle : ☐ Oui / ☐ Non / ☐ Partiel
Contrastes WCAG AA respectés :     ☐ Oui / ☐ Non / ☐ Partiel
Alt text sur images :              ☐ Oui / ☐ Non / ☐ Partiel

Score Accessibilité : ___/15

═══════════════════════════════════
DIMENSION 5 — CONTENU & SEO (15 pts)
═══════════════════════════════════

Clarté du message (< 5 sec pour comprendre l'offre) : ___/5
Qualité du copywriting (tone of voice cohérent) :     ___/5
Présence SEO (ranking mots-clés cibles) :             ___/5

Score Contenu & SEO : ___/15

═══════════════════════════════════
DIMENSION 6 — BRAND (10 pts)
═══════════════════════════════════

Mémorabilité (logo, couleurs uniques) :     ___/5
Cohérence cross-platform (web, app, RS) :   ___/5

Score Brand : ___/10

═══════════════════════════════════
SCORE TOTAL : ___/100
═══════════════════════════════════
```

---

## 3. Heuristic Evaluation (Nielsen)

> Source : Nielsen Norman Group — How to Conduct a Heuristic Evaluation — [nngroup.com/articles/how-to-conduct-a-heuristic-evaluation](https://www.nngroup.com/articles/how-to-conduct-a-heuristic-evaluation/)

Pour chaque concurrent, appliquer les 10 heuristiques de Nielsen. Scorer de 0 à 4 :

| Score | Signification |
|-------|---------------|
| 0 | Pas de problème |
| 1 | Problème cosmétique — fix si le temps le permet |
| 2 | Problème mineur — priorité basse |
| 3 | Problème majeur — priorité haute |
| 4 | Catastrophe — bloque l'usage |

```
Heuristique 1 — Visibilité du statut :         [0-4]
Heuristique 2 — Correspondance monde réel :    [0-4]
Heuristique 3 — Contrôle et liberté :          [0-4]
Heuristique 4 — Cohérence et standards :       [0-4]
Heuristique 5 — Prévention des erreurs :       [0-4]
Heuristique 6 — Reconnaissance plutôt que rappel : [0-4]
Heuristique 7 — Flexibilité et efficacité :    [0-4]
Heuristique 8 — Design minimaliste :           [0-4]
Heuristique 9 — Aide à corriger les erreurs :  [0-4]
Heuristique 10 — Aide et documentation :       [0-4]

Score Nielsen (problèmes détectés) : ___/40
(Plus le score est bas = mieux / 0 = aucun problème)
```

> **Nombre d'évaluateurs recommandé : 3–5.** Un seul évaluateur détecte ~35% des problèmes. Cinq évaluateurs en détectent ~75%. Au-delà de 5 = rendements décroissants.
> Source : Nielsen Norman Group — [nngroup.com/articles/how-to-conduct-a-heuristic-evaluation](https://www.nngroup.com/articles/how-to-conduct-a-heuristic-evaluation/)

---

## 4. Blue Ocean Canvas

> Source : Kim & Mauborgne — *Blue Ocean Strategy* (Harvard Business Review Press, 2005)
> [hbr.org/2004/10/blue-ocean-strategy](https://hbr.org/2004/10/blue-ocean-strategy)

Le Blue Ocean Canvas permet de visualiser les facteurs compétitifs et d'identifier les espaces non exploités.

### Instructions

1. Lister les **6–8 facteurs compétitifs** importants dans votre secteur
2. Scorer chaque concurrent de 1 (bas) à 5 (haut) sur chaque facteur
3. Tracer les courbes de valeur
4. Identifier les zones où vous pouvez : **Éliminer / Réduire / Augmenter / Créer (ERIC)**

### Template Blue Ocean Canvas

```
FACTEURS COMPÉTITIFS          | Vous | Conc.A | Conc.B | Conc.C
─────────────────────────────────────────────────────────────────
[Facteur 1 — ex: Prix]        |  3   |   5    |   2    |   4
[Facteur 2 — ex: Vitesse]     |  4   |   3    |   5    |   2
[Facteur 3 — ex: Design]      |  5   |   2    |   3    |   2
[Facteur 4 — ex: Support]     |  2   |   4    |   3    |   5
[Facteur 5 — ex: Intégrations]|  3   |   5    |   4    |   3
[Facteur 6 — ex: Mobile]      |  5   |   3    |   2    |   4
[Facteur 7 — ex: IA/Auto]     |  4   |   2    |   1    |   2
─────────────────────────────────────────────────────────────────

ACTIONS ERIC :
→ ÉLIMINER : [facteurs sur lesquels tous investissent mais qui n'ont pas de valeur perçue]
→ RÉDUIRE : [facteurs sur-investis vs standard du secteur]
→ AUGMENTER : [facteurs sous-investis vs standard du secteur]
→ CRÉER : [facteurs inexistants dans le secteur = océan bleu]
```

---

## 5. Mystery Shopper — Parcours Utilisateur

> Source : Harvard Business Review — Customer Journey Mapping (hbr.org)
> Source : Baymard Institute — UX Benchmark methodology (baymard.com/research)

**Principe :** effectuer le parcours complet d'un concurrent comme si vous étiez un vrai utilisateur. Documenter chaque friction.

```
MYSTERY SHOPPER — Rapport de parcours
Concurrent : [Nom]
Parcours testé : [ex: Inscription → Premier achat → Support]
Date : [date]
Durée : [temps total]

─────────────────────────
ÉTAPE 1 — [Nom de l'étape]
─────────────────────────
Durée : [temps]
Action effectuée : [description]
Friction identifiée : [problème si applicable]
Émotion : [confus / frustré / satisfait / impressionné]
Screenshot : [référence]

─────────────────────────
ÉTAPE 2 — ...
─────────────────────────

SYNTHÈSE DU PARCOURS :
→ Moment le plus fluide : [étape]
→ Moment le plus frustrant : [étape + raison]
→ Ce qu'on doit absolument copier : [...]
→ Ce qu'on doit absolument éviter : [...]
→ Opportunité identifiée : [...]
```

---

## 6. Tableau de Synthèse Comparative

```
TABLEAU COMPARATIF — [Projet X] vs Concurrents
Date : [date]

                    | Vous | Conc.A | Conc.B | Conc.C | Leader idéal
────────────────────────────────────────────────────────────────────
Positionnement      |  -   |  /20   |  /20   |  /20   |    /20
Design & UX         |  -   |  /20   |  /20   |  /20   |    /20
Performance         |  -   |  /20   |  /20   |  /20   |    /20
Accessibilité       |  -   |  /15   |  /15   |  /15   |    /15
Contenu & SEO       |  -   |  /15   |  /15   |  /15   |    /15
Brand               |  -   |  /10   |  /10   |  /10   |    /10
────────────────────────────────────────────────────────────────────
SCORE TOTAL         |  -   | /100   | /100   | /100   |   /100

FORCES DE [Projet X] par rapport aux concurrents :
1. [Force 1]
2. [Force 2]

FAIBLESSES à adresser en priorité :
1. [Faiblesse 1 — dimension + score]
2. [Faiblesse 2 — dimension + score]

OPPORTUNITÉS (angles non exploités par les concurrents) :
1. [Opportunité Blue Ocean 1]
2. [Opportunité Blue Ocean 2]
```

---

## 7. Quand relancer l'audit

| Déclencheur | Fréquence recommandée |
|-------------|----------------------|
| Lancement d'un nouveau projet | Avant le premier sprint |
| Repositionnement de marque | Avant la nouvelle stratégie |
| Nouveau concurrent majeur détecté | Sous 2 semaines |
| Audit de maintenance | Tous les 6 mois |

---

## Sources

| Référence | Lien |
|-----------|------|
| Nielsen Norman Group — Competitive Usability | nngroup.com/articles/competitive-usability-evaluations |
| Nielsen — Heuristic Evaluation | nngroup.com/articles/how-to-conduct-a-heuristic-evaluation |
| Kim & Mauborgne — Blue Ocean Strategy (HBR, 2004) | hbr.org/2004/10/blue-ocean-strategy |
| Baymard Institute — UX Benchmark | baymard.com/research |
| Google PageSpeed Insights | pagespeed.web.dev |
| WebAIM Contrast Checker | webaim.org/resources/contrastchecker |
