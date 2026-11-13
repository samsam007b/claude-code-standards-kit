---
name: performance-deep-audit
description: "Audit performance approfondi : Core Web Vitals, bundle size, query optimization, React re-renders. Standards Google/Vercel."
tags: [performance, optimization, web-vitals, latency]
version: 1.0.0
---

# ⚡ Performance Deep Audit

Audit exhaustif des performances basé sur les standards Google (Core Web Vitals), Vercel, et les meilleures pratiques Next.js 14/15.

---

## Objectifs Mesurables

### Core Web Vitals (Google Standard)

| Metric | Target (Good) | Threshold | Current |
|--------|---------------|-----------|---------|
| **LCP** (Largest Contentful Paint) | < 2.5s | < 4s | [__s] |
| **INP** (Interaction to Next Paint) | < 200ms | < 500ms | [__ms] |
| **CLS** (Cumulative Layout Shift) | < 0.1 | < 0.25 | [__] |

**75th percentile** de TOUS les users doit être dans "Good".

### Application Metrics

| Metric | Target | Current |
|--------|--------|---------|
| **First Load JS** | < 200 KB | [__ KB] |
| **Total Bundle** | < 500 KB | [__ KB] |
| **API p95** | < 300ms | [__ ms] |
| **Database p95** | < 100ms | [__ ms] |
| **Images/page** | < 1 MB | [__ MB] |

---

## Phase 1 : Bundle Analysis (10 min)

### 1.1 Build Analysis

```bash
# Activer analyzer
ANALYZE=true npm run build

# Output : bundle-analyzer.html
# Ouvrir dans browser pour visualiser
```

**Check** :
- [ ] First Load JS < 200 KB
- [ ] Shared chunks < 150 KB
- [ ] Page-specific chunks < 50 KB
- [ ] Zéro duplication de code entre chunks

### 1.2 Heavy Imports

**Recherche** :
```bash
# framer-motion usage
grep -r "from 'framer-motion'" app/ components/ | wc -l

# recharts usage
grep -r "from 'recharts'" app/ components/ | wc -l

# lucide-react (combien d'icônes ?)
grep -r "from 'lucide-react'" app/ components/ | grep -o "{\s*[^}]*}" | tr ',' '\n' | wc -l
```

**Problèmes fréquents** :
- framer-motion (~60 KB) importé sur toutes pages
- recharts (~120 KB) chargé même si pas utilisé
- 30+ icônes lucide importées individuellement

**Fixes** :
```typescript
// ❌ Import lourd
import { motion, AnimatePresence, useAnimation } from 'framer-motion';

// ✅ Dynamic import
const motion = dynamic(() => import('framer-motion').then(mod => mod.motion), { ssr: false });

// ❌ 30 icônes
import { Home, User, Settings, ... } from 'lucide-react';

// ✅ Icon component wrapper
import Icon from '@/components/ui/Icon';
<Icon name="home" />
```

### 1.3 Tree-Shaking Verification

**Recherche barrel exports** :
```bash
# index.ts qui re-exportent tout
find components -name "index.ts" -exec grep -l "export.*from" {} \;
```

**❌ Anti-pattern** :
```typescript
// components/ui/index.ts
export { Button } from './button';
export { Input } from './input';
export { Select } from './select';
// ... 20 exports

// Usage
import { Button } from '@/components/ui'; // Importe TOUT le barrel
```

**✅ Fix** :
```typescript
// Import direct
import { Button } from '@/components/ui/button';
```

---

## Phase 2 : Image Optimization (5 min)

### 2.1 Image Audit

```bash
# <img> au lieu de <Image>
grep -r "<img" app/ components/ --include="*.tsx" | grep -v "\.svg"

# Images sans width/height
grep -r "<Image" app/ components/ | grep -v "width=\|fill"

# Images non lazy-loaded
grep -r "<Image" app/ components/ | grep -v "loading="
```

**Checklist** :
- [ ] Toutes images en `<Image>` (sauf SVG)
- [ ] `width` et `height` définis (évite CLS)
- [ ] `loading="lazy"` sur images below-the-fold
- [ ] Formats modernes (WebP, AVIF) configurés

