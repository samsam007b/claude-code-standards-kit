# Contract — Product Analytics

> SQWR Project Kit contract module.
> Sources: HEART Framework — Google Research (Rodden et al., CHI 2010), Pirate Metrics AARRR (Dave McClure, 2007), Google Analytics 4 docs (developers.google.com/analytics), PostHog docs (posthog.com/docs), Andreessen Horowitz SaaS Metrics (a16z.com/2015/08/21/16-metrics).

---

## Scientific Foundations

**Product analytics are not marketing analytics.** Marketing analytics measure acquisition channels. Product analytics measure what users do *inside* the product — and why they stay or leave.

**Two reference frameworks:**
- **HEART** (Google, 2010 — Kerry Rodden, Hilary Hutchinson, Xin Fu): user experience-oriented measurement
- **AARRR / Pirate Metrics** (Dave McClure, 2007): growth-oriented measurement

These two frameworks are complementary — AARRR for the macro view, HEART for per-feature evaluation.

---

## 1. AARRR — Pirate Metrics

> Source: Dave McClure — "Startup Metrics for Pirates: AARRR" (500hats.com, 2007)

| Stage | Key Metric | Reference Threshold |
|-------|-------------|----------------------|
| **Acquisition** | CAC (Customer Acquisition Cost) | LTV/CAC ≥3x (SaaStr) |
| **Activation** | % users reaching the "Aha moment" event | ≥40% (SaaS benchmark — Andreessen Horowitz) |
| **Retention** | Day 7 / Day 30 / Day 90 retention | D30 ≥30% SaaS (a16z benchmark) |
| **Referral** | NPS (Net Promoter Score) | ≥40 = good, ≥70 = excellent (Bain & Company) |
| **Revenue** | Monthly MRR Churn | <2%/month (ProfitWell benchmark) |

**Aha Moment**: specific event that correlates with long-term retention. To be identified via cohort analysis (e.g., on Twitter → "follow 30 people within the first 3 days").

---

## 2. HEART Framework — Per Feature

> Source: Rodden K., Hutchinson H., Fu X. — "Measuring the User Experience on a Large Scale: User-Centered Metrics for Web Applications" (Google, CHI 2010)

| Dimension | Meaning | Example Metric |
|-----------|--------------|-------------------|
| **H**appiness | Subjective satisfaction | CSAT, NPS, average in-app score |
| **E**ngagement | Frequency of use | DAU/MAU ratio, sessions/user/week |
| **A**doption | New users of a feature | % users who used the feature 1x |
| **R**etention | Returning users | Cohort D7, D30, D90 |
| **T**ask Success | Task completion rate | Completion rate, error rate, time-on-task |

**Process:** for each new feature, define 1-2 HEART metrics *before* development, then measure after launch.

---

## 3. Event Taxonomy — Naming Convention

> Source: Segment Analytics Spec (segment.com/docs/connections/spec/track) — industry standard adopted by Amplitude, Mixpanel, PostHog

**Convention: `<object>_<action>` in snake_case**

```typescript
// ✅ Correct naming
'user_signed_up'
'subscription_created'
'feature_clicked'
'onboarding_step_completed'
'document_exported'

// ❌ Incorrect naming
'SignUp'           // PascalCase
'click button'     // space
'btn_click'        // too vague
'userDidSignUp'    // camelCase
```

**Mandatory properties on every event:**

```typescript
// types/analytics.ts
interface BaseEventProperties {
  user_id: string | null       // null if unauthenticated
  session_id: string           // session UUID
  timestamp: string            // ISO 8601
  platform: 'web' | 'ios' | 'android'
  app_version: string          // semver
  environment: 'production' | 'staging'
}

// Union type — all possible events (type-safety)
type AnalyticsEvent =
  | { event: 'user_signed_up'; properties: { method: 'email' | 'google' | 'github' } }
  | { event: 'user_logged_in'; properties: { method: 'email' | 'google' | 'github' } }
  | { event: 'subscription_created'; properties: { plan: string; price: number; currency: string } }
  | { event: 'subscription_cancelled'; properties: { reason: string; plan: string } }
  | { event: 'feature_used'; properties: { feature_name: string; source: string } }
  | { event: 'onboarding_step_completed'; properties: { step: number; step_name: string } }
```

---

## 4. TypeScript Helper — trackEvent

```typescript
// lib/analytics.ts
import posthog from 'posthog-js'

type AnalyticsEvent =
  | { event: 'user_signed_up'; properties: { method: 'email' | 'google' } }
  | { event: 'subscription_created'; properties: { plan: string; mrr: number } }
  | { event: 'feature_used'; properties: { feature_name: string } }
  | { event: 'onboarding_completed'; properties: { steps_skipped: number } }

export function trackEvent<T extends AnalyticsEvent['event']>(
  event: T,
  properties: Extract<AnalyticsEvent, { event: T }>['properties']
): void {
  if (process.env.NODE_ENV !== 'production') {
    console.debug('[analytics]', event, properties)
    return
  }

  posthog.capture(event, {
    ...properties,
    timestamp: new Date().toISOString(),
    platform: 'web',
    app_version: process.env.NEXT_PUBLIC_APP_VERSION ?? '0.0.0',
  })
}

// Usage — TypeScript error if wrong properties
trackEvent('subscription_created', { plan: 'pro', mrr: 49 })  // ✅
trackEvent('subscription_created', { plan: 'pro' })           // ❌ TypeScript error
```

