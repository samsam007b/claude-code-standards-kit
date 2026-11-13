---
name: supabase-review
description: Supabase security audit: checks RLS on all tables, correct auth.uid(), indexes on FK columns, no select('*'), secured Edge Functions. Sources: NIST SP 800-63B, OWASP.
tags: [supabase, security, rls, postgresql, auth, database]
model: sonnet
---

# /supabase-review: Supabase Security & Quality Audit

## When to use

- Before every PR touching the DB or migrations
- Full audit of the Supabase schema
- Review of a new table or RPC
- Verification of auth and RLS for a feature

## Absolute rules (blocking)

### RLS
- [ ] **Every table has RLS enabled**: `ALTER TABLE x ENABLE ROW LEVEL SECURITY`
- [ ] **`(select auth.uid())`** in USING/WITH CHECK, NEVER bare `auth.uid()` (-40% performance on large queries)
- [ ] Separate policy for SELECT / INSERT / UPDATE / DELETE
- [ ] Publicly readable tables: explicit `USING (true)` policy + never public writes

### Auth (NIST SP 800-63B)
- [ ] Sessions invalidated server-side on logout (not just client-side)
- [ ] MFA available for sensitive actions
- [ ] JWT tokens not persisted in localStorage (HttpOnly cookie preferred)
- [ ] Refresh token rotation enabled

### SQL migrations
- [ ] Idempotent: `IF NOT EXISTS` everywhere
- [ ] Rollback possible (no `DROP` without an alternative `CREATE`)
- [ ] RPCs with `p_` prefix on all parameters
- [ ] Financial RPCs: `p_idempotency_key UUID DEFAULT NULL` mandatory
- [ ] Indexes on all FK columns (`CREATE INDEX IF NOT EXISTS`)

### App-side queries
- [ ] Never `select('*')`: use explicit field selectors
- [ ] No `supabase.from()` in UI components: go through services
- [ ] `createServerSupabaseClient()` in each server method (not in the constructor)

### Edge Functions
- [ ] Auth verified on the first line via `supabase.auth.getUser()`
- [ ] Rate limiting on public functions
- [ ] Secrets in Supabase env vars, never hardcoded

## Output format

```
## Supabase Review: [scope]

### 🔴 Blocking (fix before merge)
- [problem] → [fix]

### 🟡 Important (fix this week)
- [problem] → [fix]

### 🟢 Suggestions
- [improvement]

### Corrective SQL
[migrations/RPCs to apply]
```
