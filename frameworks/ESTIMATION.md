# Framework — Project Estimation

> Sources: US Navy PERT (1957), Daniel Kahneman & Amos Tversky (Nobel Prize in Economics 2002),
> Joel Spolsky Evidence-Based Scheduling (joelonsoftware.com, 2007),
> UK Department for Transport Reference Class Forecasting (gov.uk, 2004).
> When to use: before committing to any deadline with a client or yourself.

---

## The Core Problem: the Planning Fallacy

Kahneman & Tversky named this phenomenon in 1979: the **planning fallacy** is the systematic tendency
to underestimate the time, cost, and risks of a future task, while overestimating its benefits —
even while knowing that one has systematically underestimated in the past.

This is not a character flaw. It is a universal cognitive bias, documented across
thousands of projects, from home renovations to railway tunnels.

**Concrete data:**
- The UK Department for Transport introduced Reference Class Forecasting in 2004.
  Result: budget overruns dropped from **38% to 5%** on major projects.
- Developers systematically underestimate by **40–200%** depending on the type of task.

### The SQWR Rule: ×1.5 systematically for solo+AI

The Claude Code context introduces an additional artificial optimism:
- Claude generates a prototype in 30 min → gives the illusion that the feature is done
- Reality: debugging, edge cases, tests, and integration with existing code multiply by 2–3
- **SQWR empirical rule: multiply EVERY estimate by ×1.5 before committing**

```
Intuitive estimate : 4 hours
Calculated PERT   : 5.3 hours
×1.5 adjustment   : 8 hours → 1 working day
```

---

## Method 1 — PERT (US Navy, Polaris Program, 1957)

### The formula

PERT (Program Evaluation and Review Technique) forces thinking in three scenarios:

```
PERT Estimate = (O + 4M + P) / 6

O = Optimistic      (everything goes perfectly, no surprises)
M = Most Likely     (normal scenario with a few typical frictions)
P = Pessimistic     (complications take longer than expected)
```

**Why 4×M?** The formula comes from the Beta distribution. The most likely case
is weighted 4 times because it is empirically the most representative of reality —
with bounds to prevent extreme optimism.

### Standard deviation — measuring uncertainty

```
σ = (P - O) / 6
```

The larger σ is, the more uncertain the task. σ > 2h on a task estimated at 4h
signals high uncertainty → dig into Rabbit Holes before committing.

### SQWR Example Table

| Task | O | M | P | Raw PERT | ×1.5 | Committed Estimate |
|------|---|---|---|----------|------|-------------------|
| Static marketing page (Next.js) | 2h | 4h | 8h | 4.3h | 6.5h | **1 day** |
| Full auth feature (Supabase) | 4h | 8h | 20h | 9.3h | 14h | **2 days** |
| Third-party API integration (webhook, etc.) | 2h | 6h | 16h | 7h | 10.5h | **1.5 days** |
| Reusable UI component | 1h | 2h | 5h | 2.3h | 3.5h | **4 working hours** |
| Database migration (Supabase) | 1h | 3h | 8h | 3.5h | 5.3h | **1 day** |
| Project setup from scratch | 2h | 4h | 6h | 4h | 6h | **1 day** |

---

## Method 2 — Reference Class Forecasting (Kahneman)

### Inside view vs Outside view

| Approach | Description | Bias |
|----------|-------------|-------|
| **Inside view** | Estimate *this* task by focusing on its details | Ignores how similar tasks actually played out |
| **Outside view** | Look at how *similar* tasks have played out in the past | Corrects optimism bias with real data |

**Reference Class Forecasting means systematically preferring the Outside view.**

### Practical application at SQWR

1. Identify the task class (e.g., "page with form + Supabase API")
2. Look in SQWR history to see how long it took in previous instances
3. Use the **median** (not the average, which is too influenced by outliers)
4. Adjust for known differences with the current task

### SQWR Reference Register — to be filled in over time

