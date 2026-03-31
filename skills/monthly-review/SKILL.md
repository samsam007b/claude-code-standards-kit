---
name: "monthly-review"
description: "Monthly audit cycle — full SQWR audit across all 8 domains, dependency updates, tech debt review, and SLO check."
effort: high
model: sonnet
context: fork
agent: "general-purpose"
disable-model-invocation: true
paths:
  - "agents/AGENT-FULL-AUDIT.md"
  - "workflows/WORKFLOW-MONTHLY-REVIEW.md"
  - "audits/AUDIT-INDEX.md"
allowed-tools: ["Read", "Grep", "Glob", "Bash", "Agent"]
---

# /monthly-review — Monthly Review Cycle

**Usage:** `/monthly-review`

Runs the full monthly review. Invoke this at the end of each sprint or month to maintain kit quality standards.

---

## Phase 1 — Full Audit

Run the complete audit suite across all 8 domains.

```
Ask Claude: "Run agents/AGENT-FULL-AUDIT.md"
```

Expected runtime: 20-45 minutes. The full audit runs:
- Security (22%) — blocking at <70
- Performance (18%) — recommended ≥70
- Code Quality (18%) — recommended ≥75
- Observability (12%) — recommended ≥60
- Accessibility (12%) — legal ≥80 (EU)
- Design (8%) — recommended ≥70
- AI Governance (5%) — recommended ≥80
- Deployment (5%) — pre-production gate

**Observable truth**: Full audit report with global score ≥ 85/100 and no blocking thresholds breached.

---

## Phase 2 — Dependency Review

Check for outdated or vulnerable dependencies.

```bash
npm outdated
npm audit
```

For each vulnerability:
- CRITICAL/HIGH: fix immediately
- MODERATE: plan fix within 2 weeks
- LOW: track in Tech Debt Tracker

**Observable truth**: `npm audit` shows 0 critical/high vulnerabilities.

---

## Phase 3 — Tech Debt Review

Review `CLAUDE.md` Tech Debt Tracker section.

For each item:
1. Re-evaluate priority (P1/P2/P3)
2. Create issues for P1 items
3. Archive resolved items

**Observable truth**: Tech Debt Tracker updated, P1 items have GitHub issues.

---

## Phase 4 — SLO Review

Check actual SLO metrics against targets in CLAUDE.md.

| SLI | Target | Tool |
|-----|--------|------|
| Uptime | ≥99.5% | UptimeRobot |
| LCP p75 | ≤2.5s | Vercel Speed Insights |
| Error rate | ≤0.5% | Sentry |

If any SLO is breached:
1. Declare an incident (even minor)
2. Run `frameworks/INCIDENT-RESPONSE.md`
3. Add to Error History in CLAUDE.md

**Observable truth**: SLO dashboard reviewed, no unacknowledged breaches.

---

## Phase 5 — Contract Validation

Check that all contracts have a current `Last validated` date.

```bash
grep -l "Last validated" contracts/CONTRACT-*.md | wc -l
```

For any contract validated > 6 months ago: re-read the primary standard for updates.

**Observable truth**: All contracts validated within the last 6 months.

---

## Completion

```bash
touch .sqwr-last-audit
```

Document the monthly review outcome in CHANGELOG.md under `[Unreleased]` as a "chore" entry.

---

## Reference

Full workflow: `workflows/WORKFLOW-MONTHLY-REVIEW.md`
