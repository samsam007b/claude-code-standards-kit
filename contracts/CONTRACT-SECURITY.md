# Contract — Security

> SQWR Project Kit contract module.
> Sources: OWASP Top 10, NIST SP 800-63B, CWE Top 25, Cloudflare.

---

## Scientific Foundations

**Broken Access Control** is the #1 vulnerability in the OWASP Top 10 (2021 data, updated 2024). 94% of tested applications exhibit some form of broken access control. Security is not added as an afterthought — it is designed into the architecture from the start.

> Source: [OWASP Top 10 — owasp.org/www-project-top-ten](https://owasp.org/www-project-top-ten/)

---

## 1. OWASP Top 10 — Mitigations for Next.js + Supabase

| # | Vulnerability | SQWR Mitigation |
|---|--------------|----------------|
| **A01** | Broken Access Control | Supabase RLS enabled + auth middleware on all protected routes |
| **A02** | Cryptographic Failures | No sensitive data in plaintext, HTTPS mandatory, HttpOnly cookies |
| **A03** | Injection | Zod validation on all inputs + Supabase parameterized queries |
| **A04** | Insecure Design | Threat modeling before implementing auth features |
| **A05** | Security Misconfiguration | Security headers, RLS enabled, env vars never exposed |
| **A06** | Vulnerable Components | `npm audit` in CI, SLA <48h for critical |
| **A07** | Auth Failures | Short sessions, refresh token rotation, no localStorage |
| **A09** | Logging Failures | Errors logged (without sensitive data), alerts on suspicious events |

---

## 2. Cross-Site Scripting (XSS)

### Never do

```tsx
// ❌ Direct injection of user HTML — critical vulnerability
<div dangerouslySetInnerHTML={{ __html: userInput }} />

// ❌ Unescaped interpolation in href
<a href={userProvidedUrl}>Link</a>  // Possible javascript: protocol injection
```

### Always do

```tsx
// ✅ React escapes automatically — no dangerouslySetInnerHTML
<div>{userInput}</div>

// ✅ Validate user URLs
function sanitizeUrl(url: string): string {
  try {
    const parsed = new URL(url)
    if (!['http:', 'https:'].includes(parsed.protocol)) return '#'
    return url
  } catch { return '#' }
}
<a href={sanitizeUrl(userProvidedUrl)}>Link</a>

// ✅ Content Security Policy (next.config.js)
const ContentSecurityPolicy = `
  default-src 'self';
  script-src 'self' 'unsafe-eval' 'unsafe-inline';
  style-src 'self' 'unsafe-inline';
  img-src 'self' blob: data:;
  font-src 'self';
`
```

---

## 3. Cross-Site Request Forgery (CSRF)

Next.js App Router + Supabase with `SameSite=Lax` cookies protects against the majority of CSRF attacks.

```typescript
// Additional check for sensitive Server Actions
export async function sensitiveAction(formData: FormData) {
  const origin = headers().get('origin')
  if (origin !== process.env.NEXT_PUBLIC_APP_URL) {
    throw new Error('CSRF check failed')
  }
  // Logic...
}
```

---

## 4. Injection (SQL, LDAP, OS)

**Supabase automatically uses prepared statements via PostgREST.** The main risk is building SQL manually.

```typescript
// ❌ NEVER build SQL with user inputs
const { data } = await supabase.rpc(`SELECT * FROM projects WHERE name = '${name}'`)

// ✅ Native Supabase API = parameterized by default
const { data } = await supabase.from('projects').select('*').eq('name', name)

// ✅ Zod validation before any DB operation
const validated = ProjectSchema.parse(input)  // throws if invalid
```

---

## 5. Security Headers (next.config.js)

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          { key: 'X-Content-Type-Options', value: 'nosniff' },
          { key: 'X-Frame-Options', value: 'DENY' },
          { key: 'X-XSS-Protection', value: '1; mode=block' },
          { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
          { key: 'Permissions-Policy', value: 'camera=(), microphone=(), geolocation=()' },
          {
            key: 'Strict-Transport-Security',
            value: 'max-age=63072000; includeSubDomains; preload',
          },
        ],
      },
    ]
  },
}
```

---

## 6. Dependency Scanning

```bash
# In CI/CD (GitHub Actions) — block on critical vulnerabilities
npm audit --audit-level=critical

