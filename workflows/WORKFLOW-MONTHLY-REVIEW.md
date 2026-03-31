# Workflow — Monthly Review

> Monthly maintenance audit cycle to prevent quality drift over time.
> Based on: `audits/AUDIT-INDEX.md` (all 8 domains) + `frameworks/DEPENDENCY-MANAGEMENT.md`
> Run on: the 1st of each month, or before any major release

---

## When to run this workflow

- The 1st of each month (standing recurring task)
- Before any major version release (vX.0.0)
- After a production incident is resolved (post-incident review)
- When onboarding a new collaborator (establish baseline scores)

**Estimated time investment: 2–4 hours for a full cycle.**

---

## Monthly audit score tracker

Copy this table into your monthly report at the end of the review.

| Domain | Weight | Last month | This month | Delta | Status |
|--------|--------|-----------|------------|-------|--------|
| SECURITY | 22% | — | — | — | — |
| PERFORMANCE | 18% | — | — | — | — |
| CODE-QUALITY | 18% | — | — | — | — |
| OBSERVABILITY | 12% | — | — | — | — |
| ACCESSIBILITY | 12% | — | — | — | — |
| DESIGN | 8% | — | — | — | — |
| AI-GOVERNANCE | 5% | — | — | — | — |
| DEPLOYMENT | 5% | — | — | — | — |
| **GLOBAL** | 100% | — | — | — | — |
| GDPR (contextual) | — | — | — | — | — |

---

## Phase 1 — Full audit sequence

> Follow the recommended sequencing from `audits/AUDIT-INDEX.md` §Recommended sequencing.
> Do not skip or reorder — later audits build on findings from earlier ones.

### 1.1 — Security audit (22% weight — run first)

- [ ] Run `audits/AUDIT-SECURITY.md` completely — record score
- [ ] Any score <70: **stop — fix before continuing** (hard block, no exceptions)
- [ ] Review all OWASP Top 10 items for changes since last month

**Observable truth**: `AUDIT-SECURITY.md` score ≥70 documented with date. If <70, a remediation plan with a completion date exists.

---

### 1.2 — Observability audit (12% weight)

- [ ] Run `audits/AUDIT-OBSERVABILITY.md` — record score
- [ ] Verify all alerting rules are still configured and firing correctly
- [ ] Check that no monitoring gap was introduced during the month's deployments

**Observable truth**: `AUDIT-OBSERVABILITY.md` score ≥60. A test alert was triggered and received during this review cycle.

---

### 1.3 — Performance audit (18% weight)

- [ ] Run `audits/AUDIT-PERFORMANCE.md` — record score
- [ ] Run Lighthouse on homepage and top 3 most-visited pages:

```bash
npx lighthouse https://your-domain.com --output json --quiet
```

- [ ] Record LCP, CLS, FID/INP for each page
- [ ] Compare against last month's baseline — flag any regression >10%

**Observable truth**: `AUDIT-PERFORMANCE.md` score ≥70. LCP ≤2.5s and CLS <0.1 on all tracked pages, or a regression ticket exists. Lighthouse scores documented for at least 3 pages.

---

### 1.4 — Code quality audit (18% weight)

- [ ] Run `audits/AUDIT-CODE-QUALITY.md` — record score
- [ ] Run tests and record coverage:

```bash
npm run test -- --coverage
```

- [ ] Run TypeScript check:

```bash
npx tsc --noEmit
```

- [ ] Count `any` types introduced since last month:

```bash
grep -r ": any" src/ --include="*.ts" --include="*.tsx" | wc -l
```

- [ ] Flag if `any` count increased by more than 5 since last month

**Observable truth**: `AUDIT-CODE-QUALITY.md` score ≥75. `npm run test` exits 0. `npx tsc --noEmit` exits 0. Test coverage has not dropped more than 5 percentage points from last month's baseline.

---

### 1.5 — Accessibility audit (12% weight)

