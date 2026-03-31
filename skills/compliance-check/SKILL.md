---
name: "compliance-check"
description: "Check EU regulatory compliance (European Accessibility Act, GDPR, EU AI Act) across the project — produces a compliance report with required actions"
effort: high
model: sonnet
context: fork
agent: "general-purpose"
disable-model-invocation: true
argument-hint: "regulation name or 'all' (e.g., 'eu-ai-act', 'gdpr', 'accessibility', 'all')"
paths:
  - "contracts/CONTRACT-ACCESSIBILITY.md"
  - "contracts/CONTRACT-EU-AI-ACT.md"
  - "agents/AGENT-ACCESSIBILITY-AUDIT.md"
  - "agents/AGENT-AI-GOVERNANCE-AUDIT.md"
allowed-tools: ["Read", "Grep", "Glob", "Bash", "Agent"]
---

# /compliance-check — EU Regulatory Compliance Check

**Usage:** `/compliance-check [regulation]`

Checks the project against EU regulatory requirements and produces a compliance report with required actions.

**Supported regulations:**
- `eu-ai-act` — EU AI Act (Regulation 2024/1689)
- `accessibility` / `eaa` — European Accessibility Act (enforceable June 28, 2025)
- `gdpr` — General Data Protection Regulation
- `all` — Full EU compliance sweep (default)

---

## Step 1 — Determine Scope

Parse `$ARGUMENTS` to determine which regulation(s) to check.
If empty or "all", check all three.

---

## Step 2 — EU AI Act Check (if applicable)

Read `contracts/CONTRACT-EU-AI-ACT.md` for criteria.

Check:
1. **AI system risk classification** — Is the system high-risk per Annex III? (recruitment, credit, law enforcement, education, critical infrastructure)
2. **Transparency obligations** — Are AI-generated outputs clearly labeled?
3. **Human oversight mechanisms** — Is there a human override capability?
4. **Technical documentation** — Is the model/system documented?
5. **Prohibited practices** — No social scoring, no subliminal manipulation, no real-time biometric surveillance in public spaces

For each criterion: PASS / FAIL / N/A

**Observable truth**: EU AI Act compliance report with no FAIL on prohibited practices.

---

## Step 3 — Accessibility Check (if applicable)

Run `agents/AGENT-ACCESSIBILITY-AUDIT.md` with focus on:
- WCAG 2.1 AA minimum (European Accessibility Act threshold)
- EN 301 549 standard
- Keyboard navigation, screen reader compatibility
- Color contrast ≥ 4.5:1 (normal text), ≥ 3:1 (large text)

**Legal threshold**: Score ≥ 80/100 (EAA enforceable June 28, 2025)

**Observable truth**: Accessibility audit score ≥ 80/100.

---

## Step 4 — GDPR Check (if applicable)

Check:
1. **Data minimization** — Are only necessary data fields collected?
2. **Consent mechanisms** — Is consent obtained before data processing?
3. **Right to deletion** — Is there a data deletion mechanism?
4. **Privacy policy** — Does a privacy policy exist and reference GDPR?
5. **Data processing records** — Are data flows documented?

For each criterion: PASS / FAIL / N/A

**Observable truth**: GDPR compliance report with no FAIL on mandatory items.

---

## Step 5 — Compliance Summary

Output a compliance matrix:

```
╔══════════════════════════════════════════╗
║     EU COMPLIANCE REPORT                 ║
╚══════════════════════════════════════════╝

Date: [current date]
Regulations checked: [list]

┌──────────────────┬────────┬──────────────┐
│ Regulation       │ Status │ Actions      │
├──────────────────┼────────┼──────────────┤
│ EU AI Act        │ [✓/✗]  │ [count] req. │
│ Accessibility    │ [✓/✗]  │ [count] req. │
│ GDPR             │ [✓/✗]  │ [count] req. │
└──────────────────┴────────┴──────────────┘

REQUIRED ACTIONS:
[Numbered list of mandatory fixes]

RECOMMENDED ACTIONS:
[Numbered list of improvements]
```

**Observable truth**: Compliance matrix generated. No blocking violations unaddressed.
