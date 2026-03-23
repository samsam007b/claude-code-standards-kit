# Contract — Vercel & Deployment

> SQWR Project Kit contract module.
> Covers: Vercel deployment, environment variables, CI/CD, Edge.

---

## Fundamental Rules

### Never do

- **Merge to `main` without verifying the build passes** — Vercel deploys automatically from main
- **Hard-code environment variables in the code** — always use `.env.local` (local) or the Vercel dashboard (production)
- **Expose `SUPABASE_SERVICE_ROLE_KEY` or any secret key** in a `NEXT_PUBLIC_`-prefixed variable
- **Ignore build warnings** — treat them as errors

### Always do

- Test the local build with `npm run build` before any significant PR/merge
- Document environment variables in `.env.example`
- Check Vercel logs after every production deployment

---

## Environment Variable Convention

| Prefix | Accessible | Usage |
|---------|-----------|-------|
| `NEXT_PUBLIC_` | Client + Server | Public URLs, anon keys |
| *(no prefix)* | Server only | Secret keys, service roles, webhooks |

```bash
# ✅ Safe client-side
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...

# ✅ Server only
SUPABASE_SERVICE_ROLE_KEY=eyJ...  # NEVER NEXT_PUBLIC_
RESEND_API_KEY=re_...
```

---

## Branches & Deployment

```
main        → Production (sqwr.be, cozygrowth.vercel.app, etc.)
develop     → Automatic Vercel Preview
feature/*   → Automatic Vercel Preview
```

- Never force-push to `main`
- PRs to main = mandatory build verification (GitHub Actions or Vercel check)

---

## Recommended Vercel Optimizations

### Edge Functions vs Serverless
- **Edge**: middleware, redirects, fast auth checks (no direct DB access)
- **Serverless**: API routes with Supabase access, business logic

### Security Headers (next.config.js)
```javascript
const securityHeaders = [
  { key: 'X-Content-Type-Options', value: 'nosniff' },
  { key: 'X-Frame-Options', value: 'DENY' },
  { key: 'X-XSS-Protection', value: '1; mode=block' },
  { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
]
```

### Caching
- `revalidate` on Server Components for semi-static data
- `cache: 'no-store'` only for user-specific data (never as default)

---

## Analytics — Recommended Strategy

### Plausible vs Vercel Analytics

| Criterion | Plausible | Vercel Analytics |
|---------|-----------|-----------------|
| **GDPR / Cookies** | Cookie-free, GDPR-native | Light tracking but Vercel-dependent |
| **Price** | $9/month (flat rate) | Included in Vercel Pro or pay-per-event |
| **Data** | Aggregated only (privacy by design) | Includes real-time Web Vitals |
| **SQWR Recommendation** | sqwr-site → Plausible (no-cookie, SEO safe) | Optional for CWV monitoring |

**SQWR rule**: On public-facing sites, **Plausible is preferred** (no-cookie = no consent banner, GDPR compliant by design).

```javascript
// next.config.js — prevent double tracking
// If Plausible is active, disable Vercel Analytics to avoid duplicates
module.exports = {
  // Vercel Analytics disabled if Plausible is deployed
}
```

---

## Environment Variable Validation

**Problem**: a silent deployment may succeed even if critical variables are missing — the error only appears at runtime.

**Solution**: validate required variables at server startup.

```typescript
// lib/env.ts — validation at boot (server-side only)
const REQUIRED_ENV_VARS = [
  'NEXT_PUBLIC_SUPABASE_URL',
  'NEXT_PUBLIC_SUPABASE_ANON_KEY',
  'SUPABASE_SERVICE_ROLE_KEY',
  // Add as needed per project...
] as const

export function validateEnv() {
  const missing = REQUIRED_ENV_VARS.filter(
    (key) => !process.env[key]
  )
  if (missing.length > 0) {
    throw new Error(
      `Missing environment variables:\n${missing.map((k) => `  - ${k}`).join('\n')}\n` +
      `Check Vercel Dashboard → Settings → Environment Variables`
    )
  }
}
```

```typescript
// app/layout.tsx — call in the root layout (server component)
import { validateEnv } from '@/lib/env'
validateEnv() // Fast fail if config is incomplete — better than an opaque runtime error
```

**Rule**: `validateEnv()` must be called in the root layout or the server entry point. An immediate crash at boot is preferable to a silent failure in production.

---

## Vercel Rollback Procedure

**When to rollback**: critical production bug (500 errors, blank page, broken auth) not resolvable within 30 minutes.

### Rollback via Dashboard (fast method — <2 min)

1. Go to **Vercel Dashboard** → project → **Deployments**
2. Find the last stable deployment (badge "Ready")
3. Click `⋯` → **Promote to Production**
4. Confirm — the domain immediately points to the old build

### Rollback via CLI

```bash
# List recent deployments
vercel ls --prod

# Promote a specific deployment
vercel promote <deployment-url>

# Example
vercel promote https://sqwr-site-abc123.vercel.app
```

### After the rollback

```bash
# 1. Create a hotfix branch
git checkout -b hotfix/prod-crash-$(date +%Y%m%d)

# 2. Reproduce locally, fix, test
npm run build && npm run test

# 3. PR → merge → re-deploy
```

**Document the incident** in `AUDIT-DEPLOYMENT.md` (section "Resolved Blocker") with date, root cause, and remediation plan.

---

## Progressive Rollout — Canary Pattern

> Sources: Martin Fowler — Feature Toggles (martinfowler.com, 2016),
> Vercel Rolling Releases Docs, Vercel Skew Protection Docs.