# Locally — full report
npm audit

# Automatic fix (watch for breaking changes)
npm audit fix
```

**Remediation SLA:**
| Severity | SLA |
|----------|-----|
| **Critical** | <48h |
| **High** | <1 week |
| **Medium** | Next sprint |
| **Low** | Backlog |

---

## 7. Secrets Management

```bash
# ✅ Rotate Supabase keys if compromised
# Go to Supabase Dashboard → Settings → API → Rotate keys

# ✅ Verify no secrets are in git
git log -S "SUPABASE_SERVICE" --all  # Search through git history
```

**NIST SP 800-63B rule:** do not rotate on a fixed calendar schedule. Rotate only if compromise is suspected.

---

## 8. Incident Response (3 steps)

**If a compromise is detected:**

1. **Contain** (0-1h)
   - Invalidate all active sessions (Supabase Auth → Invalidate all tokens)
   - Rotate exposed API keys
   - Revoke suspicious access

2. **Analyze** (1-24h)
   - Identify the attack vector
   - Assess compromised data
   - Document the timeline

3. **Communicate** (per GDPR)
   - Notify CNIL if personal data is compromised (< 72h)
   - Notify affected users if necessary

---

## 9. GDPR Compliance — Technical Obligations

> Sources: EU Regulation 2016/679 (GDPR), CNIL (cnil.fr), European Data Protection Board (edpb.europa.eu)

**Applicable to any project processing personal data of EU residents.**

### 9.1 Article 8 — Age Verification

**Legal threshold: minimum 16 years without parental consent (recommended implementation: 18 years).**

```typescript
// ✅ Age check at registration (GDPR Article 8)
const birthDate = new Date(input.birthDate)
const age = differenceInYears(new Date(), birthDate)
if (age < 18) {
  return NextResponse.json(
    { error: 'You must be 18 years or older to register.' },
    { status: 400 }
  )
}
```

**Rules:**
- `birthDate` field required at signup
- `age >= 18` check server-side (not client-side only)
- Document in Terms of Service: minimum age requirement

### 9.2 Article 34 — Data Breach Notification

**Threshold: maximum 72 hours to notify the supervisory authority (CNIL/DPA).**

```sql
-- Mandatory table for incident traceability
CREATE TABLE security_breaches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  detected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  severity TEXT CHECK (severity IN ('low', 'medium', 'high', 'critical')),
  affected_records INTEGER,
  data_types TEXT[],      -- e.g.: ['email', 'phone', 'bank_info']
  description TEXT,
  containment_actions TEXT,
  notified_authority BOOLEAN DEFAULT false,
  notified_at TIMESTAMPTZ,
  notified_users BOOLEAN DEFAULT false,
  resolved_at TIMESTAMPTZ
);
```

**Process:**
1. Incident detected → log to `security_breaches` immediately
2. Assess whether personal data is affected
3. If YES → notify national authority (CNIL/DPA) **< 72h** after detection
4. If high risk to individuals → notify affected users without delay

### 9.3 Articles 44-49 — International Transfers (Schrems II)

**Applicable when US sub-processors handle EU data.**

| Sub-processor | Country | Required legal mechanism |
|---------------|------|----------------------|
| Stripe Inc. | USA | Standard Contractual Clauses (SCC) |
| Sentry (Functional Software) | USA | Standard Contractual Clauses (SCC) |
| Vercel Inc. | USA | SCC or EU DPA |
| Supabase Inc. | USA | DPA available at supabase.com/dpa |

**Privacy Policy obligations:**
```markdown
Our sub-processors located in the United States process your data
on the basis of Standard Contractual Clauses (SCC)
approved by the European Commission (Decision 2021/914).
```

**Never:** name US sub-processors without mentioning the legal transfer mechanism.

### 9.4 Circuit Breaker for Rate Limiting

**Problem:** A "fail-open" rate limiter (lets requests through when Redis is down) exposes the system to DoS attacks during a Redis outage.

```typescript
// ✅ Circuit breaker pattern with memory fallback
import { Ratelimit } from '@upstash/ratelimit'
import { Redis } from '@upstash/redis'