### 2.2 Image Compression

**Target sizes** :
| Type | Max Size | Format |
|------|----------|--------|
| Hero image | 200 KB | WebP 85% |
| Property photo | 150 KB | WebP 85% |
| Avatar | 30 KB | WebP 80% |
| Icon | 10 KB | SVG |

**Check actual sizes** :
```bash
# Images > 200 KB
find public -name "*.jpg" -o -name "*.png" | xargs du -k | awk '$1 > 200'
```

### 2.3 Next.js Image Config

**Vérifier `next.config.js`** :
```javascript
images: {
  domains: [
    'your-project.supabase.co', // Supabase
    'lh3.googleusercontent.com', // Google OAuth
  ],
  formats: ['image/avif', 'image/webp'], // ✅
  deviceSizes: [640, 750, 828, 1080, 1200, 1920],
  imageSizes: [16, 32, 48, 64, 96, 128, 256],
  minimumCacheTTL: 31536000, // 1 an
}
```

---

## Phase 3 : Query Optimization (10 min)

### 3.1 SELECT * Abuse

```bash
# Count queries avec SELECT *
grep -r "select('\*')" app/ lib/ --include="*.ts" | wc -l
```

**✅ PASS** : 0 occurrences (sauf `.from('table').select('*').single()` légitime)
**🔴 FAIL** : > 5 occurrences

**Fix** :
```typescript
// ❌ SELECT * pour count
.select('*', { count: 'exact', head: true })

// ✅ SELECT id uniquement
.select('id', { count: 'exact', head: true })

// Gain : 30-50% plus rapide
```

### 3.2 N+1 Queries

**Recherche** :
```bash
# Loops avec queries
grep -rA 10 "for.*of\|\.map(" lib/services/ | grep "await.*supabase"
```

**❌ Anti-pattern** :
```typescript
for (const conv of conversations) {
  const { data: participants } = await supabase
    .from('participants')
    .select('*')
    .eq('conversation_id', conv.id); // N+1 !
}
// 10 conversations = 11 queries (1 + 10)
```

**✅ Fix** :
```typescript
// 1 query pour TOUTES conversations
const { data: allParticipants } = await supabase
  .from('participants')
  .select('*')
  .in('conversation_id', conversations.map(c => c.id));

// Puis group by conversation_id
const byConv = groupBy(allParticipants, 'conversation_id');
// 10 conversations = 1 query
```

### 3.3 Missing LIMIT

```bash
# List queries sans .limit()
grep -r "\.from.*\.select" lib/services/ app/api/ \
  | grep -v "\.limit(\|\.single()"
```

**Fix** : Ajouter `.limit(100)` sur toutes list queries.

---

## Phase 4 : React Performance (10 min)

### 4.1 Unnecessary Re-renders

**Recherche** :
```bash
# Components exportés sans memo
grep -r "^export.*function.*Props" components/ | grep -v "memo("

# Inline callbacks dans render
grep -r "onClick={() =>\|onChange={() =>" app/ components/
```

**❌ Anti-pattern** :
```tsx
<SwipeCard
  onSwipe={(dir) => { handleSwipe(dir); }} // Inline = new function chaque render
/>
```

**✅ Fix** :
```tsx
const handleSwipeAction = useCallback((dir) => {
  handleSwipe(dir);
}, [handleSwipe]);

<SwipeCard onSwipe={handleSwipeAction} />
```

### 4.2 Expensive Calculations

**Recherche** :
```bash
# .filter/.map/.reduce sans useMemo
grep -rB 5 "\.filter(\|\.map(\|\.reduce(" app/ \
  | grep -v "useMemo"
```

**Fix** :
```typescript
// ❌ Filtre à chaque render
const filtered = properties.filter(p => p.city === filters.city);

// ✅ Memoized
const filtered = useMemo(
  () => properties.filter(p => p.city === filters.city),
  [properties, filters.city]
);
```

### 4.3 Context Overuse

**Recherche** :
```bash
# Contexts avec beaucoup de state
find contexts -name "*.tsx" -exec wc -l {} \; | awk '$1 > 200'
```

