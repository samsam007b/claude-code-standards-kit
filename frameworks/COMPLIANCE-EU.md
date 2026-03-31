# Framework — EU Legal Compliance 2026

> SQWR Project Kit Framework — legal obligations for Belgian/European startups.
> Sources: EU Regulation 2024/1689 (EU AI Act), EN 301 549, GDPR, NIS2 Directive.
> Last updated: March 2026

---

## ⚠️ Urgency — Imminent Deadlines

| Date | Obligation | SQWR Impact |
|------|-----------|------------|
| **28 June 2025** | **EAA in force** — accessibility mandatory for digital products in the EU | All websites delivered to EU clients |
| **2 August 2025** | EU AI Act — GPAI (General-Purpose AI) obligations | Any project using LLM APIs |
| **2 August 2026** | EU AI Act — high-risk AI systems (Annex III) | [ClientApp] (matching), [YourProject] (AI agents) |

---

## 1. EU AI Act — Classification of SQWR Use Cases

### Mandatory classification

Before 2 August 2026, each SQWR AI system must be classified.

| System | Use | Classification | Required Action |
|--------|-----|---------------|----------------|
| **[YourProject] agents** | Marketing content generation (AI-assisted) | Limited risk | Transparency (indicate AI) |
| **[ClientApp] matching** | User matching / recommendation | To evaluate (Annex III possible) | Compliance assessment |
| **Claude Code (dev)** | Internal development tool | Out of scope (professional use) | None |
| **Client chatbots** | If SQWR develops for clients | Limited risk | AI disclosure mandatory |

### Obligations by risk level

**Limited risk (most SQWR use cases):**
- Inform users that they are interacting with an AI
- Example: "This content was generated with AI assistance"

**High risk (if Annex III applies):**
- Documented risk management system
- Governed training data
- Transparency and technical documentation
- Mandatory human oversight
- Demonstrated accuracy, robustness, and cybersecurity
- Registration with the EU AI Act database

**Penalties:**
- Prohibited practices: up to €35M or 7% of global revenue
- Non-compliant high-risk systems: up to €15M or 3% of global revenue
- Incorrect information: up to €7.5M or 1.5% of global revenue

### EU AI Act Checklist (to complete before August 2026)

- [ ] All SQWR AI systems classified
- [ ] Classification document created and archived
- [ ] AI legal disclosures added in the relevant interfaces
- [ ] If high-risk: compliance assessment launched

---

## 2. European Accessibility Act (EAA) — Already mandatory

**Applicable since 28 June 2025.** Every digital product or service sold in the EU must comply with EN 301 549 (= WCAG 2.1 AA in practice).

### What this means for SQWR

**Every website delivered to a Belgian/European client engages the responsibility of SQWR Studio** if the site is not accessible.

### Technical standards

| Standard | Level | Obligation |
|---------|--------|-----------|
| WCAG 2.1 AA | Level A + AA | Legal minimum |
| EN 301 549 | v3.2.1 (2021) | EU technical standard |
| WCAG 2.2 | Recommended | Target 2026–2027 |

### EAA Checklist per delivered project

- [ ] AUDIT-ACCESSIBILITY.md audit completed
- [ ] Score ≥80/100 (WCAG 2.1 AA)
- [ ] Contrast ratios verified (4.5:1 text, 3:1 UI elements)
- [ ] Full keyboard navigation
- [ ] Images with alt text
- [ ] Forms with explicit labels
- [ ] Accessibility statement published on the site

### Accessibility Statement (mandatory)

Each delivered site must publish an accessibility statement including:
- The conformance level achieved (AA)
- Known non-conformances and their alternative solutions
- A contact for reporting accessibility issues
- The date of the last assessment

---

## 3. GDPR — Data Processing Agreements with AI providers

**A critical point often overlooked:** when SQWR sends user data to LLM APIs, those providers become **data processors** under the GDPR. A DPA (Data Processing Agreement) is mandatory.