| Task Class | Past Examples | Actual Median | Adjustment |
|------------|---------------|---------------|-----------|
| Static marketing page | La Villa, SQWR, Villa Coladeira | [to fill] | |
| Page with Supabase auth | izzico login, CozyGrowth dashboard | [to fill] | |
| Reusable UI component | [list of components created] | [to fill] | |
| Full CRUD feature | [list] | [to fill] | |
| Third-party service integration | [list] | [to fill] | |
| Project setup from scratch | [list] | [to fill] | |

**Instruction:** After each project, record [initial estimate, actual duration] in this table.
After 3–4 projects, medians become statistically reliable.

---

## Method 3 — Evidence-Based Scheduling (Joel Spolsky, 2007)

### Principle

> *"Instead of pulling a date out of thin air, you use your actual historical velocity
> to produce a probability distribution of ship dates."* — Joel Spolsky

**Individual velocity = estimated time / actual time**

```
If you estimate "4h" and it takes "6h" → velocity = 4/6 = 0.67
To correct: future estimate × (1 / 0.67) = × 1.5

If you estimate "4h" and it takes "3h" → velocity = 4/3 = 1.33
To correct: future estimate × (1 / 1.33) = × 0.75
```

### How to track your SQWR velocity

| Month | Task | Estimated | Actual | Ratio |
|-------|------|-----------|--------|-------|
| [month] | [task] | [Xh] | [Yh] | [X/Y] |
| | | | | |
| | | | | |
| **Average** | | | | **[calculate]** |

**Personal multiplier = 1 / (average of ratios)**

*Example: if your average is 0.7 → you divide by 0.7 = you multiply by ×1.43.
This is very close to the empirical ×1.5 SQWR rule — that is not a coincidence.*

---

## SQWR Estimation Template

```markdown
## Estimation — [Feature / Project]

**Date:** [DD/MM/YYYY]
**Project:** [name]
**Described in Pitch:** [link or short description]

### Task Breakdown

| # | Task | O | M | P | Raw PERT |
|---|------|---|---|---|----------|
| 1 | [task] | | | | |
| 2 | [task] | | | | |
| 3 | [task] | | | | |
| **Total** | | | | | **[sum]h** |

### Adjustments

| Adjustment | Factor | Result |
|-----------|--------|--------|
| Raw PERT total | 1.0 | [X]h |
| Solo+AI multiplier | ×1.5 | [X × 1.5]h |
| Personal velocity adjustment | ×[your ratio] | [result]h |
| **Final estimate** | | **[result]h → [X] days** |

### Reference Class

Most similar task in SQWR history: [description]
Actual duration of that task: [X]h / [X] days

### Delivery Commitments

| Confidence | Date |
|-----------|------|
| 50% (optimistic) | [DD/MM/YYYY] |
| **85% (to communicate)** | **[DD/MM/YYYY]** |

**SQWR Rule: always communicate the 85% confidence date to the client.
Never communicate the optimistic date as the delivery date.**
```

---

## Estimation Checklist

- [ ] Task broken down into sub-tasks (each sub-task ≤ 4h)
- [ ] PERT formula applied to each sub-task (O, M, P filled in)
- [ ] Reference Class consulted (have we done something similar before?)
- [ ] ×1.5 multiplier (solo+AI) applied to the total
- [ ] Personal velocity taken into account if history is available
- [ ] Rabbit Holes identified (→ see `frameworks/PROJECT-SCOPING.md`)
- [ ] **85% confidence date communicated — never the optimistic date**

---

## Sources

| Reference | Link |
|-----------|------|
| PERT — US Navy Polaris Program (1957) | wikipedia.org/wiki/Program_evaluation_and_review_technique |
| Planning Fallacy — Kahneman & Tversky | scholar.princeton.edu (Nobel Prize 2002 — Judgment under Uncertainty) |
| Reference Class Forecasting — UK DfT (2004) | gov.uk/government/publications/reference-class-forecasting |
| Evidence-Based Scheduling — Joel Spolsky (2007) | joelonsoftware.com/2007/10/26/evidence-based-scheduling |
| Thinking, Fast and Slow — Daniel Kahneman (2011) | penguin.co.uk/books/thinking-fast-and-slow |