### Why a Progressive Rollout

**Deploying 100% of traffic at once is the highest-risk pattern.** A critical bug
affects all users simultaneously, and rollback takes 2–5 minutes during
which production is degraded. The canary pattern validates under real conditions on
a subset before full exposure.

### Native Vercel Tools (zero configuration required)

| Feature | Role | Where to enable |
|---------|------|-----------|
| **Rolling Releases** | Blue-green deployment — zero downtime, progressive transition | Native on all plans |
| **Skew Protection** | Client/server synchronization during transition — prevents React hydration errors | Dashboard → Project Settings → Skew Protection |

**Skew Protection is particularly important for Next.js**: without it, a user
may receive client JS from one version and server HTML from another during the transition,
causing silent hydration errors.

### SQWR Canary Pattern — 4 Phases

```
Phase 1 — Internal (preview URL, 0% production traffic)
  → Deploy to a Vercel Preview URL
  → Manually test all critical features (auth, payment, data)
  → Verify: 0 500 errors in Vercel logs + Sentry
  → Minimum duration: 30 min
  → Pass criteria: 0 critical errors

Phase 2 — Canary (5% of production traffic, 24h)
  → Promote to production via Vercel Dashboard
  → Monitor for at least 24h
  → Metrics to watch: Sentry error rate, LCP, conversion rate (Plausible)
  → Pass criteria: error rate < baseline + 0.5%

Phase 3 — Beta (25% of traffic, 12-24h)
  → If Phase 2 validated, continue widening
  → Same metrics

Phase 4 — GA (100%)
  → Full promotion via Vercel Dashboard → Deployments → Promote to Production
  → Enhanced monitoring in the 2h post-promotion
```

### Canary Implementation via Edge Middleware

For deployments where fine-grained traffic percentage control is needed:

```typescript
// middleware.ts — Canary routing (5% of traffic to a Preview URL)
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

const CANARY_URL = process.env.CANARY_DEPLOYMENT_URL // Vercel Preview URL

export function middleware(request: NextRequest) {
  // Only redirect if the canary URL is defined and the user is not already forced
  if (
    CANARY_URL &&
    !request.cookies.has('force-stable') &&
    Math.random() < 0.05  // 5% of traffic
  ) {
    // Mark as canary for metrics
    const response = NextResponse.rewrite(new URL(request.url, CANARY_URL))
    response.headers.set('x-deployment-variant', 'canary')
    return response
  }

  return NextResponse.next()
}
```

### Feature Flags — Lightweight Alternative for Features

For features that do not require a full canary deployment, feature flags
allow deploying code to production while controlling activation:

```typescript
// lib/features.ts — Feature flags via environment variables
const FEATURES = {
  NEW_DASHBOARD: process.env.NEXT_PUBLIC_FEATURE_NEW_DASHBOARD === 'true',
  BETA_ANALYTICS: process.env.NEXT_PUBLIC_FEATURE_BETA_ANALYTICS === 'true',
  EXPERIMENTAL_AI: process.env.NEXT_PUBLIC_FEATURE_EXPERIMENTAL_AI === 'true',
} as const

export type FeatureFlag = keyof typeof FEATURES

export function isFeatureEnabled(feature: FeatureFlag): boolean {
  return FEATURES[feature]
}
```

```typescript
// Usage in a component
import { isFeatureEnabled } from '@/lib/features'

export function Dashboard() {
  return (
    <div>
      {isFeatureEnabled('NEW_DASHBOARD') ? (
        <NewDashboard />
      ) : (
        <LegacyDashboard />
      )}
    </div>
  )
}
```

**To toggle without redeploying**: update the environment variable in
Vercel Dashboard → Project → Settings → Environment Variables, then trigger an
instant redeploy from the same commit (zero code change).

### Kill Switch — Emergency Rollback if the Canary Reveals a Problem

**Rule: the kill switch must be executable in < 5 minutes by anyone
with access to the Vercel Dashboard.**

```bash
# Option 1 — Dashboard (< 2 min, recommended)
# Vercel Dashboard → Deployments → click the last stable deployment → "Promote to Production"

# Option 2 — Vercel CLI
vercel promote <URL-of-last-stable-deployment>

# Option 3 — Git revert (if the issue is in the code)
git revert HEAD
git push origin main  # Automatically triggers a new Vercel deployment

# Option 4 — Disable a feature flag (if used)
# Vercel Dashboard → Environment Variables → NEXT_PUBLIC_FEATURE_X=false → Redeploy
```

---

## Pre-Production Deployment Checklist

- [ ] `npm run build` passes without errors
- [ ] `npm run lint` passes without errors
- [ ] Environment variables defined in the Vercel dashboard
- [ ] `.env.example` up to date with all required variables
- [ ] `validateEnv()` does not throw errors locally
- [ ] No debug `console.log` left behind (`/clean-commit`)
- [ ] SEO metadata verified on modified pages
- [ ] Analytics (Plausible or Vercel) configured and tested

---

## Sources

| Reference | Source |
|-----------|--------|
| Vercel Deployment Docs | vercel.com/docs/deployments |
| Plausible GDPR compliance | plausible.io/data-policy |
| Next.js Env Validation patterns | nextjs.org/docs/app/building-your-application/configuring/environment-variables |
| Martin Fowler — Feature Toggles (2016) | martinfowler.com/articles/feature-toggles.html |
| Vercel Skew Protection | vercel.com/docs/deployments/skew-protection |
| Vercel Rolling Releases | vercel.com/docs/deployments/rolling-releases |
