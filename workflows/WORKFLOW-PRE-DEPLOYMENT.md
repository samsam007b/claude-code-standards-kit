# Workflow — Pre-Deployment Gate

> Every production deployment, regardless of size, must pass this gate.
> Source: `audits/AUDIT-DEPLOYMENT.md` + `audits/AUDIT-INDEX.md` sequencing
> Reference thresholds: `audits/AUDIT-INDEX.md` §Blocking thresholds

---

## When to use this workflow

Run this workflow before **any** push to production — new features, hotfixes, dependency upgrades,
and configuration changes alike. The Quick Gate is sufficient for isolated hotfixes with no
UI or auth impact. Use the Full Gate for first deployments, minor/major version bumps,
and any change touching auth, database schema, or public-facing pages.

---

## Gate selection guide

| Deploy type | Gate to use | Estimated time |
|---|---|---|
| Hotfix (isolated, no UI, no auth) | Quick Gate | <30 min |
| Feature merge (already audited) | Quick Gate + deployment checklist | <30 min |
| First deployment of a project | Full Gate | 2–4 hours |
| Minor release (new features accumulated) | Full Gate | 1–2 hours |
| Major release / breaking changes | Full Gate + EU checklist | 2–4 hours |
| Dependency security patch only | Quick Gate (security scan only) | <20 min |

---

## Quick Gate (< 30 min)

> For hotfixes and previously-audited feature merges.

**Blocking checks — must all pass before deploying:**

- [ ] `npm run build` exits 0
- [ ] `npm run lint` exits 0 (0 ESLint errors)
- [ ] `npm audit --audit-level=critical` exits 0
- [ ] No `console.log` in `src/`:

```bash
grep -r "console\.log" src/ --include="*.ts" --include="*.tsx"
```

- [ ] No secrets in the diff:

```bash
git diff main...HEAD | grep -E "(KEY|SECRET|PASSWORD|TOKEN|PRIVATE)"
```

- [ ] `.env.local` not committed:

```bash
git status | grep "\.env"
```

- [ ] Environment variables present in deployment platform (Vercel dashboard or equivalent)

**Observable truth**: All 7 commands above return exit code 0 or no results. Any failure blocks deployment — no exceptions.

---

## Database Migration Gate (5 min)

> Run before deploying any PR that includes migration files.

**Checklist:**
- [ ] All migration files have been tested in the staging environment
- [ ] Rollback scripts have been executed in staging (verify they work)
- [ ] `supabase db diff` output is empty in staging (no pending schema drift)
- [ ] For tables >1M rows: batching strategy confirmed
- [ ] RLS policies for new tables verified with at least 2 test users

**Observable truth:** `supabase db diff --use-migra` returns no output in staging environment, OR all schema changes are explicitly documented in CHANGELOG.md with rollback instructions.

---

## Feature Flag Gate (2 min)

> Run before deploying any feature that changes >10% of user-facing surface.

**Checklist:**
- [ ] New feature is behind a feature flag (LaunchDarkly, Unleash, or env-var toggle)
- [ ] Flag is OFF by default in production
- [ ] Rollout plan documented (% users, timeline, kill switch)
- [ ] OR: PR explicitly confirms no rollout risk (e.g., internal tool, non-user-facing)

**Observable truth:** Feature flag configuration exists in the environment config OR PR description explicitly states "no feature flag needed because [reason]" and this is approved by reviewer.

---

## Smoke Test Gate (10 min)

> Run immediately after deployment, before declaring deploy successful.

**Checklist:**
- [ ] Authentication flow works (signup, login, logout)
- [ ] Core user journey completes without error (depends on app — define in project CLAUDE.md)
- [ ] No critical errors in Sentry in first 5 minutes post-deploy
- [ ] Health check endpoint returns 200

**Observable truth:** `npm run test:e2e -- --project=smoke` exits 0, OR manual smoke checklist above is completed and documented in deployment log.

---

## Full Gate (first deploy / major release)

> Run audits in the sequence defined by `audits/AUDIT-INDEX.md` §Recommended sequencing.

### Step 1 — Security (blocking — run first)

- [ ] Run `audits/AUDIT-SECURITY.md` — **score must be ≥70, no exceptions**
- [ ] Run `npm audit` — no open High or Critical vulnerabilities:

```bash
npm audit --audit-level=high
```

- [ ] Review Dependabot alerts: no pending P0/P1 vulnerabilities unaddressed
- [ ] Confirm RLS (Row Level Security) is enabled on all Supabase tables containing user data

**Observable truth**: `AUDIT-SECURITY.md` score ≥70 documented. `npm audit --audit-level=high` exits 0. If Supabase is used, RLS verification is logged.

---

### Step 2 — Observability (monitoring before going further)

- [ ] Run `audits/AUDIT-OBSERVABILITY.md` — score ≥60 recommended
- [ ] Verify error tracking (Sentry or equivalent) is active in production environment
- [ ] Verify at least one uptime alert is configured
- [ ] Confirm structured logging is in place for critical user paths

**Observable truth**: `AUDIT-OBSERVABILITY.md` score ≥60. Error tracking service reports a successful test event from the production environment.

---

### Step 3 — Performance

- [ ] Run `audits/AUDIT-PERFORMANCE.md` — score ≥70 recommended
- [ ] LCP ≤2.5s on all critical pages (PageSpeed Insights or Lighthouse CI)
- [ ] CLS <0.1 on all critical pages
- [ ] Lighthouse Performance ≥85 on homepage and primary conversion page

