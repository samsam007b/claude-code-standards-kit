# Audit — Stratégie de Marque

> Module d'audit SQWR Project Kit.
> Sources : Nielsen Norman Group — Tone of Voice (nngroup.com/articles/tone-of-voice-dimensions), Kapferer — *The New Strategic Brand Management* (Kogan Page, 2012), Aaker — *Brand Identity* (Free Press, 1996), Harvard Business Review — Brand Consistency Research.

---

## Fondements

**La cohérence de marque augmente les revenus de 10 à 20%** (Lucidpress / Marq — *The State of Brand Consistency*, 2021). Une marque incohérente n'est pas seulement esthétiquement désagréable — elle mine activement la confiance et la mémorabilité.

Cet audit doit être réalisé avant tout lancement et révisé à chaque repositionnement. Voir `frameworks/BRAND-STRATEGY.md` pour définir la stratégie avant de scorer.

---

## Instructions

Pour chaque dimension :
1. Évaluer l'état actuel selon les critères listés
2. Scorer selon le barème fourni
3. Identifier les gaps concrets
4. Prioriser selon l'impact sur la perception utilisateur

---

## Dimension 1 — Fondations Stratégiques (20 points)

**Poids : 20% du score total**

> Source : Simon Sinek — *Start With Why* (Portfolio/Penguin, 2009), Kapferer *The New Strategic Brand Management*

| Critère | Questions de vérification | Score |
|---------|--------------------------|-------|
| **Raison d'être (WHY)** | Pourquoi existez-vous au-delà de gagner de l'argent ? Documenté ? | 0-5 |
| **Positionnement différenciant** | En quoi êtes-vous objectivement différent de vos 3 concurrents directs ? | 0-5 |
| **Cible précise** | Avez-vous une persona primaire documentée avec besoins, objections, vocabulaire ? | 0-5 |
| **Proposition de valeur** | Un inconnu comprend votre offre en < 5 secondes ? (Test des 5 secondes) | 0-5 |

**Score D1 : ___/20**

**Test des 5 secondes :** montrer la homepage ou le pitch à 5 personnes extérieures pendant 5 secondes. Demander : "C'est quoi ce produit ? Pour qui ?" Si < 4/5 répondent correctement → proposition de valeur à retravailler.

---

## Dimension 2 — Identité Visuelle (20 points)

**Poids : 20% du score total**

> Source : Aaker — *Building Strong Brands* (Free Press, 1996), W3C WCAG 2.1

| Critère | Questions de vérification | Score |
|---------|--------------------------|-------|
| **Cohérence de la palette** | Même palette utilisée sur tous les supports ? Tokens définis et documentés ? | 0-5 |
| **Typographie cohérente** | Même combinaison typographique partout ? Hiérarchie respectée ? | 0-5 |
| **Logo — utilisation correcte** | Espaces de protection respectés ? Pas de variantes non-officielles utilisées ? | 0-5 |
| **WCAG accessibilité** | Contrastes ≥ 4.5:1 sur toutes les surfaces ? (vérifier avec WebAIM) | 0-5 |

**Score D2 : ___/20**

**Checklist visuelle :**
```
Palette couleurs :
  ☐ Palette principale documentée (max 3 couleurs primaires)
  ☐ Tokens CSS/Swift définis
  ☐ Variantes dark mode définies
  ☐ ΔE > 7 entre couleurs distinctes (seuil de perception humaine)

Typographie :
  ☐ Police primaire (titres) + secondaire (corps) définies
  ☐ Scale typographique basée sur un ratio mathématique (1.5 ou 1.618)
  ☐ Taille minimale 16px (corps web)

Logo :
  ☐ Versions : couleur / noir / blanc / fond foncé
  ☐ Format SVG disponible pour le web
  ☐ Règles d'utilisation documentées (minimum size, clear space)
```

---

## Dimension 3 — Tone of Voice (25 points)

**Poids : 25% du score total**

