# Contract — Resilience & Recovery Patterns

> SQWR Project Kit contract module.
> Sources: AWS Well-Architected Framework, Microsoft Resilience Patterns, Release It! (Nygard 2018).
> Principle: distributed systems always fail — the question is how they fail.

---

## Foundations

**"Design for failure"** — founding principle of the AWS Well-Architected Framework. A service that assumes its dependencies (Supabase, external APIs, LLMs) are always available is fragile by design. A resilient service assumes failure and recovers from it gracefully.

> Source: *AWS Well-Architected Framework — Reliability Pillar*
> Source: *Release It! — Michael Nygard (2018)*

---

## 1. Retry with Exponential Backoff

**Problem:** A failing request is often caused by a transient condition (temporary overload, unstable network). Retrying immediately makes the problem worse.

**Solution:** Wait progressively longer between attempts, with jitter (randomness) to avoid "thundering herds" (all clients retrying simultaneously).

```typescript
// lib/retry.ts
interface RetryOptions {
  maxAttempts?: number   // default: 3
  baseDelay?: number     // default: 1000ms
  maxDelay?: number      // default: 10000ms
  jitter?: boolean       // default: true
}

async function withRetry<T>(
  fn: () => Promise<T>,
  options: RetryOptions = {}
): Promise<T> {
  const { maxAttempts = 3, baseDelay = 1000, maxDelay = 10000, jitter = true } = options

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn()
    } catch (err) {
      if (attempt === maxAttempts) throw err

      // Non-retryable errors (4xx = client error, not transient)
      if (err instanceof Error && 'status' in err) {
        const status = (err as any).status
        if (status >= 400 && status < 500) throw err
      }

      const exponentialDelay = Math.min(baseDelay * 2 ** (attempt - 1), maxDelay)
      const delay = jitter
        ? exponentialDelay * (0.5 + Math.random() * 0.5)
        : exponentialDelay

      await new Promise(resolve => setTimeout(resolve, delay))
    }
  }
  throw new Error('Retry exhausted') // unreachable
}

// Usage
const data = await withRetry(
  () => supabase.from('projects').select('*'),
  { maxAttempts: 3, baseDelay: 500 }
)
```

---

## 2. Circuit Breaker

**Problem:** If a dependency is down, continuing to call it wastes resources and slows responses for all users.

**Solution:** After N consecutive failures, "open the circuit" (stop calling the dependency) for a period. After the delay, test with a single request ("half-open"). If it succeeds, close the circuit.

```typescript
// lib/circuit-breaker.ts
type CircuitState = 'closed' | 'open' | 'half-open'

class CircuitBreaker {
  private state: CircuitState = 'closed'
  private failureCount = 0
  private lastFailureTime?: number

  constructor(
    private threshold = 5,      // number of failures before opening
    private timeout = 30000,    // ms before testing in half-open
  ) {}

  async execute<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === 'open') {
      if (Date.now() - (this.lastFailureTime ?? 0) > this.timeout) {
        this.state = 'half-open'
      } else {
        throw new Error('Circuit breaker OPEN — service unavailable')
      }
    }

    try {
      const result = await fn()
      this.onSuccess()
      return result
    } catch (err) {
      this.onFailure()
      throw err
    }
  }

  private onSuccess() {
    this.failureCount = 0
    this.state = 'closed'
  }

  private onFailure() {
    this.failureCount++
    this.lastFailureTime = Date.now()
    if (this.failureCount >= this.threshold) {
      this.state = 'open'
    }
  }
}

// Instances per external service
export const supabaseBreaker = new CircuitBreaker(5, 30000)
export const llmBreaker = new CircuitBreaker(3, 60000)  // LLM = stricter
```

---

## 3. Graceful Degradation

**Principle:** When part of the system fails, the rest must keep running — in degraded mode if necessary, but not in a total crash.

```typescript
// ✅ Non-critical feature that degrades gracefully
async function getPersonalizedRecommendations(userId: string) {
  try {
    return await llmBreaker.execute(() => fetchAIRecommendations(userId))
  } catch {
    // Fallback: static recommendations if the LLM is unavailable
    return getStaticRecommendations()
  }
}

// ✅ React component with fallback UI
function RecommendationsSection({ userId }: { userId: string }) {
  return (
    <Suspense fallback={<RecommendationsSkeleton />}>
      <ErrorBoundary
        fallback={<StaticRecommendations />}  // ← replacement UI
      >
        <DynamicRecommendations userId={userId} />
      </ErrorBoundary>
    </Suspense>
  )
}
```

**Degradation levels:**

