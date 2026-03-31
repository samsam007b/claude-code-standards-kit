# Resilience Audit

> Based on CONTRACT-RESILIENCE.md | AWS Well-Architected Framework (Reliability Pillar) | Michael Nygard "Release It!" 2nd ed. (2018) | Google SRE Book (2016)
> Score: /100 | Recommended threshold: ≥70

---

## Section 1 — Circuit Breaker Pattern (25 points)

- [ ] Circuit breaker implemented for all external API calls (Supabase, third-party APIs) ......... (8)
- [ ] Three states defined : CLOSED (normal), OPEN (failing), HALF-OPEN (testing recovery) ........ (5)
- [ ] Failure threshold configured : opens after N failures in T seconds (e.g., 5 fails in 10s) ... (5)
- [ ] Recovery timeout configured : time in OPEN state before transitioning to HALF-OPEN .......... (4)
- [ ] Circuit state changes are logged for observability (CLOSED→OPEN, OPEN→HALF-OPEN) ........... (3)

**Sources:** Michael Nygard, *Release It!* 2nd ed., Chapter 5 (2018); Martin Fowler, "CircuitBreaker" pattern (martinfowler.com/bliki/CircuitBreaker.html)

**Subtotal: /25**

---

## Section 2 — Retry with Exponential Backoff (20 points)

- [ ] Transient errors (timeout, 503, 502, network failure) trigger automatic retry .............. (6)
- [ ] Exponential backoff implemented : delay doubles after each attempt (baseDelay × 2^attempt) .. (5)
- [ ] Jitter (randomization) added to backoff to prevent thundering herd ....................... (5)
- [ ] Maximum retry count defined : ≤3 for user-facing operations, ≤5 for background jobs ........ (4)

**Sources:** AWS Architecture Blog "Exponential Backoff and Jitter" (aws.amazon.com/blogs/architecture, 2015); Google Cloud "Retry Strategy" documentation; CONTRACT-ERROR-HANDLING.md §4.2

**Subtotal: /20**

---

## Section 3 — Graceful Degradation (20 points)

- [ ] Core feature continues when non-essential services fail .................................. (7)
- [ ] Fallback content shown when real-time data is unavailable (stale cache or placeholder) ...... (6)
- [ ] Degraded state is clearly communicated to users — no silent failures ...................... (4)
- [ ] Critical path is isolated : a failed recommendation engine does not block checkout .......... (3)

**Sources:** AWS Well-Architected Framework — Reliability Pillar, REL 10 (aws.amazon.com/architecture/well-architected); Michael Nygard, *Release It!* Chapter 4

**Subtotal: /20**

---

## Section 4 — Health Checks (15 points)

- [ ] `/api/health` endpoint returns 200 OK with structured body when all dependencies healthy .... (5)
- [ ] Health check verifies actual database connectivity (not just app startup status) ............ (5)
- [ ] Health check verifies external API connectivity (Supabase, third-party APIs) ............... (3)
- [ ] Health check responds in <100ms (no slow queries in health check path) ..................... (2)

**Sources:** Google SRE Book Chapter 6 (Monitoring Distributed Systems); Kubernetes Liveness and Readiness Probes documentation; CONTRACT-API-DESIGN.md §5.1

**Subtotal: /15**

---

## Section 5 — Timeout Configuration (10 points)

- [ ] All HTTP client calls have explicit timeouts configured (no infinite wait) .................. (4)
- [ ] Database query timeout configured on Supabase client or at server level .................... (3)
- [ ] Timeout values are documented and appropriate (e.g., 5s for reads, 30s for reports) ........ (3)

**Sources:** Michael Nygard, *Release It!* 2nd ed., Chapter 4 — Timeouts (2018); AWS Well-Architected Framework Reliability Pillar

**Subtotal: /10**

---

## Section 6 — Dependency Isolation (10 points)

- [ ] All third-party SDK calls are wrapped in try/catch and do not propagate raw errors to users .. (4)
- [ ] Database connection pool configured with explicit max connections (prevents pool exhaustion) .. (3)
- [ ] Rate limit errors (429) from external APIs are handled and not shown raw to users ............ (3)

**Sources:** AWS Well-Architected Framework — Reliability Pillar; CONTRACT-API-DESIGN.md §3.1

**Subtotal: /10**

---

## Total Score: /100

| Section | Score | /Total |
|---------|-------|--------|
| Circuit Breaker | | /25 |
| Retry + Backoff | | /20 |
| Graceful Degradation | | /20 |
| Health Checks | | /15 |
| Timeouts | | /10 |
| Dependency Isolation | | /10 |
| **TOTAL** | | **/100** |

```
Thresholds:
  ≥85 = Excellent — system handles failures gracefully under real conditions
  70–84 = Good — deploy with minor improvement plan tracked
  <70 = Insufficient — resilience gaps significantly increase incident probability
```

**Threshold: <70 = improvement plan required before deployment**

---

## Quick verification tools

```bash
# Check for circuit breaker or retry libraries in project
grep -r "cockatiel\|opossum\|circuit.*breaker\|retry" package.json 2>/dev/null

# Check for timeout configuration in API client setup
grep -rn "timeout\|AbortController\|AbortSignal" src/ --include="*.ts" --include="*.tsx"

# Check for health endpoint
find . -name "route.ts" -not -path "*/node_modules/*" | xargs grep -l "health" 2>/dev/null

# Check error boundaries coverage (Next.js App Router)
find . -name "error.tsx" -not -path "*/node_modules/*" | wc -l
find . -name "page.tsx" -not -path "*/node_modules/*" | wc -l
```

---

## Recommended Libraries

| Purpose | Library | npm |
|---------|---------|-----|
| Circuit breaker + retry | `cockatiel` | npmjs.com/package/cockatiel |
| Circuit breaker | `opossum` | npmjs.com/package/opossum |
| Resilience testing | Chaos Monkey (Netflix OSS) | github.com/netflix/chaosmonkey |
| Health monitoring | UptimeRobot, Better Uptime | — |
