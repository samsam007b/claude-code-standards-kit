# Contract — Error Handling

> SQWR Project Kit contract module.
> Standards: Nielsen Norman Group Error Message Guidelines (1993, revisited 2023), React Error Boundaries documentation, Next.js App Router error.tsx documentation, Google SRE Book (2016), AWS Architecture Blog Retry Patterns (2015).

---

## Scientific Foundations

**Error handling has two distinct audiences:** the user (needs clear, actionable, human language) and the developer (needs detailed, structured, searchable logs). Conflating them — showing stack traces to users, or logging vague "something went wrong" messages — creates both UX and security problems simultaneously.

Jakob Nielsen's error message guidelines (1993, still the reference standard) establish 4 non-negotiable principles for user-facing errors. Google SRE Book establishes the monitoring and SLO standards for server-side errors.

---

## 1. User-Facing Error Messages (25 pts)

### 1.1 Nielsen's 4 Principles for Error Messages

Every user-visible error message MUST satisfy all 4 criteria:

| Principle | Example (Bad) | Example (Good) |
|-----------|---------------|----------------|
| **Tell what happened** | "Error 401" | "Your session has expired" |
| **Explain why (when helpful)** | *(none)* | "Sessions expire after 24 hours of inactivity" |
| **Offer a solution** | "Try again" | "Sign in again to continue" with a direct link |
| **Use human language** | "HTTP 429: Too Many Requests" | "You've made too many requests. Please wait 30 seconds." |

No HTTP status codes, stack traces, database errors, or technical jargon in user-facing messages.

Source: Nielsen, J. (1993). *Usability Engineering* §4.2 Error Messages. Nielsen Norman Group revisited 2023 (nngroup.com/articles/error-message-guidelines)

### 1.2 Never Expose Technical Information to Users

The following MUST never appear in user-facing UI or API error responses:
- Stack traces (file paths, function names, line numbers)
- Database error messages (Postgres error codes, Supabase error strings)
- Internal identifiers (database IDs, server names, internal service names)
- File system paths or environment variable names

**Server-side mapping pattern:**
```typescript
// Map all internal errors to safe user messages before responding
function toUserError(error: unknown): string {
  if (error instanceof ZodError) return "Please check your input and try again."
  if (error instanceof AuthError) return "Your session has expired. Sign in again."
  // Log the real error internally, return generic message to user
  logger.error("Unhandled error", { error })
  return "Something went wrong. Please try again or contact support."
}
```

Source: OWASP Top 10 A05:2021 (Security Misconfiguration) — information disclosure via error messages

### 1.3 Error Display Speed

- User-facing error messages MUST appear within **200ms** of the triggering event
- Loading states must update immediately when an error is detected (do not wait for full timeout)
- A spinner that never resolves is worse than an immediate error message

Source: Nielsen, J. "Response Times: The 3 Important Limits" (Nielsen Norman Group, 1993) — 200ms is the threshold for "immediate" response perception

---

## 2. React Error Boundaries (25 pts)

### 2.1 Error Boundary Coverage

Next.js App Router structure:

```
app/
  global-error.tsx          ← catches uncaught root-level errors (REQUIRED)
  error.tsx                 ← catches errors in root layout (REQUIRED)
  dashboard/
    error.tsx               ← catches errors in dashboard section
    page.tsx
  profile/
    error.tsx               ← catches errors in profile section
    page.tsx
```

Rules:
- Root level: `app/global-error.tsx` MUST exist
- Feature level: every major feature route SHOULD have a co-located `error.tsx`
- Coverage target: **≥90% of interactive component tree** covered by error boundaries

