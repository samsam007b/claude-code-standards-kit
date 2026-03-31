# Framework — Architecture Decision Records (ADR)

> SQWR Project Kit Framework — institutional memory for architectural decisions.
> Sources: Michael Nygard (2011), ADR GitHub (adr.github.io), AWS ADR Best Practices, GOV.UK ADR Framework.
> Principle: document WHY, not just WHAT.

---

## Why ADRs?

**The problem:** In 6 months, why did we choose Supabase over PlanetScale? Why Plausible over Mixpanel? Why Vercel over Railway? These decisions live in the founders' memory. When a collaborator joins, or when a decision needs to be revisited, the context is lost.

**The solution:** An ADR (Architecture Decision Record) captures a significant decision with its context, the alternatives considered, and the consequences. Immutable. Versioned with the code. Retrievable.

> *"An ADR is not a requirements document. It's a record of a decision that was made."* — Michael Nygard

---

## Storage convention

```
[project]/
└── docs/
    └── adr/
        ├── ADR-001-supabase-choice.md
        ├── ADR-002-analytics-plausible.md
        ├── ADR-003-tailwind-vs-styled-components.md
        └── ...
```

**Immutability rule:** An existing ADR is never edited. If a decision changes:
1. Create a new ADR: `ADR-XXX-supersedes-ADR-NNN.md`
2. Set the old ADR's status to `Superseded by ADR-XXX`

---

## ADR Template (Michael Nygard format)

```markdown
# ADR-[NNN]: [Short, descriptive title]

**Date:** [DD/MM/YYYY]
**Status:** [Proposed | Accepted | Deprecated | Superseded by ADR-XXX]
**Decider(s):** [Samuel / Samuel + Joakim / Samuel + Alexandre]

---

## Context

[Describe the situation or problem requiring this decision.
What is the technical, business, or organizational context?
What constraints exist?]

## Alternatives Considered

| Option | Advantages | Disadvantages |
|--------|-----------|--------------|
| **[Option A]** | [+] | [-] |
| **[Option B]** | [+] | [-] |
| **[Option C]** | [+] | [-] |

## Decision

[Which option was chosen and why.]

**Chosen option: [Option X]**

Reasons:
- [reason 1]
- [reason 2]

## Consequences

**What becomes easier:**
- [positive consequence 1]

**What becomes harder (trade-offs):**
- [trade-off 1]

**What must be done as a result of this decision:**
- [ ] [concrete action]

## Review conditions

[Conditions under which this decision should be reconsidered]
Ex: "If volume exceeds X requests/day" or "If monthly cost exceeds Y€"
```

---

## Status lifecycle

```
Proposed → Accepted → Deprecated
                  ↘ Superseded by ADR-XXX
```

| Status | Meaning |
|--------|---------|
| **Proposed** | Under discussion, not yet validated |
| **Accepted** | Active decision, currently in effect |
| **Deprecated** | No longer relevant (technology abandoned, context changed) |
| **Superseded by ADR-NNN** | Replaced by a new ADR |

---

## Foundational SQWR ADRs — to create for each project

These decisions have already been made implicitly. Documenting them creates institutional memory.

| Decision | Suggested ADR |
|----------|--------------|
| Choosing Supabase vs alternatives | `ADR-001-database-supabase.md` |
| Choosing Vercel vs Railway/Render | `ADR-002-hosting-vercel.md` |
| Choosing Plausible vs Google Analytics | `ADR-003-analytics-plausible.md` |
| Choosing Claude vs OpenAI for dev | `ADR-004-ai-dev-claude-code.md` |
| Choosing Next.js App Router vs Pages Router | `ADR-005-nextjs-app-router.md` |
| Choosing Tailwind vs CSS Modules | `ADR-006-styling-tailwind.md` |

---

## Complete Example — ADR-001

```markdown
# ADR-001: Supabase as the database

**Date:** 15/01/2025
**Status:** Accepted
**Decider(s):** Samuel Baudon

---

## Context

[ClientApp] requires a PostgreSQL database with integrated authentication,
file storage, and granular access policies by user role
(Seekers, Residents, Owners). Initial budget: bootstrapped, no dedicated DevOps.

## Alternatives Considered

| Option | Advantages | Disadvantages |
|--------|-----------|--------------|
| **Supabase** | Auth + DB + Storage integrated, native RLS, excellent JS SDK, generous free tier | Vendor lock-in, scalability pricing |
| **PlanetScale** | Excellent MySQL scalability, branching | No native auth, no storage, no RLS |
| **Firebase** | Mature, Google ecosystem | NoSQL = difficult migration, unpredictable pricing |

## Decision

**Chosen option: Supabase**

Reasons:
- Native RLS = multi-tenant security without additional infrastructure
- Auth, Storage, Realtime in a single service = fewer moving parts
- PostgreSQL = migration possible to any Postgres host if needed
- Next.js + SSR SDK = compatible with our stack

## Consequences

**What becomes easier:**
- Role-based permission management (RLS)
- Auth without a third-party server

**Trade-offs:**
- Vendor lock-in on Supabase-specific features (Edge Functions, Realtime)
- Scalability cost to monitor beyond 50k MAU

## Review conditions

Supabase pricing exceeds €500/month or blocking technical limitations appear
```

---

## Sources

| Reference | Source |
|-----------|--------|
| Michael Nygard — original ADR | cognitect.com/blog/2011/11/15/documenting-architecture-decisions |
| ADR GitHub | adr.github.io |
| AWS ADR Best Practices | aws.amazon.com/blogs/architecture/master-architecture-decision-records-adrs-best-practices |
| Microsoft Azure Well-Architected | learn.microsoft.com/en-us/azure/well-architected/architect-role/architecture-decision-record |
| GOV.UK ADR Framework | gov.uk/government/publications/architectural-decision-record-framework |
