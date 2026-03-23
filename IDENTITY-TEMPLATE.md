# Identity — [YourFirstName LastName]

> This file is your personal source of truth for all your projects.
> Include or reference it in each project's CLAUDE.md.
> Instructions: replace all [YOUR_*] placeholders with your real information.

---

## Who I am

**[YOUR FULL NAME]** — [Your primary role]
- [E.g. Master's student in X — University Y, city (graduating YYYY)]
- [E.g. Freelancer / Entrepreneur / Freelance developer]
- Location: [City, Country]

---

## Contacts

| Type | Value |
|------|--------|
| **Primary email** | [your@email.com] |
| **Professional email** | [pro@yourstudio.be] |
| **Phone / WhatsApp** | [+XX XXX XX XX XX] |

---

## Structures & active projects

### [YOUR STUDIO / COMPANY NAME]

[Short description: type of activity, co-founders if applicable]
- **Role**: [your role in the structure]
- **Website**: [yoursite.be / N/A]
- **Legal status**: [Sole trader / Student freelancer / Ltd / N/A]

### [MAIN PROJECT 1]

[Project description in 1-2 sentences]
- Stack: [technologies used]
- Status: [In development / In production / Archived]

### [MAIN PROJECT 2]

[Description]
- Stack: [technologies]
- Status: [status]

---

## Preferred stack

> Decisions validated across multiple real projects — adapt to your context.

- **Web**: [E.g. Next.js (App Router) + TypeScript + Tailwind CSS + Supabase]
- **Mobile**: [E.g. Swift / SwiftUI (native iOS) / React Native]
- **Infra**: [E.g. Vercel + Supabase + GitHub]
- **AI**: [E.g. Claude Code (primary production tool)]

---

## Context

- [E.g. Student in X — institution Y (years)]
- [E.g. Notable projects: Project A (description), Project B (description)]
- [E.g. Claude Code used as a production tool since YYYY]

---

## Work style & AI collaboration

### Collaboration preferences

> Fill in according to your real preferences — this information helps Claude Code work with you more effectively.

- **Responses**: [E.g. concise / detailed / with explanations]
- **Autonomy**: [E.g. execute without confirmation for non-destructive actions]
- **Language**: [E.g. English — primary language for conversations]
- **Priority**: [E.g. quality > speed / speed > quality]
- **Standards**: [E.g. cite sources rather than inventing rules]

### Strategic decision log (narrative ADR)

> Your structural tech decisions, documented with their rationale.

| Decision | Rationale | Date |
|----------|--------|------|
| [E.g. Supabase vs alternatives] | [E.g. Native RLS + Auth + migratable PostgreSQL] | YYYY |
| [E.g. Vercel vs Railway] | [E.g. Native Next.js integration + preview URLs] | YYYY |
| [Your decision 3] | [Rationale] | YYYY |

*Formal ADRs to be created in `/docs/adr/` of each project (see `frameworks/ADR-TEMPLATE.md`)*

---

## Cognitive biases to watch for

> Documented for solo/small studio projects — these 3 biases are the most dangerous.

| Bias | Manifestation | Mitigation |
|-------|--------------|-----------|
| **Planning fallacy** | "This feature takes 2 hours max" → 2 days | Compare with similar past projects before estimating. Use `frameworks/ESTIMATION.md`. |
| **Sunk cost fallacy** | Continuing an approach that is not working "because we've already invested" | Pre-defined decision checkpoints: "if blocked >4h, pivot" |
| **Anchoring bias** | Fixating on the first estimate or first architecture seen | Explicitly consider at least 2 alternatives before deciding |

**Warning signal:** if a decision is made solely because "it's what we've always done", write an ADR that forces documentation of the rejected alternatives.

---

## Personal notes

[TO FILL IN — important information about your working style, constraints, and preferences not documented elsewhere]
