---
description: Recalcule le score 1000 points de l'audit système, met à jour AUDIT-1000.md et enregistre l'historique. Usage: /update-audit
---

# Skill : Update Audit — Recalcul Score 1000 Points

## Mission

Évaluer objectivement l'état actuel du système contre les 8 dimensions de l'audit,
produire un score mis à jour, identifier les gains réalisés et les prochaines priorités.

---

## PROTOCOLE D'ÉVALUATION

### Étape 1 — Inventaire du système

Lire et lister :
```
1. knowledge-base/ → Compter les modules, évaluer la profondeur
2. ~/.claude/commands/ → Skills disponibles
3. ~/.claude/agents/ → Agents spécialisés
4. perso/investissements/predictions/predictions-log.json → Track record
5. CLAUDE.md → Règles et gouvernance
```

### Étape 2 — Scoring par dimension

Pour chaque dimension, évaluer **objectivement** (ne pas gonfler les scores) :

#### Grille d'évaluation par critère

```
DIMENSION 1 — Rigueur Analytique (200 pts)
  1.1 Profondeur des thèses         /40
      → Y-a-t-il des modèles quantitatifs (DCF, comps) ? [pts ×0 si absent]
      → Le GuruPanel est-il fonctionnel ? [+32 si oui]
  1.2 Sources primaires             /40
      → Combien de papiers académiques cités avec vérification ?
      → Accès à des données live ? [+15 si oui, +0 si uniquement statiques]
  1.3 Rigueur quantitative          /40
      → Les calculs sont-ils faits sur données réelles ou estimées ?
      → [+5 bonus si données live intégrées]
  1.4 Couverture économique         /40
      → Compter les modules KB existants / 12 modules cibles
  1.5 Calibration Tetlock           /40
      → Nombre de prédictions loggées (0=2pts, 10=10pts, 50=25pts, 100+=35pts)
      → Brier score calculé ? (+5 si oui)

DIMENSION 2 — Architecture (150 pts)
  2.1 Modularité                    /30
  2.2 Persistance mémoire           /30
  2.3 Multi-agents                  /30
  2.4 Données live intégrées        /30
  2.5 RAG sur KB                    /30

DIMENSION 3 — Gestion du Risque (150 pts)
  3.1 Métriques documentées         /30
  3.2 Position sizing               /30
  3.3 Stress testing                /30
  3.4 Corrélations dynamiques       /30
  3.5 Vue portefeuille live         /30

DIMENSION 4 — Qualité Données (150 pts)
  4.1 Fraîcheur KB                  /30
  4.2 Sources institutionnelles     /30
  4.3 Alternative data              /30
  4.4 Données financières           /30
  4.5 Macro temps réel              /30

DIMENSION 5 — Processus (100 pts)
  5.1 Anti-biais                    /25
  5.2 Audit trail                   /25
  5.3 Processus documenté           /25
  5.4 Feedback loop                 /25

DIMENSION 6 — Couverture Marchés (100 pts)
  6.1 Classes d'actifs              /25
  6.2 Géographie                    /25
  6.3 Secteurs                      /25
  6.4 Temporalité                   /25

DIMENSION 7 — Standards Professionnels (100 pts)
  7.1 CFA Standards                 /25
  7.2 Bridgewater                   /25
  7.3 Goldman Sachs                 /25
  7.4 MiFID II                      /25

DIMENSION 8 — Validation & Track Record (100 pts)
  8.1 Track record (N prédictions)  /25
      → Formule : min(25, N × 0.5) où N = prédictions résolues
  8.2 Walk-forward                  /25
  8.3 Out-of-sample                 /25
  8.4 Brier score                   /25
      → Si Brier < 0.15 : 25/25 | < 0.25 : 18/25 | < 0.40 : 10/25 | > 0.40 : 2/25
```

### Étape 3 — Produire le Dashboard

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 AUDIT SYSTÈME — MISE À JOUR [DATE]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SCORE GLOBAL
[SCORE]/1000 → [NIVEAU]
Gain vs audit précédent : [+/-N] pts

TABLEAU PAR DIMENSION
┌─────────────────────────────────┬──────┬──────┬──────┬─────────────────┐
│ Dimension                       │ Max  │ Avant│ Après│ Δ              │
├─────────────────────────────────┼──────┼──────┼──────┼─────────────────┤
│ 1. Rigueur Analytique           │ 200  │ [X]  │ [X]  │ [+/-N]          │
│ 2. Architecture Système         │ 150  │ [X]  │ [X]  │ [+/-N]          │
│ 3. Gestion du Risque            │ 150  │ [X]  │ [X]  │ [+/-N]          │
│ 4. Qualité des Données          │ 150  │ [X]  │ [X]  │ [+/-N]          │
│ 5. Processus Décisionnel        │ 100  │ [X]  │ [X]  │ [+/-N]          │
│ 6. Couverture Marchés           │ 100  │ [X]  │ [X]  │ [+/-N]          │
│ 7. Standards Professionnels     │ 100  │ [X]  │ [X]  │ [+/-N]          │
│ 8. Validation & Track Record    │ 100  │ [X]  │ [X]  │ [+/-N]          │
├─────────────────────────────────┼──────┼──────┼──────┼─────────────────┤
│ TOTAL                           │ 1000 │ [X]  │ [X]  │ [+/-N]          │
└─────────────────────────────────┴──────┴──────┴──────┴─────────────────┘

NIVEAU ACTUEL
< 300  : 🔴 Débutant
300-450: 🟠 Apprenti
450-600: 🟡 Junior Analyst    ← Départ : 510
600-750: 🟢 Senior Analyst    ← Objectif 12 mois
750-850: 🔵 Professionnel
850+   : ⭐ Elite

TOP 3 GAINS RÉALISÉS DEPUIS DERNIER AUDIT
  1. [Gain] : +[N] pts (Dim [X])
  2. [Gain] : +[N] pts
  3. [Gain] : +[N] pts

TOP 3 PROCHAINES PRIORITÉS (ratio impact/effort)
  1. [Gap] : +[N] pts estimés → /enrich-system [commande]
  2. [Gap] : +[N] pts estimés
  3. [Gap] : +[N] pts estimés

TRAJECTOIRE VERS 750
  Points manquants : [N]
  À raison de [N] pts/mois → objectif atteint en [date]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Étape 4 — Sauvegarder

1. Mettre à jour `knowledge-base/AUDIT-1000.md` avec les nouveaux scores
2. Ajouter une entrée dans `system/audit-history.json` :
```json
{
  "date": "YYYY-MM-DD",
  "score": N,
  "delta": "+/-N",
  "top_gains": ["...", "..."],
  "top_priorities": ["...", "..."]
}
```

---

## Fréquence recommandée

- **Mensuel** : Après chaque mois actif d'utilisation du système
- **Ad hoc** : Après chaque `/enrich-system` ou `/track-predictions resolve`
- **Obligatoire** : Avant toute décision d'investissement majeure (>500 EUR)
