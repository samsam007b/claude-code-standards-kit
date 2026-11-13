---
name: performance-deep-audit
description: "In-depth performance audit: Core Web Vitals, bundle size, query optimization, React re-renders. Google/Vercel standards."
tags: [performance, optimization, web-vitals, latency]
version: 1.0.0
---

# ⚡ Performance Deep Audit

Exhaustive performance audit based on Google standards (Core Web Vitals), Vercel, and Next.js 14/15 best practices.

---

## Measurable Objectives

### Core Web Vitals (Google Standard)

| Metric | Target (Good) | Threshold | Current |
|--------|---------------|-----------|---------|
| **LCP** (Largest Contentful Paint) | < 2.5s | < 4s | [__s] |
| **INP** (Interaction to Next Paint) | < 200ms | < 500ms | [__ms] |
| **CLS** (Cumulative Layout Shift) | < 0.1 | < 0.25 | [__] |

The **75th percentile** of ALL users must be in "Good".

### Application Metrics

| Metric | Target | Current |
|--------|--------|---------|
| **First Load JS** | < 200 KB | [__ KB] |
| **Total Bundle** | < 500 KB | [__ KB] |
| **API p95** | < 300ms | [__ ms] |
| **Database p95** | < 100ms | [__ ms] |
| **Images/page** | < 1 MB | [__ MB] |

---

## Phase 1: Bundle Analysis (10 min)

### 1.1 Build Analysis

```bash
# Enable analyzer
ANALYZE=true npm run build

# Output: bundle-analyzer.html
# Open in browser to visualize
```

**Check**:
- [ ] First Load JS < 200 KB
- [ ] Shared chunks < 150 KB
- [ ] Page-specific chunks < 50 KB
- [ ] Zero code duplication between chunks

### 1.2 Heavy Imports

**Search**:
```bash
# framer-motion usage
grep -r "from 'framer-motion'" app/ components/ | wc -l

# recharts usage
grep -r "from 'recharts'" app/ components/ | wc -l

# lucide-react (how many icons?)
grep -r "from 'lucide-react'" app/ components/ | grep -o "{\s*[^}]*}" | tr ',' '\n' | wc -l
```

**Frequent problems**:
- framer-motion (~60 KB) imported on every page
- recharts (~120 KB) loaded even when unused
- 30+ lucide icons imported individually

**Fixes**:
```typescript
// ❌ Heavy import
import { motion, AnimatePresence, useAnimation } from 'framer-motion';

// ✅ Dynamic import
const motion = dynamic(() => import('framer-motion').then(mod => mod.motion), { ssr: false });

// ❌ 30 icons
import { Home, User, Settings, ... } from 'lucide-react';

// ✅ Icon component wrapper
import Icon from '@/components/ui/Icon';
<Icon name="home" />
```

### 1.3 Tree-Shaking Verification

**Search for barrel exports**:
```bash
# index.ts files that re-export everything
find components -name "index.ts" -exec grep -l "export.*from" {} \;
```

**❌ Anti-pattern**:
```typescript
// components/ui/index.ts
export { Button } from './button';
export { Input } from './input';
export { Select } from './select';
// ... 20 exports

// Usage
import { Button } from '@/components/ui'; // Imports the WHOLE barrel
```

**✅ Fix**:
```typescript
// Direct import
import { Button } from '@/components/ui/button';
```

---

## Phase 2: Image Optimization (5 min)

### 2.1 Image Audit

```bash
# <img> instead of <Image>
grep -r "<img" app/ components/ --include="*.tsx" | grep -v "\.svg"

# Images without width/height
grep -r "<Image" app/ components/ | grep -v "width=\|fill"

# Images not lazy-loaded
grep -r "<Image" app/ components/ | grep -v "loading="
```

**Checklist**:
- [ ] All images use `<Image>` (except SVG)
- [ ] `width` and `height` defined (avoids CLS)
- [ ] `loading="lazy"` on below-the-fold images
- [ ] Modern formats (WebP, AVIF) configured

