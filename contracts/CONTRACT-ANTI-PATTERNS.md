---
name: "AI Coding Anti-Patterns"
domain: "Code Quality / AI Governance"
version: "1.0.0"
last_validated: "2026-03-31"
sources:
  - "Martin Fowler — Refactoring: Improving the Design of Existing Code (2018) — Rule of Three, Speculative Generality"
  - "Robert C. Martin — Clean Code (2008) — God classes, silent failures, meaningful names"
  - "Michael Feathers — Working Effectively with Legacy Code (2004) — Seam model, pinning tests"
  - "DORA State of DevOps 2024 — AI-assisted coding: rework rate and quality signals"
  - "arXiv 2602.22302 — Structured constraints achieve 86% success vs 70% baseline"
  - "OWASP Agentic AI Top 10 (2025) — AA01 Goal Hijacking, AA09 Excessive Agency"
  - "NIST AI 600-1 — AI Risk Management Framework (2024)"
  - "Donald Knuth — Structured Programming with go to Statements (1974) — premature optimization"
  - "Shape Up (Basecamp, 2019) — fixed scope, appetite-driven development"
---

# Contract: AI Coding Anti-Patterns

> Anti-patterns codify what NOT to do. Each pattern below has been observed in AI-assisted codebases and carries a measurable cost in rework, bugs, or security incidents. Every rule has a threshold and a cited source.

---

## Overview

| Anti-Pattern | Detection Signal | Threshold | Action |
|---|---|---|---|
| Premature abstraction | New base class/util with < 3 concrete consumers | 0 | **BLOCKED** |
| Anti-rationalization | Proceeding with technically unsound approach after objection | 0 | **BLOCKED** |
| Over-engineering | Implementation complexity > 2× stated requirements | 0 | **BLOCKED** |
| Hallucinated requirements | Feature absent from spec/issue/task | 0 | **BLOCKED** |
| God object | Class/module > 500 LOC or > 20 public methods | 0 | **BLOCKED** |
| Context drift | Task scope expanded > 30% without explicit approval | 0 | **BLOCKED** |
| Premature optimization | Optimization without profiling data | 1 instance | WARN |
| Cargo-cult pattern | Code copied without understanding the constraint it solves | 1 instance | WARN |
| Silent failure | Error swallowed without logging or re-throw | 1 instance | WARN |
| Speculative generalization | "We'll need this later" abstractions with no current use case | 1 instance | WARN |

**BLOCKED = Claude must stop and propose a compliant alternative before proceeding.**

---

## 1. Premature Abstraction

**Rule:** Do not create a base class, utility function, or abstraction layer until at least **3 concrete consumers** exist.

**Why:** Two examples are insufficient to infer the correct abstraction. The wrong abstraction costs more to undo than no abstraction at all.

> "The first time you do something, you just do it. The second time you do something similar, you wince at the duplication but do it anyway. The third time you do something similar, you refactor." — Martin Fowler, Rule of Three (Refactoring, 2018)

**Detection signals:**
- New abstract class with only 1–2 implementing classes
- New utility module with < 3 call sites at the time of creation
- New interface with exactly one concrete implementation

**Exception:** Abstractions mandated by a contract (e.g., adapter pattern for testability, dependency injection boundary) are exempt if the motivation is documented.

**Compliant approach:**
```
// BLOCKED: abstraction created for 1 consumer
abstract class BaseRepository { ... }
class UserRepository extends BaseRepository { ... }

// COMPLIANT: wait until 3 consumers, then extract
class UserRepository { findById(...) { ... } }
class ProductRepository { findById(...) { ... } }
class OrderRepository { findById(...) { ... } }
// Now extract BaseRepository — the pattern is confirmed
```

**Source:** Fowler (2018), Ch. 7 — Rule of Three; Martin (2008), Ch. 3.

---

## 2. Anti-Rationalization

**Rule:** When asked to implement a technically unsound approach, Claude **must challenge the premise** before proceeding. Urgency ("just do it quickly", "no time for tests") is not a valid bypass.

**Why:** AI agents optimized for helpfulness tend to rationalize any request rather than push back. This pattern is the #1 source of silent technical debt in AI-assisted codebases.

**Anti-rationalization patterns to refuse:**
| Request | Required response |
|---------|------------------|
| "Add a 50GB in-memory cache for user lookups" | Challenge the 50GB premise; identify the real performance goal |
| "Delete all rows where user_id = NULL" | Verify whether NULLs are orphaned records or valid states |
| "Skip tests — we're launching tomorrow" | Document the risk explicitly; offer minimal smoke test as compromise |
| "Just use `any` here, we'll fix it later" | Propose the correct type; show the cost of deferred typing |

**Required response pattern:**
1. Identify the underlying goal ("You want to speed up user lookups")
2. Explain why the stated approach is problematic (with source if available)
3. Propose a technically sound alternative
4. Proceed only after the user explicitly accepts the trade-off

**Source:** OWASP Agentic AI Top 10 (2025), AA09: Excessive Agency; arXiv 2602.22302.

---

## 3. Over-Engineering

**Rule:** Implementation complexity must not exceed **2× the complexity** required by the stated requirements.

**Signals:**
- Strategy pattern for a feature with exactly one strategy
- Factory for a class instantiated in one place
- Event-driven pub/sub for a synchronous 3-step workflow
- Config abstraction for a single-environment deployment
- Generic parameter `<T>` where T is always the same type

**Test:** "Does the simpler solution — the one without the abstraction — solve the stated problem with no measurable performance or maintainability deficit?" If yes, the simpler solution is required.

**YAGNI principle:** "Always implement things when you actually need them, never when you just foresee that you need them." — Ron Jeffries, XP.

**Source:** Fowler (2018), Ch. 3 "Speculative Generality"; Martin (2008), Ch. 17.

