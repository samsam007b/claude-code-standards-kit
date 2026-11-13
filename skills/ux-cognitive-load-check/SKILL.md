---
name: ux-cognitive-load-check
description: Analyser la charge cognitive d'un composant ou page UI. Score basé sur Miller's Law, Hick's Law, complexité visuelle.
tags: [ux, audit, frontend, cognitive]
model: sonnet
---

# UX Cognitive Load Check Skill

## Description
Analyse la charge cognitive d'un composant ou page. Calcule un score basé sur Miller's Law, Hick's Law, et complexité visuelle. Suggère optimisations si charge trop élevée.

## Usage
```
/ux-cognitive-load-check [file_path_or_url]
```

## Workflow

1. **Analyse des Éléments Visibles**
   - Compte tous les éléments interactifs (buttons, inputs, links)
   - Compte les sections/groupes visuels
   - Identifie les choix à faire (checkboxes, selects, radios)

2. **Calcul du Score Cognitive Load**
   ```
   Cognitive Load Score (0-100) :

   Score = 100 - (
     (visible_elements - 7) × 5 +    // Miller's Law penalty
     (choices - 9) × 3 +              // Hick's Law penalty
     (visual_complexity) × 2          // Aesthetic penalty
   )

   où :
   - visible_elements = nombre d'éléments distincts
   - choices = nombre de décisions à prendre
   - visual_complexity = score 0-10 (colors, fonts, spacing)
   ```

3. **Classification**
   - **0-30**: 🔴 CRITICAL - Refonte majeure requise
   - **31-50**: 🟠 HIGH - Optimisations nécessaires
   - **51-70**: 🟡 MEDIUM - Améliorations recommandées
   - **71-85**: 🟢 GOOD - Charge acceptable
   - **86-100**: ✅ EXCELLENT - Optimal

4. **Recommandations Spécifiques**
   - Si > 7 éléments visibles → Chunking ou Progressive Disclosure
   - Si > 9 choix → Réduire options ou étapes
   - Si complexité visuelle élevée → Simplifier design

## Exemples

### Exemple 1: Page de recherche surchargée

```bash
/ux-cognitive-load-check app/seeker/explore/page.tsx
```

**Output**:
```
🔴 COGNITIVE LOAD: CRITICAL (Score: 28/100)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ANALYSIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Visible Elements: 47 (❌ Exceeds Miller's Law by 40 elements)
├─ Filters: 32 checkboxes
├─ Controls: 8 buttons
├─ Navigation: 7 links
└─ Content: Multiple property cards

Choices Required: 35 (❌ Exceeds Hick's Law by 26 choices)
├─ Filter selections: 32
├─ Sort options: 3

Visual Complexity: 8/10 (⚠️ High)
├─ Colors used: 12 different colors
├─ Font sizes: 8 different sizes
├─ Spacing inconsistencies: 15 detected

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
VIOLATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Miller's Law: 47 elements vs 7±2 recommended
   → Users cannot hold all options in working memory
   → Decision paralysis likely

2. Hick's Law: 35 choices presented simultaneously
   → Decision time: ~8-12 seconds (vs optimal < 3 seconds)
   → High abandonment risk

3. Aesthetic & Minimalist: Visual complexity 8/10
   → Too many visual elements competing for attention

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RECOMMENDATIONS (Priority Order)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔴 P0 - Critical (Implement First)
├─ Apply Progressive Disclosure to filters
│  └─ Show only 5-7 essential filters by default
│  └─ Collapse 25+ advanced filters into drawer
│  └─ Estimated impact: Score 28 → 65 (+37)
│
└─ Chunk filters into categories
   └─ Group by: Prix, Type, Équipements, Rules, Match
   └─ Estimated impact: Score 65 → 72 (+7)

🟠 P1 - High Priority
├─ Reduce visual complexity
│  └─ Limit to 3-4 brand colors
│  └─ Standardize font sizes (max 5 variations)
│  └─ Estimated impact: Score 72 → 78 (+6)
│
└─ Add "Quick Filters" preset buttons
   └─ Example: "Meublé < 1000€", "2ch WiFi"
   └─ Reduces choices from 35 to 5-8
   └─ Estimated impact: Score 78 → 85 (+7)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PROJECTED SCORE AFTER FIXES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current:  28/100 🔴 CRITICAL
After P0: 72/100 🟢 GOOD
After P1: 85/100 ✅ EXCELLENT

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Exemple 2: Dashboard avec charge acceptable

```bash
/ux-cognitive-load-check app/seeker/page.tsx
```

**Output**:
```
✅ COGNITIVE LOAD: EXCELLENT (Score: 88/100)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ANALYSIS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Visible Elements: 6 (✅ Within Miller's Law: 7±2)
├─ KPIs: 4 stat cards
├─ CTA: 1 main button
└─ Navigation: 1 menu

Choices Required: 5 (✅ Within Hick's Law: < 9)

Visual Complexity: 3/10 (✅ Low - Clean design)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
STRENGTHS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Respects Miller's Law: Only 6 elements in glanceable zone
✅ Respects Hick's Law: Limited to 5 clear choices
✅ Visual Hierarchy: Clear F-pattern applied
✅ Progressive Disclosure: Details hidden until needed
✅ Consistent Design: Unified color palette & spacing

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MINOR IMPROVEMENTS (Optional)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🟡 P2 - Nice to Have
└─ Add hover tooltips on KPI cards
   └─ Explain what each metric means
   └─ Estimated impact: Score 88 → 92 (+4)
```

## Output Files

Le skill génère:
1. **Terminal output** (score + recommandations)
2. **Report file**: `docs/ux-audits/cognitive-load-[component]-[date].md`
3. **Heatmap visual** (optional): ASCII art montrant les zones d'attention

## Configuration

Flags disponibles:
- `--strict`: Mode strict (pénalités doublées)
- `--export=pdf`: Exporte le rapport en PDF
- `--compare=[other_file]`: Compare avec un autre composant

## Références

Basé sur:
- [Miller's Law](https://lawsofux.com/millers-law/)
- [Hick's Law](https://lawsofux.com/hicks-law/)
- [Cognitive Load Theory](https://www.nngroup.com/articles/minimize-cognitive-load/)
