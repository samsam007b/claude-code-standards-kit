# Contrat — Vercel & Déploiement

> Module de contrat SQWR Project Kit.
> Couvre : déploiement Vercel, variables d'environnement, CI/CD, Edge.

---

## Règles fondamentales

### Ne jamais faire

- **Merger sur `main` sans vérifier que le build passe** — Vercel déploie automatiquement depuis main
- **Ajouter des variables d'environnement en dur dans le code** — toujours via `.env.local` (local) ou le dashboard Vercel (prod)
- **Exposer `SUPABASE_SERVICE_ROLE_KEY` ou toute clé secrète** dans une variable préfixée `NEXT_PUBLIC_`
- **Ignorer les warnings de build** — traiter comme des erreurs

### Toujours faire

- Tester le build local avec `npm run build` avant tout PR/merge important
- Documenter les variables d'environnement dans `.env.example`
- Vérifier les logs Vercel après chaque déploiement en production

---

## Convention des variables d'environnement

| Préfixe | Accessible | Usage |
|---------|-----------|-------|
| `NEXT_PUBLIC_` | Client + Serveur | URLs publiques, clés anon |
| *(sans préfixe)* | Serveur uniquement | Clés secrètes, service roles, webhooks |

```bash
# ✅ OK côté client
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...

# ✅ Serveur uniquement
SUPABASE_SERVICE_ROLE_KEY=eyJ...  # JAMAIS NEXT_PUBLIC_
RESEND_API_KEY=re_...
```

---

## Branches & déploiement

```
main        → Production (sqwr.be, cozygrowth.vercel.app, etc.)
develop     → Preview Vercel automatique
feature/*   → Preview Vercel automatique
```

- Ne jamais force-push sur `main`
- Les PRs vers main = vérification de build obligatoire (GitHub Actions ou Vercel check)

---

## Optimisations Vercel recommandées

### Edge Functions vs Serverless
- **Edge** : middleware, redirections, auth checks rapides (pas d'accès DB direct)
- **Serverless** : routes API avec accès Supabase, logique métier

### Headers de sécurité (next.config.js)
```javascript
const securityHeaders = [
  { key: 'X-Content-Type-Options', value: 'nosniff' },
  { key: 'X-Frame-Options', value: 'DENY' },
  { key: 'X-XSS-Protection', value: '1; mode=block' },
  { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
]
```

### Caching
- `revalidate` sur les Server Components pour les données semi-statiques
- `cache: 'no-store'` uniquement pour les données utilisateur (jamais en default)

---

## Analytics — Stratégie recommandée

### Plausible vs Vercel Analytics

| Critère | Plausible | Vercel Analytics |
|---------|-----------|-----------------|
| **RGPD / Cookies** | Sans cookie, RGPD-native | Tracking léger mais dépend Vercel |
| **Prix** | $9/mois (forfait) | Inclus Vercel Pro ou pay-per-event |
| **Données** | Agrégées uniquement (privacy by design) | Inclut Web Vitals temps réel |
| **Recommandation SQWR** | sqwr-site → Plausible (no-cookie, SEO safe) | Optionnel pour CWV monitoring |

**Règle SQWR** : Sur les sites public-facing, **Plausible est préféré** (no-cookie = pas de bandeau consentement, RGPD compliant par design).

```javascript
// next.config.js — bloquer le double tracking
// Si Plausible actif, désactiver Vercel Analytics pour éviter doublons
module.exports = {
  // Vercel Analytics désactivé si Plausible déployé
}
```

---

## Validation des variables d'environnement

**Problème** : un déploiement silencieux peut réussir même si des variables critiques sont manquantes — l'erreur n'apparaît qu'à runtime.

**Solution** : valider les variables requises au démarrage du serveur.

```typescript
// lib/env.ts — validation au boot (server-side only)
const REQUIRED_ENV_VARS = [
  'NEXT_PUBLIC_SUPABASE_URL',
  'NEXT_PUBLIC_SUPABASE_ANON_KEY',
  'SUPABASE_SERVICE_ROLE_KEY',
  // Ajouter selon le projet...
] as const

export function validateEnv() {
  const missing = REQUIRED_ENV_VARS.filter(
    (key) => !process.env[key]
  )
  if (missing.length > 0) {
    throw new Error(
      `Variables d'environnement manquantes :\n${missing.map((k) => `  - ${k}`).join('\n')}\n` +
      `Vérifier Vercel Dashboard → Settings → Environment Variables`
    )
  }
}
```

```typescript
// app/layout.tsx — appeler au root layout (server component)
import { validateEnv } from '@/lib/env'
validateEnv() // Crash rapide si config incomplète — mieux qu'une erreur runtime opaque
```

**Règle** : `validateEnv()` doit être appelé dans le root layout ou le point d'entrée serveur. Un crash immédiat au boot est préférable à un crash silencieux en production.

---

## Procédure de rollback Vercel

**Quand rollback** : bug critique en prod (erreur 500, page blanche, auth cassée) non résolvable en <30 min.

### Rollback via Dashboard (méthode rapide — <2 min)

1. Aller sur **Vercel Dashboard** → projet → **Deployments**
2. Trouver le dernier déploiement stable (badge "Ready")
3. Cliquer sur `⋯` → **Promote to Production**
4. Confirmer — le domaine pointe immédiatement vers l'ancien build

### Rollback via CLI

```bash
# Lister les déploiements récents
vercel ls --prod

