# Framework — Recherche Utilisateur (UX Research)

> Module de framework SQWR Project Kit. Sortir ce framework avant de designer une nouvelle feature ou un nouveau produit.
> Sources : Jakob Nielsen — "Why You Only Need to Test with 5 Users" (nngroup.com, 2000), Clayton Christensen — Jobs-to-Be-Done (Harvard Business School), Rob Fitzpatrick — *The Mom Test* (2013), John Brooke — System Usability Scale (1996), Guest et al. — "How Many Interviews Are Enough?" (Field Methods, 2006).

---

## Fondements scientifiques

**"85% des problèmes d'utilisabilité sont détectés avec 5 testeurs."** (Jakob Nielsen, 2000 — basé sur la courbe de probabilité de détection de problèmes). Au-delà de 5, les rendements sont décroissants. La recherche n'est pas une activité réservée aux grandes équipes.

**"Les utilisateurs ne savent pas ce qu'ils veulent — ils savent ce qu'ils ont fait."** (Rob Fitzpatrick, *The Mom Test*, 2013). Les entretiens sur des intentions futures sont des données non fiables. Seul le comportement passé est une preuve.

---

## Quand faire de la recherche

| Phase | Méthode | Objectif |
|-------|---------|----------|
| **Discovery** | JTBD, entretiens (5-8 personnes) | Comprendre les problèmes réels |
| **Exploration** | Card sorting, guerilla testing | Tester des directions de solution |
| **Validation** | Test utilisabilité (5 personnes), prototype | Vérifier que la solution fonctionne |
| **Post-launch** | NPS, CSAT, analytics, session replay | Mesurer et identifier les frictions |

**Matrice de décision :**
```
Incertitude haute + Impact fort   → Recherche obligatoire avant développement
Incertitude haute + Impact faible → Recherche légère (5 entretiens rapides)
Incertitude faible + Impact fort  → Validation par test utilisabilité
Incertitude faible + Impact faible → Livrer et mesurer
```

---

## 1. Jobs-to-Be-Done (JTBD)

> Source : Clayton Christensen — *Competing Against Luck* (Harvard Business Review Press, 2016)
> Source : Tony Ulwick — *Jobs to be Done: Theory to Practice* (Idea Bite Press, 2016)

**Principe :** les utilisateurs n'"achètent" pas un produit — ils "engagent" un produit pour accomplir un job. Comprendre le job révèle ce qui compte vraiment.

### Les 3 dimensions d'un job

| Dimension | Définition | Exemple |
|-----------|-----------|---------|
| **Fonctionnel** | La tâche concrète à accomplir | "Envoyer ma déclaration fiscale" |
| **Émotionnel** | Comment l'utilisateur veut se sentir | "Me sentir compétent, pas stressé" |
| **Social** | Comment l'utilisateur veut être perçu | "Paraître organisé aux yeux de mon comptable" |

### Template d'énoncé JTBD

```
Quand [SITUATION DÉCLENCHANTE],
je veux [MOTIVATION / JOB FONCTIONNEL],
pour que [RÉSULTAT ATTENDU — émotionnel ou social].
```

**Exemples :**
```
Quand je dois envoyer un contrat à un client,
je veux le faire signer en ligne en moins de 2 minutes,
pour que je paraisse professionnel et que le client signe sans friction.

Quand je reçois le bulletin de paie de mon équipe,
je veux vérifier que les chiffres sont corrects rapidement,
pour ne pas me sentir incompétent si une erreur passe.
```

### Comment identifier le vrai JTBD

Questions à poser en entretien (The Mom Test adapté) :
1. "La dernière fois que vous avez eu ce problème, qu'avez-vous fait exactement ?"
2. "Qu'est-ce qui vous a décidé à chercher une solution à ce moment-là ?"
3. "Qu'est-ce que vous avez essayé avant ? Pourquoi ça ne suffisait pas ?"
4. "Si vous ne pouviez plus utiliser notre produit demain, que feriez-vous ?"

