# Audit — Brand Strategy

> SQWR Project Kit audit module.
> Sources: Nielsen Norman Group — Tone of Voice (nngroup.com/articles/tone-of-voice-dimensions), Kapferer — *The New Strategic Brand Management* (Kogan Page, 2012), Aaker — *Brand Identity* (Free Press, 1996), Harvard Business Review — Brand Consistency Research.

---

## Foundations

**Brand consistency increases revenue by 10 to 20%** (Lucidpress / Marq — *The State of Brand Consistency*, 2021). An inconsistent brand is not merely aesthetically unpleasant — it actively undermines trust and memorability.

This audit must be conducted before any launch and reviewed at each repositioning. See `frameworks/BRAND-STRATEGY.md` to define strategy before scoring.

---

## Instructions

For each dimension:
1. Assess the current state against the listed criteria
2. Score according to the provided scale
3. Identify concrete gaps
4. Prioritize by impact on user perception

---

## Dimension 1 — Strategic Foundations (20 points)

**Weight: 20% of total score**

> Source: Simon Sinek — *Start With Why* (Portfolio/Penguin, 2009), Kapferer *The New Strategic Brand Management*

| Criterion | Verification questions | Score |
|-----------|----------------------|-------|
| **Purpose (WHY)** | Why do you exist beyond making money? Is it documented? | 0-5 |
| **Differentiating positioning** | What objectively sets you apart from your 3 direct competitors? | 0-5 |
| **Precise target** | Do you have a documented primary persona with needs, objections, and vocabulary? | 0-5 |
| **Value proposition** | Can a stranger understand your offering in < 5 seconds? (5-second test) | 0-5 |

**Score D1: ___/20**

**5-second test:** show the homepage or pitch to 5 external people for 5 seconds. Ask: "What is this product? Who is it for?" If < 4/5 answer correctly → value proposition needs reworking.

---

## Dimension 2 — Visual Identity (20 points)

**Weight: 20% of total score**

> Source: Aaker — *Building Strong Brands* (Free Press, 1996), W3C WCAG 2.1

| Criterion | Verification questions | Score |
|-----------|----------------------|-------|
| **Palette consistency** | Same palette used across all touchpoints? Tokens defined and documented? | 0-5 |
| **Consistent typography** | Same typographic combination everywhere? Hierarchy respected? | 0-5 |
| **Logo — correct usage** | Protection spaces respected? No unofficial variants in use? | 0-5 |
| **WCAG accessibility** | Contrast ≥ 4.5:1 on all surfaces? (verify with WebAIM) | 0-5 |

**Score D2: ___/20**

**Visual checklist:**
```
Color palette:
  ☐ Primary palette documented (max 3 primary colors)
  ☐ CSS/Swift tokens defined
  ☐ Dark mode variants defined
  ☐ ΔE > 7 between distinct colors (human perception threshold)

Typography:
  ☐ Primary font (headings) + secondary font (body) defined
  ☐ Typographic scale based on a mathematical ratio (1.5 or 1.618)
  ☐ Minimum size 16px (web body)

Logo:
  ☐ Versions: color / black / white / dark background
  ☐ SVG format available for web
  ☐ Usage rules documented (minimum size, clear space)
```

---

## Dimension 3 — Tone of Voice (25 points)

**Weight: 25% of total score**

