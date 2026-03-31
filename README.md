<div align="center">

# Claude Code Standards Kit

**Professional standards for Claude Code — grounded in science, not opinions.**

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![113 files](https://img.shields.io/badge/113%20files-organised-green.svg)]()
[![Self-audit](https://img.shields.io/badge/self--audit-91%2F100-brightgreen.svg)]()
[![Made for Claude Code](https://img.shields.io/badge/made%20for-Claude%20Code-orange.svg)]()
[![By SQWR Studio](https://img.shields.io/badge/by-SQWR%20Studio-black.svg)](https://sqwr.be)
[![SQWR Kit Verification](https://github.com/samsam007b/claude-code-standards-kit/actions/workflows/verify-kit.yml/badge.svg)](https://github.com/samsam007b/claude-code-standards-kit/actions/workflows/verify-kit.yml)

<sub>Designed and maintained by <a href="https://sqwr.be"><strong>SQWR Studio</strong></a> — Branding & Web · <a href="https://sqwr.be">sqwr.be</a> · <a href="mailto:studio@sqwr.be">studio@sqwr.be</a></sub>

</div>

---

A solo developer with Claude Code can write code. But does that code comply with OWASP? WCAG 2.1? Core Web Vitals? AWS Well-Architected standards?

**Most of the time: no.** Not for lack of talent — for lack of method.

The kit provides measurable, threshold-based standards for each domain.
Projects that apply these standards consistently reach ≥85/100 when audited
against them — the same standards the kit applies to itself.

Run `bash scripts/verify-kit.sh --verbose` to see the kit score its own components.

> **Professional quality is not in the code — it is in the research that precedes the code.**

---

## Quick start

```bash
# 1. Clone the kit
git clone https://github.com/samsam007b/claude-code-standards-kit ~/Desktop/Project-Kit

# 2. Bootstrap a new project (legacy mode — copies settings.json)
bash ~/Desktop/Project-Kit/scripts/init-project.sh \
  --name "my-project" --stack "nextjs-supabase" --path "~/Desktop/my-project"

# 2b. Bootstrap with plugin mode (copies hooks.json + skills + commands)
bash ~/Desktop/Project-Kit/scripts/init-project.sh \
  --name "my-project" --stack "nextjs-supabase" --path "~/Desktop/my-project" --plugin

# 3. Verify kit integrity
bash ~/Desktop/Project-Kit/scripts/verify-kit.sh --verbose

# 4. Verify project health
bash ~/Desktop/Project-Kit/scripts/verify-project.sh --path ~/Desktop/my-project
```

**Available stacks:** `nextjs-supabase` · `nextjs` · `nextjs-supabase-ai` · `python` · `ios` · `android` · `fullstack`

**Which stack should I choose?**

| You are building... | Stack |
|---------------------|-------|
| SaaS web app with auth + database | `nextjs-supabase` |
| Marketing site or static content | `nextjs` |
| AI-powered product (chatbot, copilot, RAG) | `nextjs-supabase-ai` |
| Backend API or data pipeline | `python` |
| Native iPhone / iPad app | `ios` |
| Native Android app | `android` |
| Full platform — all 38 contract domains | `fullstack` |

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

Claude Code does not start from opinions. It looks up existing standards, synthesises them into actionable rules, then applies them. This kit structures that workflow across 38 contract domains.

Read [`METHODOLOGY.md`](METHODOLOGY.md) for the full method.

---

## What is included

| Category | Files | Role |
|-----------|---------|------|
| **Contracts** | 38 | Business rules with numerical thresholds — copy into `CLAUDE.md` |
| **Frameworks** | 13 | Situational tools (branding, estimation, incident, campaign…) |
| **Audits** | 13 | Scoring /100 per domain — run before each delivery |
| **Agents** | 11 | Automated audit agents with 4-level verification — place in `.claude/agents/` |
| **Skills** | 9 | Slash-command workflows — `/new-feature`, `/pre-deployment`, `/monthly-review`, `/audit-runner`, `/contract-lookup`, `/project-setup`, `/auto-fix`, `/compliance-check`, `/risk-score` |
| **Commands** | 4 | Slash commands — `/init-project`, `/full-audit`, `/verify-kit`, `/verify-project` |
| **Hooks** | 21 | Claude Code compliance hooks — enforcement + session management (21 hook scripts) |
| **Workflows** | 3 | Structured process templates (RESEARCH → CONTRACT → CODE → AUDIT) |
| **Templates** | 5 | `CLAUDE.md`, `settings.json`, `CHANGELOG.md`, `CONTRIBUTING.md`, `github-actions/verify-kit.yml` |
| **Scripts** | 4 | `init-project.sh`, `verify-kit.sh`, `verify-project.sh`, `validate-claude-md.sh` |

---

## Scientific Validation

The SQWR Project-Kit's contract-based approach is formally validated by peer-reviewed research:

| Paper | Finding | Source |
|-------|---------|--------|
| arXiv 2601.08815 | Contract-based prompting reduces token usage by **90%** in LLM-assisted development | arXiv, 2025 |
| arXiv 2602.22302 | Structured contracts achieve **86% success rate** vs 70% baseline for complex development tasks | arXiv, 2025 |

These papers independently validate the core hypothesis: structured, sourced contracts outperform ad-hoc prompting both in efficiency and quality.

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
| [`CONTRACT-API-DESIGN.md`](contracts/CONTRACT-API-DESIGN.md) | REST/GraphQL design, versioning, rate limiting | RFC 7231, OpenAPI 3.1.0, OWASP API Security |
| [`CONTRACT-DATABASE-MIGRATIONS.md`](contracts/CONTRACT-DATABASE-MIGRATIONS.md) | Schema evolution, zero-downtime, rollback | Fowler 2016, PostgreSQL, AWS Well-Architected |
| [`CONTRACT-ERROR-HANDLING.md`](contracts/CONTRACT-ERROR-HANDLING.md) | Error boundaries, user messages, retry | Nielsen NN/G, Google SRE Book, React docs |
| [`CONTRACT-AI-AGENTS.md`](contracts/CONTRACT-AI-AGENTS.md) | AI Agents & Tool Calling | Anthropic, OpenAI, LangChain docs |
| [`CONTRACT-GRAPHQL.md`](contracts/CONTRACT-GRAPHQL.md) | GraphQL API | GraphQL spec, Apollo docs, OWASP API Security |
| [`CONTRACT-MULTI-TENANT.md`](contracts/CONTRACT-MULTI-TENANT.md) | Multi-Tenant Architecture | AWS Well-Architected, NIST |
| [`CONTRACT-FEATURE-FLAGS.md`](contracts/CONTRACT-FEATURE-FLAGS.md) | Feature Flags | Martin Fowler, LaunchDarkly docs |
| [`CONTRACT-MONOREPO.md`](contracts/CONTRACT-MONOREPO.md) | Monorepo | Nx, Turborepo, Google monorepo research |
| [`CONTRACT-DOCUMENTATION.md`](contracts/CONTRACT-DOCUMENTATION.md) | Documentation | Divio documentation system, Google dev docs |
| [`CONTRACT-EU-AI-ACT.md`](contracts/CONTRACT-EU-AI-ACT.md) | EU AI Act Compliance | EU Regulation 2024/1689, NIST AI RMF, ISO/IEC 42001 |
| [`CONTRACT-AI-SAFETY.md`](contracts/CONTRACT-AI-SAFETY.md) | AI Safety & Agentic Security | OWASP Agentic AI Top 10 2025, NIST AI 600-1 |
| [`CONTRACT-DORA-METRICS.md`](contracts/CONTRACT-DORA-METRICS.md) | DORA DevOps Metrics | DORA State of DevOps 2024, Accelerate (Forsgren et al.) |

---

## The audit system

Score /100 before each delivery. **Delivery threshold: ≥85/100 overall.**

| Audit | Weight | Blocking |
|-------|-------|---------|
| [`AUDIT-SECURITY.md`](audits/AUDIT-SECURITY.md) | 22% | < 70 = blocking |
| [`AUDIT-PERFORMANCE.md`](audits/AUDIT-PERFORMANCE.md) | 18% | < 70 recommended |
| [`AUDIT-CODE-QUALITY.md`](audits/AUDIT-CODE-QUALITY.md) | 18% | < 75 recommended |
| [`AUDIT-OBSERVABILITY.md`](audits/AUDIT-OBSERVABILITY.md) | 12% | < 60 recommended |
| [`AUDIT-ACCESSIBILITY.md`](audits/AUDIT-ACCESSIBILITY.md) | 12% | < 80 + EU legal |
| [`AUDIT-DESIGN.md`](audits/AUDIT-DESIGN.md) | 8% | < 70 recommended |
| [`AUDIT-AI-GOVERNANCE.md`](audits/AUDIT-AI-GOVERNANCE.md) | 5% | < 80 recommended |
| [`AUDIT-DEPLOYMENT.md`](audits/AUDIT-DEPLOYMENT.md) | 5% | Pre-production gate |
| [`AUDIT-RGPD.md`](audits/AUDIT-RGPD.md) | — | ≥80/100 before public prod |
| [`AUDIT-BRAND-STRATEGY.md`](audits/AUDIT-BRAND-STRATEGY.md) | — | Before launch or repositioning |
| [`AUDIT-RESILIENCE.md`](audits/AUDIT-RESILIENCE.md) | — (supplementary) | ≥70 recommended for production systems |

See [`audits/AUDIT-INDEX.md`](audits/AUDIT-INDEX.md) for the sequencing.

---

## Automation layer

> Standards that enforce themselves.

The kit ships with a Claude Code–native automation layer inspired by [GSD](https://github.com/gsd-build/get-shit-done) — active enforcement, not passive checklists.

| Component | Count | What it does |
|-----------|-------|-------------|
| **Plugin manifest** | 1 | `.claude-plugin/plugin.json` (v3.1.0) — auto-discovers agents, skills, hooks, commands |
| **Audit agents** | 11 | Run `agents/AGENT-SECURITY-AUDIT.md` — 4-level verification with enriched frontmatter (`model`, `effort`, `color`) |
| **Skills** | 9 | `/new-feature`, `/pre-deployment`, `/monthly-review`, `/audit-runner`, `/contract-lookup`, `/project-setup`, `/auto-fix`, `/compliance-check`, `/risk-score` |
| **Slash commands** | 4 | `/init-project`, `/full-audit`, `/verify-kit`, `/verify-project` |
| **Compliance hooks** | 21 | `hooks/hooks.json` — 21 hook scripts: secrets, build, XSS, contract compliance, session context, post-response, session-end, and more |
| **Workflow templates** | 3 | `WORKFLOW-NEW-FEATURE.md` — 5 gates with Observable Truths |

**`init-project.sh` provisions:**
- `.claude/settings.json` (legacy) or `.claude/hooks.json` (with `--plugin`)
- `.claude/agents/` with all 11 audit agents
- `.claude/skills/` and `.claude/commands/` (with `--plugin`)
- `docs/audits/` with stack-relevant audit files

---

## Skills (9)

| Skill | Usage | Description |
|-------|-------|-------------|
| New Feature | `/new-feature <description>` | Full RESEARCH → CONTRACT → CODE → AUDIT workflow |
| Audit Runner | `/audit-runner <domain>` | Run one or all SQWR audit agents |
| Pre-Deployment | `/pre-deployment` | Full quality gate before merging to main |
| Monthly Review | `/monthly-review` | Complete monthly audit cycle |
| Contract Lookup | `/contract-lookup <domain>` | Find applicable contracts for a task |
| Project Setup | `/project-setup <stack>` | Bootstrap a new project with SQWR standards |
| Auto Fix | `/auto-fix` | Automatically fix console.log, alt text, TODO format |
| Compliance Check | `/compliance-check <regulation>` | EU regulatory compliance (EAA, GDPR, AI Act) |
| Risk Score | `/risk-score [quick\|full]` | Compute composite SQWR Risk Score (0-100) |

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

**6. Active enforcement, not passive checklists**
11 audit agents, 21 compliance hook scripts, 3 workflow templates. Standards that are checked automatically, not discovered in post-mortems.

**7. The only kit with API design + database migrations + error handling standards in one place**
`CONTRACT-API-DESIGN.md` (RFC 7231, OpenAPI 3.1.0), `CONTRACT-DATABASE-MIGRATIONS.md` (Fowler Expand-Contract, PostgreSQL), and `CONTRACT-ERROR-HANDLING.md` (Nielsen NN/G, Google SRE) cover the three most common sources of silent production failures.

**8. Uniquely includes brand strategy and EU legal compliance**
`frameworks/BRAND-STRATEGY.md` (Sinek, Jung, Miller) and `frameworks/COMPLIANCE-EU.md` (EAA, EU AI Act, GDPR) — absent from 100% of purely technical starter kits. The only kit that treats brand positioning as a professional standard.

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
├── .claude-plugin/         → Plugin manifest (auto-discovery for Claude Code)
│   └── plugin.json         → Registers agents, skills, hooks, commands
├── IDENTITY-TEMPLATE.md    → Identity sheet to personalise
├── METHODOLOGY.md          → Full method (read first)
├── DISCOVERY-GUIDE.md      → 10-Minute kit tour, PDF-ready
├── contracts/              → 38 contracts (thresholds + sources)
├── frameworks/             → 13 situational tools
├── audits/                 → 13 audits scoring /100
├── agents/                 → 11 audit agents (model/effort/color frontmatter)
├── skills/                 → 9 skills (/new-feature, /pre-deployment, /monthly-review, /compliance-check, /risk-score…)
├── commands/               → 4 slash commands (/init-project, /full-audit…)
├── hooks/                  → Plugin hooks
│   ├── hooks.json          → Declarative hook config (SessionStart, PreCompact, etc.)
│   └── scripts/            → 21 hook scripts (no-secrets, build-before-commit, session-context…)
├── workflows/              → 3 process templates (Observable Truths gates)
├── templates/              → CLAUDE.md, settings.json, github-actions/verify-kit.yml…
└── scripts/                → init-project.sh (--plugin flag), verify-kit.sh, verify-project.sh
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
