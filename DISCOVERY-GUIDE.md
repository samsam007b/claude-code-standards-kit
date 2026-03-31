# SQWR Project Kit — Discovery Guide

> **For whom?** Humans who want to understand what they are importing, why it exists, and how to develop it further.
> **Format:** Designed to be read in markdown or exported to PDF (see METHODOLOGY.md for the conversion command).

---

## What this kit is — in one sentence

A system of professional standards, grounded in real academic and industrial research, that enables a single person with Claude Code to produce deliverables at the level of expert teams.

---

## Why it exists

The success of a digital project — whether a SaaS app, a website, or a brand identity — does not depend solely on technical execution. It depends on knowledge of standards that already exist in every domain.

These standards are documented. They are public. They are accessible.

**The problem:** they are fragmented across dozens of sources, difficult to synthesise, and nobody tells you they exist or that you should be looking for them.

**The solution:** a kit that gathers these standards, structures them into actionable rules, and delivers them with sources so that every rule is verifiable — not one more opinion.

The method that produced this kit is itself documented in `METHODOLOGY.md`. It comes down to 5 words: **search first, implement after.**

---

## What you will find in this kit

### 38 Contracts — The rules to follow during construction

Contracts are markdown files you copy into your project (or reference in your `CLAUDE.md`). Each contract covers a domain and defines the rules with measurable thresholds and cited sources.

| Contract | Domain | Primary standard |
|---------|---------|-------------------|
| `CONTRACT-NEXTJS.md` | App Router, SSR, CWV | Google Core Web Vitals |
| `CONTRACT-SUPABASE.md` | Database, auth, RLS | NIST SP 800-63B |
| `CONTRACT-VERCEL.md` | Deployment, rollback, canary | Vercel docs + Martin Fowler |
| `CONTRACT-DESIGN.md` | Gestalt, typography, colour | Itten, Bringhurst, WCAG 2.1 |
| `CONTRACT-TYPESCRIPT.md` | TypeScript strict, SOLID | Robert C. Martin |
| `CONTRACT-TESTING.md` | Test pyramid, coverage | Martin Fowler, Agile Alliance |
| `CONTRACT-SECURITY.md` | OWASP Top 10, GDPR, XSS | OWASP, NIST, CWE Top 25 |
| `CONTRACT-PERFORMANCE.md` | LCP, INP, CLS, Lighthouse | Google, DebugBear |
| `CONTRACT-ACCESSIBILITY.md` | WCAG 2.1 AA + ARIA patterns | W3C, Nielsen NN/G, WAI-ARIA APG |
| `CONTRACT-ANTI-HALLUCINATION.md` | Real data, RAG | Nature 2025, OpenAI |
| `CONTRACT-AI-PROMPTING.md` | System prompts, few-shot | Anthropic, Lakera |
| `CONTRACT-OBSERVABILITY.md` | Logging, Sentry, RUM | Google SRE Book |
| `CONTRACT-RESILIENCE.md` | Retry, circuit breaker | AWS Well-Architected |
| `CONTRACT-GREEN-SOFTWARE.md` | Carbon impact, SCI | ISO/IEC 21031:2024 |
| `CONTRACT-PYTHON.md` | PEP 8, mypy, FastAPI | PEP standards, Python.org |
| `CONTRACT-IOS.md` | SwiftUI, touch targets, Dark Mode | Apple HIG, WCAG 2.5.5 |
| `CONTRACT-PDF-GENERATION.md` | Puppeteer, react-pdf, CSS Paged Media | W3C CSS Paged Media, pptr.dev |
| `CONTRACT-SEO.md` | SSR, metadata, JSON-LD, Core Web Vitals | Google Search Central, schema.org |
| `CONTRACT-EMAIL.md` | SPF/DKIM/DMARC, React Email, deliverability | RFC 7489, Google Sender Guidelines 2024 |
| `CONTRACT-CICD.md` | GitHub Actions, DORA metrics, branches | DORA Research 2023, semver.org |
| `CONTRACT-ANALYTICS.md` | HEART, AARRR, GA4, PostHog, event taxonomy | Google CHI 2010, Dave McClure 2007 |
| `CONTRACT-I18N.md` | next-intl, ICU, hreflang, RTL, Intl API | Unicode CLDR, W3C i18n |
| `CONTRACT-PRICING.md` | Van Westendorp, EVC, SaaS metrics, tiers | ESOMAR 1976, ProfitWell, SaaStr |
| `CONTRACT-ANDROID.md` | Jetpack Compose, Material 3, TalkBack, Vitals | Android Developers, m3.material.io |
| `CONTRACT-MOTION-DESIGN.md` | UI animation, Remotion, easing, prefers-reduced-motion | Material Design 3, Apple HIG, W3C WCAG 2.3 |
| `CONTRACT-VIDEO-PRODUCTION.md` | Video pipeline, platform export, ElevenLabs, AI studio | Instagram/TikTok/YouTube specs, NN/G |
| `CONTRACT-API-DESIGN.md` | REST/GraphQL design, versioning, rate limiting | RFC 7231, OpenAPI 3.1.0, OWASP API Security |
| `CONTRACT-DATABASE-MIGRATIONS.md` | Schema evolution, zero-downtime, rollback | Fowler 2016, PostgreSQL, AWS Well-Architected |
| `CONTRACT-ERROR-HANDLING.md` | Error boundaries, user messages, retry | Nielsen NN/G, Google SRE Book, React docs |

