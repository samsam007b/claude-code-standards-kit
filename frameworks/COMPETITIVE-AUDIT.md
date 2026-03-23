# Framework — Competitive Audit

> SQWR Project Kit framework module.
> Sources: Nielsen Norman Group — Competitive Usability (nngroup.com/articles/competitive-usability-evaluations), Harvard Business Review — Mystery Shopper methodology, Kim & Mauborgne — Blue Ocean Strategy Canvas (hbr.org/2004/10/blue-ocean-strategy), Baymard Institute — Competitive UX Benchmark.

---

## When to use this framework

**Before any new project, product, or brand repositioning**, analyze 3 to 5 direct and indirect competitors. A competitive audit takes 2 to 4 hours but prevents building something that already exists or ignores established conventions in the industry.

> "The best way to differentiate is to know exactly what you're differentiating from." — Nielsen Norman Group

---

## 1. Competitor Selection

### 3 types to analyze

| Type | Definition | Examples |
|------|------------|---------|
| **Direct competitor** | Same offer, same target | Product A vs Product B |
| **Indirect competitor** | Alternative solution to the same problem | Alternative with a different workflow |
| **Best practice (outside the sector)** | UX/branding leader in another domain | Airbnb for hospitality, Notion for productivity |

**Rule:** always include at least **1 out-of-sector competitor** — the best UX innovations often come from cross-industry analogies.

**Recommended number: 3–5 competitors.** Beyond that = analysis too diffuse. Fewer = confirmation bias.

