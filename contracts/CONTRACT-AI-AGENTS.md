# Contract — AI Agents & Tool Calling

> Sources: OWASP Top 10 for LLM Applications 2025, NIST AI RMF 1.0 (2023), Anthropic docs (docs.anthropic.com), Microsoft RAI Standard v2
> Score: /100 | Recommended threshold: ≥75
> Applies to: any project that builds, orchestrates, or integrates AI agents with tool-calling capabilities

---

## Section 1 — Input & Output Validation (28 points)

- [ ] All tool call inputs are validated before execution (type, range, format) .............. (8)
- [ ] All tool call outputs are validated before being used or displayed to users .............. (7)
- [ ] Prompt injection prevention: user-supplied content is isolated from system instructions (OWASP LLM01) .............. (8)
- [ ] No sensitive data (PII, credentials, secrets) in agent memory or context .............. (5)

**Subtotal: /28**

---

## Section 2 — Safety & Authorization (25 points)

- [ ] Irreversible actions (delete, send, deploy) require explicit human confirmation .............. (10)
- [ ] Each tool has a clearly scoped permission (principle of least privilege — NIST AI RMF MS-2.5) .............. (8)
- [ ] Agent cannot self-modify its own instructions or tools at runtime .............. (7)

**Subtotal: /25**

---

### Least Agency Principle

Per OWASP Agentic AI Top 10 #1: AI agents must operate with the minimum permissions necessary to complete their task.

- [ ] Agent tool list is scoped to required tools only (no unnecessary Bash/Write access)
- [ ] Agent cannot modify its own permissions or escalate privileges
- [ ] Sub-agents have equal or fewer permissions than their orchestrator

**Threshold**: All 3 criteria met = PASS. Any violation = **BLOCKING**.

---

## Section 3 — Observability (22 points)

- [ ] 100% of tool calls logged with: timestamp, tool name, input hash, output hash, latency .............. (10)
- [ ] Error rate per tool monitored; alert threshold defined (recommended: >5% error rate) .............. (7)
- [ ] Token consumption tracked per session and per tool type .............. (5)

**Subtotal: /22**

---

## Section 4 — Resilience & Limits (25 points)

- [ ] Maximum turns per agent session defined and enforced (recommended: ≤100 turns — Anthropic docs) .............. (8)
- [ ] Timeout per tool call defined (recommended: ≤30s per tool call) .............. (7)
- [ ] Graceful degradation: agent handles tool failure without crashing (try/catch + fallback) .............. (5)
- [ ] Cost limit per session enforced (recommended: alert at $1, hard stop at $10) .............. (5)

**Subtotal: /25**

---

## Sources

| Reference | Contribution |
|-----------|-------------|
| OWASP Agentic AI Top 10 | OWASP Top 10 for Agentic Applications, 2025, owasp.org | Tier 1 |
| OWASP — *Top 10 for LLM Applications 2025* (owasp.org, 2025) | LLM01 Prompt Injection, LLM02 Insecure Output Handling thresholds |
| NIST — *AI Risk Management Framework 1.0* (nist.gov, 2023) | MS-2.5 Least privilege, accountability requirements |
| Anthropic — *Claude Code Agent SDK documentation* (docs.anthropic.com, 2025) | maxTurns ≤100, tool permission model |
| Microsoft — *Responsible AI Standard v2* (microsoft.com, 2022) | Human oversight requirements for irreversible actions |

> **Last validated:** 2026-03-31 — OWASP LLM Top 10 2025, NIST AI RMF 1.0, Anthropic Agent SDK docs