### 13 Frameworks — The situational tools

Frameworks are not permanent rules — they are tools to pull out at the right moment.

| Framework | When to use it |
|-----------|----------------|
| `BRAND-STRATEGY.md` | **Before any visual design** — positioning, archetypes, narrative |
| `PROJECT-SCOPING.md` | Before starting — Shape Up Pitch + Pre-mortem + Risk Register |
| `ESTIMATION.md` | Before any deadline commitment — PERT + ×1.5 solo+AI rule |
| `CLIENT-HANDOFF.md` | Final delivery — access, documentation, SLA |
| `INCIDENT-RESPONSE.md` | In the event of a production incident |
| `ADR-TEMPLATE.md` | For any important architectural decision |
| `SLO-TEMPLATE.md` | To define reliability objectives |
| `COMPLIANCE-EU.md` | Projects delivered to European clients |
| `DEPENDENCY-MANAGEMENT.md` | Setup + monthly dependency maintenance |
| `COMPETITIVE-AUDIT.md` | **Before any launch** — Blue Ocean, Nielsen Heuristics, Mystery Shopper |
| `CAMPAIGN-STRATEGY.md` | Campaign launch — SEE-THINK-DO-CARE, funnel, KPIs |
| `UX-RESEARCH.md` | **Before any feature** — JTBD, interviews, usability testing |
| `SOCIAL-CONTENT.md` | Social presence launch — pillars, calendar, tone, creators |

### 13 Audits — The measurement tools

Audits allow scoring /100 for each domain at any point in the project.

| Audit | Weight | Blocking threshold |
|-------|-------|---------------|
| Security | 22% | < 70 = blocking |
| Performance | 18% | < 70 recommended |
| Code Quality | 18% | < 75 recommended |
| Observability | 12% | < 60 recommended |
| Accessibility | 12% | < 80 recommended (+ EU legal) |
| Design | 8% | < 70 recommended |
| AI Governance | 5% | < 80 recommended |
| Deployment | 5% | Pre-production gate |
| GDPR | — | ≥80/100 before public prod |
| Brand Strategy | — | Before launch or repositioning |
| Resilience | — | ≥70 recommended |

**Target score with this kit: ≥85/100** (verify-kit.sh baseline + AGENT-FULL-AUDIT.md)

**SQWR Risk Score (composite):** The `/risk-score` skill computes a weighted composite score (0–100) across all audit dimensions using the formula: `(Security×0.22 + Performance×0.18 + CodeQuality×0.18 + Observability×0.12 + Accessibility×0.12 + Design×0.08 + AIGovernance×0.05 + Deployment×0.05)`. A score below 70 triggers a blocking review before any production deployment.

### 5 Templates — Files to copy into every project

```
CLAUDE.md          → Universal AI contract (the most important)
.env.example       → Documented environment variables
.gitignore         → Multi-stack (Node, Next, Python, macOS)
CHANGELOG.md       → Keep a Changelog 1.1.0 + SemVer 2.0.0
CONTRIBUTING.md    → Conventional Commits + AI rules
```

