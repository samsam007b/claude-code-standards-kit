# CONTRACT-AI-SAFETY — AI Safety & Agentic Systems Security

**Version**: 1.0 | **Last validated**: 2026-03-31 | **Applies to**: All AI agents, autonomous systems, LLM-integrated applications

## Sources

| Standard | Reference | Tier |
|----------|-----------|------|
| OWASP Top 10 for LLM Applications | OWASP LLM Top 10, 2025 edition, owasp.org/www-project-top-10-for-large-language-model-applications | Tier 1 |
| OWASP Top 10 for Agentic AI | OWASP Agentic AI Security Top 10, 2025, owasp.org | Tier 1 |
| NIST AI 600-1 | Artificial Intelligence Risk Management Framework: Generative AI, NIST, 2024 | Tier 1 |
| ISO/IEC 27090 | Cybersecurity — AI Systems Security, ISO, 2024 (draft) | Tier 2 |
| Anthropic Safety Research | Constitutional AI, Anthropic, 2022-2025 | Tier 2 |

---

## Section 1 — Least Agency Principle (30 points) — BLOCKING threshold

The OWASP Agentic AI Top 10 mandates that AI agents operate with the minimum permissions necessary.

### 1.1 Tool Access Minimization (15 points)

- [ ] Agent only has access to tools necessary for its defined task
- [ ] Bash/shell access is scoped — no unrestricted system access
- [ ] File write access is limited to designated directories
- [ ] Network access is restricted to required endpoints
- [ ] Database access is read-only unless write is explicitly required

**Threshold**: ≥ 4 of 5 criteria met = PASS. Unrestricted shell + network + write = **BLOCKING**.

### 1.2 Permission Escalation Prevention (15 points)

- [ ] Agent cannot modify its own system permissions
- [ ] Agent cannot install software without human approval
- [ ] Agent cannot access credentials or secrets beyond what is pre-authorized
- [ ] Multi-agent systems: sub-agents have equal or fewer permissions than orchestrator

**Threshold**: All 4 criteria met = PASS. Any violation = **BLOCKING**.

---

## Section 2 — Prompt Injection Defense (25 points)

LLM Top 10 #1: Prompt injection is the top vulnerability in LLM-integrated systems.

### 2.1 Direct Prompt Injection Prevention (15 points)

- [ ] User inputs are clearly separated from system instructions
- [ ] System prompts are not exposed to users or external content
- [ ] Input validation rejects known injection patterns
- [ ] LLM output is treated as untrusted data, not executable instruction

**Threshold**: ≥ 3 of 4 criteria met = PASS. Score < 70 on this section = **BLOCKING**.

### 2.2 Indirect Prompt Injection Prevention (10 points)

- [ ] External content (web pages, documents, emails) is sanitized before being passed to LLM
- [ ] Retrieved content is clearly marked as external/untrusted in prompts
- [ ] Agent actions based on external content require confirmation for irreversible operations

**Threshold**: ≥ 2 of 3 criteria met = PASS.

---

## Section 3 — Memory & Context Security (20 points)

### 3.1 Memory Poisoning Prevention (10 points)

- [ ] Persistent memory (vector stores, files) cannot be written by untrusted external content
- [ ] Memory contents are validated before being injected into prompts
- [ ] Memory access is logged and auditable

**Threshold**: ≥ 2 of 3 criteria met = PASS.

### 3.2 Context Window Security (10 points)

- [ ] Sensitive data (API keys, passwords, PII) is not stored in conversation context
- [ ] Context is cleared between sessions when handling sensitive operations
- [ ] Context size limits are enforced to prevent token smuggling attacks

**Threshold**: ≥ 2 of 3 criteria met = PASS.

---

## Section 4 — Output Validation & Sandboxing (15 points)

### 4.1 Output Validation (8 points)

- [ ] AI-generated code is reviewed before execution
- [ ] AI-generated SQL/commands are parameterized and validated
- [ ] AI output that triggers external actions requires human confirmation

**Threshold**: ≥ 2 of 3 criteria met = PASS.

### 4.2 Execution Sandboxing (7 points)

- [ ] Code execution (if any) occurs in an isolated environment
- [ ] Sandbox prevents network access and filesystem writes to sensitive paths
- [ ] Timeout and resource limits are enforced on AI-triggered execution

**Threshold**: ≥ 2 of 3 criteria met = PASS.

---

## Section 5 — Scoring Grid

| Score | Level | Meaning |
|-------|-------|---------|
| 85-100 | **Secure** | Strong AI safety posture |
| 70-84 | **Mostly Secure** | Minor gaps — remediate within 2 weeks |
| 50-69 | **Vulnerable** | Material risks — address before production |
| < 50 | **Critical** | Deployment blocked |

**Blocking thresholds**:
- Least agency violation (unrestricted permissions) = **BLOCKED**
- Prompt injection defense < 70/100 = **BLOCKED**