// In-memory fallback if Redis is unavailable
const MEMORY_STORE = new Map<string, { count: number; reset: number }>()

async function checkRateLimit(ip: string, limit: number, windowMs: number): Promise<boolean> {
  try {
    const ratelimit = new Ratelimit({
      redis: Redis.fromEnv(),
      limiter: Ratelimit.slidingWindow(limit, `${windowMs}ms`),
    })
    const { success } = await ratelimit.limit(ip)
    return success
  } catch {
    // Memory fallback if Redis is unavailable (fail-closed)
    const now = Date.now()
    const entry = MEMORY_STORE.get(ip)
    if (!entry || entry.reset < now) {
      MEMORY_STORE.set(ip, { count: 1, reset: now + windowMs })
      return true
    }
    if (entry.count >= limit) return false  // Block (fail-closed)
    entry.count++
    return true
  }
}
```

### 9.5 Data Retention Policies

**GDPR Article 5(1)(e) — Storage limitation.**

| Data type | Retention period | Justification |
|----------------|-------------------|---------------|
| Financial data (payments) | 6 years | Legal accounting obligation |
| Security audit logs | 12 months | Incident detection |
| User messages | Account duration + 30 days | Service continuity |
| Analytics (GA) | 13 months | Google Analytics standard |
| Expired session tokens | 24 hours | Automatic cleanup |
| Deleted account data | Immediate anonymization | Art. 17 right to erasure |

```sql
-- Recommended automatic cleanup (Supabase cron)
DELETE FROM audit_logs WHERE created_at < NOW() - INTERVAL '12 months';
DELETE FROM analytics_events WHERE created_at < NOW() - INTERVAL '13 months';
```

### 9.6 Protection Against Email Enumeration

**Principle:** never reveal whether an email exists or not — prevents reconnaissance attacks.

```typescript
// ✅ Generic response regardless of outcome
export async function POST(req: Request) {
  const { email } = await req.json()

  // Always the same delay (prevents timing attacks)
  await new Promise(resolve => setTimeout(resolve, 300))

  try {
    await createUser(email) // may fail silently
  } catch {
    // Never expose "this email is already in use"
  }

  // Same response, success or failure
  return NextResponse.json({
    message: 'If this email is valid, you will receive a confirmation link.'
  })
}
```

---

## 10. Pre-Deployment Security Checklist

- [ ] `npm audit --audit-level=critical` passes
- [ ] RLS enabled on all tables with user data
- [ ] No secret keys in the code or `.env.example`
- [ ] Security headers configured in `next.config.js`
- [ ] No unsafe HTML injection (or justified with sanitization)
- [ ] Zod validation on all external inputs
- [ ] Auth middleware on all protected routes
- [ ] HTTPS configured (Vercel default)
- [ ] Age verification implemented if minors' personal data is possible (GDPR Art. 8)
- [ ] `security_breaches` table created for incident traceability (GDPR Art. 34)
- [ ] US sub-processors documented with SCC mechanism in Privacy Policy (GDPR Art. 44-49)
- [ ] Rate limiter with circuit breaker (no fail-open)
- [ ] Data retention policies documented per data type (GDPR Art. 5)
- [ ] Generic auth responses (no email enumeration)

---

## 12. AI & Supply Chain Risks (2025-2026)

> Sources: OWASP LLM Top 10 2025, The Register (April 2025), Trend Micro, Anthropic Research, Veracode 2025.

### Slopsquatting — Active Threat on AI-Assisted Projects

**LLMs hallucinate non-existent NPM/PyPI packages in 19.7% of cases** (tested on 576,000 samples, 16 models — The Register, April 2025). Attackers register these names with malicious code. An `npm install` on an AI suggestion without verification can install malware.

**Seth Larson (Python Software Foundation security lead) named this vector "slopsquatting".**

**Mandatory verification protocol (any package suggested by AI):**

```bash
# Before any npm install suggested by Claude/ChatGPT/Copilot:

