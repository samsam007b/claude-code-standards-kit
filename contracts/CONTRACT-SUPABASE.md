# Contract — Supabase

> SQWR Project Kit contract module — enriched with scientific references.
> Sources: Supabase RLS docs, NIST SP 800-63B, JWT Best Practices (Curity), OWASP.

---

## 1. Absolute Security Rules

### Never do

- **Expose the `service_role` key on the client side** — use Server Actions or API Routes only
- **Disable RLS** on a table containing user data
- **Query without verifying RLS** — always test with a non-admin user
- **Write data without Zod validation** — validate upstream systematically
- **Commit `.env.local` files** — Supabase credentials must never be in the repo
- **Store sensitive data in JWTs** — tokens travel over the network

---

## 2. JWT Standards (NIST SP 800-63B — Curity Research)

> Source: [NIST Special Publication 800-63B](https://pages.nist.gov/800-63-4/sp800-63b.html), [JWT Best Practices — Curity](https://curity.io/resources/learn/jwt-best-practices/)

### Token Lifetimes

| Token | Recommended duration | Reason |
|-------|------------------|--------|
| **Access token** | **5-15 minutes** | Minimal exposure window in case of theft |
| **Refresh token** | 7-30 days (with rotation) | User convenience with security |
| **Session cookie** | ≤24h (configurable) | UX/security balance |

### Signing Algorithm

| Algorithm | Usage | Note |
|------|-------|------|
| **RS256** (RSA + SHA-256) | Recommended in production | Public/private key — verifiable without the secret |
| **HS256** | Simple, small projects | Symmetric key — all services share the secret |

**Recommendation:** RS256 when there are multiple services or a public API.

### Token Storage

```
✅ HttpOnly cookies + SameSite=Strict   → CSRF protected, inaccessible to JS
✅ HttpOnly cookies + SameSite=Lax     → Compatible with OAuth redirects
❌ localStorage                         → Vulnerable to XSS
❌ sessionStorage                       → Vulnerable to XSS
```

### Secret Rotation (NIST SP 800-63B)

**NIST recommends NOT rotating on a fixed calendar schedule.** Rotate only if:
- Compromise confirmed or suspected
- An employee with access leaves
- A security audit requires it

---

## 3. Correct Client Pattern

```typescript
// lib/supabase/server.ts — server-side only
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'
import type { Database } from '@/types/database.types'

export async function createClient() {
  const cookieStore = await cookies()
  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll: () => cookieStore.getAll(),
        setAll: (cs) => cs.forEach(({ name, value, options }) =>
          cookieStore.set(name, value, options)
        ),
      },
    }
  )
}

// lib/supabase/client.ts — client-side only
import { createBrowserClient } from '@supabase/ssr'
import type { Database } from '@/types/database.types'

export function createClient() {
  return createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

---

## 4. Row Level Security (RLS)

**All tables with user data = RLS mandatory.**

### Critical Indexing Rule

> Source: Supabase RLS Documentation — Performance

**Every column used in an RLS policy must have an index.** Without an index, each query scans the entire table.

```sql
-- ✅ Enable RLS
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- ✅ Mandatory index on policy columns
CREATE INDEX ON projects(user_id);    -- filtered in the policy
CREATE INDEX ON projects(tenant_id);  -- filtered in the policy

-- ✅ Specific policy per operation (avoid FOR ALL with USING(true))
CREATE POLICY "select_own" ON projects FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "insert_own" ON projects FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "update_own" ON projects FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "delete_own" ON projects FOR DELETE USING (auth.uid() = user_id);
```

### Advanced RLS Patterns

```sql
-- Public read, authenticated write
CREATE POLICY "public_read" ON posts FOR SELECT USING (true);
CREATE POLICY "auth_write" ON posts FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Multi-tenant (organizations)
CREATE POLICY "tenant_isolation" ON resources
  FOR ALL USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);
```

---

## 5. Expired Session Handling

```typescript
// middleware.ts — automatically refresh the session
import { createServerClient } from '@supabase/ssr'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  let response = NextResponse.next({ request })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { cookies: { /* ... */ } }
  )

  // Automatically refreshes the token if expired
  const { data: { user } } = await supabase.auth.getUser()

  if (!user && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  return response
}
```

---

## 6. Rate Limiting

```typescript
// app/api/contact/route.ts — application-level rate limiting
import { NextResponse } from 'next/server'

const rateLimitMap = new Map<string, { count: number; timestamp: number }>()

function rateLimit(ip: string, limit = 5, windowMs = 60_000): boolean {
  const now = Date.now()
  const entry = rateLimitMap.get(ip)

  if (!entry || now - entry.timestamp > windowMs) {
    rateLimitMap.set(ip, { count: 1, timestamp: now })
    return true
  }

  if (entry.count >= limit) return false
  entry.count++
  return true
}

export async function POST(request: Request) {
  const ip = request.headers.get('x-forwarded-for') ?? 'unknown'
  if (!rateLimit(ip)) {
    return NextResponse.json({ error: 'Too many requests' }, { status: 429 })
  }
  // Normal logic...
}
```

---

## 7. Migration Management

```
Naming convention: YYYYMMDDHHMMSS_description.sql
Example: 20260317143000_create_projects_table.sql
```

- Use `supabase/migrations/` for all schema changes
- Test migrations locally before pushing to production
- Never modify the schema directly in production via the Supabase interface
- Version migrations in git (committed, never in .gitignore)

---

## 8. Required Environment Variables

```bash
NEXT_PUBLIC_SUPABASE_URL=         # Project URL (https://xxx.supabase.co)
NEXT_PUBLIC_SUPABASE_ANON_KEY=    # Anon key — public, safe client-side
SUPABASE_SERVICE_ROLE_KEY=        # Service key — NEVER NEXT_PUBLIC_
```

---

## 9. Storage

- Enable RLS on buckets in production
- No direct client upload without MIME type and size verification
- Signed URLs for private files (expiry ≤ 1h for sensitive data)
- Public buckets only for static assets (product images, logos)

---

## 10. Sources

| Reference | Link |
|-----------|------|
| Supabase RLS Documentation | supabase.com/docs/guides/database/postgres/row-level-security |
| JWT Best Practices — Curity | curity.io/resources/learn/jwt-best-practices |
| JWT Security — LogRocket | blog.logrocket.com/jwt-authentication-best-practices |
| NIST SP 800-63B | pages.nist.gov/800-63-4/sp800-63b.html |
| OWASP Secrets Management | cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet |

> **Last validated:** 2026-03-30 — Supabase docs, PostgreSQL docs, NIST SP 800-63B, OWASP Secrets Management, JWT Best Practices