# Promouvoir un déploiement spécifique
vercel promote <deployment-url>

# Exemple
vercel promote https://sqwr-site-abc123.vercel.app
```

### Après le rollback

```bash
# 1. Créer une branche hotfix
git checkout -b hotfix/prod-crash-$(date +%Y%m%d)

# 2. Reproduire en local, corriger, tester
npm run build && npm run test

# 3. PR → merge → re-déployer
```

**Documenter l'incident** dans `AUDIT-DEPLOYMENT.md` (section "Bloquant levé") avec date, cause, plan de correction.

---

## Progressive Rollout — Canary Pattern

> Sources : Martin Fowler — Feature Toggles (martinfowler.com, 2016),
> Vercel Rolling Releases Docs, Vercel Skew Protection Docs.

### Pourquoi un rollout progressif

**Déployer 100% du trafic d'un coup est le pattern le plus risqué.** Un bug critique
touche tous les utilisateurs simultanément, et le rollback prend 2-5 min pendant
lesquels la prod est dégradée. Le canary pattern valide en conditions réelles sur
un sous-ensemble avant l'exposition totale.

### Outils Vercel natifs (zéro configuration requise)

| Feature | Rôle | Où activer |
|---------|------|-----------|
| **Rolling Releases** | Blue-green deployment — zéro downtime, transition progressive | Natif sur tous les plans |
| **Skew Protection** | Synchronisation client/serveur pendant la transition — évite les erreurs d'hydratation React | Dashboard → Project Settings → Skew Protection |

**Skew Protection est particulièrement important pour Next.js** : sans elle, un utilisateur
peut recevoir du JS client d'une version et du HTML serveur d'une autre pendant la transition,
causant des erreurs d'hydratation silencieuses.

### Canary Pattern SQWR — 4 phases

```
Phase 1 — Internal (preview URL, 0% trafic prod)
  → Déployer sur une Preview URL Vercel
  → Tester manuellement toutes les features critiques (auth, paiement, data)
  → Vérifier : 0 erreur 500 dans les logs Vercel + Sentry
  → Durée minimum : 30 min
  → Critère de passage : 0 erreur critique

Phase 2 — Canary (5% du trafic production, 24h)
  → Promouvoir en production via Vercel Dashboard
  → Observer pendant 24h minimum
  → Métriques à surveiller : taux erreur Sentry, LCP, taux de conversion (Plausible)
  → Critère de passage : taux d'erreur < baseline + 0.5%

Phase 3 — Beta (25% du trafic, 12-24h)
  → Si Phase 2 validée, continuer l'élargissement
  → Mêmes métriques

Phase 4 — GA (100%)
  → Promotion complète via Vercel Dashboard → Deployments → Promote to Production
  → Monitoring renforcé dans les 2h post-promotion
