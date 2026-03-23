# Contrat — Analytics Produit

> Module de contrat SQWR Project Kit.
> Sources : HEART Framework — Google Research (Rodden et al., CHI 2010), Pirate Metrics AARRR (Dave McClure, 2007), Google Analytics 4 docs (developers.google.com/analytics), PostHog docs (posthog.com/docs), Andreessen Horowitz SaaS Metrics (a16z.com/2015/08/21/16-metrics).

---

## Fondements scientifiques

**Les analytics produit ne sont pas les analytics marketing.** Les analytics marketing mesurent les canaux d'acquisition. Les analytics produit mesurent ce que les utilisateurs font *dans* le produit — et pourquoi ils restent ou partent.

**Deux frameworks de référence :**
- **HEART** (Google, 2010 — Kerry Rodden, Hilary Hutchinson, Xin Fu) : mesure orientée expérience utilisateur
- **AARRR / Pirate Metrics** (Dave McClure, 2007) : mesure orientée croissance

Ces deux frameworks sont complémentaires — AARRR pour la vision macro, HEART pour l'évaluation par feature.

---

## 1. AARRR — Pirate Metrics

> Source : Dave McClure — "Startup Metrics for Pirates: AARRR" (500hats.com, 2007)

| Étape | Métrique clé | Threshold de référence |
|-------|-------------|----------------------|
| **Acquisition** | CAC (Coût d'Acquisition Client) | LTV/CAC ≥3x (SaaStr) |
| **Activation** | % users atteignant l'événement "Aha moment" | ≥40% (benchmark SaaS — Andreessen Horowitz) |
| **Retention** | Rétention J7 / J30 / J90 | J30 ≥30% SaaS (a16z benchmark) |
| **Referral** | NPS (Net Promoter Score) | ≥40 = bon, ≥70 = excellent (Bain & Company) |
| **Revenue** | MRR Churn mensuel | <2%/mois (ProfitWell benchmark) |

**Aha Moment** : événement spécifique qui corrèle avec la rétention long terme. À identifier par cohort analysis (ex : sur Twitter → "suivre 30 personnes dans les 3 premiers jours").

---

## 2. HEART Framework — Par feature

> Source : Rodden K., Hutchinson H., Fu X. — "Measuring the User Experience on a Large Scale: User-Centered Metrics for Web Applications" (Google, CHI 2010)

| Dimension | Signification | Exemple de métrique |
|-----------|--------------|-------------------|
| **H**appiness | Satisfaction subjective | CSAT, NPS, score moyen in-app |
| **E**ngagement | Fréquence d'utilisation | DAU/MAU ratio, sessions/user/semaine |
| **A**doption | Nouveaux utilisateurs d'une feature | % users ayant utilisé la feature 1x |
| **R**etention | Utilisateurs revenant | Cohort J7, J30, J90 |
| **T**ask Success | Taux de complétion d'une tâche | Completion rate, error rate, time-on-task |

**Processus :** pour chaque nouvelle feature, définir 1-2 métriques HEART *avant* le développement, puis mesurer après le launch.

---

## 3. Taxonomie d'événements — Naming convention

> Source : Segment Analytics Spec (segment.com/docs/connections/spec/track) — standard industriel adopté par Amplitude, Mixpanel, PostHog

**Convention : `<object>_<action>` en snake_case**

```typescript
// ✅ Naming correct
'user_signed_up'
'subscription_created'
'feature_clicked'
'onboarding_step_completed'
'document_exported'

// ❌ Naming incorrect
'SignUp'           // PascalCase
'click button'     // espace
'btn_click'        // trop vague
'userDidSignUp'    // camelCase
```

**Propriétés obligatoires sur chaque événement :**

```typescript
// types/analytics.ts
interface BaseEventProperties {
  user_id: string | null       // null si non-authentifié
  session_id: string           // UUID de session
  timestamp: string            // ISO 8601
  platform: 'web' | 'ios' | 'android'
  app_version: string          // semver
  environment: 'production' | 'staging'
}

// Union type — tous les événements possibles (type-safety)
type AnalyticsEvent =
  | { event: 'user_signed_up'; properties: { method: 'email' | 'google' | 'github' } }
  | { event: 'user_logged_in'; properties: { method: 'email' | 'google' | 'github' } }
  | { event: 'subscription_created'; properties: { plan: string; price: number; currency: string } }
  | { event: 'subscription_cancelled'; properties: { reason: string; plan: string } }
  | { event: 'feature_used'; properties: { feature_name: string; source: string } }
  | { event: 'onboarding_step_completed'; properties: { step: number; step_name: string } }
```

---

## 4. Helper TypeScript — trackEvent

```typescript
// lib/analytics.ts
import posthog from 'posthog-js'

type AnalyticsEvent =
  | { event: 'user_signed_up'; properties: { method: 'email' | 'google' } }
  | { event: 'subscription_created'; properties: { plan: string; mrr: number } }
  | { event: 'feature_used'; properties: { feature_name: string } }
  | { event: 'onboarding_completed'; properties: { steps_skipped: number } }

export function trackEvent<T extends AnalyticsEvent['event']>(
  event: T,
  properties: Extract<AnalyticsEvent, { event: T }>['properties']
): void {
  if (process.env.NODE_ENV !== 'production') {
    console.debug('[analytics]', event, properties)
    return
  }

  posthog.capture(event, {
    ...properties,
    timestamp: new Date().toISOString(),
    platform: 'web',
    app_version: process.env.NEXT_PUBLIC_APP_VERSION ?? '0.0.0',
  })
}

// Utilisation — erreur TypeScript si mauvaises propriétés
trackEvent('subscription_created', { plan: 'pro', mrr: 49 })  // ✅
trackEvent('subscription_created', { plan: 'pro' })           // ❌ TypeScript error
```

---

## 5. GA4 — Configuration Next.js 14

> Source : Next.js docs — `@next/third-parties` (nextjs.org/docs/app/building-your-application/optimizing/third-party-libraries), Google Analytics 4 docs (developers.google.com/analytics/devguides/collection/ga4)

```tsx
// app/layout.tsx
import { GoogleAnalytics } from '@next/third-parties/google'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="fr">
      <body>{children}</body>
      {process.env.NEXT_PUBLIC_GA_ID && (
        <GoogleAnalytics gaId={process.env.NEXT_PUBLIC_GA_ID} />
      )}
    </html>
  )
}
```

```typescript
// lib/gtag.ts
export const GA_MEASUREMENT_ID = process.env.NEXT_PUBLIC_GA_ID ?? ''

export function gtagEvent(action: string, parameters: Record<string, unknown>) {
  if (typeof window === 'undefined') return
  window.gtag?.('event', action, parameters)
}

// Événement e-commerce GA4
gtagEvent('purchase', {
  transaction_id: 'T_12345',
  value: 49.00,
  currency: 'EUR',
  items: [{ item_id: 'plan_pro', item_name: 'Pro Plan', price: 49.00 }],
})
```

**Variables d'environnement :**
```bash
NEXT_PUBLIC_GA_ID=G-XXXXXXXXXX    # Google Analytics 4 Measurement ID
```

---

## 6. PostHog — Recommandé pour projets EU (RGPD)

> Source : PostHog docs (posthog.com/docs), PostHog EU Cloud (eu.posthog.com)

**Pourquoi PostHog vs GA4 pour les projets EU :**
- Hébergement EU disponible (eu.posthog.com) → données restent en Europe
- Open-source → auto-hébergeable
- Session replay + heatmaps + feature flags inclus
- Gratuit jusqu'à 1M events/mois

```bash
npm install posthog-js
```

```typescript
// app/providers.tsx
'use client'
import posthog from 'posthog-js'
import { PostHogProvider } from 'posthog-js/react'
import { useEffect } from 'react'

export function PHProvider({ children }: { children: React.ReactNode }) {
  useEffect(() => {
    posthog.init(process.env.NEXT_PUBLIC_POSTHOG_KEY!, {
      api_host: process.env.NEXT_PUBLIC_POSTHOG_HOST ?? 'https://eu.i.posthog.com',
      person_profiles: 'identified_only',  // RGPD : pas de profil anonyme par défaut
      capture_pageview: false,  // gérer manuellement pour Next.js App Router
    })
  }, [])

  return <PostHogProvider client={posthog}>{children}</PostHogProvider>
}
```

---

## 7. Rétention — Cohort Analysis (Supabase)

```sql
-- Cohorte J30 : % d'utilisateurs actifs 30 jours après inscription
WITH cohort AS (
  SELECT
    user_id,
    DATE_TRUNC('week', created_at) AS cohort_week
  FROM users
  WHERE created_at >= NOW() - INTERVAL '90 days'
),
activity AS (
  SELECT DISTINCT
    user_id,
    DATE_TRUNC('week', created_at) AS activity_week
  FROM events
  WHERE created_at >= NOW() - INTERVAL '90 days'
)
SELECT
  c.cohort_week,
  COUNT(DISTINCT c.user_id) AS cohort_size,
  COUNT(DISTINCT a.user_id) AS retained_week_4,
  ROUND(COUNT(DISTINCT a.user_id)::numeric / COUNT(DISTINCT c.user_id) * 100, 1) AS retention_rate
FROM cohort c
LEFT JOIN activity a ON c.user_id = a.user_id
  AND a.activity_week = c.cohort_week + INTERVAL '4 weeks'
GROUP BY c.cohort_week
ORDER BY c.cohort_week;
```

---

## Checklist pré-lancement analytics

### Bloquants

- [ ] Plan de tracking documenté (liste des événements + propriétés) avant développement
- [ ] GA4 ou PostHog configuré et testé en staging
- [ ] Consentement RGPD avant tout tracking (banner cookie → analytics désactivées par défaut)
- [ ] `trackEvent` type-safe — aucun `string` libre pour les noms d'événements
- [ ] `user_id` hashé ou pseudonymisé dans les événements (RGPD)

### Importants

- [ ] Funnel d'activation défini et instrumenté (Sign up → Aha Moment)
- [ ] NPS configuré (in-app ou email, déclenché à J7 après activation)
- [ ] Cohort J7/J30 visible dans le dashboard
- [ ] DAU/MAU ratio instrumenté

### Souhaitables

- [ ] Session replay activé (PostHog) pour le debugging UX
- [ ] Feature flags (PostHog) pour les A/B tests
- [ ] Alertes automatiques si churn rate hebdomadaire > seuil

---

## Sources

| Référence | Lien |
|-----------|------|
| HEART Framework — Google CHI 2010 | research.google/pubs/measuring-the-user-experience-on-a-large-scale |
| Pirate Metrics AARRR — Dave McClure | 500hats.com/startups/distribution |
| Andreessen Horowitz — 16 SaaS Metrics | a16z.com/2015/08/21/16-metrics |
| Google Analytics 4 docs | developers.google.com/analytics |
| PostHog docs | posthog.com/docs |
| Segment Analytics Spec | segment.com/docs/connections/spec/track |
| ProfitWell SaaS Metrics | profitwell.com/recur/all |
