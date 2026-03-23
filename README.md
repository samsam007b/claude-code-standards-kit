<div align="center">

# Claude Code Standards Kit

**Professional standards for Claude Code — grounded in science, not opinions.**

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![67 files](https://img.shields.io/badge/67%20files-organised-green.svg)]()
[![Self-audit](https://img.shields.io/badge/self--audit-91%2F100-brightgreen.svg)]()
[![Made for Claude Code](https://img.shields.io/badge/made%20for-Claude%20Code-orange.svg)]()
[![By SQWR Studio](https://img.shields.io/badge/by-SQWR%20Studio-black.svg)](https://sqwr.be)

<sub>Designed and maintained by <a href="https://sqwr.be"><strong>SQWR Studio</strong></a> — Branding & Web · <a href="https://sqwr.be">sqwr.be</a> · <a href="mailto:studio@sqwr.be">studio@sqwr.be</a></sub>

</div>

---

A solo developer with Claude Code can write code. But does that code comply with OWASP? WCAG 2.1? Core Web Vitals? AWS Well-Architected standards?

**Most of the time: no.** Not for lack of talent — for lack of method.

```
Without this kit   ████████████░░░░░░░░  ~51/100
With this kit      █████████████████░░░  ≥85/100
```

> **Professional quality is not in the code — it is in the research that precedes the code.**

---

## Quick start

```bash
# 1. Clone the kit
git clone https://github.com/samsam007b/claude-code-standards-kit ~/Desktop/Project-Kit

# 2. Bootstrap a new project
bash ~/Desktop/Project-Kit/scripts/init-project.sh \
  --name "mon-projet" --stack "nextjs-supabase" --path "~/Desktop/mon-projet"

# 3. Verify kit integrity
bash ~/Desktop/Project-Kit/scripts/verify-kit.sh --verbose
```

**Available stacks:** `nextjs-supabase` · `nextjs` · `nextjs-supabase-ai` · `python`

---

## How it works

```
  RESEARCH   →  CONTRACT  →  CODE  →  AUDIT

  "What are     Rules +      Claude Code   Score /100
  the pro       thresholds   follows the   per domain
  standards     + cited      contract      (≥85 target)
  on this       sources
  topic?"
```

Claude Code does not start from opinions. It looks up existing standards, synthesises them into actionable rules, then applies them. This kit structures that workflow across 15 domains.

Read [`METHODOLOGY.md`](METHODOLOGY.md) for the full method.

---

## What is included

| Category | Files | Role |
|-----------|---------|------|
| **Contracts** | 26 | Business rules with numerical thresholds — copy into `CLAUDE.md` |
| **Frameworks** | 13 | Situational tools (branding, estimation, incident, campaign…) |
| **Audits** | 11 | Scoring /100 per domain — run before each delivery |
| **Templates** | 5 | `CLAUDE.md`, `.env.example`, `.gitignore`, `CHANGELOG.md`, `CONTRIBUTING.md` |
| **Scripts** | 3 | `init-project.sh`, `verify-kit.sh`, `validate-claude-md.sh` |

---

## The contracts

> Every rule has a numerical threshold. Every threshold has a verifiable source.

| Contract | Domain | Standard |
|---------|---------|----------|
| [`CONTRACT-NEXTJS.md`](contracts/CONTRACT-NEXTJS.md) | App Router, SSR, CWV | Google Core Web Vitals |
| [`CONTRACT-SUPABASE.md`](contracts/CONTRACT-SUPABASE.md) | Database, RLS, auth | NIST SP 800-63B |
| [`CONTRACT-VERCEL.md`](contracts/CONTRACT-VERCEL.md) | Deployment, rollback, canary | Vercel docs + Martin Fowler |
| [`CONTRACT-DESIGN.md`](contracts/CONTRACT-DESIGN.md) | Gestalt, typography, colour | Itten, Bringhurst, WCAG 2.1 |
| [`CONTRACT-TYPESCRIPT.md`](contracts/CONTRACT-TYPESCRIPT.md) | TypeScript strict, SOLID | Robert C. Martin |
| [`CONTRACT-TESTING.md`](contracts/CONTRACT-TESTING.md) | Test pyramid, coverage | Martin Fowler, Agile Alliance |
| [`CONTRACT-SECURITY.md`](contracts/CONTRACT-SECURITY.md) | OWASP Top 10, secrets, XSS | OWASP, NIST, CWE Top 25 |
| [`CONTRACT-PERFORMANCE.md`](contracts/CONTRACT-PERFORMANCE.md) | LCP, INP, CLS, Lighthouse | Google, DebugBear |
| [`CONTRACT-ACCESSIBILITY.md`](contracts/CONTRACT-ACCESSIBILITY.md) | WCAG 2.1 AA + EAA (EU law) | W3C, Nielsen NN/G |
| [`CONTRACT-ANTI-HALLUCINATION.md`](contracts/CONTRACT-ANTI-HALLUCINATION.md) | Real data, RAG, context poisoning | Nature 2025, OpenAI |
| [`CONTRACT-AI-PROMPTING.md`](contracts/CONTRACT-AI-PROMPTING.md) | System prompts, few-shot, models | Anthropic, Lakera |
| [`CONTRACT-OBSERVABILITY.md`](contracts/CONTRACT-OBSERVABILITY.md) | Structured logging, Sentry, RUM | Google SRE Book |
| [`CONTRACT-RESILIENCE.md`](contracts/CONTRACT-RESILIENCE.md) | Retry, circuit breaker, graceful degradation | AWS Well-Architected |
| [`CONTRACT-GREEN-SOFTWARE.md`](contracts/CONTRACT-GREEN-SOFTWARE.md) | Carbon impact, SCI | ISO/IEC 21031:2024 |
| [`CONTRACT-PYTHON.md`](contracts/CONTRACT-PYTHON.md) | PEP 8, mypy, FastAPI, packaging | PEP standards, Python.org |
| [`CONTRACT-IOS.md`](contracts/CONTRACT-IOS.md) | SwiftUI, touch targets, Dark Mode | Apple HIG, WCAG 2.5.5 |
| [`CONTRACT-PDF-GENERATION.md`](contracts/CONTRACT-PDF-GENERATION.md) | Puppeteer, react-pdf, CSS Paged Media | W3C CSS Paged Media, pptr.dev |
| [`CONTRACT-SEO.md`](contracts/CONTRACT-SEO.md) | SSR, metadata, JSON-LD, Core Web Vitals | Google Search Central, schema.org |
| [`CONTRACT-EMAIL.md`](contracts/CONTRACT-EMAIL.md) | SPF/DKIM/DMARC, React Email, deliverability | RFC 7489, Google Sender Guidelines 2024 |
| [`CONTRACT-CICD.md`](contracts/CONTRACT-CICD.md) | GitHub Actions, DORA, branches, Conventional Commits | DORA Research, semver.org |
| [`CONTRACT-ANALYTICS.md`](contracts/CONTRACT-ANALYTICS.md) | HEART, AARRR, GA4, PostHog, event taxonomy | Google CHI 2010, Dave McClure 2007 |
| [`CONTRACT-I18N.md`](contracts/CONTRACT-I18N.md) | next-intl, ICU, hreflang, RTL, Intl API | Unicode CLDR, W3C i18n |
| [`CONTRACT-PRICING.md`](contracts/CONTRACT-PRICING.md) | Van Westendorp, EVC, SaaS metrics, tiers | ESOMAR 1976, ProfitWell, SaaStr |
| [`CONTRACT-ANDROID.md`](contracts/CONTRACT-ANDROID.md) | Jetpack Compose, Material 3, TalkBack, Vitals | Android Developers, m3.material.io |
| [`CONTRACT-MOTION-DESIGN.md`](contracts/CONTRACT-MOTION-DESIGN.md) | UI animation, Remotion, easing, prefers-reduced-motion | Material Design 3, Apple HIG, W3C WCAG 2.3 |
| [`CONTRACT-VIDEO-PRODUCTION.md`](contracts/CONTRACT-VIDEO-PRODUCTION.md) | Video pipeline, platform export, ElevenLabs, AI studio | Instagram/TikTok/YouTube specs, NN/G |

---

## The audit system

Score /100 before each delivery. **Delivery threshold: ≥85/100 overall.**

| Audit | Weight | Blocking |
|-------|-------|---------|
| [`AUDIT-SECURITY.md`](audits/AUDIT-SECURITY.md) | 22% | < 70 = blocking |
| [`AUDIT-PERFORMANCE.md`](audits/AUDIT-PERFORMANCE.md) | 18% | < 70 recommended |
| [`AUDIT-CODE-QUALITY.md`](audits/AUDIT-CODE-QUALITY.md) | 18% | < 75 recommended |
| [`AUDIT-OBSERVABILITY.md`](audits/AUDIT-OBSERVABILITY.md) | 12% | < 70 recommended |
| [`AUDIT-ACCESSIBILITY.md`](audits/AUDIT-ACCESSIBILITY.md) | 12% | < 80 + EU legal |
| [`AUDIT-DESIGN.md`](audits/AUDIT-DESIGN.md) | 8% | < 70 recommended |
| [`AUDIT-AI-GOVERNANCE.md`](audits/AUDIT-AI-GOVERNANCE.md) | 5% | < 80 recommended |
| [`AUDIT-DEPLOYMENT.md`](audits/AUDIT-DEPLOYMENT.md) | 5% | Pre-production gate |
| [`AUDIT-RGPD.md`](audits/AUDIT-RGPD.md) | — | ≥80/100 before public prod |
| [`AUDIT-BRAND-STRATEGY.md`](audits/AUDIT-BRAND-STRATEGY.md) | — | Before launch or repositioning |

See [`audits/AUDIT-INDEX.md`](audits/AUDIT-INDEX.md) for the sequencing.

---

## Why this kit?

**What sets it apart from all other starter kits:**

**1. Numerical thresholds, not opinions**
`"LCP ≤2.5s (p75)"` — not `"good performance"`. Every rule is measurable.

**2. Mandatory Tier 1/2 sources**
OWASP, WCAG, Google SRE, NIST, Nielsen NN/G, W3C. No "it is recommended to".

**3. Brand strategy included**
[`frameworks/BRAND-STRATEGY.md`](frameworks/BRAND-STRATEGY.md) covers Sinek, Jung, StoryBrand, Blue Ocean. **Absent from 99% of technical starter kits.**

**4. Built-in EU legal compliance**
EAA (active since June 2025), EU AI Act, GDPR. See [`frameworks/COMPLIANCE-EU.md`](frameworks/COMPLIANCE-EU.md).

**5. The kit applies itself**
Self-audit: **91/100**. `bash scripts/verify-kit.sh --verbose` → 0 errors.

---

## Situational frameworks

| Framework | Pull it when |
|-----------|-------------|
| [`BRAND-STRATEGY.md`](frameworks/BRAND-STRATEGY.md) | **Before any visual design** — Golden Circle, archetypes, narrative |
| [`PROJECT-SCOPING.md`](frameworks/PROJECT-SCOPING.md) | Before starting — Shape Up Pitch + Pre-mortem |
| [`ESTIMATION.md`](frameworks/ESTIMATION.md) | Before any deadline commitment — PERT + ×1.5 rule |
| [`CLIENT-HANDOFF.md`](frameworks/CLIENT-HANDOFF.md) | Final delivery — access, docs, SLA |
| [`INCIDENT-RESPONSE.md`](frameworks/INCIDENT-RESPONSE.md) | Service outage — blameless postmortem |
| [`ADR-TEMPLATE.md`](frameworks/ADR-TEMPLATE.md) | New architectural decision |
| [`SLO-TEMPLATE.md`](frameworks/SLO-TEMPLATE.md) | Define reliability objectives |
| [`COMPLIANCE-EU.md`](frameworks/COMPLIANCE-EU.md) | Project delivered to European clients |
| [`DEPENDENCY-MANAGEMENT.md`](frameworks/DEPENDENCY-MANAGEMENT.md) | Setup + monthly dependency maintenance |
| [`COMPETITIVE-AUDIT.md`](frameworks/COMPETITIVE-AUDIT.md) | **Before any launch** — Blue Ocean, Nielsen Heuristics, Mystery Shopper |
| [`CAMPAIGN-STRATEGY.md`](frameworks/CAMPAIGN-STRATEGY.md) | Campaign launch — SEE-THINK-DO-CARE, funnel, KPIs |
| [`UX-RESEARCH.md`](frameworks/UX-RESEARCH.md) | **Before any feature** — JTBD, interviews, usability testing (Nielsen, Fitzpatrick) |
| [`SOCIAL-CONTENT.md`](frameworks/SOCIAL-CONTENT.md) | Social presence launch — pillars, calendar, tone, creators |

---

## Integrated sources (excerpt)

| Domain | Sources |
|---------|--------|
| Security | OWASP Top 10, NIST SP 800-63B, CWE Top 25 |
| Performance | Google Core Web Vitals, DebugBear |
| Accessibility | WCAG 2.1 W3C, EN 301 549, Nielsen Norman Group |
| Design | Gestalt (1920), Bringhurst (1992), Baymard Institute |
| Testing | Martin Fowler pyramid, Agile Alliance DoD |
| Reliability | Google SRE Book, AWS Well-Architected |
| Resilience | Michael Nygard (Release It! 2018) |
| Green IT | ISO/IEC 21031:2024 (SCI) |
| Brand | Sinek (2009), Jung/Mark & Pearson (2001), Donald Miller (2017) |
| Estimation | PERT (1957), Kahneman & Tversky (Nobel 2002) |
| AI / LLM | Anthropic docs, Lakera, Nature 2025 |
| EU Legal | Regulation EU 2024/1689, EAA, ENISA NIS2 |

---

## Full structure

```
project-kit/
├── IDENTITY-TEMPLATE.md    → Identity sheet to personalise
├── METHODOLOGY.md          → Full method (read first)
├── DISCOVERY-GUIDE.md      → 10-Minute kit tour, PDF-ready
├── contracts/              → 26 contracts (thresholds + sources)
├── frameworks/             → 13 situational tools
├── audits/                 → 11 audits scoring /100
├── templates/              → CLAUDE.md, .env.example, .gitignore…
└── scripts/                → init-project.sh, verify-kit.sh, validate-claude-md.sh
```

---

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md).

**Golden rule:** every new rule = a Tier 1 source (official docs) or Tier 2 (academic/industrial). No opinions without a source. Numerical threshold required.

---

## Want this level of quality without handling it yourself?

This kit is the public method of **[SQWR Studio](https://sqwr.be)** — the studio that created it, refined it across dozens of real projects, and applies it to every delivery.

**What SQWR Studio offers:**
- **Project audit** — score your existing codebase against the kit's standards (/100 per domain, PDF report)
- **Kit setup** — integrate the kit into your stack and train your team
- **Project delivery** — Next.js / Supabase / iOS development at the standards described here

> A score ≥85/100 is not a goal — it is our delivery baseline.

**Contact:** [studio@sqwr.be](mailto:studio@sqwr.be) · [sqwr.be](https://sqwr.be)

---

## Licence

MIT — free to use, modify, and distribute.

---

<div align="center">
<sub>
<a href="METHODOLOGY.md">Methodology</a> · <a href="DISCOVERY-GUIDE.md">10-Minute Tour</a> · <a href="audits/AUDIT-INDEX.md">Run an audit</a> · <a href="https://sqwr.be">SQWR Studio</a> · <a href="mailto:studio@sqwr.be">studio@sqwr.be</a>
</sub>
</div>
