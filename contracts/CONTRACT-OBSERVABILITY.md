# Contract — Observability & Monitoring

> SQWR Project Kit contract module.
> Sources: Google SRE Book, OpenTelemetry, Sentry docs, Supabase Backup docs.
> Principle: "Vercel logs" ≠ observability. Production without monitoring is blind.

---

## Foundations

**Without observability, the system fails silently.** Google SRE distinguishes three pillars:
- **Logs**: discrete events (what happened)
- **Metrics**: numerical aggregates over time (what state the system is in)
- **Traces**: the path of a request through components (why it is slow)

> Source: *Google SRE Book, Chapter 6 — Monitoring Distributed Systems*

---

## 1. Structured Logging

### Never do

```typescript
// ❌ Unstructured console.log — impossible to filter or alert on
console.log("Payment error", err)
console.log("User " + userId + " logged in")
```

### Always do

```typescript
// ✅ Structured logging — JSON parseable, filterable, alertable
const log = {
  level: 'error',          // debug | info | warn | error | fatal
  message: 'payment_failed',
  userId: userId,          // identifier, never email/password
  orderId: orderId,
  errorCode: err.code,
  timestamp: new Date().toISOString(),
  traceId: generateTraceId(),  // to correlate logs from the same request
}
console.error(JSON.stringify(log))
```

**PII Rules (GDPR):**

| Never log | Log instead |
|-----------|-------------|
| Email | userId (anonymous hash) |
| Password | — (never) |
| Card number | last 4 digits only |
| Full address | city only |
| Session token | — (never) |

**Log levels:**

| Level | When to use |
|-------|------------|
| `debug` | Dev only — disabled in production |
| `info` | Normal business actions (user created, payment succeeded) |
| `warn` | Abnormal but recoverable situation (retry, deprecated API) |
| `error` | Error that affects a user |
| `fatal` | Service unavailable |

---

## 2. Error Tracking — Sentry

**Rule: `console.error` alone is insufficient in production.** Sentry aggregates, deduplicates, alerts, and links errors to releases.

```bash
npm install @sentry/nextjs
npx @sentry/wizard@latest -i nextjs
```

```typescript
// sentry.client.config.ts
import * as Sentry from "@sentry/nextjs"

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 0.1,      // 10% of transactions — adjust based on volume
  profilesSampleRate: 0.1,
  // Do not send errors from local dev
  enabled: process.env.NODE_ENV === 'production',
})
```

```typescript
// In Server Actions or API routes
import * as Sentry from "@sentry/nextjs"

export async function createPayment(data: unknown) {
  try {
    const validated = PaymentSchema.parse(data)
    return await processPayment(validated)
  } catch (err) {
    Sentry.captureException(err, {
      tags: { feature: 'payment', userId },
      level: 'error',
    })
    throw err
  }
}
```

**Sentry alerts to configure:**
- Error rate > 1% on a page → immediate Slack/email notification
- New unseen error → immediate notification
- Error affecting > 10 users → critical notification

---

## 3. Performance Monitoring — Real User Monitoring (RUM)

**Lighthouse DevTools ≠ real user experience.** Lighthouse measures under ideal conditions. RUM measures what real users actually experience.

```typescript
// app/layout.tsx — Vercel Speed Insights (free RUM on Vercel)
import { SpeedInsights } from "@vercel/speed-insights/next"

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <SpeedInsights />  {/* Measures real LCP, INP, CLS per user */}
      </body>
    </html>
  )
}
```

**RUM metrics to monitor:**

| Metric | Alert Threshold | Tool |
|--------|----------------|------|
| LCP | >3s at 75th percentile | Vercel Speed Insights |
| INP | >300ms | Vercel Speed Insights |
| CLS | >0.15 | Vercel Speed Insights |
| Error rate | >1% of sessions | Sentry |

---

## 4. Backup & Disaster Recovery

### Supabase

```bash
# Verify that PITR (Point-in-Time Recovery) is enabled
# Supabase Dashboard → Settings → Database → PITR
# Pro plan: PITR up to 7 days
# Team plan: PITR up to 28 days
```

**Restoration procedure:**
1. Supabase Dashboard → Backups → select the restore point
2. Restore to a separate project first (do not overwrite production directly)
3. Verify the integrity of the restored data
4. Switch the connection once validated

**Manual regular export (for plans without PITR):**
```bash
# Full database export
pg_dump "postgresql://postgres:[password]@[host]:5432/postgres" \
  --format=custom \
  --file="backup-$(date +%Y%m%d).dump"
```

### Disaster Recovery Checklist

- [ ] PITR enabled on Supabase (or automated export configured)
- [ ] Last restoration tested (never merely assumed to work)
- [ ] Procedure documented and accessible without access to the compromised system
- [ ] Emergency contacts defined (Supabase support, Vercel support)

---

## 5. Alerting — Recommended Thresholds

| Event | Threshold | Action |
|-------|-----------|--------|
| Error rate | >1% | Immediate Slack notification |
| p95 latency | >2s | Slack notification |
| p99 latency | >5s | Page (on-call) |
| Supabase connection pool | >80% | Warning |
| Build failure | Any | Immediate notification |
| npm audit critical | Any | Block deployment |

---

## 6. Absolute Rules

### Never do
- Log sensitive data (email, password, tokens, card numbers)
- Disable Sentry alerts "because of noise" without investigating
- Go to production without error tracking configured
- Use `console.log` as the sole monitoring mechanism

### Always do
- Include a `traceId` in every log to correlate events
- Configure Sentry alerts before the first production deployment
- Test the Supabase restoration procedure on a clone project
- Check Vercel logs + Sentry within the 30 minutes following a deployment

---

## 7. Sources

| Reference | Source |
|-----------|--------|
| Google SRE Book — Monitoring | sre.google/sre-book/monitoring-distributed-systems |
| OpenTelemetry | opentelemetry.io |
| Sentry Next.js Setup | docs.sentry.io/platforms/javascript/guides/nextjs |
| Vercel Speed Insights | vercel.com/docs/speed-insights |
| Supabase Backup & PITR | supabase.com/docs/guides/platform/backups |

> **Last validated:** 2026-03-30 — OpenTelemetry, Google SRE Book, Sentry docs, Vercel Speed Insights, Supabase Backup & PITR