> Source : Nielsen Norman Group — 4 Dimensions of Tone of Voice
> [nngroup.com/articles/tone-of-voice-dimensions](https://www.nngroup.com/articles/tone-of-voice-dimensions)

Nielsen NN/G a identifié 4 dimensions mesurables du tone of voice. Chaque marque doit se positionner sur ces 4 axes et le documenter.

### Les 4 dimensions Nielsen NN/G

| Dimension | Axe | Score 1–5 |
|-----------|-----|-----------|
| **Formalité** | 1 = Casual / 5 = Formel | ___ |
| **Humour** | 1 = Sérieux / 5 = Humoristique | ___ |
| **Irrévérence** | 1 = Respectueux / 5 = Irrévérencieux | ___ |
| **Énergie** | 1 = Neutre / 5 = Enthousiaste | ___ |

**Règle :** si la marque s'adresse à des segments différents (ex: B2C et B2B), définir une matrice distincte par segment.

### Scoring Tone of Voice

| Critère | Questions de vérification | Score |
|---------|--------------------------|-------|
| **Positionnement documenté** | Les 4 dimensions Nielsen sont-elles définies et documentées ? | 0-5 |
| **Cohérence cross-surface** | Même tone sur : site, emails, app, réseaux sociaux, support ? | 0-5 |
| **Vocabulaire propriétaire** | Termes de marque définis (et leurs interdits) ? | 0-5 |
| **Adaptation par segment** | Si multi-cibles, matrice distincte documentée ? | 0-5 |
| **Test en pratique** | Rédiger 5 phrases représentatives — sont-elles cohérentes avec la matrice ? | 0-5 |

**Score D3 : ___/25**

### Template matrice tone of voice

```
MATRICE TONE OF VOICE — [Marque]

Segment : [ex: Utilisateurs consumers]
  Formalité :   [1-5] — [1 phrase d'exemple]
  Humour :      [1-5] — [1 phrase d'exemple]
  Irrévérence : [1-5] — [1 phrase d'exemple]
  Énergie :     [1-5] — [1 phrase d'exemple]

Segment : [ex: Clients business]
  Formalité :   [1-5] — [1 phrase d'exemple]
  Humour :      [1-5] — [1 phrase d'exemple]
  Irrévérence : [1-5] — [1 phrase d'exemple]
  Énergie :     [1-5] — [1 phrase d'exemple]

Mots interdits : [liste]
Mots de marque propriétaires : [liste]
Salutations : [ex: "Hello [Prénom] !" vs "Bonjour,"]
Signature : [ex: "L'équipe [Marque]"]
```

---

## Dimension 4 — Cohérence Cross-Platform (20 points)

**Poids : 20% du score total**

> Source : Lucidpress / Marq — *The State of Brand Consistency* (2021)

| Critère | Questions de vérification | Score |
|---------|--------------------------|-------|
| **Site web** | Design system respecté ? Tone of voice cohérent ? | 0-5 |
| **Application mobile** | Même tokens visuels que le web ? Adaptations iOS/Android documentées ? | 0-5 |
| **Réseaux sociaux** | Même palette ? Templates de posts définis ? | 0-5 |
| **Emails** | Template email brandé ? Même tone de voice ? | 0-5 |

**Score D4 : ___/20**

**Test de cohérence :** ouvrir simultanément le site, l'app et les réseaux sociaux. Fermer les yeux. Rouvrir. La marque est-elle instantanément reconnaissable sur chaque surface sans lire le logo ?

---

## Dimension 5 — Différenciation (15 points)

**Poids : 15% du score total**

> Source : Ries & Trout — *Positioning: The Battle for Your Mind* (McGraw-Hill, 2001)
> Source : Kim & Mauborgne — *Blue Ocean Strategy* (HBR Press, 2005)

| Critère | Questions de vérification | Score |
|---------|--------------------------|-------|
| **Position unique** | Pouvez-vous citer votre différenciant en 1 phrase sans nommer la concurrence ? | 0-5 |
| **Preuve du différenciant** | Avez-vous des données/preuves concrètes de ce différenciant ? | 0-5 |
| **Durabilité** | Ce différenciant est-il difficile à copier par les concurrents ? | 0-5 |

**Score D5 : ___/15**

---

## Calcul du Score Global

```
Score Brand = D1 (20) + D2 (20) + D3 (25) + D4 (20) + D5 (15)
            = Score sur 100
```

| Score | Niveau | Action |
|-------|--------|--------|
| ≥85/100 | ✅ Marque forte | Maintenir la cohérence — audit semestriel |
| 70-84/100 | 🟡 Marque en développement | Identifier et traiter les gaps prioritaires |
| 55-69/100 | 🟠 Marque fragile | Retravailler les fondations avant de scaler |
| <55/100 | 🔴 Marque incohérente | Repositionnement nécessaire avant tout investissement marketing |

---

## Checklist pré-lancement Brand

### 🔴 Bloquants

- [ ] WHY documenté (raison d'être)
- [ ] Proposition de valeur testée (test des 5 secondes)
- [ ] Palette couleurs avec tokens + vérification WCAG
- [ ] Tone of voice avec les 4 dimensions Nielsen documentées
- [ ] Vocabulaire interdit défini (mots à bannir)

### 🟡 Importants

- [ ] Logo en 3 variantes (couleur / noir / blanc)
- [ ] Scale typographique mathématique
- [ ] Template email brandé
- [ ] Matrice tone of voice par segment (si multi-cibles)

### 🟢 Souhaitables

- [ ] Brand guidelines document complet (PDF)
- [ ] Kit de presse / médias kit
- [ ] Templates réseaux sociaux
- [ ] Tests utilisateurs sur mémorabilité de la marque

---

## Template Rapport

```
RAPPORT AUDIT BRAND STRATEGY
Marque : [nom]
Date : [date]
Auditeur : [nom]

D1 — Fondations stratégiques : ___/20
D2 — Identité visuelle        : ___/20
D3 — Tone of Voice            : ___/25
D4 — Cohérence cross-platform : ___/20
D5 — Différenciation          : ___/15
                                ------
SCORE GLOBAL                  : ___/100

FORCES :
1. [Force principale]
2. [Force secondaire]

GAPS PRIORITAIRES :
1. [Gap 1 — dimension + impact estimé]
2. [Gap 2 — dimension + impact estimé]

PLAN D'ACTION :
- [Action 1] — Délai : [date] — Responsable : [nom]
- [Action 2] — Délai : [date] — Responsable : [nom]
```

---

## Sources

| Référence | Lien |
|-----------|------|
| Nielsen Norman Group — 4 Dimensions of Tone of Voice | nngroup.com/articles/tone-of-voice-dimensions |
| Kapferer — *The New Strategic Brand Management* (Kogan Page, 2012) | — |
| Aaker — *Building Strong Brands* (Free Press, 1996) | — |
| Simon Sinek — *Start With Why* (Portfolio/Penguin, 2009) | — |
| Ries & Trout — *Positioning: The Battle for Your Mind* (McGraw-Hill, 2001) | — |
| Lucidpress / Marq — *State of Brand Consistency* (2021) | marq.com/brand-consistency-report |
| Kim & Mauborgne — *Blue Ocean Strategy* (HBR Press, 2005) | hbr.org/2004/10/blue-ocean-strategy |