- [ ] Run `audits/AUDIT-ACCESSIBILITY.md` — record score
- [ ] Re-run axe or Lighthouse Accessibility on all pages modified this month
- [ ] **If EU users are targeted: score ≥80 is a legal requirement (EAA, June 2025)**
- [ ] Verify contrast ratios on any new color or typography changes

**Observable truth**: `AUDIT-ACCESSIBILITY.md` score documented. Score ≥80 if EU users are served. No new WCAG 2.1 AA violations introduced this month.

---

### 1.6 — Design audit (8% weight)

- [ ] Run `audits/AUDIT-DESIGN.md` — record score
- [ ] Verify design token consistency: no one-off values introduced this month
- [ ] Check that all new UI components follow the spacing and typography system

**Observable truth**: `AUDIT-DESIGN.md` score ≥70. No undocumented design token deviations in the current codebase.

---

### 1.7 — AI Governance audit (5% weight)

- [ ] Run `audits/AUDIT-AI-GOVERNANCE.md` — record score
- [ ] Verify `CLAUDE.md` is still accurate and up to date (stack, contracts, SLOs)
- [ ] Check that all AI-generated content in production is labelled if required by EU AI Act

**Observable truth**: `AUDIT-AI-GOVERNANCE.md` score ≥80. `CLAUDE.md` last-modified date is within the last 30 days (or unchanged intentionally).

---

### 1.8 — Deployment audit (5% weight)

- [ ] Run `audits/AUDIT-DEPLOYMENT.md` — confirm all blocking items are still passing
- [ ] Verify `CHANGELOG.md` is up to date for all changes made this month

**Observable truth**: `audits/AUDIT-DEPLOYMENT.md` has zero unchecked blocking items. `CHANGELOG.md` has entries for all production deployments made during the month.

---

## Phase 2 — Dependency security review

> Reference: `frameworks/DEPENDENCY-MANAGEMENT.md`

- [ ] Run full npm audit:

```bash
npm audit
```

- [ ] List all High and Critical vulnerabilities:

```bash
npm audit --audit-level=high --json | jq '.vulnerabilities | to_entries[] | select(.value.severity == "high" or .value.severity == "critical") | .key'
```

- [ ] For each High/Critical: create a fix ticket with a deadline (High: 30 days, Critical: 7 days)
- [ ] Review outdated packages:

```bash
npm outdated
```

- [ ] Update packages that have had security advisories since last month
- [ ] Review any pending Dependabot PRs — merge or dismiss with documented reason

**Observable truth**: `npm audit --audit-level=critical` exits 0. All Critical CVEs have a fix ticket with a deadline ≤7 days. All High CVEs have a fix ticket with a deadline ≤30 days.

---

## Phase 3 — Contract freshness check

> Contracts go stale when the underlying technology releases new versions.
> A contract that references outdated version-specific rules creates false confidence.

- [ ] Check the current versions of your main stack dependencies:

```bash
cat package.json | grep -E '"(next|react|supabase|typescript)"'
```

- [ ] For each active contract in `CLAUDE.md`, verify the contract's referenced version matches the installed version
- [ ] If a major version gap exists (e.g., contract references Next.js 13, project is on Next.js 15): flag the contract for update
- [ ] Update the contract or create a ticket to update it within 30 days

**Observable truth**: All active contracts reference the correct major version of the technology they govern. Any stale contract has a ticket with a deadline of ≤30 days.

---

## Phase 4 — Tech debt review

> Reference: `CLAUDE.md` Tech Debt Tracker section

- [ ] Open the Tech Debt Tracker in `CLAUDE.md`
- [ ] Review each open debt item: is it still relevant? Has complexity grown?
- [ ] Prioritise items that have been open for more than 90 days
- [ ] Assign at least 1 debt item to the upcoming sprint (no debt-free sprints policy)
- [ ] Close items that have been resolved during the month

**Observable truth**: The Tech Debt Tracker in `CLAUDE.md` has a "Last reviewed" date updated to today. At least 1 item is assigned to the upcoming sprint. Items older than 90 days are either in-progress or have a documented deferral reason.

---

## Phase 5 — SLO review

