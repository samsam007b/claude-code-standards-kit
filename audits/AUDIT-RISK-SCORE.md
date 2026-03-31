# AUDIT-RISK-SCORE — Composite Risk Score Audit

**Weights verified**: 2026-03-31 | **Based on**: SQWR weighted formula v3.1

## Purpose

This audit computes the composite SQWR Risk Score — a single 0-100 indicator of overall project health. It uses a weighted formula across all 8 audit domains, with Security and Performance receiving the highest weights reflecting their criticality.

## Weighted Formula

```
Risk Score = (Security × 0.22) + (Performance × 0.18) + (Code Quality × 0.18)
           + (Observability × 0.12) + (Accessibility × 0.12) + (Design × 0.08)
           + (AI Governance × 0.05) + (Deployment × 0.05)
```

**Weight verification**: 0.22 + 0.18 + 0.18 + 0.12 + 0.12 + 0.08 + 0.05 + 0.05 = **1.00** ✓

## Weight Rationale

| Domain | Weight | Rationale |
|--------|--------|-----------|
| Security | 22% | Highest weight: security failures are catastrophic, irreversible, and have legal consequences (GDPR, OWASP) |
| Performance | 18% | Core Web Vitals directly impact business metrics (Google ranking, conversion, user retention) |
| Code Quality | 18% | Technical debt is cumulative — poor quality compounds into security and performance issues |
| Observability | 12% | Production issues require observability to detect and resolve (SRE Golden Signals) |
| Accessibility | 12% | Legal requirement (EAA enforceable June 2025) + reaches widest possible audience |
| Design | 8% | UX quality impacts adoption and user trust; lower weight as less objectively measurable |
| AI Governance | 5% | Critical for AI-enabled products; lower weight as not universally applicable |
| Deployment | 5% | Process quality; lower weight as pass/fail rather than gradient |

## Scoring Grid

| Score | Level | Color | Action |
|-------|-------|-------|--------|
| 85-100 | **Excellent** | 🟢 Green | Ready for production. Review monthly. |
| 70-84 | **Good** | 🟡 Yellow | Minor improvements recommended. Address within 30 days. |
| 50-69 | **Warning** | 🟠 Orange | Material risks present. Address before next release. |
| 0-49 | **Critical** | 🔴 Red | BLOCKING — do not deploy. Immediate action required. |

## Blocking Thresholds

Regardless of composite score, the following automatically block deployment:
- Security < 70/100 (independent threshold per AUDIT-SECURITY.md)
- Deployment gate: any FAIL check
- Accessibility < 80/100 for EU-deployed products

## Computation Procedure

### Step 1 — Collect Domain Scores

Run each audit agent or read from `.sqwr-last-state.sh`:

```bash
# Read cached scores (if available and fresh)
source .sqwr-last-state.sh 2>/dev/null || true

# Required variables:
# SQWR_SECURITY_SCORE, SQWR_PERFORMANCE_SCORE, SQWR_CODEQUALITY_SCORE
# SQWR_OBSERVABILITY_SCORE, SQWR_ACCESSIBILITY_SCORE, SQWR_DESIGN_SCORE
# SQWR_AI_GOVERNANCE_SCORE, SQWR_DEPLOYMENT_SCORE
```

### Step 2 — Apply Formula

```bash
# Example computation in bash
RISK_SCORE=$(echo "scale=1; \
  ($SQWR_SECURITY_SCORE * 0.22) + \
  ($SQWR_PERFORMANCE_SCORE * 0.18) + \
  ($SQWR_CODEQUALITY_SCORE * 0.18) + \
  ($SQWR_OBSERVABILITY_SCORE * 0.12) + \
  ($SQWR_ACCESSIBILITY_SCORE * 0.12) + \
  ($SQWR_DESIGN_SCORE * 0.08) + \
  ($SQWR_AI_GOVERNANCE_SCORE * 0.05) + \
  ($SQWR_DEPLOYMENT_SCORE * 0.05)" | bc)
```

### Step 3 — Store Results

```bash
{
  echo "SQWR_LAST_SCORE=$RISK_SCORE"
  echo "SQWR_LAST_AUDIT_DATE=$(date '+%Y-%m-%d')"
  # ... individual scores
} > .sqwr-last-state.sh
```

## Output Template

```
╔══════════════════════════════════════════════════╗
║           SQWR RISK SCORE REPORT                 ║
╚══════════════════════════════════════════════════╝

Project: [name]
Date: [YYYY-MM-DD]
Mode: [Quick/Full]

Domain Scores:
  Security       (×0.22): [S]/100  → [S×0.22]
  Performance    (×0.18): [P]/100  → [P×0.18]
  Code Quality   (×0.18): [Q]/100  → [Q×0.18]
  Observability  (×0.12): [O]/100  → [O×0.12]
  Accessibility  (×0.12): [A]/100  → [A×0.12]
  Design         (×0.08): [D]/100  → [D×0.08]
  AI Governance  (×0.05): [G]/100  → [G×0.05]
  Deployment     (×0.05): [Y]/100  → [Y×0.05]
                         ────────────────────
COMPOSITE RISK SCORE:    [TOTAL]/100 — [LEVEL]

[Recommendations based on level]
```

## Integration with Agents

This audit is executed by:
- `/risk-score` skill — user-facing command
- `AGENT-RISK-SCORE.md` — autonomous agent
- `AGENT-FULL-AUDIT.md` — includes risk score in full audit report

## Related Audits

All domain audits feed into this composite:
- AUDIT-SECURITY.md (22%)
- AUDIT-PERFORMANCE.md (18%)
- AUDIT-CODE-QUALITY.md (18%)
- AUDIT-OBSERVABILITY.md (12%)
- AUDIT-ACCESSIBILITY.md (12%)
- AUDIT-DESIGN.md (8%)
- AUDIT-AI-GOVERNANCE.md (5%)
- AUDIT-DEPLOYMENT.md (5%)
