# Workflow — New Feature

> SQWR Methodology: RESEARCH → CONTRACT → CODE → AUDIT
> Based on `METHODOLOGY.md` + `audits/AUDIT-INDEX.md` sequencing
> Use with: Claude Code + active contracts in `CLAUDE.md`

---

## When to use this workflow

Use this workflow for any feature that will take more than half a day to implement,
touches security, auth, database, or public-facing UI, or introduces a new architectural
dependency. For minor bug fixes or copy changes, skip to Gate 2.

---

## Estimated time investment

| Gate | Typical time | Artifact produced |
|------|-------------|-------------------|
| Gate 0 — Scope | 30–60 min | `pitches/PITCH-[feature].md` |
| Gate 1 — Research | 20–40 min | Updated `CLAUDE.md` (Active contracts) |
| Gate 2 — Implement | Variable (scoped appetite) | Working code + passing tests |
| Gate 3 — Verify | 30–60 min | Audit reports in `audits/reports/` |
| Gate 4 — Ship | 15–30 min | PR with scores + updated `CHANGELOG.md` |

---

## Gate 0 — Scope (before any code)

> Purpose: Define the problem precisely before committing to a solution.
> Framework: `frameworks/PROJECT-SCOPING.md` (Shape Up: Problem → Appetite → Solution → Rabbit Holes → No-Gos)

Steps:
- [ ] Write a Pitch using the SQWR Pitch Template (`frameworks/PROJECT-SCOPING.md` §Part 1)
- [ ] Fill all 5 Shape Up fields: Problem, Appetite, Solution (fat-marker sketch), Rabbit Holes, No-Gos
- [ ] Assign an Appetite from the SQWR table (Small: 1–3d / Medium: 4–7d / Large: 2–3w)
- [ ] If the feature does not fit in a known Appetite size, break it down into multiple Pitches
- [ ] Run the Pre-mortem (`frameworks/PROJECT-SCOPING.md` §Part 2): "What could make this fail?"
- [ ] Save the Pitch as `pitches/PITCH-[short-title].md` in the project

**Observable truth:** A file `pitches/PITCH-[feature-name].md` exists AND the Appetite field contains a specific duration (e.g., '2 weeks', '5 days') — NOT 'TBD', 'open-ended', or 'as long as it takes'.

---

## Gate 1 — Research (CONTRACT phase)

> Purpose: Identify applicable standards before writing a line of code.
> Framework: `METHODOLOGY.md` Steps 1–4 (Identify → Upstream research → Community benchmarking → Official docs)

Steps:
- [ ] Identify which contracts apply using the mapping below
- [ ] Read each applicable contract — focus on thresholds and pre-deployment checklists
- [ ] If a domain is not covered by any contract, run upstream research (`METHODOLOGY.md` §Step 2):
  - Tier 1 docs (official), then Tier 2 standards (OWASP, WCAG, NIST), then Tier 4 community
- [ ] Update the `CLAUDE.md` "Active contracts" section: list each contract with `[x]` once read
- [ ] Verify every threshold you will enforce has a Tier 1 or Tier 2 source (`METHODOLOGY.md` Rule 3)

**Contract selection guide** (quick reference):

| Feature type | Required contracts |
|---|---|
| Auth / user data | `CONTRACT-SECURITY.md` + `CONTRACT-SUPABASE.md` |
| Any UI page | `CONTRACT-ACCESSIBILITY.md` + `CONTRACT-DESIGN.md` + `CONTRACT-PERFORMANCE.md` |
| API endpoint | `CONTRACT-SECURITY.md` + `CONTRACT-OBSERVABILITY.md` + `CONTRACT-TYPESCRIPT.md` |
| AI feature | `CONTRACT-AI-PROMPTING.md` + `CONTRACT-ANTI-HALLUCINATION.md` |
| Email | `CONTRACT-EMAIL.md` |
| Deployment change | `CONTRACT-CICD.md` + `CONTRACT-VERCEL.md` |
| Database schema | `CONTRACT-SUPABASE.md` + `CONTRACT-SECURITY.md` |
| Mobile (iOS/Android) | `CONTRACT-IOS.md` or `CONTRACT-ANDROID.md` |
| PDF generation | `CONTRACT-PDF-GENERATION.md` |
| Green IT / perf | `CONTRACT-GREEN-SOFTWARE.md` + `CONTRACT-PERFORMANCE.md` |
| SEO impact | `CONTRACT-SEO.md` |
| Analytics / tracking | `CONTRACT-ANALYTICS.md` |
| i18n | `CONTRACT-I18N.md` |
| Motion / animation | `CONTRACT-MOTION-DESIGN.md` |