---

## 5. GA4 — Next.js 14 Configuration

> Source: Next.js docs — `@next/third-parties` (nextjs.org/docs/app/building-your-application/optimizing/third-party-libraries), Google Analytics 4 docs (developers.google.com/analytics/devguides/collection/ga4)

```tsx
// app/layout.tsx
import { GoogleAnalytics } from '@next/third-parties/google'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="fr">
      <body>{children}</body>
      {process.env.NEXT_PUBLIC_GA_ID && (
        <GoogleAnalytics gaId={process.env.NEXT_PUBLIC_GA_ID} />
      )}
    </html>
  )
}
```

```typescript
// lib/gtag.ts
export const GA_MEASUREMENT_ID = process.env.NEXT_PUBLIC_GA_ID ?? ''

export function gtagEvent(action: string, parameters: Record<string, unknown>) {
  if (typeof window === 'undefined') return
  window.gtag?.('event', action, parameters)
}

// GA4 e-commerce event
gtagEvent('purchase', {
  transaction_id: 'T_12345',
  value: 49.00,
  currency: 'EUR',
  items: [{ item_id: 'plan_pro', item_name: 'Pro Plan', price: 49.00 }],
})
```

**Environment variables:**
```bash
NEXT_PUBLIC_GA_ID=G-XXXXXXXXXX    # Google Analytics 4 Measurement ID
```

---

## 6. PostHog — Recommended for EU Projects (GDPR)

> Source: PostHog docs (posthog.com/docs), PostHog EU Cloud (eu.posthog.com)

**Why PostHog vs GA4 for EU projects:**
- EU hosting available (eu.posthog.com) → data stays in Europe
- Open-source → self-hostable
- Session replay + heatmaps + feature flags included
- Free up to 1M events/month

```bash
npm install posthog-js
```

```typescript
// app/providers.tsx
'use client'
import posthog from 'posthog-js'
import { PostHogProvider } from 'posthog-js/react'
import { useEffect } from 'react'

export function PHProvider({ children }: { children: React.ReactNode }) {
  useEffect(() => {
    posthog.init(process.env.NEXT_PUBLIC_POSTHOG_KEY!, {
      api_host: process.env.NEXT_PUBLIC_POSTHOG_HOST ?? 'https://eu.i.posthog.com',
      person_profiles: 'identified_only',  // GDPR: no anonymous profile by default
      capture_pageview: false,  // manage manually for Next.js App Router
    })
  }, [])

  return <PostHogProvider client={posthog}>{children}</PostHogProvider>
}
```

---

## 7. Retention — Cohort Analysis (Supabase)

```sql
-- D30 Cohort: % of active users 30 days after signup
WITH cohort AS (
  SELECT
    user_id,
    DATE_TRUNC('week', created_at) AS cohort_week
  FROM users
  WHERE created_at >= NOW() - INTERVAL '90 days'
),
activity AS (
  SELECT DISTINCT
    user_id,
    DATE_TRUNC('week', created_at) AS activity_week
  FROM events
  WHERE created_at >= NOW() - INTERVAL '90 days'
)
SELECT
  c.cohort_week,
  COUNT(DISTINCT c.user_id) AS cohort_size,
  COUNT(DISTINCT a.user_id) AS retained_week_4,
  ROUND(COUNT(DISTINCT a.user_id)::numeric / COUNT(DISTINCT c.user_id) * 100, 1) AS retention_rate
FROM cohort c
LEFT JOIN activity a ON c.user_id = a.user_id
  AND a.activity_week = c.cohort_week + INTERVAL '4 weeks'
GROUP BY c.cohort_week
ORDER BY c.cohort_week;
```

---

## Pre-Launch Analytics Checklist

### Blockers

- [ ] Tracking plan documented (event list + properties) before development
- [ ] GA4 or PostHog configured and tested in staging
- [ ] GDPR consent before any tracking (cookie banner → analytics disabled by default)
- [ ] `trackEvent` type-safe — no free `string` for event names
- [ ] `user_id` hashed or pseudonymized in events (GDPR)

### Important

- [ ] Activation funnel defined and instrumented (Sign up → Aha Moment)
- [ ] NPS configured (in-app or email, triggered at D7 after activation)
- [ ] D7/D30 cohort visible in the dashboard
- [ ] DAU/MAU ratio instrumented

### Desirable

- [ ] Session replay enabled (PostHog) for UX debugging
- [ ] Feature flags (PostHog) for A/B tests
- [ ] Automatic alerts if weekly churn rate exceeds threshold

---

## Sources

| Reference | Link |
|-----------|------|
| HEART Framework — Google CHI 2010 | research.google/pubs/measuring-the-user-experience-on-a-large-scale |
| Pirate Metrics AARRR — Dave McClure | 500hats.com/startups/distribution |
| Andreessen Horowitz — 16 SaaS Metrics | a16z.com/2015/08/21/16-metrics |
| Google Analytics 4 docs | developers.google.com/analytics |
| PostHog docs | posthog.com/docs |
| Segment Analytics Spec | segment.com/docs/connections/spec/track |
| ProfitWell SaaS Metrics | profitwell.com/recur/all |
