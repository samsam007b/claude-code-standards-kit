---
name: "contract-lookup"
description: "Find which SQWR contracts apply to a given task, feature, or domain. Returns specific rules and numerical thresholds."
effort: low
model: haiku
argument-hint: "domain or task description"
paths:
  - "contracts/**"
allowed-tools: ["Read", "Grep", "Glob"]
---

# /contract-lookup — Contract Lookup

**Usage:** `/contract-lookup [task or domain description]`

Finds the applicable SQWR contracts and specific rules for the task or domain described in `$ARGUMENTS`.

---

## How to use

Describe what you are building or the domain you are working in:

- `/contract-lookup user authentication form`
- `/contract-lookup payment integration`
- `/contract-lookup image gallery with lazy loading`
- `/contract-lookup REST API endpoint with rate limiting`
- `/contract-lookup database schema migration`

---

## Lookup process

1. **Parse the request**: Identify key technical domains in `$ARGUMENTS`

2. **Map domains to contracts**:

| Domain keyword | Contracts to check |
|---------------|-------------------|
| form, input, validation | CONTRACT-SECURITY §3, CONTRACT-ACCESSIBILITY §2 |
| password, auth, JWT | CONTRACT-SECURITY §1, CONTRACT-SUPABASE §2 |
| API, endpoint, REST, GraphQL | CONTRACT-API-DESIGN |
| database, schema, migration | CONTRACT-DATABASE-MIGRATIONS, CONTRACT-SUPABASE |
| performance, loading, LCP | CONTRACT-PERFORMANCE, CONTRACT-NEXTJS |
| accessibility, a11y, WCAG | CONTRACT-ACCESSIBILITY |
| TypeScript, types | CONTRACT-TYPESCRIPT |
| test, spec, coverage | CONTRACT-TESTING |
| deploy, CI, CD | CONTRACT-CICD, CONTRACT-VERCEL |
| error, exception | CONTRACT-ERROR-HANDLING |
| log, monitoring | CONTRACT-OBSERVABILITY |
| AI, LLM, prompt | CONTRACT-AI-PROMPTING, CONTRACT-ANTI-HALLUCINATION |
| image, video, media | CONTRACT-PERFORMANCE, CONTRACT-ACCESSIBILITY |
| email, SMTP | CONTRACT-EMAIL |
| SEO, metadata | CONTRACT-SEO |
| i18n, locale, translation | CONTRACT-I18N |
| iOS, Swift | CONTRACT-IOS |
| Android, Kotlin | CONTRACT-ANDROID |
| Python | CONTRACT-PYTHON |
| PDF | CONTRACT-PDF-GENERATION |
| animation, motion | CONTRACT-MOTION-DESIGN |
| analytics, events | CONTRACT-ANALYTICS |
| pricing, subscription | CONTRACT-PRICING |

3. **Read each relevant contract** and extract:
   - The specific sections that apply
   - The numerical thresholds (these are mandatory, not advisory)
   - The source standards (OWASP, WCAG, NIST, etc.)

4. **Output a summary** in this format:

```
## Applicable contracts for: [task description]

### CONTRACT-X.md — §N [Section name]
Rule: [exact rule with numerical threshold]
Source: [standard]
Why it applies: [reason]

### CONTRACT-Y.md — §M [Section name]
...
```

---

## Source

All contracts: `contracts/CONTRACT-*.md`
Source philosophy: `METHODOLOGY.md` — every rule must have a verifiable source with a numerical threshold.