> Source: Nielsen Norman Group — [nngroup.com/articles/competitive-usability-evaluations](https://www.nngroup.com/articles/competitive-usability-evaluations/)

---

## 2. Analysis Grid — Template

For each competitor, evaluate the following 6 dimensions.

### Template per competitor

```
Competitor: [Name]
URL / App: [link]
Analysis date: [date]
Analyst: [name]

═══════════════════════════════════
DIMENSION 1 — POSITIONING (20 pts)
═══════════════════════════════════

Main value proposition:
→ [In 1 sentence — what they claim to be]

Stated target:
→ [Who they explicitly target]

Claimed differentiators:
→ [What they say makes them unique]

Positioning score: ___/20
Comments: ...

═══════════════════════════════════
DIMENSION 2 — DESIGN & UX (20 pts)
═══════════════════════════════════

Visual consistency (colors, type, spacing):  ___/5
Navigation clarity (time to find X):         ___/5
Onboarding quality (first experience):       ___/5
Responsive / Mobile:                         ___/5

Design & UX score: ___/20

Observations:
→ [What works]
→ [What does not work]
→ [Possible inspiration]

═══════════════════════════════════
DIMENSION 3 — PERFORMANCE (20 pts)
═══════════════════════════════════

LCP (Largest Contentful Paint):   [Measure at web.dev/measure]
FID / INP:                        [Measure at web.dev/measure]
CLS:                              [Measure at web.dev/measure]
Lighthouse Performance score:     ___/100

Performance score: ___/20
(>90 Lighthouse = 20pts | 75-90 = 15pts | 60-75 = 10pts | <60 = 5pts)

═══════════════════════════════════
DIMENSION 4 — ACCESSIBILITY (15 pts)
═══════════════════════════════════

Lighthouse Accessibility score:    ___/100
Functional keyboard navigation:    ☐ Yes / ☐ No / ☐ Partial
WCAG AA contrast ratios respected: ☐ Yes / ☐ No / ☐ Partial
Alt text on images:                ☐ Yes / ☐ No / ☐ Partial

Accessibility score: ___/15

═══════════════════════════════════
DIMENSION 5 — CONTENT & SEO (15 pts)
═══════════════════════════════════

Message clarity (< 5 sec to understand the offer): ___/5
Copywriting quality (consistent tone of voice):    ___/5
SEO presence (target keyword rankings):            ___/5

Content & SEO score: ___/15

═══════════════════════════════════
DIMENSION 6 — BRAND (10 pts)
═══════════════════════════════════

Memorability (unique logo, colors):     ___/5
Cross-platform consistency (web, app, social): ___/5

Brand score: ___/10

═══════════════════════════════════
TOTAL SCORE: ___/100
═══════════════════════════════════
```

---

## 3. Heuristic Evaluation (Nielsen)

> Source: Nielsen Norman Group — How to Conduct a Heuristic Evaluation — [nngroup.com/articles/how-to-conduct-a-heuristic-evaluation](https://www.nngroup.com/articles/how-to-conduct-a-heuristic-evaluation/)

For each competitor, apply Nielsen's 10 heuristics. Score from 0 to 4:

| Score | Meaning |
|-------|---------|
| 0 | Not a problem |
| 1 | Cosmetic problem — fix if time allows |
| 2 | Minor problem — low priority |
| 3 | Major problem — high priority |
| 4 | Catastrophe — blocks usage |

```
Heuristic 1 — Visibility of system status:       [0-4]
Heuristic 2 — Match between system and world:    [0-4]
Heuristic 3 — User control and freedom:          [0-4]
Heuristic 4 — Consistency and standards:         [0-4]
Heuristic 5 — Error prevention:                  [0-4]
Heuristic 6 — Recognition rather than recall:    [0-4]
Heuristic 7 — Flexibility and efficiency:        [0-4]
Heuristic 8 — Aesthetic and minimalist design:   [0-4]
Heuristic 9 — Help users recognize errors:       [0-4]
Heuristic 10 — Help and documentation:           [0-4]

Nielsen score (problems detected): ___/40
(Lower score = better / 0 = no problems)
```

> **Recommended number of evaluators: 3–5.** A single evaluator detects ~35% of problems. Five evaluators detect ~75%. Beyond 5 = diminishing returns.
> Source: Nielsen Norman Group — [nngroup.com/articles/how-to-conduct-a-heuristic-evaluation](https://www.nngroup.com/articles/how-to-conduct-a-heuristic-evaluation/)

---

## 4. Blue Ocean Canvas

> Source: Kim & Mauborgne — *Blue Ocean Strategy* (Harvard Business Review Press, 2005)
> [hbr.org/2004/10/blue-ocean-strategy](https://hbr.org/2004/10/blue-ocean-strategy)

The Blue Ocean Canvas allows you to visualize competitive factors and identify unexplored spaces.

### Instructions

1. List the **6–8 competitive factors** important in your sector
2. Score each competitor from 1 (low) to 5 (high) on each factor
3. Draw the value curves
4. Identify zones where you can: **Eliminate / Reduce / Raise / Create (ERRC)**

### Blue Ocean Canvas Template

```
COMPETITIVE FACTORS              | You | Comp.A | Comp.B | Comp.C
─────────────────────────────────────────────────────────────────
[Factor 1 — e.g., Price]         |  3  |   5    |   2    |   4
[Factor 2 — e.g., Speed]         |  4  |   3    |   5    |   2
[Factor 3 — e.g., Design]        |  5  |   2    |   3    |   2
[Factor 4 — e.g., Support]       |  2  |   4    |   3    |   5
[Factor 5 — e.g., Integrations]  |  3  |   5    |   4    |   3
[Factor 6 — e.g., Mobile]        |  5  |   3    |   2    |   4
[Factor 7 — e.g., AI/Automation] |  4  |   2    |   1    |   2
─────────────────────────────────────────────────────────────────

ERRC ACTIONS:
→ ELIMINATE: [factors everyone invests in but that have no perceived value]
→ REDUCE: [factors over-invested vs sector standard]
→ RAISE: [factors under-invested vs sector standard]
→ CREATE: [factors nonexistent in the sector = blue ocean]
```

---

## 5. Mystery Shopper — User Journey

> Source: Harvard Business Review — Customer Journey Mapping (hbr.org)
> Source: Baymard Institute — UX Benchmark methodology (baymard.com/research)

**Principle:** complete a competitor's full user journey as if you were a real user. Document every friction.

```
MYSTERY SHOPPER — Journey Report
Competitor: [Name]
Journey tested: [e.g., Sign-up → First purchase → Support]
Date: [date]
Duration: [total time]

─────────────────────────
STEP 1 — [Step Name]
─────────────────────────
Duration: [time]
Action taken: [description]
Friction identified: [problem if applicable]
Emotion: [confused / frustrated / satisfied / impressed]
Screenshot: [reference]

─────────────────────────
STEP 2 — ...
─────────────────────────

JOURNEY SUMMARY:
→ Smoothest moment: [step]
→ Most frustrating moment: [step + reason]
→ What we must absolutely copy: [...]
→ What we must absolutely avoid: [...]
→ Opportunity identified: [...]
```

---

## 6. Comparative Summary Table

```
COMPARATIVE TABLE — [Project X] vs Competitors
Date: [date]

                    | You | Comp.A | Comp.B | Comp.C | Ideal leader
────────────────────────────────────────────────────────────────────
Positioning         |  -  |  /20   |  /20   |  /20   |    /20
Design & UX         |  -  |  /20   |  /20   |  /20   |    /20
Performance         |  -  |  /20   |  /20   |  /20   |    /20
Accessibility       |  -  |  /15   |  /15   |  /15   |    /15
Content & SEO       |  -  |  /15   |  /15   |  /15   |    /15
Brand               |  -  |  /10   |  /10   |  /10   |    /10
────────────────────────────────────────────────────────────────────
TOTAL SCORE         |  -  | /100   | /100   | /100   |   /100

STRENGTHS OF [Project X] relative to competitors:
1. [Strength 1]
2. [Strength 2]

WEAKNESSES to address as a priority:
1. [Weakness 1 — dimension + score]
2. [Weakness 2 — dimension + score]

OPPORTUNITIES (angles unexploited by competitors):
1. [Blue Ocean Opportunity 1]
2. [Blue Ocean Opportunity 2]
```

---

## 7. When to re-run the audit

| Trigger | Recommended frequency |
|---------|----------------------|
| Launch of a new project | Before the first sprint |
| Brand repositioning | Before the new strategy |
| Major new competitor detected | Within 2 weeks |
| Maintenance audit | Every 6 months |

---

## Sources

| Reference | Link |
|-----------|------|
| Nielsen Norman Group — Competitive Usability | nngroup.com/articles/competitive-usability-evaluations |
| Nielsen — Heuristic Evaluation | nngroup.com/articles/how-to-conduct-a-heuristic-evaluation |
| Kim & Mauborgne — Blue Ocean Strategy (HBR, 2004) | hbr.org/2004/10/blue-ocean-strategy |
| Baymard Institute — UX Benchmark | baymard.com/research |
| Google PageSpeed Insights | pagespeed.web.dev |
| WebAIM Contrast Checker | webaim.org/resources/contrastchecker |
