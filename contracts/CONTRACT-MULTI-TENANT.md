# Contract — Multi-Tenant Architecture

> Sources: OWASP ASVS 4.0 — Chapter 4 (Access Control), Supabase RLS docs (supabase.com/docs), AWS Well-Architected Framework — Security Pillar, NIST SP 800-204
> Score: /100 | Recommended threshold: ≥80
> Applies to: any SaaS application serving multiple isolated customer organizations
> Note: threshold is 80 (not 70) because tenant data leakage is catastrophic and irreversible

---

## Section 1 — Tenant Isolation (35 points)

- [ ] Every database query includes a tenant filter — no cross-tenant queries possible (OWASP ASVS 4.1.3) .............. (15)
- [ ] Row Level Security (RLS) enabled on ALL tenant-scoped tables (Supabase RLS docs §Required) .............. (12)
- [ ] Tenant ID is never user-supplied: always derived from authenticated session .............. (8)

**Subtotal: /35**

---

## Section 2 — Authentication & Authorization (30 points)

- [ ] Tenant context injected at middleware level — no route can bypass it .............. (10)
- [ ] Tenant ID validated as UUID v4 format before use (OWASP ASVS 5.1.3 — input validation) .............. (8)
- [ ] Admin operations on tenant data require separate elevated role, not regular user JWT .............. (7)
- [ ] Cross-tenant API calls explicitly blocked (404 or 403, not 200 with empty data) .............. (5)

**Subtotal: /30**

---

## Section 3 — Audit & Operations (20 points)

- [ ] Audit log per tenant: all data modifications logged with: tenant_id, user_id, action, timestamp .............. (10)
- [ ] Tenant deletion: cascades to all related data + data retention policy documented .............. (10)

**Subtotal: /20**

---

## Section 4 — Resource Management (15 points)

- [ ] Resource quotas per tenant defined (storage, API calls/min, seats — AWS Well-Architected REL06) .............. (8)
- [ ] Tenant-level rate limiting enforced independently (not just global rate limiting) .............. (7)

**Subtotal: /15**

---

## Sources

| Reference | Contribution |
|-----------|-------------|
| OWASP — *Application Security Verification Standard 4.0* (owasp.org, 2021) | §4.1.3 access control, §5.1.3 input validation thresholds |
| Supabase — *Row Level Security documentation* (supabase.com/docs/guides/auth/row-level-security, 2024) | RLS requirement, policy patterns |
| AWS — *Well-Architected Framework — Security Pillar* (docs.aws.amazon.com/wellarchitected, 2023) | REL06 resource quota patterns |
| NIST — *SP 800-204: Security Strategies for Microservices* (nist.gov, 2019) | Tenant isolation architecture |

> **Last validated:** 2026-03-31 — OWASP ASVS 4.0, Supabase RLS docs 2024, AWS Well-Architected 2023
