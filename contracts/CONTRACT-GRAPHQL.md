# Contract — GraphQL API

> Sources: GraphQL Foundation Specification (spec.graphql.org), Principled GraphQL (principledgraphql.com — Shopify/Apollo, 2018), OWASP API Security Top 10 2023
> Score: /100 | Recommended threshold: ≥70
> Applies to: projects exposing a GraphQL API (Apollo Server, Pothos, Yoga, Hasura, etc.)

---

## Section 1 — Schema Design (25 points)

- [ ] All list fields are paginated using Relay connection spec (first/after/last/before — Relay Cursor Connections spec) .............. (8)
- [ ] Naming conventions: queries=camelCase nouns, mutations=camelCase verbs, types=PascalCase (Principled GraphQL §2) .............. (5)
- [ ] No breaking changes without version warning (field deprecation before removal — GraphQL spec §Oct 2021) .............. (7)
- [ ] Input types used for mutations (no positional arguments for ≥2 params — Principled GraphQL §3) .............. (5)

**Subtotal: /25**

---

## Section 2 — Security (30 points)

- [ ] Query depth limiting enforced: max depth ≤10 levels (OWASP API4:2023 — Unrestricted Resource Consumption) .............. (10)
- [ ] Query complexity scoring enforced: max complexity score defined and rejected if exceeded .............. (8)
- [ ] Introspection disabled in production (OWASP API8:2023 — Security Misconfiguration) .............. (7)
- [ ] Field-level authorization: every resolver checks permissions before returning data .............. (5)

**Subtotal: /30**

---

## Section 3 — Performance (25 points)

- [ ] N+1 queries prevented: DataLoader (or equivalent) used for all relationship fields .............. (12)
- [ ] Persisted queries implemented for production (reduces bandwidth, prevents abuse — Apollo docs) .............. (8)
- [ ] Query timeout enforced (recommended: ≤10s per query — Principled GraphQL §Performance) .............. (5)

**Subtotal: /25**

---

## Section 4 — Error Handling (20 points)

- [ ] No stack traces in error responses (OWASP API8:2023) .............. (8)
- [ ] Error classification: user errors vs. server errors (Apollo error codes) .............. (7)
- [ ] Subscription cleanup: subscriptions unsubscribed on client disconnect .............. (5)

**Subtotal: /20**

---

## Sources

| Reference | Contribution |
|-----------|-------------|
| GraphQL Foundation — *GraphQL Specification* (spec.graphql.org, Oct 2021) | Spec-level requirements for schema design |
| Principled GraphQL — *10 Principles for GraphQL APIs* (principledgraphql.com, Shopify/Apollo, 2018) | Naming, schema design, versioning thresholds |
| OWASP — *API Security Top 10 2023* (owasp.org/www-project-api-security) | API4 resource consumption, API8 misconfiguration |
| Apollo — *Apollo Server Best Practices* (apollographql.com/docs, 2024) | Persisted queries, error handling patterns |

> **Last validated:** 2026-03-31 — GraphQL spec Oct 2021, Principled GraphQL 2018, OWASP API Top 10 2023
