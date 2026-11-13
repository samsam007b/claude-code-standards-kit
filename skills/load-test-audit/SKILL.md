---
name: load-test-audit
description: "Audit de scalabilité : peut l'app gérer 100+ utilisateurs simultanés ? Analyse limits Supabase, Next.js, Vercel"
tags: [performance, scalability, load-testing, infrastructure]
version: 1.0.0
---

# ⚡ Load Test & Scalability Audit

Vérifier si l'application peut gérer une charge importante (100+ utilisateurs concurrents) sans crasher ni ralentir.

---

## 🎯 Objectifs de Performance

| Métrique | Target | Acceptable | Critique |
|----------|--------|------------|----------|
| **Concurrent users** | 100 | 50 | < 20 |
| **API response (p95)** | < 300ms | < 500ms | > 1s |
| **Database queries** | < 100ms | < 200ms | > 500ms |
| **Page load (LCP)** | < 2s | < 2.5s | > 4s |
| **Time to Interactive** | < 3s | < 5s | > 8s |
| **Error rate** | < 0.1% | < 1% | > 5% |

---

## Phase 1 : Supabase Limits Analysis

### 1.1 Connection Pooling

**Check configuration** :
```typescript
// Vérifier DATABASE_URL dans .env
// Doit contenir : ?pgbouncer=true&connection_limit=10
```

**Supabase Plans** :
| Plan | Max Connections | Simultaneous Requests | Storage |
|------|-----------------|----------------------|---------|
| Free | 60 | 500 req/sec | 500 MB |
| Pro | 200 | 2000 req/sec | 8 GB |
| Team | 400 | 5000 req/sec | 100 GB |

**Calcul pour 100 users** :
- Si chaque user fait 2 queries/sec → 200 queries/sec
- Free tier : OK (500 req/sec max)
- Mais connexions : 100 users × 1 connexion = 100 connections
- Free tier limite : 60 connections → **UPGRADE REQUIS** pour 100 users

**Action** :
- [ ] Vérifier plan Supabase actuel
- [ ] Si Free + > 60 users attendus → Upgrade Pro
- [ ] Connection pooling activé

### 1.2 Realtime Limits

**Supabase Realtime** :
| Plan | Concurrent Connections | Concurrent Channels |
|------|------------------------|---------------------|
| Free | 200 | 2 |
| Pro | 500 | 100 |

**Si utilisation realtime** (messages, notifications) :
- [ ] 100 users = 100 connections → OK sur Free
- [ ] Mais si > 2 channels différents → Pro requis

### 1.3 Storage & Bandwidth

**Free tier** :
- 1 GB storage
- 2 GB bandwidth/mois

**Calcul** :
- 100 users × 5 photos (2 MB) = 1 GB → **limite atteinte**
- 100 users × 10 MB download/mois = 1 GB/mois → OK

**Action** :
- [ ] Compression agressive (WebP, quality 85%)
- [ ] CDN cache (réduire bandwidth)
- [ ] Monitorer usage actuel

---

## Phase 2 : Next.js / Vercel Limits

### 2.1 Vercel Plan Limits

| Plan | Bandwidth | Executions | Execution Duration |
|------|-----------|------------|-------------------|
| Hobby | 100 GB/mois | 100k/mois | 10s |
| Pro | 1 TB/mois | 1M/mois | 300s |

**Pour 100 users** :
- 100 users × 100 pages/mois × 1 MB/page = 10 GB → OK Hobby
- 100 users × 100 API calls/mois = 10k calls → OK Hobby

**Mais** :
- Hobby = 1 concurrent build
- Hobby = pas de team collaboration
- **Si projet pro → Pro tier recommandé**

### 2.2 Edge Functions vs Serverless

**Next.js API Routes** (Serverless par défaut) :
- Cold start : 100-300ms
- Timeout : 10s (Hobby), 300s (Pro)
- Concurrent : Illimité (auto-scale)

**Edge Functions** (pour ultra-low latency) :
- Cold start : < 50ms
- Timeout : 30s max
- Mais limitations : pas de fs, crypto limité

**Recommandation** :
- API routes standards → Serverless (auto-scale)
- Auth, redirects → Edge si besoin

### 2.3 ISR & Caching

**Incremental Static Regeneration** :
```typescript
export const revalidate = 3600; // 1 hour

// OU
export async function generateStaticParams() {
  // Pre-render top 100 properties
}
```

**Checklist** :
- [ ] Pages publiques (landing, listings) en ISR
- [ ] `Cache-Control` headers corrects
- [ ] CDN activé sur Vercel

---

## Phase 3 : Database Query Performance

### 3.1 Index Analysis

**SQL à exécuter** :
```sql
-- Tables sans index
SELECT tablename, indexname
FROM pg_indexes
WHERE schemaname = 'public'
GROUP BY tablename
HAVING COUNT(*) <= 1; -- Seulement primary key

-- Queries lentes (activer log_min_duration_statement)
SELECT query, mean_exec_time
FROM pg_stat_statements
WHERE mean_exec_time > 100
ORDER BY mean_exec_time DESC
LIMIT 20;
```

