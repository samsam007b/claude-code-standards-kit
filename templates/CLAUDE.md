# [PROJECT NAME] — AI Contract

> Universal template — [Claude Code Standards Kit](https://github.com/samsam007b/claude-code-standards-kit) by [SQWR Studio](https://sqwr.be).
> Instructions: replace all `[TO FILL IN]` placeholders and remove irrelevant sections.

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

> Include here the contracts relevant to this project.
> Source files: `[KIT_PATH]/contracts/`

- [ ] `CONTRACT-NEXTJS.md` — App Router, SSR, Server Components
- [ ] `CONTRACT-SUPABASE.md` — RLS, auth, migrations
- [ ] `CONTRACT-VERCEL.md` — Deployment, env vars
- [ ] `CONTRACT-DESIGN.md` — Tailwind, design system, tokens
- [ ] `CONTRACT-TYPESCRIPT.md` — Strict typing
- [ ] `CONTRACT-ANTI-HALLUCINATION.md` — Real data only

> Copy the content of selected contracts directly here OR read them via Read before any work on this project.
> Kit path: `[KIT_PATH]/contracts/`

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

## Context notes

[TO FILL IN — important project information that the AI should always keep in mind]
