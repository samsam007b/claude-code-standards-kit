# Contrat — Observabilité & Monitoring

> Module de contrat SQWR Project Kit.
> Sources : Google SRE Book, OpenTelemetry, Sentry docs, Supabase Backup docs.
> Principe : "Vercel logs" ≠ observabilité. La production sans monitoring est aveugle.

---

## Fondements

**Sans observabilité, le système échoue en silence.** Google SRE distingue trois pilliers :
- **Logs** : événements discrets (ce qui s'est passé)
- **Metrics** : agrégats numériques dans le temps (dans quel état)
- **Traces** : chemin d'une requête à travers les composants (pourquoi c'est lent)

> Source : *Google SRE Book, Chapter 6 — Monitoring Distributed Systems*

---

## 1. Logging structuré

### Ne jamais faire

```typescript
// ❌ console.log non structuré — impossible à filtrer ou alerter
console.log("Erreur paiement", err)
console.log("User " + userId + " logged in")
```

### Toujours faire

```typescript
// ✅ Logging structuré — JSON parseable, filtrable, alertable
const log = {
  level: 'error',          // debug | info | warn | error | fatal
  message: 'payment_failed',
  userId: userId,          // identifiant, jamais email/password
  orderId: orderId,
  errorCode: err.code,
  timestamp: new Date().toISOString(),
  traceId: generateTraceId(),  // pour corréler les logs d'une même requête
}
console.error(JSON.stringify(log))
```

**Règles PII (RGPD) :**

| Ne jamais logger | Logger à la place |
|-----------------|------------------|
| Email | userId (hash anonyme) |
| Mot de passe | — (jamais) |
| Numéro de carte | last4 digits uniquement |
| Adresse complète | city uniquement |
| Token de session | — (jamais) |

**Niveaux de log :**

| Niveau | Quand l'utiliser |
|--------|-----------------|
| `debug` | Dev only — désactivé en prod |
| `info` | Actions métier normales (user created, payment succeeded) |
| `warn` | Situation anormale mais récupérable (retry, deprecated API) |
| `error` | Erreur qui affecte un utilisateur |
| `fatal` | Service indisponible |

---

## 2. Error Tracking — Sentry

**Règle : `console.error` seul est insuffisant en production.** Sentry agrège, déduplique, alerte, et relie les erreurs aux releases.

```bash
npm install @sentry/nextjs
npx @sentry/wizard@latest -i nextjs
```

```typescript
// sentry.client.config.ts
import * as Sentry from "@sentry/nextjs"

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 0.1,      // 10% des transactions — ajuster selon volume
  profilesSampleRate: 0.1,
  // Ne pas envoyer les erreurs de dev local
  enabled: process.env.NODE_ENV === 'production',
})
```

```typescript
// Dans les Server Actions ou API routes
import * as Sentry from "@sentry/nextjs"

export async function createPayment(data: unknown) {
  try {
    const validated = PaymentSchema.parse(data)
    return await processPayment(validated)
  } catch (err) {
    Sentry.captureException(err, {
      tags: { feature: 'payment', userId },
      level: 'error',
    })
    throw err
  }
}
```

**Alertes Sentry à configurer :**
- Error rate > 1% sur une page → notification Slack/email immédiate
- Nouvelle erreur non vue → notification immédiate
- Erreur qui affecte > 10 utilisateurs → notification critique

---

## 3. Performance Monitoring — Real User Monitoring (RUM)

**Lighthouse DevTools ≠ expérience utilisateur réelle.** Lighthouse mesure dans des conditions idéales. Le RUM mesure ce que les vrais utilisateurs vivent.

```typescript
// app/layout.tsx — Vercel Speed Insights (RUM gratuit sur Vercel)
import { SpeedInsights } from "@vercel/speed-insights/next"

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <SpeedInsights />  {/* Mesure LCP, INP, CLS réels par utilisateur */}
      </body>
    </html>
  )
}
```

**Métriques RUM à surveiller :**

| Métrique | Seuil alerte | Outil |
|----------|-------------|-------|
| LCP | >3s au 75e percentile | Vercel Speed Insights |
| INP | >300ms | Vercel Speed Insights |
| CLS | >0.15 | Vercel Speed Insights |
| Error rate | >1% des sessions | Sentry |

---

## 4. Backup & Disaster Recovery

### Supabase

```bash
# Vérifier que le PITR (Point-in-Time Recovery) est activé
# Supabase Dashboard → Settings → Database → PITR
# Pro plan : PITR jusqu'à 7 jours
# Team plan : PITR jusqu'à 28 jours
```

**Procédure de restauration :**
1. Supabase Dashboard → Backups → sélectionner le point de restauration
2. Restauration dans un projet séparé d'abord (ne pas écraser la prod directement)
3. Vérifier l'intégrité des données restaurées
4. Switch de connexion une fois validé

**Export manuel régulier (pour les plans sans PITR) :**
```bash
# Export complet de la base
pg_dump "postgresql://postgres:[password]@[host]:5432/postgres" \
  --format=custom \
  --file="backup-$(date +%Y%m%d).dump"
```

### Checklist Disaster Recovery

- [ ] PITR activé sur Supabase (ou export automatique configuré)
- [ ] Dernière restauration testée (jamais uniquement assumée fonctionnelle)
- [ ] Procédure documentée et accessible sans accès au système compromis
- [ ] Contacts d'urgence définis (Supabase support, Vercel support)

---

## 5. Alerting — Seuils recommandés

| Événement | Seuil | Action |
|-----------|-------|--------|
| Error rate | >1% | Notification Slack immédiate |
| p95 latency | >2s | Notification Slack |
| p99 latency | >5s | Page (on-call) |
| Supabase connection pool | >80% | Warning |
| Build failure | Toute | Notification immédiate |
| npm audit critical | Toute | Bloquer le déploiement |

---

## 6. Règles absolues

### Ne jamais faire
- Logger des données sensibles (email, password, tokens, cartes)
- Désactiver les alertes Sentry "parce que c'est du bruit" sans investiguer
- Partir en production sans error tracking configuré
- Utiliser `console.log` comme seul mécanisme de monitoring

### Toujours faire
- Avoir un `traceId` dans chaque log pour corréler les événements
- Configurer les alertes Sentry avant le premier déploiement prod
- Tester la procédure de restauration Supabase sur un projet clone
- Vérifier les logs Vercel + Sentry dans les 30 min suivant un déploiement

---

## 7. Sources

| Référence | Source |
|-----------|--------|
| Google SRE Book — Monitoring | sre.google/sre-book/monitoring-distributed-systems |
| OpenTelemetry | opentelemetry.io |
| Sentry Next.js Setup | docs.sentry.io/platforms/javascript/guides/nextjs |
| Vercel Speed Insights | vercel.com/docs/speed-insights |
| Supabase Backup & PITR | supabase.com/docs/guides/platform/backups |