| Provider | DPA available | Action |
|----------|--------------|--------|
| **Anthropic** (Claude API) | Yes — anthropic.com/legal/dpa | Sign before production use with personal data |
| **Vercel** | Yes — vercel.com/legal/dpa | Already included in Pro/Team ToS |
| **Supabase** | Yes — supabase.com/privacy | Included in paid plans |
| **OpenRouter** | Verify — openrouter.ai | Verify before use with client data |
| **Resend** | Yes — resend.com/legal | To sign for sending user emails |

### Data minimization rules

- Do not send personally identifiable information (PII) to LLMs unless necessary
- If necessary: anonymize or pseudonymize before sending
- Document which data is sent to which providers

---

## 4. NIS2 — Supply Chain Security

**Applicable since October 2024.** SQWR may be subject to NIS2 indirectly if a client operates in a critical sector.

### NIS2 client sectors (require security evidence)
- Healthcare (hospitals, physicians)
- Finance (banks, insurance)
- Energy
- Transport
- Water / digital infrastructure

### What NIS2 requires from software providers
- Documented security policy (→ CONTRACT-SECURITY.md + AUDIT-SECURITY.md)
- Vulnerability management (→ npm audit SLA, dependency scanning)
- Supply chain security (→ SBOM, package verification)
- Incident notification (< 24h for significant incidents)

### NIS2 Checklist per project for regulated-sector clients

- [ ] Security policy documented (CLAUDE.md + CONTRACT-SECURITY.md)
- [ ] AUDIT-SECURITY.md security audit completed (score ≥70)
- [ ] Dependency scanning in CI (npm audit critical = blocking)
- [ ] Incident notification procedure documented (INCIDENT-RESPONSE.md)
- [ ] DPA signed with all sub-processors

---

## 5. ePrivacy — Cookies and Tracking

**Main rule:** any analytical tracking requires explicit consent, unless anonymous and cookie-free (= Plausible).

| Analytics solution | Cookie? | Consent required? | SQWR recommendation |
|-------------------|---------|------------------|---------------------|
| **Plausible** | No | No — GDPR-native | ✅ Recommended (sqwr-site) |
| **Vercel Analytics** | Variable | Yes if personal data | ⚠️ Verify config |
| **Google Analytics** | Yes | Yes — CMP required | ❌ Avoid if possible |
| **PostHog** | Yes | Yes — CMP required | Only if necessary |

---

## 6. SQWR Compliance Register

Keep this register up to date for each active project:

| Project | EAA audit | EU AI Act classified | GDPR DPAs signed | NIS2 if applicable |
|---------|-----------|--------------------|-----------------|--------------------|
| sqwr-site | [ ] | N/A | Vercel ✅ | N/A |
| [ClientApp] | [ ] | [ ] To evaluate | Vercel ✅ Supabase ✅ | N/A |
| [your-project] | [ ] | [ ] Limited risk | Vercel ✅ Supabase ✅ Anthropic ☐ | N/A |
| [Client project] | [ ] | N/A | [ ] | [ ] If regulated sector |

---

## Sources

| Reference | Source |
|-----------|--------|
| EU AI Act — EU Regulation 2024/1689 | eur-lex.europa.eu/legal-content/FR/TXT/?uri=CELEX:32024R1689 |
| EU AI Act — Practical guide | digital-strategy.ec.europa.eu/fr/policies/regulatory-framework-ai |
| European Accessibility Act | ec.europa.eu/social/main.jsp?catId=1202 |
| EN 301 549 v3.2.1 | etsi.org/deliver/etsi_en/301500_302000/301549 |
| GDPR — CNIL | cnil.fr/fr/rgpd-de-quoi-parle-t-on |
| NIS2 Directive | digital-strategy.ec.europa.eu/en/policies/nis2-directive |
| Anthropic DPA | anthropic.com/legal/data-processing-addendum |
