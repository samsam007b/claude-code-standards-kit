---
description: Recomputes the 1000-point system audit score, updates AUDIT-1000.md and records the history. Usage: /update-audit
---

# Skill: Update Audit, 1000-Point Score Recalculation

## Mission

Objectively evaluate the current state of the system against the 8 audit dimensions,
produce an updated score, identify the gains achieved and the next priorities.

---

## EVALUATION PROTOCOL

### Step 1: System inventory

Read and list:
```
1. knowledge-base/ → Count the modules, assess the depth
2. ~/.claude/commands/ → Available skills
3. ~/.claude/agents/ → Specialized agents
4. perso/investissements/predictions/predictions-log.json → Track record
5. CLAUDE.md → Rules and governance
```

### Step 2: Scoring per dimension

For each dimension, evaluate **objectively** (do not inflate scores):

#### Evaluation grid per criterion

```
DIMENSION 1: Analytical Rigor (200 pts)
  1.1 Depth of theses               /40
      → Are there quantitative models (DCF, comps)? [pts ×0 if absent]
      → Is the GuruPanel functional? [+32 if yes]
  1.2 Primary sources               /40
      → How many academic papers cited with verification?
      → Access to live data? [+15 if yes, +0 if static only]
  1.3 Quantitative rigor            /40
      → Are calculations done on real or estimated data?
      → [+5 bonus if live data integrated]
  1.4 Economic coverage             /40
      → Count existing KB modules / 12 target modules
  1.5 Tetlock calibration           /40
      → Number of logged predictions (0=2pts, 10=10pts, 50=25pts, 100+=35pts)
      → Brier score computed? (+5 if yes)

DIMENSION 2: Architecture (150 pts)
  2.1 Modularity                    /30
  2.2 Memory persistence            /30
  2.3 Multi-agents                  /30
  2.4 Live data integrated          /30
  2.5 RAG on KB                     /30

DIMENSION 3: Risk Management (150 pts)
  3.1 Documented metrics            /30
  3.2 Position sizing               /30
  3.3 Stress testing                /30
  3.4 Dynamic correlations          /30
  3.5 Live portfolio view           /30

DIMENSION 4: Data Quality (150 pts)
  4.1 KB freshness                  /30
  4.2 Institutional sources         /30
  4.3 Alternative data              /30
  4.4 Financial data                /30
  4.5 Real-time macro               /30

DIMENSION 5: Process (100 pts)
  5.1 Anti-bias                     /25
  5.2 Audit trail                   /25
  5.3 Documented process            /25
  5.4 Feedback loop                 /25

DIMENSION 6: Market Coverage (100 pts)
  6.1 Asset classes                 /25
  6.2 Geography                     /25
  6.3 Sectors                       /25
  6.4 Time horizons                 /25

DIMENSION 7: Professional Standards (100 pts)
  7.1 CFA Standards                 /25
  7.2 Bridgewater                   /25
  7.3 Goldman Sachs                 /25
  7.4 MiFID II                      /25

DIMENSION 8: Validation & Track Record (100 pts)
  8.1 Track record (N predictions)  /25
      → Formula: min(25, N × 0.5) where N = resolved predictions
  8.2 Walk-forward                  /25
  8.3 Out-of-sample                 /25
  8.4 Brier score                   /25
      → If Brier < 0.15: 25/25 | < 0.25: 18/25 | < 0.40: 10/25 | > 0.40: 2/25
```

### Step 3: Produce the Dashboard

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 SYSTEM AUDIT: UPDATE [DATE]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

OVERALL SCORE
[SCORE]/1000 → [LEVEL]
Gain vs previous audit: [+/-N] pts

TABLE PER DIMENSION
┌─────────────────────────────────┬──────┬──────┬──────┬─────────────────┐
│ Dimension                       │ Max  │Before│After │ Δ               │
├─────────────────────────────────┼──────┼──────┼──────┼─────────────────┤
│ 1. Analytical Rigor             │ 200  │ [X]  │ [X]  │ [+/-N]          │
│ 2. System Architecture          │ 150  │ [X]  │ [X]  │ [+/-N]          │
│ 3. Risk Management              │ 150  │ [X]  │ [X]  │ [+/-N]          │
│ 4. Data Quality                 │ 150  │ [X]  │ [X]  │ [+/-N]          │
│ 5. Decision Process             │ 100  │ [X]  │ [X]  │ [+/-N]          │
│ 6. Market Coverage              │ 100  │ [X]  │ [X]  │ [+/-N]          │
│ 7. Professional Standards       │ 100  │ [X]  │ [X]  │ [+/-N]          │
│ 8. Validation & Track Record    │ 100  │ [X]  │ [X]  │ [+/-N]          │
├─────────────────────────────────┼──────┼──────┼──────┼─────────────────┤
│ TOTAL                           │ 1000 │ [X]  │ [X]  │ [+/-N]          │
└─────────────────────────────────┴──────┴──────┴──────┴─────────────────┘

CURRENT LEVEL
< 300  : 🔴 Beginner
300-450: 🟠 Apprentice
450-600: 🟡 Junior Analyst    ← Start: 510
600-750: 🟢 Senior Analyst    ← 12-month goal
750-850: 🔵 Professional
850+   : ⭐ Elite

TOP 3 GAINS ACHIEVED SINCE LAST AUDIT
  1. [Gain]: +[N] pts (Dim [X])
  2. [Gain]: +[N] pts
  3. [Gain]: +[N] pts

TOP 3 NEXT PRIORITIES (impact/effort ratio)
  1. [Gap]: +[N] estimated pts → /enrich-system [command]
  2. [Gap]: +[N] estimated pts
  3. [Gap]: +[N] estimated pts

TRAJECTORY TO 750
  Missing points: [N]
  At [N] pts/month → goal reached on [date]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 4: Save

1. Update `knowledge-base/AUDIT-1000.md` with the new scores
2. Add an entry in `system/audit-history.json`:
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

## Recommended frequency

- **Monthly**: After each active month of using the system
- **Ad hoc**: After each `/enrich-system` or `/track-predictions resolve`
- **Mandatory**: Before any major investment decision (>500 EUR)