---

## 4. Hallucinated Requirements

**Rule:** Claude must not implement features that are absent from the stated task, linked issue, or `CLAUDE.md`. All scope additions require explicit user approval.

**Why:** DORA 2024 identifies hallucinated features (scope added without request) as the #1 driver of AI-assisted rework rate. OWASP Agentic AI AA01 (Goal Hijacking) describes this as a primary failure mode.

**Blocked additions:**
- New database tables not mentioned in the task
- New UI components beyond what was requested
- New API endpoints not in the task specification
- New npm/pip dependencies not referenced by the task
- Refactors or "improvements" to code outside the task scope

**Required behavior:** When noticing a potential improvement outside task scope:
```
"This is outside the current task scope. I noticed [X] could be improved.
Should I include it? [Yes / No — keep it scoped]"
```

**Source:** OWASP Agentic AI (2025), AA01; DORA State of DevOps 2024 — AI Rework Rate metric.

---

## 5. God Object

**Rule:** No single class, module, or file may exceed the following thresholds.

| Metric | Threshold | Action |
|--------|-----------|--------|
| Lines of code | > 500 LOC | Refactor required |
| Public methods | > 20 | Split into focused classes |
| Direct dependencies (imports) | > 7 | Dependency audit |
| Cyclomatic complexity | > 15 per function | Refactor |

**Detection:** `wc -l` on new files; `grep -c "^  \(async \)\?[a-zA-Z]" class.ts` for method count.

**Compliant split strategy:**
- Extract private helpers to a `[Entity]Utils` module
- Extract domain logic to a `[Entity]Service` class
- Extract persistence to a `[Entity]Repository` class

**Source:** Martin (2008), Ch. 10 "Classes — Single Responsibility Principle"; Feathers (2004).

---

## 6. Context Drift

**Rule:** If the work in progress deviates by more than **30% from the original task scope**, Claude must stop and request explicit approval before continuing.

**Measurement:**
- Original task = N files mentioned or expected to change
- If actual changes touch > 1.3 × N files → pause

**Required halt message:**
```
SQWR HALT — Context drift detected
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Original scope: [N files]
Current scope:  [M files]
Delta:          [+X files beyond 30% threshold]

Proceed with expanded scope? [Yes / Reduce scope / Split into separate task]
```

**Source:** Shape Up (Basecamp, 2019) — fixed scope principle; DORA 2024 — unplanned work correlates with low performer tier.

---

## 7. Silent Failure

**Rule:** Errors must not be swallowed. Every `try/catch` without a re-throw, log, or user-facing error message is a silent failure.

```typescript
// BLOCKED — silent failure
try {
  await doSomething();
} catch (e) {
  // empty — error disappears
}

// REQUIRED — minimum acceptable:
try {
  await doSomething();
} catch (e) {
  logger.error('doSomething failed', { error: e, context: { ... } });
  throw e; // or return structured error response
}
```

**Reference:** `CONTRACT-ERROR-HANDLING.md` — §3 Error propagation; Google SRE Book, Ch. 4.

---

## 8. Premature Optimization

**Rule:** Performance optimization must be preceded by **profiling data showing a measurable baseline**. No optimization without evidence.

**Why:** "We should forget about small efficiencies, say about 97% of the time: premature optimization is the root of all evil." — Donald Knuth (1974).

**Exception:** Known O(n²) or worse algorithms on unbounded input may be proactively replaced with O(n log n) alternatives without profiling.

**Threshold:** If Lighthouse/profiler score is ≥90 for the relevant metric, no optimization is needed.

**Source:** Knuth (1974); `CONTRACT-PERFORMANCE.md` — measure-first principle.

---

## 9. Cargo-Cult Pattern

**Rule:** Do not copy code patterns without understanding the constraint they solve. If the constraint does not apply to the current context, the pattern must not be copied.

**Common cargo-cult patterns in AI-assisted code:**
- `useCallback`/`useMemo` on every function (not just referentially unstable ones)
- `try/catch` around synchronous code that cannot throw
- `async/await` on synchronous functions
- Index on every database column regardless of query patterns
- `z.object({}).strip()` when the schema is already validated upstream

**Test:** Can you explain *why* this pattern is needed here, not just *what* it does?

**Source:** Fowler (2018), Ch. 3 "Mysterious Name"; Martin (2008), Ch. 9.

---

## 10. Speculative Generalization

**Rule:** Do not design for hypothetical future requirements that have no current use case.

> "Do The Simplest Thing That Could Possibly Work." — Ward Cunningham.

**Signals:**
- `// Will be useful when we add multi-tenancy`
- Abstract factory for a single product family
- Plugin architecture for a product with one plugin
- Feature flags for features that do not exist yet

**Threshold:** No speculative work without a confirmed use case in the current sprint or backlog.

**Source:** Fowler (2018), Ch. 3 "Speculative Generality"; XP — YAGNI principle.

---

## Enforcement

This contract is enforced by:

| Enforcer | Trigger | What it checks |
|----------|---------|----------------|
| `hook-contract-compliance.sh` | PostToolUse (Write) | God objects (LOC > 500), console.log, any type excess |
| `hook-user-prompt.sh` | UserPromptSubmit | Anti-rationalization signals, large-scope keywords |
| `hook-permission-guard.sh` | PermissionRequest | Destructive operations requiring scope confirmation |
| `AGENT-CODE-QUALITY-AUDIT.md` | On demand | Full anti-pattern scoring in Code Quality audit |
| `skills/brainstorm/SKILL.md` | `/brainstorm` | Pre-implementation scope + reversibility + approach analysis |
| `rules/testing-rules.md` | Write (test files) | Silent failures in test assertions |

**Last validated:** 2026-03-31
