# [PROJECT NAME] — AI Contract

> Universal template — [Claude Code Standards Kit](https://github.com/samsam007b/claude-code-standards-kit) by [SQWR Studio](https://sqwr.be).
> Instructions: replace all `[TO FILL IN]` placeholders and remove irrelevant sections.
>
> **Plugin mode**: If using the SQWR plugin (`.claude/hooks.json` or via `.claude-plugin/`), hooks and slash commands are auto-discovered. Slash commands available: `/new-feature`, `/pre-deployment`, `/monthly-review`, `/full-audit`, `/verify-project`.

---

## Who you are

**[YOUR NAME]** — [your role, e.g.: founder / developer / student]

| Contact | Value |
|---------|-------|
| Email | [your@email.com] |
| Work email | [pro@yourstudio.com] |

**This project belongs to:** [Your studio / your company / personal]

Full context:
- Identity: `[KIT_PATH]/IDENTITY-TEMPLATE.md` (fill in with your information)

---

## This project

**Name:** [TO FILL IN]
**Description:** [TO FILL IN — 1-2 sentences max]
**Production URL:** [TO FILL IN or N/A]
**Status:** [In development / In production / Archived]

**Stack:**
- [TO FILL IN — e.g.: Next.js 16 + TypeScript + Tailwind CSS + Supabase]

**Deployment:**
- [TO FILL IN — e.g.: Vercel (auto from main)]

---

## Architecture

```
[TO FILL IN — key folder structure]
src/
├── app/          → Next.js App Router routes
├── components/   → Reusable components
├── lib/          → Utilities, config, helpers
└── types/        → Shared TypeScript types
```

**Critical files:**

| File | Role |
|------|------|
| [TO FILL IN] | [role] |
| [TO FILL IN] | [role] |

---

## Active contracts

> Include the contracts relevant to this project. Source files: `docs/contracts/`
> Check [x] the ones active for this project. Read each checked contract before working on the relevant domain.

### Core (check all that apply to your stack)
- [ ] `CONTRACT-TYPESCRIPT.md` — Strict typing, no `any`, SOLID
- [ ] `CONTRACT-SECURITY.md` — OWASP Top 10, NIST, secrets management
- [ ] `CONTRACT-TESTING.md` — Test pyramid, TDD, coverage ≥80%
- [ ] `CONTRACT-CICD.md` — GitHub Actions, DORA metrics, Conventional Commits

### Web stack
- [ ] `CONTRACT-NEXTJS.md` — App Router, SSR, Server Components, CWV
- [ ] `CONTRACT-SUPABASE.md` — RLS, auth, migrations, NIST SP 800-63B
- [ ] `CONTRACT-VERCEL.md` — Deployment, env vars, rollback
- [ ] `CONTRACT-PERFORMANCE.md` — LCP ≤2.5s, INP ≤200ms, CLS ≤0.1
- [ ] `CONTRACT-ACCESSIBILITY.md` — WCAG 2.1 AA, EAA (EU law since June 2025)
- [ ] `CONTRACT-SEO.md` — SSR, metadata, JSON-LD, Core Web Vitals
- [ ] `CONTRACT-DESIGN.md` — Gestalt, typography, colour tokens, Tailwind
- [ ] `CONTRACT-OBSERVABILITY.md` — Structured logging, Sentry, RUM
- [ ] `CONTRACT-RESILIENCE.md` — Circuit breaker, retry, graceful degradation

### AI features
- [ ] `CONTRACT-AI-PROMPTING.md` — System prompts, few-shot, model selection
- [ ] `CONTRACT-ANTI-HALLUCINATION.md` — Real data only, RAG, context poisoning

### Mobile
- [ ] `CONTRACT-IOS.md` — SwiftUI, HIG, Dark Mode, touch targets ≥44pt
- [ ] `CONTRACT-ANDROID.md` — Jetpack Compose, Material 3, TalkBack

### Specialized
- [ ] `CONTRACT-EMAIL.md` — SPF/DKIM/DMARC, React Email, deliverability
- [ ] `CONTRACT-PDF-GENERATION.md` — Puppeteer, react-pdf, CSS Paged Media
- [ ] `CONTRACT-I18N.md` — next-intl, ICU, hreflang, RTL, Intl API
- [ ] `CONTRACT-ANALYTICS.md` — HEART framework, AARRR, GA4, PostHog
- [ ] `CONTRACT-PRICING.md` — Van Westendorp, EVC, SaaS metrics, tiers
- [ ] `CONTRACT-GREEN-SOFTWARE.md` — Carbon efficiency, SCI (ISO/IEC 21031:2024)
- [ ] `CONTRACT-MOTION-DESIGN.md` — UI animation, easing, prefers-reduced-motion
- [ ] `CONTRACT-VIDEO-PRODUCTION.md` — Video pipeline, platform export specs
- [ ] `CONTRACT-PYTHON.md` — PEP 8, mypy strict, FastAPI patterns

> Read each checked contract directly OR ask Claude: "Read docs/contracts/CONTRACT-X.md before working on [domain]."

---

## Absolute rules

> What the AI must NEVER do on this project, specific to this context.

### Never do

- [TO FILL IN — e.g.: Modify the Supabase schema without checking RLS]
- [TO FILL IN — e.g.: Switch a page to `'use client'` without justification]
- [TO FILL IN]

### Always do

- [TO FILL IN — e.g.: Run `npm run build` before any commit]
- [TO FILL IN — e.g.: Check SSR rendering on SEO-critical pages]
- [TO FILL IN]

---

## Error history

> Track detected errors here to prevent recurrence.
> Format: date | error | status

| Date | Error | Status |
|------|-------|--------|
| [DD/MM/YYYY] | [description] | Fixed / To fix |

---

## Active ADRs

> Architecture Decision Records — the key technical decisions structuring this project.
> Full template: `[KIT_PATH]/frameworks/ADR-TEMPLATE.md`
> ADR files: `./docs/adr/`

| ADR | Decision | Status |
|-----|----------|--------|
| ADR-001 | [TO FILL IN — e.g.: Supabase choice] | Accepted |
| ADR-002 | [TO FILL IN — e.g.: Vercel vs Railway choice] | Accepted |

*Create an ADR in `./docs/adr/` for every significant new architectural decision.*

---

## SLO (Service Level Objectives)

> Target reliability definition. Template: `[KIT_PATH]/frameworks/SLO-TEMPLATE.md`

| SLI | Target SLO | Current | Tool |
|-----|-----------|---------|------|
| Uptime | [TO FILL IN — e.g.: 99.5%] | [current] | UptimeRobot |
| LCP p75 | ≤2.5s | [current] | Vercel Speed Insights |
| Error rate | ≤0.5% | [current] | Sentry |

*Error budget: [% SLO] × 30d = [X]h of allowed downtime per month*

---

## Tech Debt Tracker

> Known technical debt, to be addressed by priority.

| Debt | Impact | Priority | Date detected |
|------|--------|----------|---------------|
| [TO FILL IN] | [e.g.: Performance] | P1/P2/P3 | [DD/MM] |

---

## Active hooks

> Configured in `.claude/settings.json`. Review and uncomment to activate.

| Hook | Contract | Trigger | Action |
|------|----------|---------|--------|
| `hook-no-secrets.sh` | CONTRACT-SECURITY §2 (OWASP A02) | Pre-commit | BLOCK secrets in staged files |
| `hook-build-before-commit.sh` | AUDIT-DEPLOYMENT | Pre-commit | BLOCK if build/lint fails |
| `hook-no-dangerous-html.sh` | CONTRACT-SECURITY (XSS) | Write *.tsx | WARN on unsafe HTML |
| `hook-contract-compliance.sh` | All active contracts | Post-write | WARN on violations |
| `hook-audit-before-push.sh` | AUDIT-INDEX | Pre-push | REMIND to run audit |

*Escape hatch for build hook: `SQWR_SKIP_BUILD_CHECK=1 git commit -m "..."`*

---

## Audit schedule

> Run the relevant audit agents before key milestones.

| Trigger | Agents to run | Blocking threshold |
|---------|--------------|-------------------|
| Before any deployment | `AGENT-SECURITY-AUDIT` + `AGENT-DEPLOYMENT-GATE` | Security <70 = BLOCK |
| Before merging a feature | `AGENT-CODE-QUALITY-AUDIT` + `AGENT-SECURITY-AUDIT` | Code-Quality <75 |
| Before EU client delivery | + `AGENT-ACCESSIBILITY-AUDIT` | Accessibility <80 = legal |
| Design / visual change | `AGENT-DESIGN-AUDIT` + `AGENT-PERFORMANCE-AUDIT` | Design <70 |
| Adding AI features | `AGENT-AI-GOVERNANCE-AUDIT` | AI-Gov <80 |
| Production incident | `AGENT-OBSERVABILITY-AUDIT` | Observability <60 |
| Weekly / end of sprint | `AGENT-FULL-AUDIT` (all 8 domains) | Global <85 |

*Run: ask Claude "Run .claude/agents/AGENT-FULL-AUDIT.md" or use a specific agent.*
*Mark audit complete: `touch .sqwr-last-audit` (tracked by hook-audit-before-push)*

---

## Quality gates

> Workflow for any new feature. Full details: `docs/workflows/WORKFLOW-NEW-FEATURE.md`

| Gate | Purpose | Observable truth |
|------|---------|-----------------|
| 0 — Scope | Shape Up Pitch | Scoping doc with Problem + Appetite + No-Gos |
| 1 — Research | Identify applicable contracts | CLAUDE.md "Active contracts" updated |
| 2 — Implement | Code with active hooks | `npm run build && npm test` exits 0 |
| 3 — Verify | Run audit agents | All scores above thresholds |
| 4 — Ship | CHANGELOG + PR | PR with audit scores, CI passes |

---

## Context notes

[TO FILL IN — important project information that the AI should always keep in mind]