### 9 Skills — Executable workflows

Slash commands that run complex workflows automatically:

| Skill | Invocation | What it does |
|-------|-----------|-------------|
| `new-feature` | `/new-feature [description]` | RESEARCH → CONTRACT → CODE → AUDIT cycle |
| `pre-deployment` | `/pre-deployment` | All blocking gates before merging to main |
| `monthly-review` | `/monthly-review` | Full audit + deps + SLO + contract validation |
| `contract-lookup` | `/contract-lookup [task]` | Finds applicable contracts with exact rules |
| `audit-runner` | `/audit-runner [domain\|full]` | Runs specific or full audit suite |
| `project-setup` | `/project-setup [name] [stack] [path]` | Bootstraps new project interactively |
| `auto-fix` | `/auto-fix` | Automatically fix console.log, alt text, TODO format |
| `compliance-check` | `/compliance-check [regulation]` | EU regulatory compliance (EAA, GDPR, AI Act) |
| `risk-score` | `/risk-score [quick\|full]` | Compute composite SQWR Risk Score (0-100) |

## Modular Rules (6)

The `rules/` directory contains contextual rules that Claude Code activates based on file paths:

| Rule | Activated for | Key constraints |
|------|--------------|-----------------|
| security-rules.md | src/**, api/**, lib/** | No SQL injection, no hardcoded secrets, input validation |
| accessibility-rules.md | components/**, pages/**, *.html | Alt text, contrast ≥4.5:1, keyboard nav |
| performance-rules.md | src/**, next.config.* | LCP ≤2.5s, INP ≤200ms, CLS ≤0.1 |
| api-rules.md | api/**, src/app/api/** | Rate limiting, auth headers, schema validation |
| testing-rules.md | __tests__/**, *.test.* | Coverage ≥80%, test pyramid, no mocks of internals |
| documentation-rules.md | *.md, docs/** | README requirements, link validation, code examples |

### 4 Commands — Slash commands

| Command | What it does |
|---------|-------------|
| `/init-project` | Runs `init-project.sh` + validates output |
| `/full-audit` | Runs `AGENT-FULL-AUDIT.md` |
| `/verify-kit` | Runs `verify-kit.sh` |
| `/verify-project` | Validates a project CLAUDE.md |

### 3 Scripts — Automation

```bash
# Full bootstrap of a new project (legacy mode)
bash scripts/init-project.sh --name "mon-projet" --stack "nextjs-supabase" --path "~/Desktop/mon-projet"

# Full bootstrap with plugin mode (copies skills, commands, hooks.json)
bash scripts/init-project.sh --name "mon-projet" --stack "nextjs-supabase" --path "~/Desktop/mon-projet" --plugin

# Verify kit integrity
bash scripts/verify-kit.sh --verbose

# Validate that a project CLAUDE.md is complete
bash scripts/validate-claude-md.sh ~/mon-projet/CLAUDE.md
```

---

## The 10-Minute Tour

### Minutes 1-2: Understand the philosophy

Read `METHODOLOGY.md` — the first 3 sections. This is the "why" behind everything else.

### Minutes 3-4: Bootstrap a test project

```bash
bash scripts/init-project.sh \
  --name "test-kit" \
  --stack "nextjs-supabase" \
  --path "/tmp/test-kit"
```

Observe what is generated: a pre-filled CLAUDE.md, copied contracts, a CHANGELOG initialised with today's date, a CONTRIBUTING.md with the project name.

### Minutes 5-6: Read a contract

Open `contracts/CONTRACT-SECURITY.md`. Observe the structure:
- Every rule has a numerical threshold (not "good contrast" but "≥4.5:1")
- Every section cites its source (OWASP, NIST, W3C)
- Verification commands are included

That is the difference between "having good practices" and "knowing the professional standards".

### Minutes 7-8: Run an audit

Open `audits/AUDIT-INDEX.md`. Follow the sequencing. Run `AUDIT-SECURITY.md` on any existing project.

### Minutes 7-8 (continued): Try a skill

After reading a contract, try the contract lookup skill:

```
Ask Claude: "/contract-lookup user signup form with email validation"
```

Observe how it maps your task description to specific contract sections and numerical thresholds.

Then try the audit runner on a test project:
```
Ask Claude: "/audit-runner security"
```

### Minutes 9-10: Explore the frameworks

Open `frameworks/BRAND-STRATEGY.md`. Even if you only write code, understanding the section on the Golden Circle (Simon Sinek) changes the way you write READMEs, landing pages, and client briefs.

---

## The discipline of brand

> This section is the kit's rarest contribution — absent from virtually all technical starter kits.

**The success of an app or an agency does not depend solely on infrastructure.** It depends on answering questions that most developers never ask:

- **Why** does this product exist, beyond its functionality?
- **For whom** exactly — and what deep desire are we addressing?
- **How** does it differentiate itself in a credible and memorable way?
- **What story** are we giving the user to live?

These questions have scientific answers. Simon Sinek formalised the WHY (60M+ TED views). Carl Jung provided universal psychological archetypes. Donald Miller structured the narrative. Al Ries and Jack Trout theorised mental positioning.

**The strongest brand is not the most beautiful — it is the one that best answers these questions.**

`frameworks/BRAND-STRATEGY.md` contains the tools to answer these questions before starting the visual design.

---

## How to develop this kit

This kit is a foundation, not a finished product. It is built to grow with every project.

### Contribution principles

**1. Mandatory grounding**
Every new rule must have a verifiable source (Tier 1 = official, Tier 2 = academic). "It's a best practice" without a source has no place here.

**2. Numerical threshold**
"Correct performance" is not a rule. "LCP ≤2.5s (75th percentile, Google CWV)" is a rule.

**3. Consistent structure**
Follow the format of existing contracts: introduction → numbered sections → subtotal → score → sources.

**4. Open/Closed**
Open to extension (new contracts), closed to unsourced modification (no removal of sources without a replacement).

### Potential future domains

| Domain | Priority | Sources to explore |
|---------|---------|-------------------|
| WebAssembly | P2 | W3C WASM spec, Emscripten docs, Bytecode Alliance |
| Monorepo tooling | P2 | Turborepo docs, Nx documentation, pnpm workspaces |
| Supply chain security | P2 | SLSA framework, SBOM (CycloneDX), CISA guidance |

---

## About this kit

This kit was developed by **[Samuel Baudon](https://sqwr.be)** ([SQWR Studio](https://sqwr.be), Brussels) from 2024, refined across dozens of real projects — websites, SaaS applications, academic projects, brand identities.

It is the public method of SQWR Studio — the studio that created it, maintains it, and applies it as a delivery baseline on every project.

It reflects a conviction: **AI tools like Claude Code are not shortcuts to mediocrity — they are amplifiers of rigour for those who have the method.**

The method is this kit.

---

## Want this level of quality without handling it yourself?

**What SQWR Studio offers:**
- **Project audit** — score your existing codebase against the kit's standards (/100 per domain, PDF report)
- **Kit setup** — integrate the kit into your stack and train your team
- **Project delivery** — Next.js / Supabase / iOS development at the standards described here

> A score ≥85/100 is not a goal — it is our delivery baseline.

**Contact:** [studio@sqwr.be](mailto:studio@sqwr.be) · [sqwr.be](https://sqwr.be)

---

## Licence & Sharing

This kit is free to use, modify, and distribute.
If you improve it, sharing your improvements benefits everyone.

**Attribution appreciated but not required:**
> Based on [Claude Code Standards Kit](https://github.com/samsam007b/claude-code-standards-kit) — [SQWR Studio](https://sqwr.be)

---

## Further resources

**On Claude Code:**
- `METHODOLOGY.md` — The full working method
- Anthropic docs: docs.anthropic.com
- Claude Code changelog: github.com/anthropics/claude-code

**On standards:**
- OWASP: owasp.org
- WCAG 2.1: w3.org/WAI/WCAG21
- Google SRE Book: sre.google/sre-book
- Nielsen Norman Group: nngroup.com

**On brand strategy:**
- Simon Sinek, *Start With Why* (2009)
- Donald Miller, *Building a StoryBrand* (2017)
- Marty Neumeier, *The Brand Gap* (2005)

**On estimation & project management:**
- Ryan Singer, *Shape Up* (basecamp.com/shapeup) — free online
- Daniel Kahneman, *Thinking, Fast and Slow* (2011) — planning bias

---

## Worked Example — Adding a User Signup Form

This is a complete walkthrough of the RESEARCH → CONTRACT → CODE → AUDIT workflow for a real feature.

**Feature**: Add an email + password signup form with validation, error handling, and accessibility.

---

### Step 1 — RESEARCH (20 min)

Before writing a single line of code, identify the applicable standards.

**Contracts to read for this feature:**
- `docs/contracts/CONTRACT-SECURITY.md` → Input validation (Zod), no plaintext passwords
- `docs/contracts/CONTRACT-ACCESSIBILITY.md` → Label/input association (WCAG 1.3.1), error message association (WCAG 3.3.1)
- `docs/contracts/CONTRACT-TYPESCRIPT.md` → Type the form state, use strict types
- `docs/contracts/CONTRACT-ERROR-HANDLING.md` → Nielsen's 4 error message principles

**Key rules identified:**
- Passwords must be hashed with bcrypt (cost factor ≥12) — NIST SP 800-63B
- Email must be validated with Zod before any DB write — OWASP A03
- Each form field must have a `<label>` associated via `htmlFor` — WCAG 1.3.1
- Error messages must say what happened + why + solution — Nielsen 1993
- `@ts-ignore` is forbidden; type the entire form state

---

### Step 2 — CONTRACT (5 min)

Update your project's `CLAUDE.md` to note which contracts are active for this feature:

```
Active for this sprint: CONTRACT-SECURITY (§3 Input Validation), CONTRACT-ACCESSIBILITY (§2 Forms), CONTRACT-ERROR-HANDLING (§1 User Messages)
```

---

### Step 3 — CODE (implementation)

With contracts active, Claude Code will apply the rules automatically via hooks:

```typescript
// Zod schema — CONTRACT-SECURITY §3
const SignupSchema = z.object({
  email: z.string().email("Please enter a valid email address"),
  password: z.string()
    .min(12, "Password must be at least 12 characters")
    .regex(/[A-Z]/, "Password must contain at least one uppercase letter"),
})

// Error messages follow Nielsen's 4 principles
// "Your password is too short" — what happened
// "Passwords must be at least 12 characters" — why
// "Add more characters to continue" — solution
// (no "Error code: PASS_001" — human language)
```

The `hook-contract-compliance.sh` will warn if:
- `any` type is used (>3 times)
- `console.log` is present in the signup handler
- `<img>` is added without `alt`

---

### Step 4 — AUDIT (30 min)

After implementing the feature, run the relevant agents:

```
Ask Claude: "Run .claude/agents/AGENT-SECURITY-AUDIT.md"
Ask Claude: "Run .claude/agents/AGENT-ACCESSIBILITY-AUDIT.md"
```

**Sample expected results:**

```
SQWR SECURITY AUDIT — my-project
Score   : 84/100    Status: PASS
Level 1 : 5/6       (middleware missing — add middleware.ts)
Level 2 : 6/7       (no rate limiting on /api/signup — add Upstash)
Level 3 : 5/5       ✓
Level 4 : 4/5       (manual test: CSRF verified via SameSite cookies)

SQWR ACCESSIBILITY AUDIT — my-project
Score   : 91/100    Status: PASS
Level 1 : 6/7       (missing skip-to-content link)
Level 2 : 7/8       (one fieldset/legend missing on address group)
Level 3 : 5/5       ✓
Level 4 : 4/5       (screen reader test: passed with VoiceOver)
```

**Action from audit:**
- Security 84/100: add rate limiting (`upstash/ratelimit`) to `/api/auth/signup`
- Accessibility 91/100: add `<fieldset><legend>Account Details</legend>` around email+password fields

After fixing: re-run audit → SECURITY 89/100, ACCESSIBILITY 95/100. Ship.

---

**The complete cycle took:** Research 20min + Contract 5min + Code [variable] + Audit 30min = 55 minutes of overhead for a production-grade, standards-compliant feature.
