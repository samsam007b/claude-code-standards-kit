# Audit — GDPR Compliance

> SQWR Project Kit audit module.
> Sources: EU Regulation 2016/679 (GDPR), CNIL (cnil.fr), European Data Protection Board (edpb.europa.eu), ICO (ico.org.uk).

---

## Legal basis

**The GDPR (General Data Protection Regulation) is mandatory for any processing of personal data of EU residents** since May 25, 2018. Fines: up to 4% of global annual revenue or €20M. Out of 10 critical points, a score ≥8/10 is required before general public production launch.

> Source: Regulation (EU) 2016/679 of the European Parliament — [eur-lex.europa.eu](https://eur-lex.europa.eu/legal-content/FR/TXT/?uri=CELEX%3A32016R0679)

---

## Usage instructions

For each dimension below:
1. Verify the current implementation
2. Score 0-10 according to the scoring guide
3. Identify gaps
4. Prioritize by risk level (🔴 critical / 🟡 important / 🟢 desirable)

---

## Audit dimensions

### D1 — Core User Rights (20 points)

**Weight: 20% of total score**

| Article | Right | Implemented | Points |
|---------|-------|-------------|--------|
| Art. 15 | Right of access — personal data export (readable JSON format) | ☐ | 0-5 |
| Art. 17 | Right to erasure — deletion + anonymization of PII | ☐ | 0-5 |
| Art. 20 | Right to data portability — standard format export, machine-readable | ☐ | 0-5 |
| Art. 21 | Right to object — opt-out from marketing/profiling | ☐ | 0-5 |

**Score D1: ___/20**

#### Technical implications

```typescript
// Art. 15 + 20 — Data export
// Route: GET /api/user/export
// Rate limit: 2/hour per IP
// Content: profile, messages, transactions, preferences
// Format: timestamped JSON with export_version

// Art. 17 — Account deletion
// Recommended strategy:
// - Anonymize: name, email, phone, bio → null
// - Anonymize: messages → "[Message deleted]"
// - Retain: financial data (legal obligation 6 years)
// - Delete: storage (avatars, documents)
// - Delete: auth account
```

---

### D2 — Consent & Collection (15 points)

**Weight: 15% of total score**

| Article | Obligation | Implemented | Points |
|---------|------------|-------------|--------|
| Art. 6 | Legal basis documented for each processing (consent / contract / legitimate interest) | ☐ | 0-5 |
| Art. 7 | Granular consent, freely given, withdrawable — opt-in cookie banner (not opt-out) | ☐ | 0-5 |
| Art. 8 | Minimum age verification 16 years (recommended: 18 years) at registration | ☐ | 0-5 |

**Score D2: ___/15**

#### Threshold article 8

```typescript
// ✅ Minimum compliant implementation Article 8
const age = differenceInYears(new Date(), new Date(birthDate))
if (age < 18) {
  return { error: 'GDPR Art. 8 — Minimum age 18 required.' }
}
```

**Cookie consent — compliance criteria:**
- ✅ Opt-in (not opt-out by default)
- ✅ Granular consent by category (essential / analytics / marketing)
- ✅ Consent timestamp stored in DB
- ✅ Revocation possible at any time
- ❌ Pre-checked boxes = NOT compliant

---

### D3 — Transparency & Documentation (15 points)

**Weight: 15% of total score**

| Article | Obligation | Implemented | Points |
|---------|------------|-------------|--------|
| Art. 13 | Complete Privacy Policy: controller identity, purposes, sub-processors, retention periods | ☐ | 0-5 |
| Art. 13 | Sub-processors named + legal mechanism for transfers outside EU (SCC if USA) | ☐ | 0-5 |
| Art. 5(1)(e) | Data retention policies documented per data type | ☐ | 0-5 |

**Score D3: ___/15**

#### Sub-processors template (Privacy Policy)

```markdown
| Sub-processor | Country | Role | Legal mechanism |
|---------------|---------|------|-----------------|
| Supabase Inc. | USA | Database, auth, storage | DPA + SCC (Decision 2021/914) |
| Stripe Inc. | USA | Payments | SCC + Privacy Shield successor |
| Sentry (Functional Software) | USA | Error monitoring | SCC (Decision 2021/914) |
| Vercel Inc. | USA | Hosting | DPA available at vercel.com/legal/dpa |
```

#### Minimum data retention policies

| Type | Duration | Legal justification |
|------|----------|---------------------|
| Financial data | 6 years | Belgian / French civil code |
| Security logs | 12 months | CNIL best practice |
| Marketing data | 3 years without contact | CNIL recommendation |
| Analytics | 13 months | GA4 standard |
| Expired sessions | 24h | Technical cleanup |

---

### D4 — Data Security (20 points)

**Weight: 20% of total score**

| Article | Obligation | Implemented | Points |
|---------|------------|-------------|--------|
| Art. 25 | Privacy by Design — minimal data collected (no superfluous fields) | ☐ | 0-5 |
| Art. 32 | Technical measures: encryption, RLS, rate limiting, HTTPS | ☐ | 0-5 |
| Art. 32 | Protection against email enumeration (generic auth responses) | ☐ | 0-5 |
| Art. 32 | No `console.log(email/password/token)` in production | ☐ | 0-5 |

**Score D4: ___/20**

#### Technical checklist Art. 32

```bash
# Detect logs with PII
grep -r "console.log" src/ | grep -i "email\|password\|token\|secret"

# Detect unprotected sensitive data
grep -r "SELECT \*" src/ --include="*.ts"  # Avoid SELECT * on sensitive tables
```

---

### D5 — Incident Notification (15 points)

**Weight: 15% of total score**

| Article | Obligation | Implemented | Points |
|---------|------------|-------------|--------|
| Art. 33 | `security_breaches` table for internal incident traceability | ☐ | 0-5 |
| Art. 33 | Process documented for authority notification < 72h after detection | ☐ | 0-5 |
| Art. 34 | Process documented for user notification if high risk | ☐ | 0-5 |

**Score D5: ___/15**

#### Minimum `security_breaches` table structure

```sql
CREATE TABLE security_breaches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  detected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  severity TEXT CHECK (severity IN ('low', 'medium', 'high', 'critical')),
  affected_records INTEGER,
  data_types TEXT[],
  description TEXT,
  containment_actions TEXT,
  notified_authority BOOLEAN DEFAULT false,
  notified_at TIMESTAMPTZ,
  resolved_at TIMESTAMPTZ
);
```

**EU supervisory authority contacts:**
| Country | Authority | Deadline |
|---------|-----------|----------|
| Belgium | APD — apd-gba.be | <72h |
| France | CNIL — cnil.fr | <72h |
| EU (cross-border) | EDPB — edpb.europa.eu | <72h |

---

### D6 — Legal Pages (15 points)

**Weight: 15% of total score**

| Obligation | Implemented | Points |
|------------|-------------|--------|
| Complete Privacy Policy accessible (footer link) | ☐ | 0-3 |
| Terms of Service / Terms and Conditions | ☐ | 0-3 |
| Legal notice (company identity, registration number) | ☐ | 0-3 |
| Cookie Policy with list of cookies | ☐ | 0-3 |
| Contact details for exercising rights | ☐ | 0-3 |

**Score D6: ___/15**

---

## Global Score Calculation

```
GDPR Score = (D1/20 × 20) + (D2/15 × 15) + (D3/15 × 15) + (D4/20 × 20) + (D5/15 × 15) + (D6/15 × 15)
           = Score out of 100
```

| Score | Level | Action |
|-------|-------|--------|
| ≥90/100 | ✅ Compliant | Annual maintenance audit |
| 75-89/100 | 🟡 Mostly compliant | Address gaps within 30 days |
| 60-74/100 | 🟠 Partially compliant | Do not launch for general public |
| <60/100 | 🔴 Non-compliant | **BLOCK** the launch — legal risk |

**Target score before general public production: ≥80/100**

---

## Pre-launch Checklist

### 🔴 Blocking (score <80 = do not launch)

- [ ] Core user rights implemented (export + deletion — Art. 15, 17, 20)
- [ ] Complete Privacy Policy with sub-processors and SCC for USA transfers
- [ ] Opt-in cookie banner (not opt-out)
- [ ] Age verification at registration (Art. 8)
- [ ] Financial data retained 6 years, PII anonymized after account deletion
- [ ] No `console.log(email/password)` in production

### 🟡 Important (within 30 days post-launch)

- [ ] `security_breaches` table created + 72h notification process documented (Art. 34)
- [ ] Consent stored with timestamp in DB (Art. 7)
- [ ] Email enumeration protection — generic auth responses
- [ ] Marketing email opt-out (Art. 21)

### 🟢 Desirable (within 90 days)

- [ ] DPIA (Data Protection Impact Assessment) for high-risk processing (Art. 35)
- [ ] DPO designated if large-scale processing
- [ ] Admin dashboard to audit sub-processors

---

## Audit Report Template

```
GDPR AUDIT REPORT
Project: [name]
Date: [date]
Auditor: [name]

D1 — User rights          : ___/20
D2 — Consent              : ___/15
D3 — Transparency         : ___/15
D4 — Security             : ___/20
D5 — Incident notification: ___/15
D6 — Legal pages          : ___/15
                            ------
GLOBAL SCORE              : ___/100

Critical gaps (🔴):
- [gap 1]
- [gap 2]

Action plan:
- [action 1] — Owner: [name] — Deadline: [date]
- [action 2] — Owner: [name] — Deadline: [date]
```

---

## Sources

| Reference | Link |
|-----------|------|
| GDPR — EU Regulation 2016/679 | eur-lex.europa.eu/legal-content/FR/TXT/?uri=CELEX%3A32016R0679 |
| CNIL — Developer security guide | cnil.fr/fr/la-securite-des-donnees-personnelles |
| EDPB — Guidelines | edpb.europa.eu/our-work-tools/our-documents/guidelines |
| ICO — GDPR Guide for developers | ico.org.uk/for-organisations/guide-to-data-protection |
| SCC — Commission Decision 2021/914 | eur-lex.europa.eu/eli/dec_impl/2021/914/oj |
| APD Belgium | apd-gba.be |
| CNIL France | cnil.fr |