**Colonnes devant avoir un index** :
- `user_id` (presque toutes tables)
- `property_id` (tables liées aux propriétés)
- `created_at` (pour ORDER BY)
- Foreign keys

### 3.2 Query Complexity

**Recherche** :
```bash
# Queries avec 3+ JOINs
grep -r "\.select(" lib/services/ | grep -o "," | wc -l

# Queries sans .limit()
grep -r "\.order(" lib/services/ | grep -v "\.limit("
```

**Limits recommandées** :
- List queries : `.limit(100)` max
- Search results : `.limit(50)`
- Autocomplete : `.limit(10)`

---

## Phase 4 : Frontend Performance

### 4.1 Bundle Size Analysis

```bash
# Analyser bundle
ANALYZE=true npm run build

# Vérifier First Load JS
# Target : < 200 KB
```

**Checklist** :
- [ ] Dynamic imports pour composants lourds
- [ ] Tree-shaking activé
- [ ] Pas de barrel exports (index.ts qui re-exportent tout)

### 4.2 Image Optimization

**Targets** :
- Total image weight par page : < 1 MB
- LCP image : < 500 KB
- Lazy loading sur images below-the-fold

**Check** :
```bash
# Images > 500 KB
find public -name "*.jpg" -o -name "*.png" | xargs du -h | grep "M$"
```

### 4.3 React Re-renders

**Tools** :
- React DevTools Profiler
- Why Did You Render (dev dependency)

**Targets** :
- < 10 re-renders par interaction utilisateur
- Composants `memo()` pour listes > 20 items

---

## Phase 5 : Stress Test Simulation

### 5.1 Tools Recommandés

| Tool | Usage | Prix |
|------|-------|------|
| **k6** | Open-source, script JS | Free |
| **Artillery** | YAML config, facile | Free |
| **Loader.io** | Cloud-based, rapide | $99/mois |
| **BlazeMeter** | Enterprise, détaillé | $199/mois |

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

### 5.3 Résultats à Analyser

**k6 Output** :
```
http_req_duration..............: avg=250ms p(95)=450ms
http_req_failed................: 0.5%
http_reqs......................: 15000 (50/s)
vus............................: 100 (peak)
```

**Interprétation** :
- ✅ p95 < 500ms → PASS
- ✅ error rate < 1% → PASS
- ✅ 50 req/sec soutenu → PASS

---

## Phase 6 : Infrastructure Readiness

### 6.1 Disaster Recovery

**Checklist** :
- [ ] Backups Supabase activés (daily)
- [ ] Point-in-time recovery configuré (Pro tier)
- [ ] Backup restoration testée
- [ ] RTO (Recovery Time Objective) < 4h
- [ ] RPO (Recovery Point Objective) < 1h

### 6.2 Monitoring & Alerting

**Métriques à surveiller** :
- CPU usage (Vercel functions)
- Memory usage
- Database connections actives
- Error rate (Sentry)
- Response time p95

**Alertes à configurer** :
- Error rate > 5% → Slack immédiat
- Database connections > 80% → Email
- Response time p95 > 1s → Slack

### 6.3 Scaling Strategy

**Vertical Scaling** :
- Supabase Pro (200 connections)
- Vercel Pro (300s timeout)

**Horizontal Scaling** :
- Next.js API routes = auto-scale
- Supabase Read Replicas (Enterprise)
- CDN pour assets statiques

**Pour 1000+ users** :
- Supabase Team plan ($599/mois)
- Vercel Enterprise
- Dedicated database instance

---

## Rapport Final - Template

```markdown
# LOAD TEST RESULTS - [Date]

## Test Configuration
- **Users** : 100 concurrent
- **Duration** : 15 minutes
- **Scenario** : [Login → Browse → Search → View property]

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

- Supabase : $XX/mois (Pro tier recommended)
- Vercel : $XX/mois (Pro tier)
- Total : $XX/mois

## Scaling Roadmap

- 0-50 users : Free tiers OK
- 50-100 users : Pro tiers
- 100-500 users : Pro + optimizations
- 500-1000 users : Team/Enterprise tiers
- 1000+ users : Dedicated infrastructure
```

---

## Checklists par Tier

### Free Tier (0-50 users)
- [ ] Connection pooling activé
- [ ] Rate limiting strict
- [ ] Image compression agressive
- [ ] ISR sur pages publiques
- [ ] Monitoring basique (Sentry free)

### Pro Tier (50-200 users)
- [ ] Supabase Pro ($25/mois)
- [ ] Vercel Pro ($20/mois)
- [ ] Read replicas si besoin
- [ ] APM monitoring (Sentry Pro)
- [ ] Daily backups

### Enterprise (200+ users)
- [ ] Dedicated Supabase instance
- [ ] Vercel Enterprise
- [ ] CDN premium (Cloudflare)
- [ ] 24/7 monitoring
- [ ] SLA guarantees

---

**Execution time** : 30 min (setup) + 15 min (test run) + 15 min (analysis)
**Tools required** : k6 OU Artillery
**Cost** : Free (k6/Artillery) OU $99-199/mois (Loader.io, BlazeMeter)