---

## 2. Protocole d'entretien — The Mom Test

> Source : Rob Fitzpatrick — *The Mom Test* (2013)

**Les 3 règles de The Mom Test :**
1. Parler du passé (comportement réel), jamais du futur (intentions non fiables)
2. Ne jamais pitcher pendant l'entretien
3. Chercher des preuves comportementales, pas des opinions

### Nombre de participants

**Règle de saturation thématique :** les nouveaux insights s'arrêtent après 5-8 entretiens par segment homogène. (Guest, Bunce & Johnson — "How Many Interviews Are Enough?", Field Methods, 2006)

**Ne jamais mélanger les segments** : 5 entretiens avec des PME et 5 avec des startups ≠ 10 entretiens sur "les entreprises".

### Script d'entretien (45-60 min)

```markdown
INTRODUCTION (5 min)
"Je cherche à comprendre comment vous [domaine] — pas à vous vendre quoi que ce soit.
Il n'y a pas de bonnes ou mauvaises réponses. Si quelque chose vous semble
étrange dans mes questions, dites-le moi."

CONTEXTE (10 min)
1. "Décrivez-moi votre rôle et ce que vous faites typiquement dans une semaine ?"
2. "Quelle est la partie la plus frustrante de [domaine] pour vous ?"

PROBLÈME (20 min)
3. "La dernière fois que vous avez rencontré [problème], que s'est-il passé exactement ?"
4. "Qu'est-ce que vous avez fait pour le résoudre ?"
5. "Combien de temps ça vous a pris ? Combien de fois ça arrive par semaine/mois ?"
6. "Vous avez essayé d'autres outils ou méthodes ? Pourquoi ça n'a pas suffi ?"

VALEUR (10 min)
7. "Si ce problème disparaissait demain, quel serait l'impact pour vous ?"
8. "Est-ce que vous avez déjà payé pour résoudre ce problème ? Combien ?"

CLÔTURE (5 min)
9. "Y a-t-il quelque chose d'important que je n'ai pas pensé à vous demander ?"
10. "Connaissez-vous 2-3 personnes dans la même situation à qui je pourrais parler ?"
```

---

## 3. Test d'utilisabilité

> Source : Jakob Nielsen — "Why You Only Need to Test with 5 Users" (nngroup.com, 2000)
> Source : Ericsson & Simon — Protocol Analysis (1980) — méthode think-aloud

### Protocole think-aloud

**Instruction au participant :** "Pendant que vous utilisez l'interface, pensez à voix haute. Dites ce que vous voyez, ce que vous pensez, ce que vous cherchez à faire. Il n'y a pas de jugement."

**Règle absolue pour le modérateur : ne jamais aider.** Si le participant est bloqué, noter l'heure et le blocage. Ne pas dire "essayez de cliquer ici".

### Définir les tâches avant la session

```markdown
TÂCHE 1 : "Vous venez de créer un compte. Completez votre profil."
Critère de succès : profil 100% complété en < 3 minutes

TÂCHE 2 : "Vous souhaitez inviter un collègue. Faites-le."
Critère de succès : invitation envoyée sans aide

TÂCHE 3 : "Trouvez comment exporter vos données."
Critère de succès : export téléchargé
```

### Grille de sévérité Nielsen (0-4)

| Score | Signification |
|-------|--------------|
| 0 | Pas un problème d'utilisabilité |
| 1 | Problème cosmétique — corriger seulement si le temps le permet |
| 2 | Problème mineur — priorité basse |
| 3 | Problème majeur — priorité haute |
| 4 | Catastrophe — must fix avant launch |

### System Usability Scale (SUS)

> Source : John Brooke — "SUS: A 'Quick and Dirty' Usability Scale" (1996)

10 questions sur échelle Likert 1-5. Score /100. **Threshold ≥68 = acceptable** (moyenne industrie).

