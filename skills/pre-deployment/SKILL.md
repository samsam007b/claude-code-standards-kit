---
name: "pre-deployment"
description: "Pre-deployment quality gate — runs all blocking audit agents before merging to main or deploying to production."
effort: high
model: sonnet
context: fork
agent: "general-purpose"
disable-model-invocation: true
paths:
  - "agents/**"
  - "audits/AUDIT-INDEX.md"
  - "workflows/WORKFLOW-PRE-DEPLOYMENT.md"
allowed-tools: ["Read", "Grep", "Glob", "Bash", "Agent"]
---

# /pre-deployment — Pre-Deployment Quality Gate

**Usage:** `/pre-deployment`

Runs the complete pre-deployment checklist. Invoke this before any merge to main or production deployment.

---

## Step 1 — Security Gate (BLOCKING)

Run first. If this fails, deployment is blocked — no exceptions.

```
Ask Claude: "Run agents/AGENT-SECURITY-AUDIT.md"
```

**Blocking threshold**: Score < 70/100 = BLOCKED
**Observable truth**: Security audit report with score ≥ 70/100.

---

## Step 2 — Deployment Gate (BLOCKING)

```
Ask Claude: "Run agents/AGENT-DEPLOYMENT-GATE.md"
```

Checks: TypeScript strict, ESLint 0 errors, build passes, env vars documented, migrations safe.

**Observable truth**: All blocking checks in AUDIT-DEPLOYMENT.md return PASS.

---

## Step 3 — Code Quality

```
Ask Claude: "Run agents/AGENT-CODE-QUALITY-AUDIT.md"
```

**Recommended threshold**: Score ≥ 75/100
**Observable truth**: Code quality audit report with score ≥ 75/100.

---

## Step 4 — Performance

```
Ask Claude: "Run agents/AGENT-PERFORMANCE-AUDIT.md"
```

**Recommended threshold**: Score ≥ 70/100
Focus: LCP ≤2.5s, INP ≤200ms, CLS ≤0.1 (Google Core Web Vitals)

**Observable truth**: Performance audit report with score ≥ 70/100.

---

## Step 5 — EU Compliance (if applicable)

If deploying to European users:

```
Ask Claude: "Run agents/AGENT-ACCESSIBILITY-AUDIT.md"
```

**Legal threshold**: Score ≥ 80/100 (European Accessibility Act, enforceable June 2025)

**Observable truth**: Accessibility audit report with score ≥ 80/100.

---

## Completion Checklist

- [ ] CHANGELOG.md updated with release version and date
- [ ] All migrations are additive (no column renames or drops without expand-contract)
- [ ] Feature flags set correctly for this release
- [ ] Monitoring/alerting in place for new functionality
- [ ] Rollback plan documented
- [ ] `touch .sqwr-last-audit` to mark audit complete

**Observable truth**: All items above checked. Ready to merge.

---

## Reference

Full workflow: `workflows/WORKFLOW-PRE-DEPLOYMENT.md`
Audit weightings: `audits/AUDIT-INDEX.md`