| Service down | Degraded behavior |
|-----------------|---------------------|
| LLM (OpenRouter/Claude) | Static content or template |
| Supabase (read) | Local cache or graceful error |
| Supabase (write) | Local queue + async retry |
| Email service (Resend) | Internal log + scheduled retry |
| Analytics (Plausible) | Silent — non-blocking by nature |

---

## 4. Timeouts

**Rule:** All I/O (network, DB, LLM) must have an explicit timeout. Without a timeout, a blocked request can hold a thread/worker indefinitely.

```typescript
// Recommended timeouts by operation type
const TIMEOUTS = {
  supabase_read: 5_000,     // 5s — DB read
  supabase_write: 10_000,   // 10s — DB write + triggers
  llm_api: 30_000,          // 30s — LLM can be slow
  external_api: 10_000,     // 10s — third-party APIs
  email_send: 5_000,        // 5s — email service
} as const

// fetch with timeout
async function fetchWithTimeout(url: string, ms: number) {
  const controller = new AbortController()
  const timeout = setTimeout(() => controller.abort(), ms)

  try {
    const response = await fetch(url, { signal: controller.signal })
    return response
  } finally {
    clearTimeout(timeout)
  }
}

// Supabase with timeout
const { data, error } = await Promise.race([
  supabase.from('spaces').select('*').eq('id', spaceId),
  new Promise((_, reject) =>
    setTimeout(() => reject(new Error('Supabase timeout')), TIMEOUTS.supabase_read)
  )
])
```

---

## 5. Cascading Failures — Serverless + Supabase

**Specific problem with Next.js / Vercel + Supabase:**

Vercel serverless functions have **cold starts**. Under a traffic spike, dozens of functions start simultaneously → each opens a Supabase connection → the **connection pool is exhausted** → all requests fail.

**Mitigation:**

```typescript
// Use Supabase Transaction Pooler (port 6543) instead of Direct Connection
// In .env.local:
# ✅ Transaction Pooler — supports far more simultaneous connections
DATABASE_URL="postgresql://postgres.[ref]:[password]@aws-0-eu-central-1.pooler.supabase.com:6543/postgres?pgbouncer=true"

# ❌ Direct connection — limited to ~100 simultaneous connections
DATABASE_URL="postgresql://postgres:[password]@db.[ref].supabase.co:5432/postgres"
```

```typescript
// Singleton Supabase client to reuse connections
// lib/supabase/server.ts
import { createServerClient } from '@supabase/ssr'

// ✅ One client per request (Next.js caches the module)
export function createClient() {
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { cookies }
  )
}
```

---

## 6. Feature Flags — Controlled Degradation

Feature flags allow disabling a faulty feature in production **without redeployment**.

```typescript
// lib/feature-flags.ts — simple implementation with no external dependency
const flags: Record<string, boolean> = {
  'ai-recommendations': true,
  'advanced-analytics': true,
  'experimental-search': false,
}

export function isEnabled(flag: string): boolean {
  // In production, read from env var or Supabase config table
  const envFlag = process.env[`FEATURE_${flag.toUpperCase().replace(/-/g, '_')}`]
  if (envFlag !== undefined) return envFlag === 'true'
  return flags[flag] ?? false
}

// Usage in components
if (isEnabled('ai-recommendations')) {
  return <AIRecommendations />
}
return <StaticRecommendations />  // fallback
```

---

## 7. Absolute Rules

### Never do
- Perform I/O (network, DB, LLM) without an explicit timeout
- Propagate an error from a non-critical feature into a full-page crash
- Retry immediately without backoff (worsens outages)
- Use the direct Supabase connection (port 5432) in serverless production

### Always do
- Define a fallback for every feature that relies on an external service
- Log circuit breaker events (open/closed/half-open state)
- Use the Supabase Transaction Pooler (port 6543) in production
- Test degradation behavior in staging before production

---

## 8. Sources

| Reference | Source |
|-----------|--------|
| AWS Well-Architected — Reliability | docs.aws.amazon.com/wellarchitected/reliability |
| Microsoft Resilience Patterns | learn.microsoft.com/en-us/azure/architecture/patterns/category/resiliency |
| Release It! — Michael Nygard | pragprog.com/titles/mnee2 |
| Supabase Connection Pooling | supabase.com/docs/guides/database/connecting-to-postgres |
| Vercel Serverless Cold Starts | vercel.com/docs/functions/runtimes |

> **Last validated:** 2026-03-30 — AWS Well-Architected Framework, Release It\! (Nygard 2018), Google SRE Book, Microsoft Resilience Patterns, Supabase docs