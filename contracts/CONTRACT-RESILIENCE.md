# Contrat — Résilience & Patterns de Récupération

> Module de contrat SQWR Project Kit.
> Sources : AWS Well-Architected Framework, Microsoft Resilience Patterns, Release It! (Nygard 2018).
> Principe : les systèmes distribués échouent toujours — la question est comment ils échouent.

---

## Fondements

**"Design for failure"** — principe fondateur de l'AWS Well-Architected Framework. Un service qui suppose que ses dépendances (Supabase, APIs externes, LLMs) sont toujours disponibles est fragile par construction. Un service résilient assume l'échec et s'en remet gracieusement.

> Source : *AWS Well-Architected Framework — Reliability Pillar*
> Source : *Release It! — Michael Nygard (2018)*

---

## 1. Retry avec Exponential Backoff

**Problème :** Une requête qui échoue est souvent due à une condition transitoire (surcharge temporaire, réseau instable). Réessayer immédiatement empire le problème.

**Solution :** Attendre de plus en plus longtemps entre les tentatives, avec un jitter (aléatoire) pour éviter les "thundering herds" (tous les clients qui réessayent en même temps).

```typescript
// lib/retry.ts
interface RetryOptions {
  maxAttempts?: number   // défaut : 3
  baseDelay?: number     // défaut : 1000ms
  maxDelay?: number      // défaut : 10000ms
  jitter?: boolean       // défaut : true
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

      // Erreurs non-retriables (4xx = erreur client, pas transitoire)
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

**Problème :** Si une dépendance est en panne, continuer à l'appeler consomme des ressources inutilement et ralentit les réponses pour tous les utilisateurs.

**Solution :** Après N échecs consécutifs, "ouvrir le circuit" (ne plus appeler la dépendance) pendant une période. Après le délai, tester avec une seule requête ("half-open"). Si ça marche, fermer le circuit.

```typescript
// lib/circuit-breaker.ts
type CircuitState = 'closed' | 'open' | 'half-open'

class CircuitBreaker {
  private state: CircuitState = 'closed'
  private failureCount = 0
  private lastFailureTime?: number