### 2.2 Image Compression

**Target sizes**:
| Type | Max Size | Format |
|------|----------|--------|
| Hero image | 200 KB | WebP 85% |
| Property photo | 150 KB | WebP 85% |
| Avatar | 30 KB | WebP 80% |
| Icon | 10 KB | SVG |

**Check actual sizes**:
```bash
# Images > 200 KB
find public -name "*.jpg" -o -name "*.png" | xargs du -k | awk '$1 > 200'
```

### 2.3 Next.js Image Config

**Check `next.config.js`**:
```javascript
images: {
  domains: [
    'your-project.supabase.co', // Supabase
    'lh3.googleusercontent.com', // Google OAuth
  ],
  formats: ['image/avif', 'image/webp'], // ✅
  deviceSizes: [640, 750, 828, 1080, 1200, 1920],
  imageSizes: [16, 32, 48, 64, 96, 128, 256],
  minimumCacheTTL: 31536000, // 1 year
}
```

---

## Phase 3: Query Optimization (10 min)

### 3.1 SELECT * Abuse

```bash
# Count queries using SELECT *
grep -r "select('\*')" app/ lib/ --include="*.ts" | wc -l
```

**✅ PASS**: 0 occurrences (except the legitimate `.from('table').select('*').single()`)
**🔴 FAIL**: > 5 occurrences

**Fix**:
```typescript
// ❌ SELECT * for count
.select('*', { count: 'exact', head: true })

// ✅ SELECT id only
.select('id', { count: 'exact', head: true })

// Gain: 30-50% faster
```

### 3.2 N+1 Queries

**Search**:
```bash
# Loops containing queries
grep -rA 10 "for.*of\|\.map(" lib/services/ | grep "await.*supabase"
```

**❌ Anti-pattern**:
```typescript
for (const conv of conversations) {
  const { data: participants } = await supabase
    .from('participants')
    .select('*')
    .eq('conversation_id', conv.id); // N+1 !
}
// 10 conversations = 11 queries (1 + 10)
```

**✅ Fix**:
```typescript
// 1 query for ALL conversations
const { data: allParticipants } = await supabase
  .from('participants')
  .select('*')
  .in('conversation_id', conversations.map(c => c.id));

// Then group by conversation_id
const byConv = groupBy(allParticipants, 'conversation_id');
// 10 conversations = 1 query
```

### 3.3 Missing LIMIT

```bash
# List queries without .limit()
grep -r "\.from.*\.select" lib/services/ app/api/ \
  | grep -v "\.limit(\|\.single()"
```

**Fix**: Add `.limit(100)` on all list queries.

---

## Phase 4: React Performance (10 min)

### 4.1 Unnecessary Re-renders

**Search**:
```bash
# Exported components without memo
grep -r "^export.*function.*Props" components/ | grep -v "memo("

# Inline callbacks in render
grep -r "onClick={() =>\|onChange={() =>" app/ components/
```

**❌ Anti-pattern**:
```tsx
<SwipeCard
  onSwipe={(dir) => { handleSwipe(dir); }} // Inline = new function on every render
/>
```

**✅ Fix**:
```tsx
const handleSwipeAction = useCallback((dir) => {
  handleSwipe(dir);
}, [handleSwipe]);

<SwipeCard onSwipe={handleSwipeAction} />
```

### 4.2 Expensive Calculations

**Search**:
```bash
# .filter/.map/.reduce without useMemo
grep -rB 5 "\.filter(\|\.map(\|\.reduce(" app/ \
  | grep -v "useMemo"
```

**Fix**:
```typescript
// ❌ Filters on every render
const filtered = properties.filter(p => p.city === filters.city);

// ✅ Memoized
const filtered = useMemo(
  () => properties.filter(p => p.city === filters.city),
  [properties, filters.city]
);
```

### 4.3 Context Overuse

**Search**:
```bash
# Contexts holding a lot of state
find contexts -name "*.tsx" -exec wc -l {} \; | awk '$1 > 200'
```

