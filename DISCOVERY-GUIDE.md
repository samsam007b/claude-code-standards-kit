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

### 26 Contracts — The rules to follow during construction

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

### 11 Audits — The measurement tools

Audits allow scoring /100 for each domain at any point in the project.

| Audit | Weight | Blocking threshold |
|-------|-------|---------------|
| Security | 22% | < 70 = blocking |
| Performance | 18% | < 70 recommended |
| Code Quality | 18% | < 75 recommended |
| Observability | 12% | < 70 recommended |
| Accessibility | 12% | < 80 recommended (+ EU legal) |
| Design | 8% | < 70 recommended |
| AI Governance | 5% | < 80 recommended |
| Deployment | 5% | Pre-production gate |
| GDPR | — | ≥80/100 before public prod |
| Brand Strategy | — | Before launch or repositioning |

**Average score without this kit: ~51/100**
**Target score with this kit: ≥85/100**

### 5 Templates — Files to copy into every project

```
CLAUDE.md          → Universal AI contract (the most important)
.env.example       → Documented environment variables
.gitignore         → Multi-stack (Node, Next, Python, macOS)
CHANGELOG.md       → Keep a Changelog 1.1.0 + SemVer 2.0.0
CONTRIBUTING.md    → Conventional Commits + AI rules
```

### 3 Scripts — Automation

```bash
# Full bootstrap of a new project
bash scripts/init-project.sh --name "mon-projet" --stack "nextjs-supabase" --path "~/Desktop/mon-projet"

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

### Uncovered domains — extension opportunities

| Domain | Priority | Sources to explore |
|---------|---------|-------------------|
| Android | P2 | Material Design 3, Android Accessibility advanced (Compose) |
| Internationalisation (i18n) | P2 | Next.js i18n docs, Unicode CLDR, ICU Message Format |
| Pricing & monetisation | P2 | Van Westendorp, Price Intelligently, value-based pricing |
| User research (UX) | P2 | JTBD (Christensen), Nielsen usability testing, Baymard Institute |
| Android | P3 | Material Design 3, Android Accessibility (WCAG) |

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
