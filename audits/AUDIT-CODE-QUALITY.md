# Code Quality Audit

> Based on Robert C. Martin (Clean Code), SOLID, Google Engineering Practices, ISO/IEC 25010.
> Score: /100 | Recommended threshold: ≥75

**N/A scoring rule (ISO/IEC 25010):**
```
Score = (points obtained / applicable points) × 100
```
A criterion marked `[-]` N/A is excluded from both the numerator AND denominator.
Example: If Section 1 = N/A → score over 75 applicable points, not 100.

---

## Section 1 — TypeScript strict (25 points)

> **⚠️ Applicability**: This section is `[-] N/A` for non-TypeScript projects
> (bash scripts, documentation, pure Python, markdown kits).
> In that case, the score is calculated over 75 applicable points (Sections 2+3+4).

- [ ] `strict: true` in `tsconfig.json` ...................................... (10)
- [ ] Zero `any` errors in source code (except out-of-control cases) ......... (8)
- [ ] No `@ts-ignore` without a justifying comment ........................... (4)
- [ ] Supabase types generated and used ...................................... (3)

**Subtotal: /25** *(or N/A if non-TypeScript project)*

---

## Section 2 — Tests and coverage (30 points)

- [ ] Global coverage ≥80% ................................................... (12)
- [ ] Coverage on auth paths ≥100% ........................................... (8)
- [ ] Unit tests present for business logic .................................. (5)
- [ ] Integration tests on real DB (not mocked) .............................. (5)

**Command:** `npm run test:coverage`

**Subtotal: /30**

---

## Section 3 — Clean Code & SOLID (25 points)

- [ ] Functions ≤20 lines (except justified cases) ........................... (5)
- [ ] Cyclomatic complexity ≤10 per function ................................. (5)
- [ ] No obvious duplication (DRY respected) ................................. (5)
- [ ] Explicit naming (no `data`, `temp`, `x`, `res`) ........................ (5)
- [ ] Single Responsibility respected (no God Components) .................... (5)

**Subtotal: /25**

---

## Section 4 — Build and lint (20 points)

- [ ] `npm run build` passes without errors .................................. (8)
- [ ] `npm run lint` passes with 0 errors .................................... (7)
- [ ] No forgotten debug `console.log` ....................................... (5)

**Commands:**
```bash
npm run build
npm run lint
grep -r "console.log" src/ --include="*.ts" --include="*.tsx"
```

**Subtotal: /20**

---

## Total Score: /100

| Section | Score | /Total | N/A? |
|---------|-------|--------|------|
| TypeScript strict | | /25 | Yes if non-TS |
| Tests & coverage | | /30 | — |
| Clean Code & SOLID | | /25 | — |
| Build & lint | | /20 | — |
| **TOTAL** | | **/100** | |

**Calculation if TypeScript N/A:**
```
Score = (Section2 + Section3 + Section4) / 75 × 100
```
Example: 30/30 + 25/25 + 20/20 = 75/75 → **100/100**

**Standard calculation (TypeScript project):**
```
Score = (Section1 + Section2 + Section3 + Section4) / 100
```

---

## Google Code Review Checklist (pre-merge)

Before any merge to `main`:

- [ ] **Design**: The code is well-designed and appropriate for the system
- [ ] **Functionality**: Does what it should, good for users
- [ ] **Complexity**: As simple as possible
- [ ] **Tests**: Correct, thorough, well-designed
- [ ] **Naming**: Clear and descriptive names
- [ ] **Documentation**: README and comments updated if necessary
