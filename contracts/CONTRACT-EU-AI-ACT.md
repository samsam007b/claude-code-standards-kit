# CONTRACT-EU-AI-ACT — EU Artificial Intelligence Act Compliance

**Version**: 1.0 | **Last validated**: 2026-03-31 | **Applies to**: All AI-enabled products serving EU users

## Sources

| Standard | Reference | Tier |
|----------|-----------|------|
| EU AI Act | Regulation (EU) 2024/1689, Official Journal of the EU, 12 July 2024 | Tier 1 |
| AI Act Implementation | EU AI Office, ai-act.europa.eu, 2024 | Tier 1 |
| NIST AI RMF | NIST AI 100-1, National Institute of Standards and Technology, 2023 | Tier 2 |
| ISO/IEC 42001 | AI Management Systems Standard, ISO, 2023 | Tier 2 |

---

## Section 1 — Risk Classification (25 points)

The EU AI Act classifies AI systems into 4 risk categories with different obligations.

### 1.1 Prohibited AI Practices (15 points) — BLOCKING

The following AI applications are **prohibited** regardless of use case:

| Prohibited Practice | Applies to this system? |
|--------------------|------------------------|
| Social scoring by public authorities | [ ] Yes / [x] No |
| Real-time biometric identification in public spaces (exceptions apply) | [ ] Yes / [x] No |
| Subliminal manipulation of behavior | [ ] Yes / [x] No |
| Exploitation of vulnerabilities (age, disability, social situation) | [ ] Yes / [x] No |
| Predictive policing based on profiling | [ ] Yes / [x] No |
| Emotion recognition in workplace/education | [ ] Yes / [x] No |

**Threshold**: Any "Yes" = **BLOCKED** — system cannot be deployed in EU.

**Verification**: Legal review + system capability assessment.

### 1.2 High-Risk System Classification (10 points)

Check if the system falls under Annex III high-risk categories:

| Domain | High-Risk Use Case |
|--------|-------------------|
| Critical infrastructure | Energy, water, transport, finance AI |
| Education | AI for student assessment, admission, evaluation |
| Employment | CV screening, job candidate ranking, performance monitoring |
| Essential services | Credit scoring, insurance risk assessment |
| Law enforcement | Crime prediction, evidence reliability assessment |
| Migration | Risk assessment for asylum/visa applications |
| Justice | AI for court decisions or dispute resolution |
| Democratic processes | AI in elections or political advertising |

**If high-risk**: Mandatory conformity assessment before deployment (Articles 43-46).
**Threshold**: High-risk systems without conformity assessment = **BLOCKED** in EU.

---

## Section 2 — Transparency Obligations (25 points)

Applies to all AI systems interacting with humans (Article 50).

### 2.1 AI Interaction Disclosure (10 points)

- [ ] Users are clearly informed when interacting with an AI system
- [ ] AI-generated content is labeled as such (text, images, audio, video)
- [ ] Chatbots and virtual assistants identify themselves as AI at session start
- [ ] Disclosure is provided at first interaction, not buried in ToS

**Threshold**: ≥ 3 of 4 criteria met = PASS. Non-disclosure = **BLOCKING** fine risk.

### 2.2 General-Purpose AI (GPAI) Transparency (10 points)

If using GPAI models (GPT-4, Claude, Gemini, etc.):

- [ ] EU copyright law compliance documented for training data
- [ ] Publicly available summary of training data published
- [ ] Systemic risk assessment completed (if model > 10^25 FLOPs)

**Threshold**: ≥ 2 of 3 criteria met = PASS.

### 2.3 Technical Documentation (5 points)

- [ ] AI system capabilities and limitations documented
- [ ] Intended purpose clearly defined and documented
- [ ] Performance metrics on representative datasets documented

**Threshold**: All 3 criteria met = PASS.

---

## Section 3 — Human Oversight (25 points)

High-risk systems require human oversight mechanisms (Article 14).

### 3.1 Human Override Capability (15 points)

- [ ] Humans can override, interrupt, or stop the AI system
- [ ] Output can be disregarded by human operator
- [ ] No automatic AI decisions without human review for high-stakes outputs
- [ ] Human responsible for AI output is identifiable

**Threshold**: ≥ 3 of 4 criteria met = PASS for high-risk systems.

### 3.2 Monitoring and Logging (10 points)

- [ ] AI system outputs are logged with sufficient detail for audit
- [ ] Anomaly detection or monitoring is in place
- [ ] Logs are retained for ≥ 6 months (high-risk: ≥ 3 years)

**Threshold**: ≥ 2 of 3 criteria met = PASS.

---

## Section 4 — Data Governance (15 points)

For high-risk AI systems (Article 10).

### 4.1 Training Data Quality

- [ ] Training data is relevant, representative, and free from errors
- [ ] Data bias analysis has been conducted
- [ ] Data provenance is documented

**Threshold**: ≥ 2 of 3 criteria met = PASS.

### 4.2 Data Minimization

- [ ] Only data necessary for the AI purpose is collected and processed
- [ ] Personal data processing has a legal basis under GDPR

**Threshold**: Both criteria met = PASS.

---

## Section 5 — Scoring Grid

| Score | Level | Meaning |
|-------|-------|---------|
| 90-100 | **Compliant** | Full EU AI Act compliance |
| 70-89 | **Mostly Compliant** | Minor gaps — create remediation plan |
| 50-69 | **Partially Compliant** | Material gaps — address before EU launch |
| < 50 or any BLOCKING | **Non-Compliant** | Cannot deploy to EU market |

**Blocking threshold**: Any prohibited practice or undisclosed high-risk system = deployment blocked.
