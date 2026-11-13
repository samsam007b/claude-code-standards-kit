---
name: ux-cognitive-load-check
description: Analyze the cognitive load of a UI component or page. Score based on Miller's Law, Hick's Law, and visual complexity.
tags: [ux, audit, frontend, cognitive]
model: sonnet
---

# UX Cognitive Load Check Skill

## Description
Analyzes the cognitive load of a component or page. Computes a score based on Miller's Law, Hick's Law, and visual complexity. Suggests optimizations if the load is too high.

## Usage
```
/ux-cognitive-load-check [file_path_or_url]
```

## Workflow

1. **Analysis of Visible Elements**
   - Counts all interactive elements (buttons, inputs, links)
   - Counts visual sections/groups
   - Identifies the choices to be made (checkboxes, selects, radios)

2. **Cognitive Load Score Calculation**
   ```
   Cognitive Load Score (0-100) :

   Score = 100 - (
     (visible_elements - 7) × 5 +    // Miller's Law penalty
     (choices - 9) × 3 +              // Hick's Law penalty
     (visual_complexity) × 2          // Aesthetic penalty
   )

   where:
   - visible_elements = number of distinct elements
   - choices = number of decisions to make
   - visual_complexity = score 0-10 (colors, fonts, spacing)
   ```

3. **Classification**
   - **0-30**: 🔴 CRITICAL - Major redesign required
   - **31-50**: 🟠 HIGH - Optimizations needed
   - **51-70**: 🟡 MEDIUM - Improvements recommended
   - **71-85**: 🟢 GOOD - Acceptable load
   - **86-100**: ✅ EXCELLENT - Optimal

4. **Specific Recommendations**
   - If > 7 visible elements → Chunking or Progressive Disclosure
   - If > 9 choices → Reduce options or steps
   - If visual complexity is high → Simplify the design

## Examples

### Example 1: Overloaded search page

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
   └─ Group by: Price, Type, Amenities, Rules, Match
   └─ Estimated impact: Score 65 → 72 (+7)

🟠 P1 - High Priority
├─ Reduce visual complexity
│  └─ Limit to 3-4 brand colors
│  └─ Standardize font sizes (max 5 variations)
│  └─ Estimated impact: Score 72 → 78 (+6)
│
└─ Add "Quick Filters" preset buttons
   └─ Example: "Furnished < 1000€", "2 bed WiFi"
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

### Example 2: Dashboard with acceptable load

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

The skill generates:
1. **Terminal output** (score + recommendations)
2. **Report file**: `docs/ux-audits/cognitive-load-[component]-[date].md`
3. **Heatmap visual** (optional): ASCII art showing attention zones

## Configuration

Available flags:
- `--strict`: Strict mode (doubled penalties)
- `--export=pdf`: Exports the report as PDF
- `--compare=[other_file]`: Compares with another component

## References

Based on:
- [Miller's Law](https://lawsofux.com/millers-law/)
- [Hick's Law](https://lawsofux.com/hicks-law/)
- [Cognitive Load Theory](https://www.nngroup.com/articles/minimize-cognitive-load/)