```
1. Je pense que j'utiliserais ce système fréquemment.
2. J'ai trouvé le système inutilement complexe.
3. J'ai trouvé le système facile à utiliser.
4. Je pense que j'aurais besoin d'aide pour utiliser ce système.
5. J'ai trouvé que les différentes fonctions étaient bien intégrées.
6. J'ai trouvé trop d'incohérences dans ce système.
7. J'imagine que la plupart des gens apprendraient très rapidement à utiliser ce système.
8. J'ai trouvé ce système très lourd à utiliser.
9. Je me suis senti très confiant en utilisant ce système.
10. J'ai dû apprendre beaucoup de choses avant de pouvoir utiliser ce système.
```

**Calcul :** questions impaires : score - 1. Questions paires : 5 - score. Somme × 2.5.

---

## 4. NPS — Net Promoter Score

> Source : Fred Reichheld — "The One Number You Need to Grow" (Harvard Business Review, 2003)

**Une question :** "Sur une échelle de 0 à 10, quelle est la probabilité que vous recommandiez [Produit] à un ami ou collègue ?"

| Score | Segment | Action |
|-------|---------|--------|
| 9-10 | Promoteurs | Demander un témoignage, référral program |
| 7-8 | Passifs | Comprendre ce qui manque |
| 0-6 | Détracteurs | Entretien pour comprendre la frustration |

**NPS = % Promoteurs - % Détracteurs**

| Score NPS | Niveau |
|-----------|--------|
| >70 | Excellent (Apple, Tesla niveau) |
| 40-70 | Bon |
| 0-40 | À améliorer |
| <0 | Problème critique |

**Quand le lancer :** J7 après activation (utilisateur a eu le temps d'utiliser le produit, assez tôt pour agir sur les détracteurs).

---

## 5. Synthèse — Affinity Mapping

> Source : Méthode KJ (Jiro Kawakita, années 1960), adoptée par IDEO et la communauté UX

**Processus :**
1. Transcrire chaque insight sur une note (digitale : FigJam, Miro)
2. Regrouper silencieusement par affinité (sans discussion d'abord)
3. Nommer chaque groupe par un verbe-action (ex : "Comprendre le statut", "Trouver l'aide")
4. Prioriser les groupes par fréquence × sévérité

**Matrice de priorisation :**
```
Impact utilisateur (1-5) × Fréquence (1-5) = Score de priorité
```

---

## Checklist

### Bloquants (avant tout développement d'une nouvelle feature)

- [ ] JTBD documenté pour la feature (les 3 dimensions : fonctionnel, émotionnel, social)
- [ ] Au moins 5 entretiens utilisateurs réalisés sur le segment cible

### Importants (avant launch)

- [ ] Test utilisabilité (5 participants, tâches définies)
- [ ] SUS score ≥68/100
- [ ] NPS configuré et déclenché à J7 post-activation

### Souhaitables

- [ ] Session replay activé (PostHog) pour identifier les frictions post-launch
- [ ] Panel d'utilisateurs récurrents (5-10 personnes disponibles pour tests rapides)

---

## Sources

| Référence | Lien |
|-----------|------|
| Nielsen — "Why You Only Need to Test with 5 Users" (2000) | nngroup.com/articles/why-you-only-need-to-test-with-5-users |
| Christensen — Jobs-to-Be-Done | hbs.edu/faculty/Pages/item.aspx?num=46

 |
| Fitzpatrick — *The Mom Test* (2013) | momtestbook.com |
| Brooke — SUS Scale (1996) | usabilitynet.org/trump/documents/Suschapt.doc |
| Reichheld — NPS (HBR, 2003) | hbr.org/2003/12/the-one-number-you-need-to-grow |
| Guest et al. — "How Many Interviews Are Enough?" (2006) | journals.sagepub.com/doi/10.1177/1525822X05279903 |
| Nielsen Severity Ratings | nngroup.com/articles/how-to-rate-the-severity-of-usability-problems |
