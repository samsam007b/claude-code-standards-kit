---
name: "Anti-Patterns Audit"
domain: "Code Quality / AI Governance"
version: "1.0.0"
last_validated: "2026-03-31"
contract: "CONTRACT-ANTI-PATTERNS.md"
---

# Audit: Anti-Patterns

> Evaluate the codebase for the 10 AI coding anti-patterns defined in `CONTRACT-ANTI-PATTERNS.md`. Run before any major merge or delivery.

**Threshold:** Score ≥80/100 before merging to main. Blocking items (marked 🔴) must be resolved first.

---

## Scoring

Score = (points obtained / applicable points) × 100

| Range | Meaning | Action |
|-------|---------|--------|
| 90–100 | Excellent | Merge |
| 80–89 | Good | Merge with minor fixes |
| 70–79 | Acceptable | Fix blocking items before merge |
| < 70 | Insufficient | Do not merge |

---

## Section 1 — Premature Abstraction (20 pts)

```
[ ] No new abstract classes/interfaces with < 3 consumers .............. (10)
[ ] No utility modules created for a single call site .................. (5)
[ ] All abstractions have documented motivation ......................... (5)
```

**Check:**
```bash
# Find abstract classes — count implementing classes
grep -r "abstract class\|implements " --include="*.ts" -l

# Find utility files — count imports
grep -r "from.*utils\|from.*helpers" --include="*.ts" | awk -F'"' '{print $2}' | sort | uniq -c | sort -rn
```

**Score: __ / 20**

---

## Section 2 — God Objects (20 pts)

```
[ ] No file exceeds 500 LOC .............................................. (10)
[ ] No class exceeds 20 public methods ................................... (5)
[ ] No module has > 7 direct dependencies ................................ (5)
```

**Check:**
```bash
# Files over 500 lines
find src -name "*.ts" -o -name "*.tsx" | xargs wc -l | awk '$1 > 500 {print}' | sort -rn

# Classes with many methods (approximate)
grep -rn "^\s*\(async \)\?[a-zA-Z].*(" --include="*.ts" | grep -v "//\|import\|export" | awk -F: '{print $1}' | uniq -c | awk '$1 > 20'
```

**Score: __ / 20**

---

## Section 3 — Silent Failures (20 pts)

```
[ ] No empty catch blocks ................................................ (10)
[ ] All errors are logged or re-thrown ................................... (7)
[ ] User-facing errors have messages suitable for display ................ (3)
```

**Check:**
```bash
# Empty catch blocks
grep -rn "catch\s*(.*)\s*{$" --include="*.ts" --include="*.tsx" -A 2 | grep -B 2 "^--\|^}$"

# Catch blocks without throw/log (approximate)
grep -rn "} catch" --include="*.ts" -A 3 | grep -v "logger\|console\|throw\|return\|next("
```

**Score: __ / 20**

---

## Section 4 — Context Drift & Scope (20 pts)

```
[ ] PR diff touches only files related to stated task ................... (10)
[ ] No unrelated refactors bundled with feature changes .................. (5)
[ ] PR description matches actual scope of changes ...................... (5)
```

**Check (manual):**
- Count files changed in PR: `git diff --name-only main...HEAD | wc -l`
- Compare to expected scope from PR description
- Flag if actual count > 1.3 × expected count

**Score: __ / 20**

---

## Section 5 — Speculative Generalization & Over-Engineering (20 pts)

```
[ ] No Strategy pattern with a single strategy .......................... (5)
[ ] No plugin architecture for a single plugin .......................... (5)
[ ] No generic <T> used where T is always the same type ................. (5)
[ ] No config abstraction for single-environment deployment ............. (5)
```

**Check:**
```bash
# Generic types that are never varied
grep -rn "<T>" --include="*.ts" | grep -v "Array\|Promise\|Record\|Map\|Set\|Optional"

# Strategy pattern usage
grep -rn "interface.*Strategy\|abstract.*Strategy" --include="*.ts"
```

**Score: __ / 20**

---

## Global Score

| Section | Weight | Score | Weighted |
|---------|--------|-------|---------|
| Premature Abstraction | 20% | __ /20 | __ |
| God Objects | 20% | __ /20 | __ |
| Silent Failures | 20% | __ /20 | __ |
| Context Drift | 20% | __ /20 | __ |
| Speculative Generalization | 20% | __ /20 | __ |
| **Total** | 100% | | **__ /100** |

---

## Blocking items

Items that must reach score 10/10 (fully compliant) before merging:

- 🔴 **Empty catch blocks** (Section 3, item 1)
- 🔴 **Files > 500 LOC** (Section 2, item 1)
- 🔴 **PR scope drift > 30%** (Section 4, item 1)

---

## Recommended remediation

| Issue | Remediation |
|-------|-------------|
| File > 500 LOC | Extract to `[Entity]Service` + `[Entity]Repository` pattern |
| Empty catch | Add `logger.error(...)` minimum + re-throw or error response |
| God class > 20 methods | Apply Single Responsibility Principle — split by concern |
| Scope drift | Split into separate PRs by concern |
| Speculative abstraction | Remove — reintroduce when 3rd consumer exists |

**Last validated:** 2026-03-31
