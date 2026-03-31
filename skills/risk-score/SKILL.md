---
name: "risk-score"
description: "Calculate and display the composite SQWR Risk Score — weighted average across 8 audit domains producing a single 0-100 health indicator"
effort: high
model: sonnet
context: fork
agent: "general-purpose"
disable-model-invocation: true
argument-hint: "mode: 'quick' (cached scores) or 'full' (rerun all audits)"
paths:
  - "agents/AGENT-RISK-SCORE.md"
  - "audits/AUDIT-RISK-SCORE.md"
  - "audits/AUDIT-INDEX.md"
allowed-tools: ["Read", "Grep", "Glob", "Bash", "Agent"]
---

# /risk-score — Composite Risk Score

**Usage:** `/risk-score [mode]`

Calculates the composite SQWR Risk Score using the weighted formula across all 8 audit domains.

**Modes:**
- `quick` — Uses cached scores from `.sqwr-last-state.sh` (default if < 24h old)
- `full` — Reruns all 8 audit agents for fresh scores

---

## Weighted Formula

```
Risk Score = (Security × 0.22) + (Performance × 0.18) + (Code Quality × 0.18)
           + (Observability × 0.12) + (Accessibility × 0.12) + (Design × 0.08)
           + (AI Governance × 0.05) + (Deployment × 0.05)
```

---

## Step 1 — Determine Mode

Parse `$ARGUMENTS`:
- If "full" → run full recalculation
- If "quick" or empty → check `.sqwr-last-state.sh` for cached scores

---

## Step 2a — Quick Mode (cached scores)

Read `.sqwr-last-state.sh`. If scores exist and `SQWR_LAST_AUDIT_DATE` is today or yesterday, use them.
Otherwise, warn user and switch to full mode.

---

## Step 2b — Full Mode (rerun audits)

Run `agents/AGENT-RISK-SCORE.md` with argument "full".

This agent will orchestrate all 8 domain audits and compute the composite score.

---

## Step 3 — Display Results

Apply the weighted formula and display the risk score report:

```
╔══════════════════════════════════════╗
║     SQWR RISK SCORE                  ║
╚══════════════════════════════════════╝

[Domain scores table]

COMPOSITE RISK SCORE: [X]/100 — [Level]
```

Scoring levels:
- 85-100: Excellent — Ready for production
- 70-84: Good — Minor improvements recommended
- 50-69: Warning — Address before next release
- 0-49: Critical — BLOCKING — fix before any deployment

**Observable truth**: Risk Score displayed with domain breakdown and actionable recommendations.