# 1. Verify the package exists on npmjs.com
npm info <package-name>

# 2. Check download count (legitimate packages = millions/week)
npm info <package-name> downloads-per-week 2>/dev/null || echo "Check on npmjs.com"

# 3. Check creation date (recently created package = suspicious)
npm info <package-name> time.created

# 4. Check the linked GitHub repo
npm info <package-name> repository

# 5. Scan after installation
npm audit
```

**Rules:**
- Every NPM/PyPI package suggested by an AI must be verified manually before installation
- Packages with <1000 downloads/week → enhanced source code review
- Never copy-paste an `npm install` from AI output without verifying the package exists

### AI-Generated Code Review Checklist

**Veracode 2025 GenAI Code Security Report: 45% of AI-generated code contains security vulnerabilities.** The 5 most frequent patterns to systematically verify:

| Pattern | Check |
|---------|-------------|
| **Broken Authentication** | Tokens exposed? No auth on protected routes? |
| **Injection** | Inputs validated with Zod? No manually built SQL? |
| **Sensitive Data Exposure** | Env vars not in code? No NEXT_PUBLIC_ on secrets? |
| **Missing Access Control** | RLS active? Auth middleware on all routes? |
| **Insecure Direct Object References** | URLs with IDs → ownership check in DB? |

**AI code review process:**
1. Read the generated code line by line (don't just "test if it works")
2. Apply the checklist above before any commit
3. Run `npm audit` after installing new packages
4. Scan `src/` for dangerous patterns (unsafe HTML injection, direct innerHTML assignments)

### RAG Poisoning — Threat for CozyGrowth/izzico Knowledge Bases

**Anthropic Research (2025): 5 carefully crafted documents are enough to manipulate AI responses 90% of the time** in a RAG system. Source: CSA 2025 "AI Security Threats".

**Mitigations:**

```typescript
// Validation of documents before injection into KB
function validateKBDocument(doc: string): boolean {
  // Detect prompt injection attempts in documents
  const injectionPatterns = [
    /ignore (all |previous |above )?instructions/i,
    /you are now/i,
    /system prompt/i,
  ]

  return !injectionPatterns.some(pattern => pattern.test(doc))
}

// For CozyGrowth: validate each KB document before insertion
function addToKnowledgeBase(doc: string, metadata: KBMetadata) {
  if (!validateKBDocument(doc)) {
    throw new Error('KB document rejected: injection attempt detected')
  }
  // Normal insertion...
}
```

**Sources:**

| Reference | Source |
|-----------|--------|
| OWASP LLM Top 10 2025 | genai.owasp.org/llmrisk |
| Slopsquatting — The Register | theregister.com/2025/04/12/ai_code_suggestions_sabotage_supply_chain |
| Slopsquatting — Trend Micro | trendmicro.com/vinfo/us/security/news/slopsquatting |
| AI Code Security — Veracode | veracode.com/blog/research/state-of-software-security-genai |
| RAG Poisoning — Anthropic | anthropic.com/research |
| OWASP LLM03:2025 Supply Chain | genai.owasp.org/llmrisk/llm032025-supply-chain |

---

## 13. Sources

| Reference | Link |
|-----------|------|
| OWASP Top 10 | owasp.org/www-project-top-ten |
| OWASP Top 10:2025 | owasptopten.org |
| NIST SP 800-63B | pages.nist.gov/800-63-4/sp800-63b.html |
| CWE Top 25 | cwe.mitre.org/top25 |
| OWASP Cheat Sheets | cheatsheetseries.owasp.org |
| Cloudflare — OWASP Top 10 | cloudflare.com/learning/security/threats/owasp-top-10 |
| GDPR — EU Regulation 2016/679 | eur-lex.europa.eu/legal-content/FR/TXT/?uri=CELEX%3A32016R0679 |
| CNIL — GDPR Developer Guide | cnil.fr/fr/la-securite-des-donnees-personnelles |
| EDPB — International Transfer Guidelines | edpb.europa.eu/our-work-tools/our-documents/guidelines |
| SCC — Commission Decision 2021/914 | eur-lex.europa.eu/eli/dec_impl/2021/914/oj |