**Anti-pattern**: A context with 10+ states → every update re-renders ALL consumers.

**Fix**: Split contexts by domain (auth, theme, data, etc.).

---

## Phase 5: Network Optimization (5 min)

### 5.1 API Calls

**Waterfall analysis** (Chrome DevTools Network tab):
- Avoid cascades (fetch A → fetch B → fetch C)
- Parallelize with `Promise.all()`
- Prefetch data with Server Components

**Checklist**:
- [ ] Critical data fetched in Server Components
- [ ] React Query for caching (5 min staleTime)
- [ ] Prefetch on hover (next/link)

### 5.2 Third-Party Scripts

**Search**:
```bash
# Third-party scripts that block rendering
grep -r "<script" app/ | grep -v "async\|defer"
```

**Checklist**:
- [ ] Google Analytics: async script
- [ ] Stripe: defer script
- [ ] All non-critical scripts: defer OR async

---

## Phase 6: Database Performance (10 min)

### 6.1 Index Coverage

**SQL to run**:
```sql
-- Queries without an index (Seq Scan = bad)
SELECT
  schemaname,
  tablename,
  indexname,
  idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0
  AND indexrelname NOT LIKE '%pkey';

-- Slow queries
SELECT
  calls,
  mean_exec_time,
  query
FROM pg_stat_statements
WHERE mean_exec_time > 100 -- > 100ms
ORDER BY mean_exec_time DESC
LIMIT 20;
```

### 6.2 Query Plan Analysis

**For critical queries**:
```sql
EXPLAIN ANALYZE
SELECT p.*, u.full_name
FROM properties p
JOIN users u ON p.owner_id = u.id
WHERE p.city = 'Brussels'
  AND p.monthly_rent BETWEEN 800 AND 1200
ORDER BY p.created_at DESC
LIMIT 50;
```

**Look for**:
- Seq Scan → add an index
- Nested Loop → check the join
- Sort on disk → increase work_mem

---

## Phase 7: Caching Strategy (5 min)

### 7.1 Cache Headers

**Check**:
```typescript
// next.config.js
async headers() {
  return [
    {
      source: '/_next/static/:path*',
      headers: [
        { key: 'Cache-Control', value: 'public, max-age=31536000, immutable' }
      ]
    },
    {
      source: '/api/properties', // Public API
      headers: [
        { key: 'Cache-Control', value: 'public, s-maxage=3600, stale-while-revalidate=7200' }
      ]
    }
  ];
}
```

### 7.2 ISR (Incremental Static Regeneration)

**Candidate pages**:
- Landing page: `revalidate: 3600` (1h)
- Property listings: `revalidate: 1800` (30min)
- Blog posts: `revalidate: 86400` (24h)

**Checklist**:
- [ ] Public pages use ISR
- [ ] `revalidate` configured
- [ ] On-demand revalidation for urgent updates

---

## Phase 8: Monitoring Setup (5 min)

### 8.1 Vercel Analytics

**Enable**:
```typescript
// app/layout.tsx
import { Analytics } from '@vercel/analytics/react';

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <Analytics />
      </body>
    </html>
  );
}
```

**Metrics collected**:
- Real User Monitoring (RUM)
- Core Web Vitals
- Page views
- Unique visitors

### 8.2 Web Vitals Tracking

**Custom tracking**:
```typescript
// lib/monitoring/web-vitals.ts
import { onCLS, onINP, onLCP } from 'web-vitals';

function sendToAnalytics(metric) {
  // Send to your analytics endpoint
  fetch('/api/analytics/web-vitals', {
    method: 'POST',
    body: JSON.stringify(metric),
  });
}

onCLS(sendToAnalytics);
onINP(sendToAnalytics);
onLCP(sendToAnalytics);
```

### 8.3 Slow Query Detection

**Supabase**:
```sql
-- Enable pg_stat_statements
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Dashboard query for slow queries
SELECT
  substring(query, 1, 100) as query_preview,
  calls,
  mean_exec_time,
  max_exec_time
FROM pg_stat_statements
WHERE mean_exec_time > 50 -- > 50ms
ORDER BY mean_exec_time DESC;
```