> Reference: `frameworks/SLO-TEMPLATE.md` + `CLAUDE.md` SLO section

- [ ] Pull uptime and error rate data for the past 30 days from your monitoring platform
- [ ] Compare against the SLOs defined in `CLAUDE.md`:
  - Availability target (e.g., ≥99.5%)
  - Error rate target (e.g., <0.5% of requests)
  - P95 latency target (e.g., ≤500ms)
- [ ] Calculate error budget burn rate: `(1 - actual_uptime) / (1 - slo_target)`
- [ ] If burn rate >1: SLO was missed — open a reliability review

```
Error budget remaining = 1 - (downtime_minutes / (30 * 24 * 60 * (1 - slo_target)))
```

- [ ] If reliability has degraded: review `frameworks/INCIDENT-RESPONSE.md` for corrective actions

**Observable truth**: SLO metrics for the past 30 days are documented in the monthly report. If any SLO was missed, a root cause analysis exists. Error budget burn rate is calculated and on record.

---

## Phase 6 — ADR review

> Reference: `frameworks/ADR-TEMPLATE.md`

- [ ] List all ADRs in `adrs/` directory
- [ ] For each ADR with status "Accepted": ask whether the context has changed since the decision was made
- [ ] For any ADR that is no longer valid: update its status to "Superseded" and write a new ADR
- [ ] Check whether any architectural choices made this month should be formalised as a new ADR

**Observable truth**: All ADRs have a status that reflects current reality (Proposed / Accepted / Deprecated / Superseded). Any architectural decision made this month that would be hard to reverse is documented in a new ADR file.

---

## Phase 7 — Monthly report

Fill this template and save as `audits/reports/MONTHLY-REVIEW-[YYYY-MM].md`:

```markdown
# Monthly Review — [Month YYYY]

**Date:** [DD/MM/YYYY]
**Reviewer:** [Name]
**Kit version:** [e.g., v2.1]

## Global score

| Domain | Score | Delta | Status |
|--------|-------|-------|--------|
| SECURITY (22%) | /100 | +/- | |
| PERFORMANCE (18%) | /100 | +/- | |
| CODE-QUALITY (18%) | /100 | +/- | |
| OBSERVABILITY (12%) | /100 | +/- | |
| ACCESSIBILITY (12%) | /100 | +/- | |
| DESIGN (8%) | /100 | +/- | |
| AI-GOVERNANCE (5%) | /100 | +/- | |
| DEPLOYMENT (5%) | /100 | +/- | |
| **GLOBAL WEIGHTED** | **/100** | **+/-** | |

## Key findings

- [Finding 1]
- [Finding 2]

## Actions this month

| Action | Owner | Deadline | Priority |
|--------|-------|----------|----------|
| | | | |

## Tech debt items assigned to next sprint

- [ ] [Debt item]

## SLO summary

- Availability: [X]% (target: [Y]%)
- Error rate: [X]% (target: <[Y]%)
- P95 latency: [X]ms (target: ≤[Y]ms)
- Error budget remaining: [X]%
```

**Observable truth**: The file `audits/reports/MONTHLY-REVIEW-[YYYY-MM].md` exists, is complete, and the global weighted score is calculated. The report is committed to the repository.

---

## Actions when global score drops below 85

A global score below 85 indicates quality drift requiring immediate attention.

| Trigger | Action |
|---|---|
| Global score 80–84 | Create improvement plan — address lowest domain this sprint |
| Global score 70–79 | Freeze new features until global score returns to ≥80 |
| Global score <70 | Engineering halt on new features — full remediation sprint |
| SECURITY <70 (any month) | Immediate remediation — do not wait for month end |
| ACCESSIBILITY <80 (EU product) | Immediate remediation — legal obligation (EAA) |
| GDPR <80 (EU personal data) | Immediate remediation — CNIL/ICO risk |

**The feature freeze rule**: if the global score drops below 75, no new feature work begins until the score is back above 80. Quality gates exist to prevent compounding debt, not to slow progress — they accelerate it in the long run.