**Observable truth**: The `CLAUDE.md` "Active contracts" section lists at least 2 contracts relevant to this feature, each marked `[x]`. If the domain is new and no contract covers it, a research note with Tier 1-2 sources exists in the PR description or a new contract file has been created.

---

## Gate 2 — Implement (CODE phase)

> Purpose: Write code that enforces contract standards from the start, not as an afterthought.
> Tools: Active hooks in `.claude/settings.json`

Steps:
- [ ] Verify `.claude/settings.json` hooks are active: `hook-no-secrets` and `hook-build-before-commit` at minimum
- [ ] Write code following the rules of each active contract
- [ ] Keep TypeScript strict — no `any` without documented justification
- [ ] Write or update tests alongside the implementation (not after)
- [ ] Run the full build:

```bash
npm run build
```

- [ ] Run lint:

```bash
npm run lint
```

- [ ] Run tests with coverage:

```bash
npm run test -- --coverage
```

- [ ] If TypeScript project, verify types:

```bash
npx tsc --noEmit
```

- [ ] Check for forgotten debug code:

```bash
grep -r "console\.log" src/ --include="*.ts" --include="*.tsx"
```

**Observable truth**: `npm run build && npm run lint && npm run test` all exit 0. `npx tsc --noEmit` exits 0 (TypeScript projects). The `grep` for `console.log` returns no results in `src/`. For each active contract in CLAUDE.md, a reviewer has confirmed no violations exist in the added code — either via hook output (no blocking messages) or explicit comment in PR checklist.

---

## Gate 3 — Verify (AUDIT phase)

> Purpose: Validate against professional standards before shipping.
> Tools: `agents/AGENT-FULL-AUDIT.md` or targeted agents from `agents/`
> Reference: `audits/AUDIT-INDEX.md` for thresholds and sequencing

Follow the recommended sequencing from `audits/AUDIT-INDEX.md`:

**Mandatory for all features:**
- [ ] `audits/AUDIT-SECURITY.md` — threshold: **≥70/100 (hard block, no exceptions)**
- [ ] `audits/AUDIT-CODE-QUALITY.md` — threshold: ≥75/100

**Required for UI-touching features:**
- [ ] `audits/AUDIT-PERFORMANCE.md` — threshold: ≥70/100 (LCP ≤2.5s, CLS <0.1)
- [ ] `audits/AUDIT-ACCESSIBILITY.md` — threshold: **≥80/100 (EAA legal requirement, EU)**
- [ ] `audits/AUDIT-DESIGN.md` — threshold: ≥70/100

**Required for features with monitoring/infra impact:**
- [ ] `audits/AUDIT-OBSERVABILITY.md` — threshold: ≥60/100

**Required for features with AI/LLM components:**
- [ ] `audits/AUDIT-AI-GOVERNANCE.md` — threshold: ≥80/100

**Required if EU personal data is processed:**
- [ ] `audits/AUDIT-RGPD.md` — threshold: **≥80/100 (CNIL/ICO risk below this)**

Score interpretation (from `audits/AUDIT-INDEX.md`):

| Score | Status | Action |
|-------|--------|--------|
| <50 | Critical | Block deployment |
| 50–69 | Insufficient | Fix before merge |
| 70–84 | Acceptable | Deploy with improvement plan |
| ≥85 | Good | Deploy |
| ≥95 | Excellent | Deploy + document as reference |

**Observable truth:** Audit report file exists at `audits/reports/YYYY-MM-DD-[feature-name].md` with all applicable domain scores documented, OR each domain score is explicitly listed in the PR description in this format: `SECURITY: 78/100 ✓ | CODE-QUALITY: 82/100 ✓ | ACCESSIBILITY: 85/100 ✓`.

---

## Gate 4 — Ship

> Purpose: Clean, traceable delivery with audit scores visible to the team.

Steps:
- [ ] Complete `audits/AUDIT-DEPLOYMENT.md` checklist (all blocking items checked)
- [ ] Verify no secrets in the diff:

```bash
git diff main...HEAD | grep -E "(KEY|SECRET|PASSWORD|TOKEN)"
```

- [ ] Update `CHANGELOG.md` with the new entry (semantic version + today's date + summary of changes)
- [ ] Write the PR description including:
  - Summary of the feature
  - Contracts used
  - Audit scores (at minimum: SECURITY, CODE-QUALITY, and any UI audits run)
  - Any known limitations or follow-up tasks
- [ ] If EU users are targeted: confirm ACCESSIBILITY ≥80/100 (European Accessibility Act, mandatory June 2025)
- [ ] If GDPR data processed: confirm GDPR ≥80/100

**Observable truth**: A PR exists with audit scores listed in the description. `CHANGELOG.md` has a new entry dated today with a semantic version tag. CI passes. `audits/AUDIT-DEPLOYMENT.md` has no unchecked blocking items.
