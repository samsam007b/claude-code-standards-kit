# Audit Index — SQWR Project Kit

> Audit system inspired by the SQWR Starter Kit (Writing-Skills/INDEX.md).
> Principle: every rule is verifiable, every score is measurable.
> Format: weighted checklist → score /100 per domain → global score.

---

## When to use which audit

| Situation | Audits to run |
|-----------|----------------|
| **Before first deployment** | DEPLOYMENT + SECURITY + PERFORMANCE + ACCESSIBILITY + OBSERVABILITY |
| **Before merging a feature** | CODE-QUALITY + SECURITY (if auth/DB) + DEPLOYMENT |
| **Monthly maintenance review** | all audits |
| **Security emergency** | SECURITY alone, highest priority |
| **Production incident** | OBSERVABILITY + RESILIENCE (post-incident) |
| **Design overhaul** | DESIGN + ACCESSIBILITY + PERFORMANCE |
| **Adding an AI agent** | AI-GOVERNANCE + ANTI-HALLUCINATION (contract) |
| **New project launched** | AI-GOVERNANCE + CODE-QUALITY + DESIGN |
| **Client delivery (EU)** | ACCESSIBILITY (EAA mandatory) + SECURITY + DEPLOYMENT + GDPR |
| **Before client delivery** | CLIENT-HANDOFF (→ frameworks/) + DEPLOYMENT + ACCESSIBILITY + SECURITY + GDPR |
| **End of sprint / release** | DEPLOYMENT (CHANGELOG updated?) + CODE-QUALITY |
| **Before product/brand launch** | BRAND-STRATEGY + COMPETITIVE-AUDIT (→ frameworks/) |
| **Repositioning or rebranding** | BRAND-STRATEGY alone |
| **EU general public (personal data)** | GDPR ≥80/100 mandatory before production |

---

## Blocking thresholds

| Score | Meaning | Action |
|-------|---------|--------|
| <50 | Critical | ❌ Block deployment |
| 50-69 | Insufficient | ⚠️ Fix before merge |
| 70-84 | Acceptable | Deployment possible, improvement plan required |
| 85-94 | Good | Deploy |
| 95-100 | Excellent | Deploy + document as reference |

**SECURITY Score <70 = absolute block — no exceptions.**

---

## Scores by domain (global weighting — v2)

| Audit | Weight | File | Blocking threshold |
|-------|--------|------|--------------------|
| **SECURITY** | 22% | `AUDIT-SECURITY.md` | <70 = BLOCKING |
| **PERFORMANCE** | 18% | `AUDIT-PERFORMANCE.md` | <70 recommended |
| **CODE-QUALITY** | 18% | `AUDIT-CODE-QUALITY.md` | <75 recommended |
| **OBSERVABILITY** | 12% | `AUDIT-OBSERVABILITY.md` | <60 recommended |
| **ACCESSIBILITY** | 12% | `AUDIT-ACCESSIBILITY.md` | <80 (EU legal) |
| **DESIGN** | 8% | `AUDIT-DESIGN.md` | <70 recommended |
| **AI-GOVERNANCE** | 5% | `AUDIT-AI-GOVERNANCE.md` | <80 recommended |
| **DEPLOYMENT** | 5% | `AUDIT-DEPLOYMENT.md` | Pre-prod gate |
| **GDPR** | — | `AUDIT-RGPD.md` | ≥80/100 before general public prod |
| **BRAND-STRATEGY** | — | `AUDIT-BRAND-STRATEGY.md` | Before launch / repositioning |

**Global score = weighted sum of the 8 weighted domains.**
**GDPR and BRAND-STRATEGY are out-of-weighting audits — mandatory depending on context.**

**ACCESSIBILITY <80 = non-compliant with European Accessibility Act (June 2025) — legal obligation.**
**GDPR <80 = CNIL / ICO risk if processing personal data of EU residents.**

---

## Score format per audit

Each audit uses this format:

```
[ ] Item to check ........................... (points)
[x] Validated item .......................... ✅ (points)
[-] Not applicable .......................... N/A
```

Score = (points obtained / applicable points) × 100

---

## Recommended sequencing

```
Audit SECURITY          → highest priority
       ↓
Audit OBSERVABILITY     → monitoring in place before going further
       ↓
Audit PERFORMANCE       → Core Web Vitals
       ↓
Audit CODE-QUALITY      → TypeScript, tests, coverage
       ↓
Audit ACCESSIBILITY     → WCAG + EAA legal
       ↓
Audit DESIGN            → colors, typography, Gestalt
       ↓
Audit AI-GOVERNANCE     → CLAUDE.md, contracts, hallucinations
       ↓
Audit DEPLOYMENT        → final gate before prod
```

---

## Auditing the Project Kit itself

To audit the quality of the SQWR kit:

1. `bash scripts/verify-kit.sh --verbose` — automatic integrity check (0 errors = prerequisite)
2. `AUDIT-AI-GOVERNANCE.md` — CLAUDE.md templates complete?
3. `AUDIT-CODE-QUALITY.md` — TypeScript/Testing contracts correct?
4. `AUDIT-DESIGN.md` — Design contract scientifically grounded?
5. Verify that each contract cites its sources

**Target score for the Project Kit (2026 reference): ≥92/100**

---

## Available frameworks (outside audits — complementary tools)

| Framework | File | Usage |
|-----------|------|-------|
| **Incident Response** | `frameworks/INCIDENT-RESPONSE.md` | When a service breaks in prod |
| **ADR Template** | `frameworks/ADR-TEMPLATE.md` | Documenting architectural decisions |
| **SLO Template** | `frameworks/SLO-TEMPLATE.md` | Defining reliability objectives |
| **EU Compliance** | `frameworks/COMPLIANCE-EU.md` | EU AI Act, EAA, GDPR, NIS2 |
| **Project Scoping** | `frameworks/PROJECT-SCOPING.md` | Before any new feature or project (Shape Up + Pre-mortem) |
| **Client Handoff** | `frameworks/CLIENT-HANDOFF.md` | Final delivery to a client (5 categories + SLA) |
| **Estimation** | `frameworks/ESTIMATION.md` | Before committing to a deadline (PERT + RCF + ×1.5 rule) |
| **Dependency Management** | `frameworks/DEPENDENCY-MANAGEMENT.md` | Project setup + monthly security dependency review |
| **Brand Strategy** | `frameworks/BRAND-STRATEGY.md` | Positioning, Golden Circle, archetypes — before any design |
| **Competitive Audit** | `frameworks/COMPETITIVE-AUDIT.md` | Blue Ocean + Nielsen competitive analysis before launch |
| **Campaign Strategy** | `frameworks/CAMPAIGN-STRATEGY.md` | SEE-THINK-DO-CARE, funnel, KPIs — for any launch |
