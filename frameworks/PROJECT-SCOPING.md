# Framework — Project Scoping

> Sources : Ryan Singer (Shape Up, Basecamp 2019), Jake Knapp (Sprint, Google Ventures 2016),
> Gary Klein (HBR 2007 — pre-mortem), PMI PMBOK 6th Edition, Standish Group CHAOS Report 2020.
> À utiliser : avant de commencer tout nouveau projet ou feature significative (>1 jour de travail).

---

## Pourquoi scoper avant de coder

**70% des projets IT dépassent leur budget ou délai initial** (Standish CHAOS Report 2020).
La cause principale n'est pas le code — c'est l'absence de définition claire du problème,
du périmètre, et des risques *avant* de toucher l'éditeur.

Pour un studio solo+IA comme SQWR, le risque est amplifié : Claude Code peut générer
du code rapidement, ce qui donne l'illusion que tout avance — même dans la mauvaise direction.
**Scoper en amont coûte 1 heure. Un pivot après 2 semaines de développement coûte 2 semaines.**

---

## Partie 1 — Shape Up Pitch (Ryan Singer, Basecamp 2019)

### Principe

Shape Up remplace les PRDs et user stories par un document court (le "Pitch") qui capture
l'essentiel d'une feature avant que le développement ne commence. L'objectif n'est pas
de spec chaque pixel — c'est de définir le problème et les limites du possible.

> *"We don't want to waste the team's time. We shape the work in advance by formulating
> a precise problem and a rough solution."* — Ryan Singer

### Les 5 composants du Pitch

| Composant | Question clé | Exemple SQWR |
|-----------|-------------|--------------|
| **Problem** | Quel problème réel l'utilisateur a-t-il ? | "Les propriétaires ne peuvent pas voir qui a consulté leur annonce izzico sans naviguer dans 3 écrans" |
| **Appetite** | Combien de temps est-on prêt à y consacrer ? | "2 jours max — si plus, on réduit le scope" |
| **Solution** | Esquisse fat-marker (pas un wireframe précis) | Dashboard propriétaire avec compteur de vues + liste des 5 derniers profils consultants |
| **Rabbit Holes** | Quelles complexités pourraient exploser le scope ? | "Ne pas essayer d'afficher les analytics historiques — juste les 30 derniers jours" |
| **No-Gos** | Qu'est-ce qu'on ne fait **pas** dans cette version ? | "Pas de comparaison entre annonces, pas de graphiques, pas de filtre par date" |

### Appetites recommandés pour SQWR (solo+IA)

| Taille | Durée | Quand l'utiliser |
|--------|-------|-----------------|
| **Small** | 1-3 jours | Amélioration visible, périmètre clair, peu de dépendances |
| **Medium** | 4-7 jours (1 semaine) | Feature complète, quelques dépendances, ≥1 inconnu |
| **Large** | 2-3 semaines | Nouveau module ou refonte, plusieurs inconnus |
| **Hors-scope** | >3 semaines | Décomposer en plusieurs Pitches. Ne pas pitcher une montagne. |

**Règle absolue :** si le Pitch ne rentre pas dans une taille connue, c'est que le problème
n'est pas assez bien défini. Revenir à l'étape Problem avant de continuer.

### Template Pitch SQWR

```markdown
# Pitch — [Titre court]

**Projet :** [izzico / SQWR Studio / CozyGrowth / Client X]
**Date :** [JJ/MM/AAAA]
**Appetite :** [Small 1-3j / Medium 1 semaine / Large 2-3 semaines]

## Problem

[Histoire concrète d'un utilisateur face au problème. Une seule histoire, pas une liste.]

## Solution

[Esquisse textuelle ou dessin scan — pas de wireframe précis. Le COMMENT sans le pixel-perfect.]

## Rabbit Holes

- [Complexité cachée 1 — à éviter ou à traiter séparément]
- [Complexité cachée 2]

## No-Gos (ce qu'on ne fait PAS dans cette version)

- [Feature exclue 1]
- [Feature exclue 2]

## Betting Table (auto-validation solo)

- [ ] Le problème mérite-t-il l'investissement défini par l'Appetite ?
- [ ] La solution est-elle réaliste dans l'Appetite ?
- [ ] Les Rabbit Holes identifiés sont-ils gérables ?
- [ ] Les No-Gos sont-ils acceptables pour le client/utilisateur ?
```