> Source: Nielsen Norman Group — 4 Dimensions of Tone of Voice
> [nngroup.com/articles/tone-of-voice-dimensions](https://www.nngroup.com/articles/tone-of-voice-dimensions)

Nielsen NN/G identified 4 measurable dimensions of tone of voice. Each brand must position itself on these 4 axes and document them.

### The 4 Nielsen NN/G dimensions

| Dimension | Axis | Score 1–5 |
|-----------|------|-----------|
| **Formality** | 1 = Casual / 5 = Formal | ___ |
| **Humor** | 1 = Serious / 5 = Humorous | ___ |
| **Irreverence** | 1 = Respectful / 5 = Irreverent | ___ |
| **Energy** | 1 = Neutral / 5 = Enthusiastic | ___ |

**Rule:** if the brand addresses different segments (e.g., B2C and B2B), define a distinct matrix per segment.

### Tone of Voice Scoring

| Criterion | Verification questions | Score |
|-----------|----------------------|-------|
| **Documented positioning** | Are the 4 Nielsen dimensions defined and documented? | 0-5 |
| **Cross-surface consistency** | Same tone on: website, emails, app, social media, support? | 0-5 |
| **Proprietary vocabulary** | Brand terms defined (and their prohibited alternatives)? | 0-5 |
| **Adaptation by segment** | If multi-target, is a distinct matrix documented? | 0-5 |
| **Practical test** | Write 5 representative sentences — are they consistent with the matrix? | 0-5 |

**Score D3: ___/25**

### Tone of voice matrix template

```
TONE OF VOICE MATRIX — [Brand]

Segment: [e.g., Consumer users]
  Formality:   [1-5] — [1 example sentence]
  Humor:       [1-5] — [1 example sentence]
  Irreverence: [1-5] — [1 example sentence]
  Energy:      [1-5] — [1 example sentence]

Segment: [e.g., Business clients]
  Formality:   [1-5] — [1 example sentence]
  Humor:       [1-5] — [1 example sentence]
  Irreverence: [1-5] — [1 example sentence]
  Energy:      [1-5] — [1 example sentence]

Prohibited words: [list]
Proprietary brand words: [list]
Greetings: [e.g., "Hello [First name]!" vs "Dear,"]
Sign-off: [e.g., "The [Brand] team"]
```

---

## Dimension 4 — Cross-Platform Consistency (20 points)

**Weight: 20% of total score**

> Source: Lucidpress / Marq — *The State of Brand Consistency* (2021)

| Criterion | Verification questions | Score |
|-----------|----------------------|-------|
| **Website** | Design system respected? Tone of voice consistent? | 0-5 |
| **Mobile application** | Same visual tokens as web? iOS/Android adaptations documented? | 0-5 |
| **Social media** | Same palette? Post templates defined? | 0-5 |
| **Emails** | Branded email template? Same tone of voice? | 0-5 |

**Score D4: ___/20**

**Consistency test:** open the website, app, and social media simultaneously. Close your eyes. Reopen. Is the brand instantly recognizable on each surface without reading the logo?

---

## Dimension 5 — Differentiation (15 points)

**Weight: 15% of total score**

> Source: Ries & Trout — *Positioning: The Battle for Your Mind* (McGraw-Hill, 2001)
> Source: Kim & Mauborgne — *Blue Ocean Strategy* (HBR Press, 2005)

| Criterion | Verification questions | Score |
|-----------|----------------------|-------|
| **Unique position** | Can you state your differentiator in 1 sentence without naming the competition? | 0-5 |
| **Proof of differentiator** | Do you have concrete data/evidence of this differentiator? | 0-5 |
| **Durability** | Is this differentiator difficult for competitors to copy? | 0-5 |

**Score D5: ___/15**

---

## Global Score Calculation

```
Brand Score = D1 (20) + D2 (20) + D3 (25) + D4 (20) + D5 (15)
            = Score out of 100
```

| Score | Level | Action |
|-------|-------|--------|
| ≥85/100 | ✅ Strong brand | Maintain consistency — semi-annual audit |
| 70-84/100 | 🟡 Developing brand | Identify and address priority gaps |
| 55-69/100 | 🟠 Fragile brand | Rework foundations before scaling |
| <55/100 | 🔴 Inconsistent brand | Repositioning required before any marketing investment |

---

## Pre-launch Brand Checklist

### 🔴 Blocking

- [ ] WHY documented (purpose)
- [ ] Value proposition tested (5-second test)
- [ ] Color palette with tokens + WCAG verification
- [ ] Tone of voice with the 4 Nielsen dimensions documented
- [ ] Prohibited vocabulary defined (words to ban)

### 🟡 Important

- [ ] Logo in 3 variants (color / black / white)
- [ ] Mathematical typographic scale
- [ ] Branded email template
- [ ] Tone of voice matrix per segment (if multi-target)

### 🟢 Desirable

- [ ] Complete brand guidelines document (PDF)
- [ ] Press kit / media kit
- [ ] Social media templates
- [ ] User tests on brand memorability

---

## Report Template

```
BRAND STRATEGY AUDIT REPORT
Brand: [name]
Date: [date]
Auditor: [name]

D1 — Strategic foundations  : ___/20
D2 — Visual identity        : ___/20
D3 — Tone of Voice          : ___/25
D4 — Cross-platform consistency: ___/20
D5 — Differentiation        : ___/15
                               ------
GLOBAL SCORE                 : ___/100

STRENGTHS:
1. [Primary strength]
2. [Secondary strength]

PRIORITY GAPS:
1. [Gap 1 — dimension + estimated impact]
2. [Gap 2 — dimension + estimated impact]

ACTION PLAN:
- [Action 1] — Deadline: [date] — Owner: [name]
- [Action 2] — Deadline: [date] — Owner: [name]
```

---

## Sources

| Reference | Link |
|-----------|------|
| Nielsen Norman Group — 4 Dimensions of Tone of Voice | nngroup.com/articles/tone-of-voice-dimensions |
| Kapferer — *The New Strategic Brand Management* (Kogan Page, 2012) | — |
| Aaker — *Building Strong Brands* (Free Press, 1996) | — |
| Simon Sinek — *Start With Why* (Portfolio/Penguin, 2009) | — |
| Ries & Trout — *Positioning: The Battle for Your Mind* (McGraw-Hill, 2001) | — |
| Lucidpress / Marq — *State of Brand Consistency* (2021) | marq.com/brand-consistency-report |
| Kim & Mauborgne — *Blue Ocean Strategy* (HBR Press, 2005) | hbr.org/2004/10/blue-ocean-strategy |