```

### Implémentation du Canary via Edge Middleware

Pour les déploiements où on veut contrôler finement le pourcentage de trafic :

```typescript
// middleware.ts — Canary routing (5% du trafic vers une Preview URL)
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

const CANARY_URL = process.env.CANARY_DEPLOYMENT_URL // Preview URL Vercel

export function middleware(request: NextRequest) {
  // Ne rediriger que si l'URL canary est définie et que l'utilisateur n'est pas déjà forcé
  if (
    CANARY_URL &&
    !request.cookies.has('force-stable') &&
    Math.random() < 0.05  // 5% du trafic
  ) {
    // Marquer comme canary pour les métriques
    const response = NextResponse.rewrite(new URL(request.url, CANARY_URL))
    response.headers.set('x-deployment-variant', 'canary')
    return response
  }

  return NextResponse.next()
}
```

### Feature Flags — alternative légère pour les features

Pour les features qui ne nécessitent pas un canary deployment complet, les feature flags
permettent de déployer le code en production tout en contrôlant l'activation :

```typescript
// lib/features.ts — Feature flags via variables d'environnement
const FEATURES = {
  NEW_DASHBOARD: process.env.NEXT_PUBLIC_FEATURE_NEW_DASHBOARD === 'true',
  BETA_ANALYTICS: process.env.NEXT_PUBLIC_FEATURE_BETA_ANALYTICS === 'true',
  EXPERIMENTAL_AI: process.env.NEXT_PUBLIC_FEATURE_EXPERIMENTAL_AI === 'true',
} as const

export type FeatureFlag = keyof typeof FEATURES

export function isFeatureEnabled(feature: FeatureFlag): boolean {
  return FEATURES[feature]
}
```

```typescript
// Utilisation dans un composant
import { isFeatureEnabled } from '@/lib/features'

export function Dashboard() {
  return (
    <div>
      {isFeatureEnabled('NEW_DASHBOARD') ? (
        <NewDashboard />
      ) : (
        <LegacyDashboard />
      )}
    </div>
  )
}
```

**Pour toggler sans re-déployer** : modifier la variable d'environnement dans
Vercel Dashboard → Project → Settings → Environment Variables, puis faire un
redéploiement instantané depuis la même commit (zéro code change).

### Kill Switch — rollback d'urgence si le canary révèle un problème

**Règle : le kill switch doit pouvoir être exécuté en < 5 minutes par n'importe qui
ayant accès au Vercel Dashboard.**

```bash
# Option 1 — Dashboard (< 2 min, recommandé)
# Vercel Dashboard → Deployments → cliquer sur le dernier déploiement stable → "Promote to Production"

# Option 2 — CLI Vercel
vercel promote <URL-du-dernier-déploiement-stable>

# Option 3 — Git revert (si le problème est dans le code)
git revert HEAD
git push origin main  # Déclenche automatiquement un nouveau déploiement Vercel

# Option 4 — Désactiver une feature flag (si utilisée)
# Vercel Dashboard → Environment Variables → NEXT_PUBLIC_FEATURE_X=false → Redeploy
```

---

## Checklist avant déploiement prod

- [ ] `npm run build` passe sans erreur
- [ ] `npm run lint` passe sans erreur
- [ ] Variables d'environnement définies dans Vercel dashboard
- [ ] `.env.example` à jour avec toutes les variables requises
- [ ] `validateEnv()` ne lève pas d'erreur en local
- [ ] Pas de `console.log` de debug oubliés (`/clean-commit`)
- [ ] Metadata SEO vérifiée sur les pages modifiées
- [ ] Analytics (Plausible ou Vercel) configuré et testé

---

## Sources

| Référence | Source |
|-----------|--------|
| Vercel Deployment Docs | vercel.com/docs/deployments |
| Plausible RGPD compliance | plausible.io/data-policy |
| Next.js Env Validation patterns | nextjs.org/docs/app/building-your-application/configuring/environment-variables |
| Martin Fowler — Feature Toggles (2016) | martinfowler.com/articles/feature-toggles.html |
| Vercel Skew Protection | vercel.com/docs/deployments/skew-protection |
| Vercel Rolling Releases | vercel.com/docs/deployments/rolling-releases |
