---
name: load-test-audit
description: "Scalability audit: can the app handle 100+ simultaneous users? Analyzes Supabase, Next.js, Vercel limits"
tags: [performance, scalability, load-testing, infrastructure]
version: 1.0.0
---

# ⚡ Load Test & Scalability Audit

Check whether the application can handle a heavy load (100+ concurrent users) without crashing or slowing down.

---

## 🎯 Performance Objectives

| Metric | Target | Acceptable | Critical |
|----------|--------|------------|----------|
| **Concurrent users** | 100 | 50 | < 20 |
| **API response (p95)** | < 300ms | < 500ms | > 1s |
| **Database queries** | < 100ms | < 200ms | > 500ms |
| **Page load (LCP)** | < 2s | < 2.5s | > 4s |
| **Time to Interactive** | < 3s | < 5s | > 8s |
| **Error rate** | < 0.1% | < 1% | > 5% |

---

## Phase 1: Supabase Limits Analysis

### 1.1 Connection Pooling

**Check configuration**:
```typescript
// Check DATABASE_URL in .env
// Must contain: ?pgbouncer=true&connection_limit=10
```

**Supabase Plans**:
| Plan | Max Connections | Simultaneous Requests | Storage |
|------|-----------------|----------------------|---------|
| Free | 60 | 500 req/sec | 500 MB |
| Pro | 200 | 2000 req/sec | 8 GB |
| Team | 400 | 5000 req/sec | 100 GB |

**Calculation for 100 users**:
- If each user makes 2 queries/sec → 200 queries/sec
- Free tier: OK (500 req/sec max)
- But connections: 100 users × 1 connection = 100 connections
- Free tier limit: 60 connections → **UPGRADE REQUIRED** for 100 users

**Action**:
- [ ] Check the current Supabase plan
- [ ] If Free + > 60 users expected → Upgrade to Pro
- [ ] Connection pooling enabled

### 1.2 Realtime Limits

**Supabase Realtime**:
| Plan | Concurrent Connections | Concurrent Channels |
|------|------------------------|---------------------|
| Free | 200 | 2 |
| Pro | 500 | 100 |

**If realtime is used** (messages, notifications):
- [ ] 100 users = 100 connections → OK on Free
- [ ] But if > 2 different channels → Pro required

### 1.3 Storage & Bandwidth

**Free tier**:
- 1 GB storage
- 2 GB bandwidth/month

**Calculation**:
- 100 users × 5 photos (2 MB) = 1 GB → **limit reached**
- 100 users × 10 MB download/month = 1 GB/month → OK

**Action**:
- [ ] Aggressive compression (WebP, quality 85%)
- [ ] CDN cache (reduce bandwidth)
- [ ] Monitor current usage

---

## Phase 2: Next.js / Vercel Limits

### 2.1 Vercel Plan Limits

| Plan | Bandwidth | Executions | Execution Duration |
|------|-----------|------------|-------------------|
| Hobby | 100 GB/month | 100k/month | 10s |
| Pro | 1 TB/month | 1M/month | 300s |

**For 100 users**:
- 100 users × 100 pages/month × 1 MB/page = 10 GB → OK Hobby
- 100 users × 100 API calls/month = 10k calls → OK Hobby

**But**:
- Hobby = 1 concurrent build
- Hobby = no team collaboration
- **If professional project → Pro tier recommended**

### 2.2 Edge Functions vs Serverless

**Next.js API Routes** (Serverless by default):
- Cold start: 100-300ms
- Timeout: 10s (Hobby), 300s (Pro)
- Concurrent: Unlimited (auto-scale)

**Edge Functions** (for ultra-low latency):
- Cold start: < 50ms
- Timeout: 30s max
- But limitations: no fs, limited crypto

**Recommendation**:
- Standard API routes → Serverless (auto-scale)
- Auth, redirects → Edge if needed

### 2.3 ISR & Caching

**Incremental Static Regeneration**:
```typescript
export const revalidate = 3600; // 1 hour

// OR
export async function generateStaticParams() {
  // Pre-render top 100 properties
}
```

**Checklist**:
- [ ] Public pages (landing, listings) on ISR
- [ ] Correct `Cache-Control` headers
- [ ] CDN enabled on Vercel

---

## Phase 3: Database Query Performance

### 3.1 Index Analysis

**SQL to run**:
```sql
-- Tables without indexes
SELECT tablename, indexname
FROM pg_indexes
WHERE schemaname = 'public'
GROUP BY tablename
HAVING COUNT(*) <= 1; -- Primary key only

-- Slow queries (enable log_min_duration_statement)
SELECT query, mean_exec_time
FROM pg_stat_statements
WHERE mean_exec_time > 100
ORDER BY mean_exec_time DESC
LIMIT 20;
```

**Columns that should have an index**:
- `user_id` (almost all tables)
- `property_id` (tables linked to properties)
- `created_at` (for ORDER BY)
- Foreign keys

### 3.2 Query Complexity

**Search**:
```bash
# Queries with 3+ JOINs
grep -r "\.select(" lib/services/ | grep -o "," | wc -l

# Queries without .limit()
grep -r "\.order(" lib/services/ | grep -v "\.limit("
```

**Recommended limits**:
- List queries: `.limit(100)` max
- Search results: `.limit(50)`
- Autocomplete: `.limit(10)`

---

## Phase 4: Frontend Performance

### 4.1 Bundle Size Analysis

```bash
# Analyze bundle
ANALYZE=true npm run build

# Check First Load JS
# Target: < 200 KB
```

