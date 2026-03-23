# Framework — UX Research

> SQWR Project Kit framework module. Use this framework before designing a new feature or product.
> Sources: Jakob Nielsen — "Why You Only Need to Test with 5 Users" (nngroup.com, 2000), Clayton Christensen — Jobs-to-Be-Done (Harvard Business School), Rob Fitzpatrick — *The Mom Test* (2013), John Brooke — System Usability Scale (1996), Guest et al. — "How Many Interviews Are Enough?" (Field Methods, 2006).

---

## Scientific Foundations

**"85% of usability problems are detected with 5 testers."** (Jakob Nielsen, 2000 — based on the problem detection probability curve). Beyond 5, returns are diminishing. Research is not an activity reserved for large teams.

**"Users don't know what they want — they know what they did."** (Rob Fitzpatrick, *The Mom Test*, 2013). Interviews about future intentions are unreliable data. Only past behavior is evidence.

---

## When to conduct research

| Phase | Method | Objective |
|-------|--------|-----------|
| **Discovery** | JTBD, interviews (5–8 people) | Understand real problems |
| **Exploration** | Card sorting, guerrilla testing | Test solution directions |
| **Validation** | Usability test (5 people), prototype | Verify that the solution works |
| **Post-launch** | NPS, CSAT, analytics, session replay | Measure and identify friction |

**Decision matrix:**
```
High uncertainty + High impact   → Research mandatory before development
High uncertainty + Low impact    → Light research (5 quick interviews)
Low uncertainty + High impact    → Validation via usability test
Low uncertainty + Low impact     → Ship and measure
```

---

## 1. Jobs-to-Be-Done (JTBD)

> Source: Clayton Christensen — *Competing Against Luck* (Harvard Business Review Press, 2016)
> Source: Tony Ulwick — *Jobs to be Done: Theory to Practice* (Idea Bite Press, 2016)

**Principle:** users don't "buy" a product — they "hire" a product to accomplish a job. Understanding the job reveals what truly matters.

### The 3 dimensions of a job

| Dimension | Definition | Example |
|-----------|-----------|---------|
| **Functional** | The concrete task to accomplish | "Submit my tax return" |
| **Emotional** | How the user wants to feel | "Feel competent, not stressed" |
| **Social** | How the user wants to be perceived | "Appear organized to my accountant" |

### JTBD Statement Template

```
When [TRIGGERING SITUATION],
I want to [MOTIVATION / FUNCTIONAL JOB],
so that [EXPECTED OUTCOME — emotional or social].
```

**Examples:**
```
When I need to send a contract to a client,
I want to get it signed online in less than 2 minutes,
so that I appear professional and the client signs without friction.

When I receive the payroll for my team,
I want to verify that the numbers are correct quickly,
so that I don't feel incompetent if an error slips through.
```

### How to identify the real JTBD

Questions to ask in an interview (The Mom Test adapted):
1. "The last time you had this problem, what did you do exactly?"
2. "What made you decide to look for a solution at that moment?"
3. "What did you try before? Why wasn't it enough?"
4. "If you could no longer use our product tomorrow, what would you do?"

---

## 2. Interview Protocol — The Mom Test

> Source: Rob Fitzpatrick — *The Mom Test* (2013)

**The 3 rules of The Mom Test:**
1. Talk about the past (real behavior), never the future (unreliable intentions)
2. Never pitch during the interview
3. Look for behavioral evidence, not opinions

### Number of participants

**Thematic saturation rule:** new insights stop after 5–8 interviews per homogeneous segment. (Guest, Bunce & Johnson — "How Many Interviews Are Enough?", Field Methods, 2006)

**Never mix segments**: 5 interviews with SMEs and 5 with startups ≠ 10 interviews about "companies".

### Interview script (45–60 min)

```markdown
INTRODUCTION (5 min)
"I'm trying to understand how you [domain] — not to sell you anything.
There are no right or wrong answers. If something seems
strange about my questions, please tell me."

CONTEXT (10 min)
1. "Describe your role and what you typically do in a week."
2. "What is the most frustrating part of [domain] for you?"

PROBLEM (20 min)
3. "The last time you encountered [problem], what happened exactly?"
4. "What did you do to resolve it?"
5. "How long did it take? How often does it happen per week/month?"
6. "Did you try other tools or methods? Why weren't they enough?"

VALUE (10 min)
7. "If this problem disappeared tomorrow, what would the impact be for you?"
8. "Have you ever paid to solve this problem? How much?"

CLOSING (5 min)
9. "Is there anything important I haven't thought to ask you?"
10. "Do you know 2–3 people in the same situation I could speak with?"
```

---

