# Framework — Project Scoping

> Sources: Ryan Singer (Shape Up, Basecamp 2019), Jake Knapp (Sprint, Google Ventures 2016),
> Gary Klein (HBR 2007 — pre-mortem), PMI PMBOK 6th Edition, Standish Group CHAOS Report 2020.
> When to use: before starting any new project or significant feature (>1 day of work).

---

## Why scope before coding

**70% of IT projects exceed their initial budget or timeline** (Standish CHAOS Report 2020).
The root cause is not the code — it is the absence of a clear problem definition,
scope, and risk assessment *before* touching the editor.

For a solo+AI studio like SQWR, the risk is amplified: Claude Code can generate
code quickly, which creates the illusion that things are progressing — even in the wrong direction.
**Scoping upfront costs 1 hour. A pivot after 2 weeks of development costs 2 weeks.**

---

## Part 1 — Shape Up Pitch (Ryan Singer, Basecamp 2019)

### Principle

Shape Up replaces PRDs and user stories with a short document (the "Pitch") that captures
the essence of a feature before development begins. The goal is not to
spec every pixel — it is to define the problem and the boundaries of the possible.

> *"We don't want to waste the team's time. We shape the work in advance by formulating
> a precise problem and a rough solution."* — Ryan Singer

### The 5 Components of the Pitch

| Component | Key Question | SQWR Example |
|-----------|-------------|--------------|
| **Problem** | What real problem does the user have? | "Property owners can't see who has viewed their izzico listing without navigating through 3 screens" |
| **Appetite** | How much time are we willing to spend on it? | "2 days max — if more, we reduce the scope" |
| **Solution** | Fat-marker sketch (not a precise wireframe) | Owner dashboard with a view counter + list of the 5 most recent viewer profiles |
| **Rabbit Holes** | What complexities could blow up the scope? | "Do not try to display historical analytics — just the last 30 days" |
| **No-Gos** | What are we **not** doing in this version? | "No comparison between listings, no charts, no date filter" |

### Recommended Appetites for SQWR (solo+AI)

| Size | Duration | When to use |
|------|----------|-------------|
| **Small** | 1–3 days | Visible improvement, clear scope, few dependencies |
| **Medium** | 4–7 days (1 week) | Full feature, a few dependencies, ≥1 unknown |
| **Large** | 2–3 weeks | New module or redesign, multiple unknowns |
| **Out of scope** | >3 weeks | Break down into multiple Pitches. Do not pitch a mountain. |

**Absolute rule:** if the Pitch does not fit within a known size, the problem
is not defined well enough. Return to the Problem step before continuing.

### SQWR Pitch Template

```markdown
# Pitch — [Short Title]

**Project:** [izzico / SQWR Studio / CozyGrowth / Client X]
**Date:** [DD/MM/YYYY]
**Appetite:** [Small 1-3d / Medium 1 week / Large 2-3 weeks]

## Problem

[Concrete story of a user facing the problem. One story only, not a list.]

## Solution

[Textual sketch or scanned drawing — not a precise wireframe. The HOW without the pixel-perfect.]

## Rabbit Holes

- [Hidden complexity 1 — to avoid or handle separately]
- [Hidden complexity 2]

## No-Gos (what we do NOT do in this version)

- [Excluded feature 1]
- [Excluded feature 2]

## Betting Table (solo self-validation)

- [ ] Does the problem merit the investment defined by the Appetite?
- [ ] Is the solution realistic within the Appetite?
- [ ] Are the identified Rabbit Holes manageable?
- [ ] Are the No-Gos acceptable for the client/user?
```

---

## Part 2 — Condensed 2-Day Design Sprint (Jake Knapp, GV 2016)

### Why 2 days for SQWR

The original Google Ventures Design Sprint runs 5 days for a team of 5–7 people.
Jake Knapp himself recommends compressed formats for small teams. With Claude Code,
a solo practitioner can cover in 2 days what a team does in 5 — generation is faster,
decisions are more direct.

### Day 1 — Understand & Decide (≈4–5h)

**Morning: Map the problem**
1. **Long-term Goal** — "In 2 years, if this project succeeds, what is true?" (1 sentence)
2. **Sprint Questions** — "What do we need to learn/test this week?" (3–5 questions)
3. **User Map** — Draw the user journey from A (entry) to Z (goal achieved)
4. **Target** — Choose 1 moment/step of the journey to focus on

**Afternoon: Explore & Decide**
5. **Lightning Demos** — Spend 20 min on similar existing solutions (competitors, inspiration)
6. **Crazy 8s** — 8 solution ideas in 8 minutes (quantity > quality)
7. **Solution Sketch** — Best idea developed in detail (3 frames: before/during/after)
8. **Vote** — If solo: sleep on it, decide the next morning

**Day 1 Deliverable:** `SPRINT-DAY1.md` document with Long-term Goal + Questions + Target + chosen Solution.

### Day 2 — Prototype & Test (≈4–5h)

**Morning: Storyboard & Prototype**
1. **Storyboard** — Sequence of 6–8 frames describing the complete experience
2. **Prototype** — As fast as possible: Figma for UI, markdown for flows, Next.js stub for technical

**Afternoon: Test with 1–3 users**
3. **Test script** — 5 questions maximum, no guiding
4. **Test sessions** — 20–30 min each, observe without explaining
5. **Patterns** — What did 2 out of 3 users struggle to do?

**Day 2 Deliverable:** Prototype + `SPRINT-INSIGHTS.md` with 3–5 actionable insights.

---

## Part 3 — Pre-mortem (Gary Klein, HBR 2007)