---

## Partie 2 — Design Sprint condensé 2 jours (Jake Knapp, GV 2016)

### Pourquoi 2 jours pour SQWR

Le Design Sprint original de Google Ventures dure 5 jours pour une équipe de 5-7 personnes.
Jake Knapp lui-même recommande des formats compressés pour les petites équipes. Avec Claude Code,
un solo peut couvrir en 2 jours ce qu'une équipe fait en 5 — la génération est plus rapide,
les décisions sont plus directes.

### Jour 1 — Comprendre & Décider (≈4-5h)

**Matin : Cartographier le problème**
1. **Long-term Goal** — "Dans 2 ans, si ce projet réussit, qu'est-ce qui est vrai ?" (1 phrase)
2. **Sprint Questions** — "Qu'est-ce qu'on doit apprendre/tester cette semaine ?" (3-5 questions)
3. **User Map** — Dessiner le parcours utilisateur de A (entrée) à Z (objectif atteint)
4. **Target** — Choisir 1 moment/étape du parcours sur lequel se concentrer

**Après-midi : Explorer & Décider**
5. **Lightning Demos** — Passer 20 min sur des solutions similaires existantes (concurrents, inspiration)
6. **Crazy 8s** — 8 idées de solution en 8 minutes (quantité > qualité)
7. **Solution Sketch** — La meilleure idée développée en détail (3 cases : avant/pendant/après)
8. **Vote** — Si solo : dormir dessus, décider le lendemain matin

**Livrable Jour 1 :** Document `SPRINT-DAY1.md` avec Long-term Goal + Questions + Target + Solution retenue.

### Jour 2 — Prototyper & Tester (≈4-5h)

**Matin : Storyboard & Prototype**
1. **Storyboard** — Séquence de 6-8 cases décrivant l'expérience complète
2. **Prototype** — Le plus rapide possible : Figma pour UI, markdown pour flows, Next.js stub pour technique

**Après-midi : Tester avec 1-3 utilisateurs**
3. **Script de test** — 5 questions maximum, pas de guidage
4. **Test sessions** — 20-30 min chacune, observer sans expliquer
5. **Patterns** — Qu'est-ce que 2 utilisateurs sur 3 ont eu du mal à faire ?

**Livrable Jour 2 :** Prototype + `SPRINT-INSIGHTS.md` avec 3-5 insights actionnables.

---

## Partie 3 — Pre-mortem (Gary Klein, HBR 2007)

### Pourquoi ça fonctionne

Gary Klein (HBR 2007) a démontré que le pre-mortem augmente la **précision d'identification
des risques de 30%**. Le mécanisme : la "prospective hindsight" — imaginer l'échec comme
*déjà arrivé* désinhibe les gens à exprimer des doutes qu'ils auraient tu autrement.

> *"The technique breaks with the conventional positive-thinking approach that
> can cause teams to ignore warning signs."* — Gary Klein, HBR 2007

**Différence fondamentale :**
- Analyse de risques classique : "Qu'est-ce qui *pourrait* mal tourner ?" → réponses vagues
- Pre-mortem : "Le projet *a* échoué. Expliquez pourquoi." → réponses précises et actionnables

### Exécution (30 minutes)

```
1. Briefer (5 min)
   Présenter le projet, l'Appetite, la solution retenue.

2. Framer le scénario (1 min)
   "Imaginons que nous sommes [date de livraison + 3 mois].
   Ce projet a échoué — pas à cause de malchance, mais parce que
   quelque chose s'est mal passé dans notre exécution.
   Listez toutes les raisons possibles."

3. Brainstorming silencieux (5 min)
   Chacun écrit sa liste. Pas de discussion encore.

4. Tour de table (10 min)
   Chaque personne partage UN item à la fois.
   Continuer jusqu'à épuisement des listes.

5. Consolider & Mitiguer (10 min)
   Pour chaque risque : peut-on le prévenir ? Comment ?
   Convertir en actions concrètes → Risk Register.
```

**Pour SQWR solo :** Faire l'exercice seul, puis le répéter avec Joakim (pour les projets
SQWR Studio) ou Alexandre (pour CozyGrowth). Même solo, l'exercice force à externaliser
des inquiétudes restées implicites.

### Template Pre-mortem SQWR