**Checklist**:
- [ ] Dynamic imports for heavy components
- [ ] Tree-shaking enabled
- [ ] No barrel exports (index.ts files that re-export everything)

### 4.2 Image Optimization

**Targets**:
- Total image weight per page: < 1 MB
- LCP image: < 500 KB
- Lazy loading on below-the-fold images

**Check**:
```bash
# Images > 500 KB
find public -name "*.jpg" -o -name "*.png" | xargs du -h | grep "M$"
```

### 4.3 React Re-renders

**Tools**:
- React DevTools Profiler
- Why Did You Render (dev dependency)

**Targets**:
- < 10 re-renders per user interaction
- `memo()` components for lists > 20 items

---

## Phase 5: Stress Test Simulation

### 5.1 Recommended Tools

| Tool | Usage | Price |
|------|-------|------|
| **k6** | Open-source, JS script | Free |
| **Artillery** | YAML config, easy | Free |
| **Loader.io** | Cloud-based, fast | $99/month |
| **BlazeMeter** | Enterprise, detailed | $199/month |

### 5.2 Test Scenario (k6)

```javascript
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 10 },   // Ramp-up to 10 users
    { duration: '5m', target: 50 },   // Stay at 50 users
    { duration: '2m', target: 100 },  // Peak at 100 users
    { duration: '5m', target: 100 },  // Sustain 100 users
    { duration: '2m', target: 0 },    // Ramp-down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% requests < 500ms
    http_req_failed: ['rate<0.01'],   // < 1% errors
  },
};

export default function () {
  // Test login
  let loginRes = http.post('https://example.com/api/auth/login', {
    email: 'test@example.com',
    password: 'test123',
  });
  check(loginRes, { 'login success': (r) => r.status === 200 });

  sleep(1);

  // Test search
  let searchRes = http.get('https://example.com/seeker/explore');
  check(searchRes, { 'search loaded': (r) => r.status === 200 });

  sleep(2);
}
```

### 5.3 Results to Analyze

**k6 Output**:
```
http_req_duration..............: avg=250ms p(95)=450ms
http_req_failed................: 0.5%
http_reqs......................: 15000 (50/s)
vus............................: 100 (peak)
```

**Interpretation**:
- ✅ p95 < 500ms → PASS
- ✅ error rate < 1% → PASS
- ✅ 50 req/sec sustained → PASS

---

## Phase 6: Infrastructure Readiness

### 6.1 Disaster Recovery

**Checklist**:
- [ ] Supabase backups enabled (daily)
- [ ] Point-in-time recovery configured (Pro tier)
- [ ] Backup restoration tested
- [ ] RTO (Recovery Time Objective) < 4h
- [ ] RPO (Recovery Point Objective) < 1h

### 6.2 Monitoring & Alerting

**Metrics to monitor**:
- CPU usage (Vercel functions)
- Memory usage
- Active database connections
- Error rate (Sentry)
- Response time p95

**Alerts to configure**:
- Error rate > 5% → immediate Slack
- Database connections > 80% → Email
- Response time p95 > 1s → Slack

### 6.3 Scaling Strategy

**Vertical Scaling**:
- Supabase Pro (200 connections)
- Vercel Pro (300s timeout)

**Horizontal Scaling**:
- Next.js API routes = auto-scale
- Supabase Read Replicas (Enterprise)
- CDN for static assets

**For 1000+ users**:
- Supabase Team plan ($599/month)
- Vercel Enterprise
- Dedicated database instance

---

## Final Report - Template

```markdown
# LOAD TEST RESULTS - [Date]

## Test Configuration
- **Users**: 100 concurrent
- **Duration**: 15 minutes
- **Scenario**: [Login → Browse → Search → View property]

## Results

| Metric | Result | Target | Status |
|--------|--------|--------|--------|
| p95 latency | XXXms | < 500ms | [✅/🔴] |
| Error rate | X.X% | < 1% | [✅/🔴] |
| Throughput | XX req/s | > 50 req/s | [✅/🔴] |

## Bottlenecks Identified

1. [Issue 1] - [Impact]
2. [Issue 2] - [Impact]

## Recommendations

1. [Action 1]
2. [Action 2]

## Infrastructure Costs (100 users)

- Supabase: $XX/month (Pro tier recommended)
- Vercel: $XX/month (Pro tier)
- Total: $XX/month

## Scaling Roadmap

- 0-50 users: Free tiers OK
- 50-100 users: Pro tiers
- 100-500 users: Pro + optimizations
- 500-1000 users: Team/Enterprise tiers
- 1000+ users: Dedicated infrastructure
```

---

## Checklists per Tier

### Free Tier (0-50 users)
- [ ] Connection pooling enabled
- [ ] Strict rate limiting
- [ ] Aggressive image compression
- [ ] ISR on public pages
- [ ] Basic monitoring (Sentry free)

### Pro Tier (50-200 users)
- [ ] Supabase Pro ($25/month)
- [ ] Vercel Pro ($20/month)
- [ ] Read replicas if needed
- [ ] APM monitoring (Sentry Pro)
- [ ] Daily backups

### Enterprise (200+ users)
- [ ] Dedicated Supabase instance
- [ ] Vercel Enterprise
- [ ] Premium CDN (Cloudflare)
- [ ] 24/7 monitoring
- [ ] SLA guarantees

---

**Execution time**: 30 min (setup) + 15 min (test run) + 15 min (analysis)
**Tools required**: k6 OR Artillery
**Cost**: Free (k6/Artillery) OR $99-199/month (Loader.io, BlazeMeter)