---

## Phase 9: Latency Sources (10 min)

### 9.1 Network Latency

**Measure**:
```bash
# Ping Supabase
ping your-project.supabase.co

# Average network latency:
# - EU → EU Supabase: 10-30ms
# - US → EU Supabase: 80-150ms
```

**Optimizations**:
- [ ] Supabase region close to users (EU for European users)
- [ ] Vercel edge functions if ultra-low latency is required
- [ ] CDN for static assets

### 9.2 Database Latency

**Components**:
1. Network: 10-50ms
2. Query execution: 10-100ms
3. RLS overhead: 5-20ms
4. JSON serialization: 5-10ms

**Typical total**: 30-180ms

**Possible reductions**:
- Connection pooling (saves 20-50ms on cold start)
- Prepared statements (cache query plan)
- Indexes on filtered columns

### 9.3 API Route Latency

**Breakdown**:
```
Total p95: 450ms
├─ Cold start: 100ms (1st request after inactivity)
├─ Auth check: 50ms (Supabase getUser)
├─ Business logic: 50ms
├─ Database query: 150ms
└─ Response serialization: 100ms
```

**Optimizations**:
- Minimize cold starts (keep functions warm)
- Cache auth session (5 min)
- Optimize queries (index, LIMIT)
- Stream responses for large datasets

---

## Phase 10: React Profiling (15 min)

### 10.1 React DevTools Profiler

**Steps**:
1. Open Chrome DevTools
2. "Profiler" tab
3. Record an interaction (e.g. filter properties)
4. Analyze the flamegraph

**Look for**:
- Components rendered > 10× for 1 action
- Long render times (> 16ms = dropped frame)
- Unexpected renders

### 10.2 Why Did You Render (Dev Tool)

**Installation**:
```bash
npm install --save-dev @welldone-software/why-did-you-render
```

**Config**:
```typescript
// pages/_app.tsx (dev only)
if (process.env.NODE_ENV === 'development') {
  if (typeof window !== 'undefined') {
    const whyDidYouRender = require('@welldone-software/why-did-you-render');
    whyDidYouRender(React, {
      trackAllPureComponents: true,
    });
  }
}
```

**Output**: Console logs explaining WHY each component re-renders.

### 10.3 Common Re-render Causes

| Cause | Fix |
|-------|-----|
| Inline callbacks | `useCallback` |
| Inline objects | `useMemo` |
| Context updates | Split context |
| Props changing | `memo()` child |
| Parent re-render | `memo()` child |

---

## Phase 11: Server-Side Performance (10 min)

### 11.1 API Route Optimization

**Checklist**:
```typescript
// ✅ Stateless (scalable)
export async function GET(request: Request) {
  // No global state, no closure over external variables
}

// ✅ Timeout configured
export const maxDuration = 10; // 10s max

// ✅ Memory limit
export const config = {
  runtime: 'nodejs', // OR 'edge' for ultra-low latency
  regions: ['fra1'], // Region close to users
};

// ✅ Caching
export const revalidate = 3600; // ISR: 1h cache
```

### 11.2 Database Connection Pooling

**Supabase config**:
```typescript
// ❌ Each API route creates its own connection
const supabase = createClient(URL, KEY);

// ✅ Connection pooling (in the connection string)
const DATABASE_URL = "postgresql://...?pgbouncer=true&connection_limit=10";
```

**Monitoring**:
```sql
-- Active connections
SELECT count(*) FROM pg_stat_activity;

-- Idle connections
SELECT count(*) FROM pg_stat_activity WHERE state = 'idle';
```

**Target**: < 50 active connections

---

## Phase 12: Lighthouse Audit (5 min)

### 12.1 Running Lighthouse

```bash
# CLI
npm install -g lighthouse
lighthouse https://example.com --output=html --output-path=./lighthouse-report.html

# OR Chrome DevTools → Lighthouse tab
```