```markdown
# Pre-mortem — [Nom du projet]

**Date :** [JJ/MM/AAAA]
**Projet :** [description courte]
**Livraison prévue :** [JJ/MM/AAAA]
**Participants :** [Samuel / Samuel + Joakim / Samuel + Alexandre]

## Scénario

"Nous sommes [3 mois après la livraison prévue].
[Nom du projet] a échoué. Qu'est-ce qui s'est passé ?"

## Causes identifiées

### Techniques
-
-

### Client / Scope
-
-

### Personnel / Tempo
-
-

### Dépendances externes
-
```

---

## Partie 4 — Risk Register (PMI PMBOK)

### Matrice Probabilité × Impact

| Probabilité ↓ \ Impact → | 1 — Négligeable | 2 — Mineur | 3 — Modéré | 4 — Majeur | 5 — Critique |
|--------------------------|-----------------|-----------|-----------|-----------|-------------|
| **5 — Quasi certain**    | 5               | 10        | **15**    | **20**    | **25**      |
| **4 — Probable**         | 4               | 8         | **12**    | **16**    | **20**      |
| **3 — Possible**         | 3               | 6         | 9         | **12**    | **15**      |
| **2 — Improbable**       | 2               | 4         | 6         | 8         | 10          |
| **1 — Rare**             | 1               | 2         | 3         | 4         | 5           |

**Seuils d'action :**
- Score ≥ 15 → **Action requise avant de commencer**
- Score 8-14 → Mitigation planifiée
- Score < 8 → Surveiller, accepter

### Template Risk Register SQWR

```markdown
# Risk Register — [Nom du projet]

**Date :** [JJ/MM/AAAA]
**Issu du pre-mortem du :** [JJ/MM/AAAA]

| ID | Risque | P (1-5) | I (1-5) | Score P×I | Mitigation | Responsable | Statut |
|----|--------|---------|---------|-----------|-----------|-------------|--------|
| R1 | Scope creep client | 4 | 4 | **16** | Pitch validé par écrit avant démarrage | Samuel | Open |
| R2 | Disponibilité Joakim (créatif) | 3 | 3 | 9 | Confirmer les disponibilités en Partie 1 | Samuel | Open |
| R3 | API tierce indisponible | 2 | 4 | 8 | Mock local + fallback prévu | Samuel | Open |
| R4 | | | | | | | |

**Règle SQWR :** Tout risque avec score ≥ 15 doit avoir une action de mitigation définie
ET un owner avant que le Pitch ne soit validé.
```

---

## Checklist de Scoping

À compléter avant de créer la première branche de développement.

- [ ] Pitch Shape Up complété (5 composants — Problem, Appetite, Solution, Rabbit Holes, No-Gos)
- [ ] Appetite défini et accepté par toutes les parties
- [ ] No-Gos listés et validés (par le client si applicable)
- [ ] Pre-mortem réalisé (minimum 5 risques identifiés)
- [ ] Risk Register créé — tous les risques ≥ 15 ont une mitigation + responsable
- [ ] Estimation calculée (→ voir `frameworks/ESTIMATION.md`)
- [ ] ADR créé si décision architecturale significative (→ voir `frameworks/ADR-TEMPLATE.md`)

---

## Quand utiliser quel outil

| Situation | Outil recommandé | Durée |
|-----------|-----------------|-------|
| Feature < 1 jour, bien connue | Checklist de Scoping seulement | 15 min |
| Feature 1-5 jours, scope modéré | Pitch Shape Up + Pre-mortem | 1h |
| Nouveau projet ou refonte | Pitch + Design Sprint 2j + Pre-mortem | 2-3 jours |
| Projet client avec budget défini | Pitch + Pre-mortem + Risk Register complet | 2h |
| Incertitude technique élevée | Design Sprint complet (2j prototype + test) | 2 jours |

---

## Sources

| Référence | Lien |
|-----------|------|
| Shape Up — Ryan Singer (Basecamp 2019) | basecamp.com/shapeup |
| Google Ventures Design Sprint | sprint.google.com |
| Design Sprint Kit (GV) | designsprintkit.withgoogle.com |
| Pre-mortem — Gary Klein (HBR 2007) | hbr.org/2007/09/performing-a-project-premortem |
| PMI PMBOK 6th Edition | pmi.org/pmbok-guide-standards |
| Standish Group CHAOS Report 2020 | standishgroup.com/chaos_report |