## 3. Usability Testing

> Source: Jakob Nielsen — "Why You Only Need to Test with 5 Users" (nngroup.com, 2000)
> Source: Ericsson & Simon — Protocol Analysis (1980) — think-aloud method

### Think-aloud protocol

**Instruction to participant:** "While you use the interface, think aloud. Say what you see, what you think, what you are trying to do. There is no judgment."

**Absolute rule for the moderator: never help.** If the participant is stuck, note the time and the blocker. Do not say "try clicking here".

### Define tasks before the session

```markdown
TASK 1: "You just created an account. Complete your profile."
Success criterion: profile 100% completed in < 3 minutes

TASK 2: "You want to invite a colleague. Do it."
Success criterion: invitation sent without assistance

TASK 3: "Find out how to export your data."
Success criterion: export downloaded
```

### Nielsen Severity Grid (0–4)

| Score | Meaning |
|-------|--------|
| 0 | Not a usability problem |
| 1 | Cosmetic problem — fix only if time allows |
| 2 | Minor problem — low priority |
| 3 | Major problem — high priority |
| 4 | Catastrophe — must fix before launch |

### System Usability Scale (SUS)

> Source: John Brooke — "SUS: A 'Quick and Dirty' Usability Scale" (1996)

10 questions on a Likert scale 1–5. Score /100. **Threshold ≥68 = acceptable** (industry average).

```
1. I think I would like to use this system frequently.
2. I found the system unnecessarily complex.
3. I thought the system was easy to use.
4. I think I would need support to use this system.
5. I found the various functions in this system were well integrated.
6. I thought there was too much inconsistency in this system.
7. I would imagine that most people would learn to use this system quickly.
8. I found the system very cumbersome to use.
9. I felt very confident using the system.
10. I needed to learn a lot of things before I could get going with this system.
```

**Calculation:** odd questions: score - 1. Even questions: 5 - score. Sum × 2.5.

---

## 4. NPS — Net Promoter Score

> Source: Fred Reichheld — "The One Number You Need to Grow" (Harvard Business Review, 2003)

**One question:** "On a scale of 0 to 10, how likely are you to recommend [Product] to a friend or colleague?"

| Score | Segment | Action |
|-------|---------|--------|
| 9–10 | Promoters | Request a testimonial, referral program |
| 7–8 | Passives | Understand what is missing |
| 0–6 | Detractors | Interview to understand the frustration |

**NPS = % Promoters - % Detractors**

| NPS Score | Level |
|-----------|-------|
| >70 | Excellent (Apple, Tesla level) |
| 40–70 | Good |
| 0–40 | Needs improvement |
| <0 | Critical problem |

**When to launch:** Day 7 after activation (the user has had time to use the product, early enough to act on detractors).

---

## 5. Synthesis — Affinity Mapping

> Source: KJ Method (Jiro Kawakita, 1960s), adopted by IDEO and the UX community

**Process:**
1. Transcribe each insight onto a note (digital: FigJam, Miro)
2. Group silently by affinity (no discussion first)
3. Name each group with an action verb (e.g., "Understand the status", "Find help")
4. Prioritize groups by frequency × severity

**Prioritization matrix:**
```
User impact (1-5) × Frequency (1-5) = Priority score
```

---

## Checklist

### Blockers (before any development of a new feature)

- [ ] JTBD documented for the feature (all 3 dimensions: functional, emotional, social)
- [ ] At least 5 user interviews conducted on the target segment

### Important (before launch)

- [ ] Usability test (5 participants, tasks defined)
- [ ] SUS score ≥68/100
- [ ] NPS configured and triggered at Day 7 post-activation

### Desirable

- [ ] Session replay activated (PostHog) to identify post-launch friction
- [ ] Recurring user panel (5–10 people available for quick tests)

---

## Sources

| Reference | Link |
|-----------|------|
| Nielsen — "Why You Only Need to Test with 5 Users" (2000) | nngroup.com/articles/why-you-only-need-to-test-with-5-users |
| Christensen — Jobs-to-Be-Done | hbs.edu/faculty/Pages/item.aspx?num=46

 |
| Fitzpatrick — *The Mom Test* (2013) | momtestbook.com |
| Brooke — SUS Scale (1996) | usabilitynet.org/trump/documents/Suschapt.doc |
| Reichheld — NPS (HBR, 2003) | hbr.org/2003/12/the-one-number-you-need-to-grow |
| Guest et al. — "How Many Interviews Are Enough?" (2006) | journals.sagepub.com/doi/10.1177/1525822X05279903 |
| Nielsen Severity Ratings | nngroup.com/articles/how-to-rate-the-severity-of-usability-problems |