### 12.2 Score Targets

| Category | Target | Acceptable |
|----------|--------|------------|
| **Performance** | > 90 | > 80 |
| **Accessibility** | > 95 | > 90 |
| **Best Practices** | 100 | > 95 |
| **SEO** | 100 | > 90 |

### 12.3 Common Issues & Fixes

| Issue | Fix | Impact |
|-------|-----|--------|
| Render-blocking resources | Defer non-critical JS/CSS | +10-20 points |
| Unoptimized images | Next.js Image | +5-15 points |
| No lazy loading | Add `loading="lazy"` | +5-10 points |
| Large JS bundles | Code splitting | +10-20 points |
| Long server response | Optimize queries | +5-15 points |

---

## Performance Report: Template

```markdown
# PERFORMANCE AUDIT: [Project Name]

**Date**: [YYYY-MM-DD]
**Tool**: Lighthouse 11.x + Custom scripts
**Environment**: Production

---

## Core Web Vitals

| Metric | Result | Target | Status |
|--------|--------|--------|--------|
| LCP | 2.1s | < 2.5s | ✅ GOOD |
| INP | 150ms | < 200ms | ✅ GOOD |
| CLS | 0.05 | < 0.1 | ✅ GOOD |

**Overall**: ✅ PASS (all metrics in "Good")

---

## Lighthouse Scores

- Performance: **92**/100 ✅
- Accessibility: **98**/100 ✅
- Best Practices: **100**/100 ✅
- SEO: **100**/100 ✅

---

## Bundle Analysis

- First Load JS: **185 KB** (target < 200 KB) ✅
- Total Bundle: **420 KB** (target < 500 KB) ✅
- Largest chunk: **recharts** (120 KB)

**Recommendation**: Dynamic import recharts

---

## Query Performance

- SELECT * count: **0** ✅
- N+1 queries: **0** ✅
- Queries without LIMIT: **0** ✅
- Avg query time: **78ms** (p95: 145ms) ✅

---

## React Performance

- Unnecessary re-renders: **3 components** 🟡
  - SwipeCard (parent callbacks not memoized)
  - PropertyList (filter without useMemo)
  - SearchBar (onChange inline)

**Recommendation**: Add useCallback/useMemo (effort: 30 min)

---

## Recommendations

### P0 (Immediate)
1. Dynamic import recharts (-120 KB bundle)
2. Fix SwipeCard re-renders (-30% renders)

### P1 (This Sprint)
1. Add React Query caching
2. Optimize property images (compress to WebP 85%)

### P2 (Next Sprint)
1. Implement ISR on public pages
2. Setup CDN for images

---

## Performance Score: 92/100 ✅

**Status**: EXCELLENT
**Production Ready**: YES
**Estimated improvement with P0 fixes**: +5 points (→ 97/100)
```

---

## Automation Scripts

### Automated Performance Check

```bash
#!/bin/bash
# scripts/performance-check.sh

echo "🔍 Performance Quick Check"
echo ""

# 1. TypeScript
echo "TypeScript errors:"
npx tsc --noEmit 2>&1 | grep "error TS" | wc -l

# 2. Bundle size
echo "First Load JS:"
npm run build 2>&1 | grep "First Load JS" | awk '{print $NF}'

# 3. SELECT * count
echo "SELECT * queries:"
grep -r "select('\*')" app/ lib/ --include="*.ts" | wc -l

# 4. Images unoptimized
echo "Unoptimized <img> tags:"
grep -r "<img" app/ components/ --include="*.tsx" | grep -v "\.svg" | wc -l

# 5. Inline callbacks
echo "Inline callbacks:"
grep -r "onClick={() =>" app/ components/ | wc -l

echo ""
echo "✅ Check complete"
```

---

**Execution time**: 30-45 min (full audit)
**Tools required**: Lighthouse, Chrome DevTools, Supabase Dashboard
**Recommended frequency**: Monthly OR before every major release