```bash
# Run Lighthouse CI if configured
npx lhci autorun
```

**Observable truth**: `AUDIT-PERFORMANCE.md` score ≥70. Lighthouse Performance ≥85 documented for at least the homepage. LCP and CLS values are on record.

---

### Step 4 — Code Quality

- [ ] Run `audits/AUDIT-CODE-QUALITY.md` — score ≥75 recommended
- [ ] TypeScript strict — `npx tsc --noEmit` exits 0
- [ ] Tests pass with no regression in coverage:

```bash
npm run test -- --coverage
```

- [ ] No `any` types introduced without documented justification
- [ ] No dead code or unused imports in changed files

**Observable truth**: `AUDIT-CODE-QUALITY.md` score ≥75. `npm run test` exits 0. `npx tsc --noEmit` exits 0. Coverage report does not show a regression compared to the previous baseline.

---

### Step 5 — Accessibility (EU legal obligation)

- [ ] Run `audits/AUDIT-ACCESSIBILITY.md` — **score ≥80 if EU users are targeted (EAA, June 2025)**
- [ ] Lighthouse Accessibility ≥90 on all new/modified pages
- [ ] All images have meaningful `alt` attributes
- [ ] All interactive elements are keyboard-reachable
- [ ] Color contrast ≥4.5:1 on all text (W3C WCAG 2.1 SC 1.4.3)

**Observable truth**: `AUDIT-ACCESSIBILITY.md` score documented. If the project targets EU users: score ≥80. Lighthouse Accessibility ≥90 on all pages modified by this release.

---

### Step 6 — Design

- [ ] Run `audits/AUDIT-DESIGN.md` if new UI components were introduced — score ≥70 recommended
- [ ] Visual regression check: no unintended layout breaks on mobile and desktop
- [ ] New components follow the design system (tokens, spacing, typography)

**Observable truth**: `AUDIT-DESIGN.md` score ≥70 (if run). Manual visual QA sign-off documented in the PR.

---

### Step 7 — Deployment checklist

- [ ] Complete all blocking items in `audits/AUDIT-DEPLOYMENT.md`
- [ ] `CHANGELOG.md` updated with semantic version, date, and list of changes
- [ ] PR description includes audit scores for all domains run
- [ ] Rollback plan is documented (see Rollback Triggers below)

**Observable truth**: `audits/AUDIT-DEPLOYMENT.md` has zero unchecked blocking items. `CHANGELOG.md` has a new entry. PR description contains audit scores.

---

## EU Compliance Checklist

> Required for any project processing personal data of EU residents or serving EU users.
> Reference: `frameworks/COMPLIANCE-EU.md`

**GDPR:**
- [ ] Run `audits/AUDIT-RGPD.md` — **score ≥80 before any production launch** (CNIL/ICO risk)
- [ ] Privacy policy is up to date and accessible from every page
- [ ] Cookie consent is functional and respects user choice
- [ ] Data retention periods are defined and enforced
- [ ] DPA (Data Processing Agreement) in place with all sub-processors

**European Accessibility Act (EAA — mandatory from June 2025):**
- [ ] `AUDIT-ACCESSIBILITY.md` score ≥80
- [ ] Accessibility statement published on the site
- [ ] Feedback mechanism for accessibility issues in place

**EU AI Act (if AI features are exposed to end users):**
- [ ] `audits/AUDIT-AI-GOVERNANCE.md` score ≥80
- [ ] AI-generated content is labelled where legally required
- [ ] Human oversight mechanism is documented

**Observable truth**: `AUDIT-RGPD.md` score ≥80 on file. `AUDIT-ACCESSIBILITY.md` score ≥80 on file. Both scores are referenced in the PR description.

---

## Post-deployment checks (within 30 minutes of deploy)

Run these immediately after each production deployment:

- [ ] Homepage loads correctly (manual check)
- [ ] Primary user flow works end-to-end (e.g., login → core action → logout)
- [ ] Contact form or primary CTA works (real test, not staging)
- [ ] Vercel (or hosting platform) logs: no 500 errors in the first 10 minutes
- [ ] Error tracking dashboard: no new error spike compared to pre-deploy baseline
- [ ] Google Search Console: no new critical crawl errors (check 24h after deploy)

**Observable truth**: All 5 live checks pass within 30 minutes of deploy. No 500 error spike in platform logs. Error tracking shows no regression.

---

## Rollback triggers — revert immediately if any of these occur

| Trigger | Threshold | Action |
|---|---|---|
| 500 error rate | >1% of requests in any 5-min window | Immediate rollback |
| Auth failure | Any user unable to log in | Immediate rollback |
| Data loss or corruption | Any confirmed report | Immediate rollback + incident |
| Core Web Vitals regression | LCP >4s or CLS >0.25 | Rollback within 2h |
| Security vulnerability disclosed | Critical CVSS ≥9.0 | Rollback + patch within 24h |
| Payment failure | Any confirmed transaction failure | Immediate rollback |

**Rollback command (Vercel):**
```bash
vercel rollback [deployment-url]
```

**If rolling back, open an incident using `frameworks/INCIDENT-RESPONSE.md` immediately.**

---

## Blocker override log

If a blocking item is skipped with documented justification:

| Date | Item overridden | Justification | Owner | Remediation deadline |
|------|----------------|---------------|-------|----------------------|
| [DD/MM/YYYY] | [item] | [reason] | [name] | [date] |