### Why it works

Gary Klein (HBR 2007) demonstrated that the pre-mortem increases the **precision of risk
identification by 30%**. The mechanism: "prospective hindsight" — imagining failure as
*already having occurred* removes inhibitions and allows people to voice doubts they would otherwise suppress.

> *"The technique breaks with the conventional positive-thinking approach that
> can cause teams to ignore warning signs."* — Gary Klein, HBR 2007

**Fundamental difference:**
- Classic risk analysis: "What *could* go wrong?" → vague answers
- Pre-mortem: "The project *has* failed. Explain why." → precise and actionable answers

### Execution (30 minutes)

```
1. Brief (5 min)
   Present the project, the Appetite, the chosen solution.

2. Frame the scenario (1 min)
   "Let's imagine we are [delivery date + 3 months].
   This project has failed — not due to bad luck, but because
   something went wrong in our execution.
   List all possible reasons."

3. Silent brainstorming (5 min)
   Everyone writes their list. No discussion yet.

4. Round table (10 min)
   Each person shares ONE item at a time.
   Continue until all lists are exhausted.

5. Consolidate & Mitigate (10 min)
   For each risk: can we prevent it? How?
   Convert into concrete actions → Risk Register.
```

**For SQWR solo:** Do the exercise alone, then repeat with Joakim (for SQWR Studio projects)
or Alexandre (for CozyGrowth). Even solo, the exercise forces the externalization
of concerns that remained implicit.

### SQWR Pre-mortem Template

```markdown
# Pre-mortem — [Project Name]

**Date:** [DD/MM/YYYY]
**Project:** [short description]
**Expected delivery:** [DD/MM/YYYY]
**Participants:** [Samuel / Samuel + Joakim / Samuel + Alexandre]

## Scenario

"We are [3 months after the expected delivery date].
[Project name] has failed. What happened?"

## Identified Causes

### Technical
-
-

### Client / Scope
-
-

### Personal / Pace
-
-

### External Dependencies
-
```

---

## Part 4 — Risk Register (PMI PMBOK)

### Probability × Impact Matrix

| Probability ↓ \ Impact → | 1 — Negligible | 2 — Minor | 3 — Moderate | 4 — Major | 5 — Critical |
|--------------------------|----------------|-----------|--------------|-----------|-------------|
| **5 — Almost certain**   | 5              | 10        | **15**       | **20**    | **25**      |
| **4 — Likely**           | 4              | 8         | **12**       | **16**    | **20**      |
| **3 — Possible**         | 3              | 6         | 9            | **12**    | **15**      |
| **2 — Unlikely**         | 2              | 4         | 6            | 8         | 10          |
| **1 — Rare**             | 1              | 2         | 3            | 4         | 5           |

**Action thresholds:**
- Score ≥ 15 → **Action required before starting**
- Score 8–14 → Planned mitigation
- Score < 8 → Monitor, accept

### SQWR Risk Register Template

```markdown
# Risk Register — [Project Name]

**Date:** [DD/MM/YYYY]
**From pre-mortem dated:** [DD/MM/YYYY]

| ID | Risk | P (1-5) | I (1-5) | Score P×I | Mitigation | Owner | Status |
|----|------|---------|---------|-----------|-----------|-------|--------|
| R1 | Client scope creep | 4 | 4 | **16** | Pitch validated in writing before start | Samuel | Open |
| R2 | Joakim availability (creative) | 3 | 3 | 9 | Confirm availability in Part 1 | Samuel | Open |
| R3 | Third-party API unavailable | 2 | 4 | 8 | Local mock + fallback planned | Samuel | Open |
| R4 | | | | | | | |

**SQWR Rule:** Any risk with a score ≥ 15 must have a defined mitigation action
AND an owner before the Pitch is validated.
```

---

## Scoping Checklist

To be completed before creating the first development branch.

- [ ] Shape Up Pitch completed (5 components — Problem, Appetite, Solution, Rabbit Holes, No-Gos)
- [ ] Appetite defined and accepted by all parties
- [ ] No-Gos listed and validated (by the client if applicable)
- [ ] Pre-mortem completed (minimum 5 risks identified)
- [ ] Risk Register created — all risks ≥ 15 have a mitigation + owner
- [ ] Estimation calculated (→ see `frameworks/ESTIMATION.md`)
- [ ] ADR created if significant architectural decision (→ see `frameworks/ADR-TEMPLATE.md`)

---

## When to use which tool

| Situation | Recommended Tool | Duration |
|-----------|-----------------|----------|
| Feature < 1 day, well understood | Scoping Checklist only | 15 min |
| Feature 1–5 days, moderate scope | Shape Up Pitch + Pre-mortem | 1h |
| New project or redesign | Pitch + 2-day Design Sprint + Pre-mortem | 2–3 days |
| Client project with defined budget | Pitch + Pre-mortem + full Risk Register | 2h |
| High technical uncertainty | Full Design Sprint (2d prototype + test) | 2 days |

---

## Sources

| Reference | Link |
|-----------|------|
| Shape Up — Ryan Singer (Basecamp 2019) | basecamp.com/shapeup |
| Google Ventures Design Sprint | sprint.google.com |
| Design Sprint Kit (GV) | designsprintkit.withgoogle.com |
| Pre-mortem — Gary Klein (HBR 2007) | hbr.org/2007/09/performing-a-project-premortem |
| PMI PMBOK 6th Edition | pmi.org/pmbok-guide-standards |
| Standish Group CHAOS Report 2020 | standishgroup.com/chaos_report |