  constructor(
    private threshold = 5,      // nombre d'échecs avant ouverture
    private timeout = 30000,    // ms avant de tester en half-open
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

// Instances par service externe
export const supabaseBreaker = new CircuitBreaker(5, 30000)
export const llmBreaker = new CircuitBreaker(3, 60000)  // LLM = plus strict
```

---

## 3. Graceful Degradation

**Principe :** Quand une partie du système échoue, le reste doit continuer à fonctionner — en mode dégradé si nécessaire, mais pas en crash total.

```typescript
// ✅ Feature non-critique qui dégrade gracieusement
async function getPersonalizedRecommendations(userId: string) {
  try {
    return await llmBreaker.execute(() => fetchAIRecommendations(userId))
  } catch {
    // Fallback : recommandations statiques si le LLM est indisponible
    return getStaticRecommendations()
  }
}

// ✅ Composant React avec fallback UI
function RecommendationsSection({ userId }: { userId: string }) {
  return (
    <Suspense fallback={<RecommendationsSkeleton />}>
      <ErrorBoundary
        fallback={<StaticRecommendations />}  // ← UI de remplacement
      >
        <DynamicRecommendations userId={userId} />
      </ErrorBoundary>
    </Suspense>
  )
}
```

**Niveaux de dégradation :**

| Service en panne | Comportement dégradé |
|-----------------|---------------------|
| LLM (OpenRouter/Claude) | Contenus statiques ou template |
| Supabase (lecture) | Cache local ou erreur gracieuse |
| Supabase (écriture) | Queue locale + retry asynchrone |
| Service email (Resend) | Log interne + retry planifié |
| Analytics (Plausible) | Silence — non-bloquant par nature |

---

## 4. Timeouts

**Règle :** Toute I/O (réseau, DB, LLM) doit avoir un timeout explicite. Sans timeout, une requête bloquée peut bloquer un thread/worker indéfiniment.

```typescript
// Timeouts recommandés par type d'opération
const TIMEOUTS = {
  supabase_read: 5_000,     // 5s — lecture DB
  supabase_write: 10_000,   // 10s — écriture DB + triggers
  llm_api: 30_000,          // 30s — LLM peut être lent
  external_api: 10_000,     // 10s — APIs tierces
  email_send: 5_000,        // 5s — service email
} as const

// fetch avec timeout
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

// Supabase avec timeout
const { data, error } = await Promise.race([
  supabase.from('spaces').select('*').eq('id', spaceId),
  new Promise((_, reject) =>
    setTimeout(() => reject(new Error('Supabase timeout')), TIMEOUTS.supabase_read)
  )
])
```

---

## 5. Cascading Failures — Serverless + Supabase

**Problème spécifique Next.js / Vercel + Supabase :**

Les fonctions serverless Vercel ont des **cold starts** (démarrage à froid). Sous un pic de trafic, des dizaines de fonctions démarrent simultanément → chacune ouvre une connexion Supabase → le **connection pool est épuisé** → toutes les requêtes échouent.

**Mitigation :**

```typescript
// Utiliser Supabase Transaction Pooler (port 6543) plutôt que Direct Connection
// Dans .env.local :
# ✅ Transaction Pooler — supporte beaucoup plus de connexions simultanées
DATABASE_URL="postgresql://postgres.[ref]:[password]@aws-0-eu-central-1.pooler.supabase.com:6543/postgres?pgbouncer=true"

# ❌ Direct connection — limite à ~100 connexions simultanées
DATABASE_URL="postgresql://postgres:[password]@db.[ref].supabase.co:5432/postgres"
```

```typescript
// Singleton client Supabase pour réutiliser les connexions
// lib/supabase/server.ts
import { createServerClient } from '@supabase/ssr'

// ✅ Un seul client par request (Next.js cache le module)
export function createClient() {
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { cookies }
  )
}
```

---

## 6. Feature Flags — Dégradation contrôlée

Les feature flags permettent de désactiver une feature défectueuse en production **sans redéploiement**.

```typescript
// lib/feature-flags.ts — implémentation simple sans dépendance externe
const flags: Record<string, boolean> = {
  'ai-recommendations': true,
  'advanced-analytics': true,
  'experimental-search': false,
}

export function isEnabled(flag: string): boolean {
  // En production, lire depuis env var ou Supabase config table
  const envFlag = process.env[`FEATURE_${flag.toUpperCase().replace(/-/g, '_')}`]
  if (envFlag !== undefined) return envFlag === 'true'
  return flags[flag] ?? false
}

// Usage dans les composants
if (isEnabled('ai-recommendations')) {
  return <AIRecommendations />
}
return <StaticRecommendations />  // fallback
```

---

## 7. Règles absolues

### Ne jamais faire
- Faire un I/O (réseau, DB, LLM) sans timeout explicite
- Propager une erreur d'une feature non-critique vers un crash de page entière
- Retenter immédiatement sans backoff (aggrave les pannes)
- Utiliser la connexion directe Supabase (port 5432) en production serverless

### Toujours faire
- Définir un fallback pour chaque feature utilisant un service externe
- Logger les circuit breaker events (état open/closed/half-open)
- Utiliser le Transaction Pooler Supabase (port 6543) en production
- Tester le comportement de dégradation en staging avant prod

---

## 8. Sources

| Référence | Source |
|-----------|--------|
| AWS Well-Architected — Reliability | docs.aws.amazon.com/wellarchitected/reliability |
| Microsoft Resilience Patterns | learn.microsoft.com/en-us/azure/architecture/patterns/category/resiliency |
| Release It! — Michael Nygard | pragprog.com/titles/mnee2 |
| Supabase Connection Pooling | supabase.com/docs/guides/database/connecting-to-postgres |
| Vercel Serverless Cold Starts | vercel.com/docs/functions/runtimes |