**Anti-pattern** : Context avec 10+ states → chaque update re-render TOUS consommateurs.

**Fix** : Split contexts par domaine (auth, theme, data, etc.).

---

## Phase 5 : Network Optimization (5 min)

### 5.1 API Calls

**Waterfall analysis** (Chrome DevTools Network tab) :
- Éviter cascades (fetch A → fetch B → fetch C)
- Paralléliser avec `Promise.all()`
- Prefetch data avec Server Components

**Checklist** :
- [ ] Données critiques fetched en Server Components
- [ ] React Query pour caching (5 min staleTime)
- [ ] Prefetch sur hover (next/link)

### 5.2 Third-Party Scripts

**Recherche** :
```bash
# Scripts tiers qui bloquent rendering
grep -r "<script" app/ | grep -v "async\|defer"
```

**Checklist** :
- [ ] Google Analytics : script async
- [ ] Stripe : script defer
- [ ] Tous scripts non-critiques : defer OU async

---

## Phase 6 : Database Performance (10 min)

### 6.1 Index Coverage

**SQL à exécuter** :
```sql
-- Queries sans index (Seq Scan = mauvais)
SELECT
  schemaname,
  tablename,
  indexname,
  idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0
  AND indexrelname NOT LIKE '%pkey';

-- Queries lentes
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

**Pour queries critiques** :
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

**Chercher** :
- Seq Scan → ajouter index
- Nested Loop → vérifier jointure
- Sort sur disk → augmenter work_mem

---

## Phase 7 : Caching Strategy (5 min)

### 7.1 Cache Headers

**Vérifier** :
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
      source: '/api/properties', // API publique
      headers: [
        { key: 'Cache-Control', value: 'public, s-maxage=3600, stale-while-revalidate=7200' }
      ]
    }
  ];
}
```

### 7.2 ISR (Incremental Static Regeneration)

**Pages candidates** :
- Landing page : `revalidate: 3600` (1h)
- Property listings : `revalidate: 1800` (30min)
- Blog posts : `revalidate: 86400` (24h)

**Checklist** :
- [ ] Pages publiques en ISR
- [ ] `revalidate` configuré
- [ ] On-demand revalidation pour updates urgentes

---

## Phase 8 : Monitoring Setup (5 min)

### 8.1 Vercel Analytics

**Activer** :
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

**Métriques collectées** :
- Real User Monitoring (RUM)
- Core Web Vitals
- Page views
- Unique visitors

### 8.2 Web Vitals Tracking

**Custom tracking** :
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

**Supabase** :
```sql
-- Activer pg_stat_statements
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Dashboard query pour queries lentes
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

## Phase 9 : Latency Sources (10 min)

### 9.1 Network Latency

**Mesurer** :
```bash
# Ping Supabase
ping your-project.supabase.co

# Latence réseau moyenne :
# - EU → EU Supabase : 10-30ms
# - US → EU Supabase : 80-150ms
```

**Optimisations** :
- [ ] Supabase region proche des users (EU pour des users européens)
- [ ] Vercel edge functions si ultra-low latency requis
- [ ] CDN pour assets statiques

### 9.2 Database Latency

**Composants** :
1. Network : 10-50ms
2. Query execution : 10-100ms
3. RLS overhead : 5-20ms
4. JSON serialization : 5-10ms

**Total typique** : 30-180ms

**Réductions possibles** :
- Connection pooling (économise 20-50ms cold start)
- Prepared statements (cache query plan)
- Index sur colonnes filtrées

### 9.3 API Route Latency

**Breakdown** :
```
Total p95 : 450ms
├─ Cold start : 100ms (1ère req après inactivité)
├─ Auth check : 50ms (Supabase getUser)
├─ Business logic : 50ms
├─ Database query : 150ms
└─ Response serialization : 100ms
```

**Optimisations** :
- Minimize cold starts (keep functions warm)
- Cache auth session (5 min)
- Optimize queries (index, LIMIT)
- Stream responses pour gros datasets

---

## Phase 10 : React Profiling (15 min)

### 10.1 React DevTools Profiler

**Steps** :
1. Ouvrir Chrome DevTools
2. Onglet "Profiler"
3. Record interaction (ex: filter properties)
4. Analyser flamegraph

**Chercher** :
- Components rendus > 10× pour 1 action
- Long render times (> 16ms = dropped frame)
- Unexpected renders

### 10.2 Why Did You Render (Dev Tool)

**Installation** :
```bash
npm install --save-dev @welldone-software/why-did-you-render
```

**Config** :
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

**Output** : Console logs expliquant POURQUOI chaque component re-render.

### 10.3 Common Re-render Causes

| Cause | Fix |
|-------|-----|
| Inline callbacks | `useCallback` |
| Inline objects | `useMemo` |
| Context updates | Split context |
| Props changing | `memo()` child |
| Parent re-render | `memo()` child |

---

## Phase 11 : Server-Side Performance (10 min)

### 11.1 API Route Optimization

**Checklist** :
```typescript
// ✅ Stateless (scalable)
export async function GET(request: Request) {
  // Pas de state global, pas de closure sur variables externes
}

