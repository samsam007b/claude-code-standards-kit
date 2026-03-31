---
name: "brainstorm"
description: "Pre-implementation analysis guard — evaluates scope, reversibility, and approach plurality before Claude starts building. Required for tasks touching > 20 files or with Low/None reversibility."
effort: medium
model: sonnet
context: fork
agent: "general-purpose"
disable-model-invocation: true
argument-hint: "task description"
paths:
  - "contracts/CONTRACT-ANTI-PATTERNS.md"
  - "frameworks/PROJECT-SCOPING.md"
  - "agents/AGENT-BRAINSTORM.md"
allowed-tools: ["Read", "Grep", "Glob", "Bash", "Agent"]
---

# Skill: Brainstorm Guard

Activate before any non-trivial implementation task. Evaluates the task against 4 criteria before proceeding: **scope**, **reversibility**, **approach plurality**, and **motivation clarity**.

## When to use

| Signal | Ceremony |
|--------|----------|
| Bug fix touching 1–3 files | Skip — proceed directly |
| Feature touching 4–20 files | Recommended |
| Feature touching > 20 files | **Required** (CONTRACT-ANTI-PATTERNS.md §6) |
| Database migration or schema change | **Required** |
| Architectural refactor | **Required** |
| Ambiguous task with no linked issue | Required — clarify first |
| Any time `/brainstorm <task>` is invoked | Run full analysis |

## Analysis dimensions

### 1. Scope assessment

Count files that will be modified or created.

| File count | Level |
|-----------|-------|
| < 5 files | Light — skip or do verbally |
| 5–20 files | Recommended brainstorm |
| > 20 files | Required brainstorm |

### 2. Reversibility check

| Change | Reversibility | Required action |
|--------|--------------|----------------|
| New file, no DB change | High | None |
| Renamed export | Medium | Document callers |
| DB schema migration | Low | Write rollback migration first |
| External API / webhook / email | None | Manual remediation plan required |

**If reversibility is Low or None: document the rollback plan before the first line of code.**

### 3. Approach plurality

List at least **2 viable approaches** before committing to one. Evaluate each on:
- Implementation complexity (Low / Medium / High)
- Reversibility
- Files affected
- Test strategy

If only one approach is visible, the problem is under-understood — clarify before proceeding.

### 4. Motivation clarity

The task must pass all four checks:
- [ ] Describable in one sentence
- [ ] Linked to an issue, contract, or spec (or task given by user)
- [ ] Success criteria are measurable
- [ ] No requirements beyond what was stated

If any check fails: clarify before implementing.

## Output format

```
SQWR BRAINSTORM — [Task title]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Scope:         [N files — Light | Recommended | Required]
Reversibility: [High | Medium | Low | None]
               [Rollback plan if Low/None]

Approach A:    [description]
  Complexity:  [Low/Medium/High]
  Trade-off:   [key consideration]

Approach B:    [description]
  Complexity:  [Low/Medium/High]
  Trade-off:   [key consideration]

Contracts:     [which SQWR contracts apply]
Motivation:    [one sentence] — Ref: [issue/contract/task]

Recommendation: Approach [A | B]
→ PROCEED / CLARIFY FIRST / SCOPE REDUCTION RECOMMENDED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Invoke

```
/brainstorm <task description>
```

**Examples:**
```
/brainstorm Refactor the authentication module to use JWT refresh tokens
/brainstorm Add multi-tenant support to the billing system
/brainstorm Migrate from Prisma to Drizzle ORM
```