Source: React Error Boundary documentation (react.dev/reference/react/Component#catching-rendering-errors-with-an-error-boundary); Next.js Error Handling docs (nextjs.org/docs/app/building-your-application/routing/error-handling)

### 2.2 Graceful Degradation

```tsx
// error.tsx — minimal compliant implementation
'use client'

import { useEffect } from 'react'

export default function ErrorBoundary({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    // Log to error monitoring (Sentry, etc.) — do not log to console in production
    if (process.env.NODE_ENV === 'production') {
      captureError(error)
    }
  }, [error])

  return (
    <div role="alert" aria-live="assertive">
      <h2>Something went wrong</h2>
      <p>We could not load this section. The rest of the page still works.</p>
      <button onClick={reset}>Try again</button>
    </div>
  )
}
```

Required in every error boundary:
- The REST of the page MUST continue to function (error visually isolated)
- Error state visually isolated — does not crash full-page layout
- `reset` button calls the `reset()` prop to retry (React 18)
- NEVER show a blank white screen or a spinner that never resolves

Source: React Error Boundaries docs, Next.js error.tsx documentation

### 2.3 Suspense + Error Boundary Pairing

For async data fetching, use Suspense alongside Error Boundary:

```tsx
<ErrorBoundary fallback={<ErrorFallback />}>
  <Suspense fallback={<LoadingSkeleton />}>
    <AsyncComponent />
  </Suspense>
</ErrorBoundary>
```

- Suspense handles the loading state (pending)
- Error Boundary handles the error state (rejected)

---

## 3. Server-Side Logging & Monitoring (25 pts)

### 3.1 Structured Error Logging

Every unhandled server-side error MUST be logged with this minimum context:

```typescript
interface ErrorLog {
  error: Error           // original error object (stack, message, name)
  userId: string | null  // authenticated user (null if unauthenticated)
  action: string         // what the user was trying to do ("create_payment", "update_profile")
  path: string           // API route or page ("/api/users", "/dashboard")
  environment: string    // "production" | "staging" | "development"
  timestamp: string      // ISO 8601 format
}
```

Source: Google SRE Book Chapter 6 (Monitoring Distributed Systems) — structured logging principle

### 3.2 Error Monitoring Integration (Sentry or equivalent)

```typescript
// Capture with full context — not just Sentry.captureException(error)
Sentry.captureException(error, {
  user: { id: userId },
  extra: {
    action,
    path,
    requestId,
  },
})
```

Requirements:
- All unhandled exceptions MUST be captured (not just console.error)
- Source maps MUST be uploaded to Sentry to get readable stack traces in the dashboard
- Set up alert rules for error rate >0.1% per session

Source: Google SRE Book Chapter 3 (Service Level Objectives); Sentry documentation (docs.sentry.io)

### 3.3 Error Rate SLO

| Threshold | Action | Source |
|-----------|--------|--------|
| <0.1% session error rate | Acceptable | Google SRE Book §3 |
| 0.1–1% session error rate | Investigate within 24 hours | Google SRE Book §3 |
| >1% session error rate | Immediate investigation or rollback | Google SRE Book §3 |

Monitor via Sentry → Releases → Session Crash Rate.

Source: Google SRE Book Chapter 3 (Service Level Objectives, Error Budget)

---

## 4. Transient Error Handling & Retry (25 pts)

### 4.1 Distinguishing Error Types

| Error type | Examples | Action |
|------------|----------|--------|
| **Expected errors** | Validation, 401, 404, form errors | Show user message — do NOT retry automatically |
| **Transient errors** | Network timeout, 503, 429 rate limit | Retry with exponential backoff |
| **Fatal errors** | 500, render crash, unhandled exception | Log, show error boundary, offer escape route |

### 4.2 Exponential Backoff for Transient Errors

```typescript
const isTransient = (error: unknown): boolean => {
  if (error instanceof Response) {
    return [429, 503, 502, 504].includes(error.status)
  }
  if (error instanceof Error) {
    return error.message.includes('fetch failed') || error.name === 'AbortError'
  }
  return false
}

// Retry with exponential backoff + jitter
const retry = async <T>(
  fn: () => Promise<T>,
  maxRetries = 3,
  baseDelayMs = 1000
): Promise<T> => {
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await fn()
    } catch (error) {
      if (attempt === maxRetries || !isTransient(error)) throw error
      const delay = baseDelayMs * Math.pow(2, attempt) + Math.random() * 1000
      await new Promise(resolve => setTimeout(resolve, delay))
    }
  }
  throw new Error('Max retries reached')
}
```

**Jitter** (the `+ Math.random() * 1000`) prevents thundering herd: when many clients fail simultaneously, randomized delays prevent all retries hitting the server at the same instant.

Source: AWS Architecture Blog "Exponential Backoff and Jitter" (aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter, 2015); Google Cloud "Retry Strategy" documentation

### 4.3 User-Initiated Retry

For operations that fail due to transient errors:
- Show a "Try again" button
- Indicate retry attempt count if retrying automatically: "Retrying... attempt 2 of 3"
- After maximum retries, show a permanent error state with an alternative action (e.g., "Try again later" or contact support link)

Maximum retry count: **3 for user-facing operations**, up to 5 for background jobs.

Source: Nielsen Norman Group "Error Recovery" guidelines (2023); AWS Architecture Blog Retry Patterns

---

## 5. Measurable Thresholds Summary

| Rule | Threshold | Standard |
|------|-----------|---------|
| Error boundary coverage | ≥90% of interactive component tree | React Error Boundaries docs |
| Error display speed | ≤200ms after triggering event | Nielsen NN/G 1993 |
| Session error rate (acceptable) | <0.1% | Google SRE Book Ch. 3 |
| Session error rate (rollback trigger) | >1% | Google SRE Book Ch. 3 |
| Max retry attempts (user-facing) | 3 | AWS Architecture Blog 2015 |
| Max retry attempts (background) | 5 | AWS Architecture Blog 2015 |
| Base retry delay (exponential) | 1000ms × 2^attempt + jitter | AWS Backoff and Jitter 2015 |

---

## 6. Sources

| Reference | Link |
|-----------|------|
| Nielsen — Usability Engineering (1993) | nngroup.com/articles/error-message-guidelines |
| React Error Boundaries | react.dev/reference/react/Component#catching-rendering-errors-with-an-error-boundary |
| Next.js App Router Error Handling | nextjs.org/docs/app/building-your-application/routing/error-handling |
| Google SRE Book — Chapter 3 (SLOs) | sre.google/sre-book/embracing-risk |
| Google SRE Book — Chapter 6 (Monitoring) | sre.google/sre-book/monitoring-distributed-systems |
| OWASP Top 10 A05:2021 | owasp.org/Top10/A05_2021-Security_Misconfiguration |
| AWS — Exponential Backoff and Jitter (2015) | aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter |
| Sentry Documentation | docs.sentry.io |

---

> **Last validated:** 2026-03-30 — Nielsen NN/G Error Guidelines 1993/2023, React Error Boundaries, Next.js App Router, Google SRE Book Ch. 3 & 6, OWASP A05:2021, AWS Retry Patterns 2015