// ✅ Timeout configuré
export const maxDuration = 10; // 10s max

// ✅ Memory limit
export const config = {
  runtime: 'nodejs', // OU 'edge' pour ultra-low latency
  regions: ['fra1'], // Region proche users
};

// ✅ Caching
export const revalidate = 3600; // ISR : 1h cache
```

### 11.2 Database Connection Pooling

**Supabase config** :
```typescript
// ❌ Chaque API route crée sa connection
const supabase = createClient(URL, KEY);

// ✅ Connection pooling (dans connection string)
const DATABASE_URL = "postgresql://...?pgbouncer=true&connection_limit=10";
```

**Monitoring** :
```sql
-- Connections actives
SELECT count(*) FROM pg_stat_activity;

-- Connections idle
SELECT count(*) FROM pg_stat_activity WHERE state = 'idle';
```

**Target** : < 50 connections actives

---

## Phase 12 : Lighthouse Audit (5 min)

### 12.1 Running Lighthouse

```bash
# CLI
npm install -g lighthouse
lighthouse https://example.com --output=html --output-path=./lighthouse-report.html

# OU Chrome DevTools → Lighthouse tab
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

## Rapport de Performance - Template

```markdown
# PERFORMANCE AUDIT - [Project Name]

**Date** : [YYYY-MM-DD]
**Tool** : Lighthouse 11.x + Custom scripts
**Environment** : Production

---

## Core Web Vitals

| Metric | Result | Target | Status |
|--------|--------|--------|--------|
| LCP | 2.1s | < 2.5s | ✅ GOOD |
| INP | 150ms | < 200ms | ✅ GOOD |
| CLS | 0.05 | < 0.1 | ✅ GOOD |

**Overall** : ✅ PASS (all metrics in "Good")

---

## Lighthouse Scores

- Performance : **92**/100 ✅
- Accessibility : **98**/100 ✅
- Best Practices : **100**/100 ✅
- SEO : **100**/100 ✅

---

## Bundle Analysis

- First Load JS : **185 KB** (target < 200 KB) ✅
- Total Bundle : **420 KB** (target < 500 KB) ✅
- Largest chunk : **recharts** (120 KB)

**Recommendation** : Dynamic import recharts

---

## Query Performance

- SELECT * count : **0** ✅
- N+1 queries : **0** ✅
- Queries sans LIMIT : **0** ✅
- Avg query time : **78ms** (p95: 145ms) ✅

---

## React Performance

- Unnecessary re-renders : **3 components** 🟡
  - SwipeCard (parent callbacks not memoized)
  - PropertyList (filter without useMemo)
  - SearchBar (onChange inline)

**Recommendation** : Add useCallback/useMemo (effort: 30 min)

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

**Status** : EXCELLENT
**Production Ready** : YES
**Estimated improvement with P0 fixes** : +5 points (→ 97/100)
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

**Execution time** : 30-45 min (full audit)
**Tools required** : Lighthouse, Chrome DevTools, Supabase Dashboard
**Recommended frequency** : Mensuel OU avant chaque release majeure
