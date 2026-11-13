---
name: perfection-audit
description: "Audit complet de perfection : sécurité, performance, qualité code, type safety - Standard enterprise"
tags: [audit, security, performance, quality, enterprise]
version: 1.0.0
author: Claude Opus 4.6
---

# 🏆 Perfection Audit - Enterprise Grade

Audit exhaustif basé sur les standards des meilleures entreprises tech (Google, Vercel, AWS) et cabinets de sécurité (Cure53, Trail of Bits, NCC Group).

## Objectif

Vérifier qu'une application Next.js/Supabase atteint les standards de **perfection** sur :
- ✅ Sécurité (OWASP Top 10, ASVS Level 2)
- ✅ Performance (Core Web Vitals, load testing)
- ✅ Qualité code (TypeScript strict, zero console, logger centralisé)
- ✅ Type safety (zero `any`, interfaces complètes)
- ✅ Scalabilité (100+ utilisateurs concurrents)

---

## Phase 1 : TypeScript Health (5 min)

### Exécution
```bash
npx tsc --noEmit --pretty
```

### Métriques
- **Target** : 0 erreurs
- **Acceptable** : < 5 erreurs non-critiques
- **Bloquant** : > 10 erreurs OU 1+ erreur critique

### Check
- [ ] 0 erreurs TypeScript
- [ ] `strict: true` dans `tsconfig.json`
- [ ] `noImplicitAny: true`
- [ ] `strictNullChecks: true`
- [ ] Pas de `@ts-ignore` sauf cas justifiés

---

## Phase 2 : Sécurité Critique (20 min)

### 2.1 API Keys & Secrets

**Recherche automatique** :
```bash
# Keys exposées au client
grep -r "NEXT_PUBLIC_.*KEY\|NEXT_PUBLIC_.*SECRET" .env* app/ components/

# Service role keys en client-side
grep -r "SERVICE_ROLE_KEY" app/ components/ lib/
```

**Checklist** :
- [ ] Zéro `NEXT_PUBLIC_` pour API keys (sauf Maps, Analytics)
- [ ] `SUPABASE_SERVICE_ROLE_KEY` uniquement server-side
- [ ] Stripe secret key jamais exposé
- [ ] `.env` dans `.gitignore`

### 2.2 Debug Endpoints

**Recherche** :
```bash
find app/api/debug -type f
grep -r "/api/test\|/api/debug" app/api/
```

**Checklist** :
- [ ] Zéro endpoint `/api/debug/`
- [ ] Zéro endpoint `/api/test/`
- [ ] Endpoints admin protégés par `is_admin` check

### 2.3 Rate Limiting

**Recherche** :
```bash
# Routes publiques sans rate limit
find app/api -name "route.ts" -exec grep -L "ratelimit\|RateLimit" {} \;
```

**Checklist** :
- [ ] Toutes routes publiques rate-limitées
- [ ] Login : 5/min per IP
- [ ] Signup : 3/hour per IP
- [ ] Upload : 10/hour per user
- [ ] Password reset : 3/hour per email

### 2.4 RLS (Row Level Security)

**SQL à exécuter** :
```sql
-- Tables sans RLS
SELECT tablename
FROM pg_tables
WHERE schemaname = 'public'
  AND rowsecurity = false;

-- Policies suspectes
SELECT tablename, policyname, definition
FROM pg_policies
WHERE definition NOT LIKE '%auth.uid()%';
```

**Checklist** :
- [ ] RLS activé sur toutes tables sensibles
- [ ] Policies testées avec différents users
- [ ] Service role usage justifié (webhooks, cron)

### 2.5 Authentication

**Recherche** :
```bash
# API routes sans auth
find app/api -name "route.ts" -exec grep -L "session\|getUser\|auth" {} \;
```

**Checklist** :
- [ ] Auth check sur toutes routes protégées
- [ ] Session timeout configuré et APPLIQUÉ
- [ ] Password hashing bcrypt/Argon2 (PAS SHA256)
- [ ] MFA disponible pour comptes critiques

---

## Phase 3 : Performance & Scalabilité (15 min)

### 3.1 Database Query Optimization

**Recherche anti-patterns** :
```bash
# SELECT * au lieu de colonnes spécifiques
grep -r "select('\*')" app/ lib/ --include="*.ts"

# Queries sans .limit()
grep -r "\.from(" app/ lib/ | grep -v "\.limit(" | grep -v "\.single()"

# N+1 queries (loop avec query)
grep -rA 10 "for.*of\|\.map(" lib/services/ | grep "supabase.from"
```

**Checklist** :
- [ ] Zéro `SELECT *` count queries
- [ ] `.limit()` sur toutes list queries
- [ ] Zéro N+1 queries
- [ ] Index créés sur colonnes filtrées

### 3.2 Image Optimization

**Recherche** :
```bash
# <img> au lieu de <Image>
grep -r "<img" app/ components/ --include="*.tsx"
```

**Checklist** :
- [ ] Next.js `<Image>` partout (sauf SVG)
- [ ] Lazy loading activé
- [ ] `next.config.js` domains configurés
- [ ] Formats WebP/AVIF activés

### 3.3 React Performance

**Recherche** :
```bash
# Components sans memo
grep -r "export.*function.*Props" components/ | grep -v "memo"

# Callbacks inline dans props
grep -r "onClick={() =>" app/ components/
```

**Checklist** :
- [ ] Components fréquents wrapped in `memo()`
- [ ] Callbacks wrapped in `useCallback`
- [ ] Expensive calculations in `useMemo`
- [ ] Context providers memoizés

### 3.4 Load Testing Readiness

**Questions** :
- Combien de connexions simultanées Supabase peut gérer ?
- Combien de requêtes/seconde les API routes supportent ?
- Le CDN Vercel est-il activé ?

**Checklist** :
- [ ] Supabase connection pooling configuré
- [ ] API routes stateless (scalable horizontalement)
- [ ] Cache headers corrects (`Cache-Control`)
- [ ] Rate limiting empêche DoS

**Benchmark targets** :
- 100 utilisateurs simultanés : < 500ms p95
- 1000 req/sec : API routes doivent tenir
- Core Web Vitals : LCP < 2.5s, FID < 100ms, CLS < 0.1

---

## Phase 4 : Code Quality (10 min)

### 4.1 Console Statements

**Recherche** :
```bash
grep -r "console\.\(log\|error\|warn\)" app/ lib/ components/ contexts/ \
  --include="*.ts" --include="*.tsx" \
  | grep -v "logger.ts" \
  | wc -l
```

**Target** : 0 console statements en production

**Checklist** :
- [ ] Zéro `console.log`
- [ ] Zéro `console.error`
- [ ] Logger centralisé utilisé partout
- [ ] Logs dev-only wrapped dans `if (process.env.NODE_ENV === 'development')`

### 4.2 Type Safety

**Recherche** :
```bash
# as any
grep -r "as any" app/ lib/ components/ --include="*.ts" --include="*.tsx" | wc -l

# @ts-ignore
grep -r "@ts-ignore\|@ts-expect-error" app/ lib/ components/
```

**Checklist** :
- [ ] < 50 `as any` (aucun dans code critique)
- [ ] < 5 `@ts-ignore` (tous justifiés)
- [ ] Interfaces pour toutes data structures
- [ ] Type guards pour unions

### 4.3 Error Handling

**Recherche** :
```bash
# Catch silencieux
grep -rA 3 "} catch" app/ lib/ | grep -B 3 "^$"

# Error boundaries
find app -name "error.tsx"
```

**Checklist** :
- [ ] Error boundary sur chaque segment (owner, seeker, resident, etc.)
- [ ] Tous les catch loggent via logger
- [ ] Errors UI-friendly pour users
- [ ] Stack traces jamais exposées

### 4.4 Dead Code

**Recherche** :
```bash
# Fichiers archivés
find app lib components -name "*OLD*" -o -name "*BACKUP*" -o -name "_archived"

# Imports inutilisés
npx eslint . --ext .ts,.tsx --rule 'no-unused-vars: error' 2>&1 | grep "is defined but never used"
```

**Checklist** :
- [ ] Zéro fichier `*-OLD.tsx`
- [ ] Zéro dossier `_archived/`
- [ ] Imports nettoyés (ESLint)

---

## Phase 5 : Supabase Specifics (10 min)

### 5.1 Connection Pooling

**Check `DATABASE_URL`** :
```
postgresql://[user]:[password]@[host]:6543/postgres?pgbouncer=true&connection_limit=10
```

**Limites Supabase** :
- Free tier : 60 connections max
- Pro tier : 200 connections max
- Enterprise : illimité

**Pour 100 users simultanés** :
- Connection pooling REQUIS
- `pgbouncer=true` dans connection string
- `connection_limit=10` par instance

### 5.2 Realtime Limits

**Free tier** :
- 200 concurrent connections
- 2 concurrent channels

**Si > 200 users simultanés** :
- Upgrade vers Pro ($25/mois)
- Ou désactiver realtime non-essentiel

### 5.3 Storage Limits

**Free tier** :
- 1 GB storage
- 2 GB bandwidth/mois

**Si app avec photos** :
- Surveiller usage actuel
- Prévoir upgrade ou compression agressive

---

## Phase 6 : Build & Deployment (5 min)

### 6.1 Build Verification

```bash
npm run build
```

**Checklist** :
- [ ] Build passe sans erreur
- [ ] Zéro warning TypeScript
- [ ] Bundle size raisonnable (< 500KB First Load JS)
- [ ] Source maps désactivées en production

### 6.2 Vercel Configuration

**`vercel.json` requis** :
```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "Strict-Transport-Security", "value": "max-age=63072000" }
      ]
    }
  ],
  "env": {
    "NODE_ENV": "production"
  }
}
```

**Checklist** :
- [ ] Security headers configurés
- [ ] Environment variables définies sur Vercel
- [ ] Domaine custom avec HTTPS
- [ ] Edge config si besoin (rate limiting, feature flags)

---

## Phase 7 : Monitoring & Observability (5 min)

### 7.1 Error Tracking

**Checklist** :
- [ ] Sentry configuré et fonctionne
- [ ] Source maps uploadées (Vercel + Sentry)
- [ ] Error boundaries capturent et loggent
- [ ] Alertes configurées (Slack, email)

### 7.2 Performance Monitoring

**Core Web Vitals** :
- [ ] LCP < 2.5s (75th percentile)
- [ ] FID < 100ms
- [ ] CLS < 0.1

**API Performance** :
- [ ] p95 < 500ms sur routes critiques
- [ ] Timeout configurés (10s max)
- [ ] Slow query logging

---

## Phase 8 : Compliance & Legal (5 min)

### RGPD (si utilisateurs EU)

**Checklist** :
- [ ] Cookie consent banner
- [ ] Privacy policy accessible
- [ ] User data export disponible
- [ ] Right to be forgotten implémenté
- [ ] Data retention policy documentée

### PCI DSS (si paiements)

**Checklist** :
- [ ] PAS de stockage carte bancaire
- [ ] Stripe Checkout OU Elements (PCI compliant)
- [ ] HTTPS obligatoire
- [ ] Logs ne contiennent PAS card numbers

---

## Rapport d'Audit - Template

```markdown
# AUDIT DE PERFECTION - [Project Name]

**Date** : [YYYY-MM-DD]
**Durée** : [Xh]
**Auditor** : Claude Opus 4.6 Perfection Audit

---

## 📊 RÉSULTATS GLOBAUX

| Phase | Score | Status |
|-------|-------|--------|
| TypeScript | X/100 | [✅ PASS / 🔴 FAIL] |
| Sécurité | X/100 | [✅ PASS / 🔴 FAIL] |
| Performance | X/100 | [✅ PASS / 🔴 FAIL] |
| Code Quality | X/100 | [✅ PASS / 🔴 FAIL] |
| Scalabilité | X/100 | [✅ PASS / 🔴 FAIL] |

**Score global** : XX/100

**Verdict** :
- ≥ 95% : 🏆 PERFECTION - Production ready
- 85-94% : ✅ EXCELLENT - Minor improvements
- 75-84% : 🟡 BON - Fix non-critical issues
- < 75% : 🔴 INSUFFISANT - Blocking issues

---

## 🔴 CRITICAL FINDINGS

### [CRIT-001] [Title]
- **Severity** : CRITICAL
- **Location** : `[file:line]`
- **Issue** : [Description]
- **Impact** : [Security/Performance consequence]
- **Fix** : [Action required]
- **Effort** : [Xh]

---

## 🟠 HIGH PRIORITY

[List of high priority issues]

---

## 🟡 MEDIUM PRIORITY

[List of medium priority issues]

---

## ✅ PASSED CHECKS

- TypeScript : 0 errors
- console.log : 0 statements
- API keys : Secured
- [etc.]

---

## 📈 RECOMMENDATIONS

### Immediate (P0)
1. [Action]

### Short-term (P1)
1. [Action]

### Long-term
1. [Action]

---

## 📊 METRICS SUMMARY

```
TypeScript errors:        0
console.log:              0
console.error:            0
as any:                   XX
Sécurité critique:        0 issues
Rate limiting:            100%
Error boundaries:         6
Logger usage:             XXX occurrences
Build:                    CLEAN
```

---

## 🔄 NEXT STEPS

1. Fix CRITICAL findings
2. Address HIGH priority
3. Schedule follow-up audit in 3 months
4. Update security patterns document
```

---

## Utilisation

### Audit complet
```bash
/perfection-audit
```

### Audit ciblé (sécurité uniquement)
```bash
/perfection-audit --security-only
```

### Audit avec auto-fix
```bash
/perfection-audit --auto-fix
```

---

## Intégration Continue

Ce skill peut être :
- Exécuté manuellement avant chaque release
- Intégré dans CI/CD (GitHub Actions)
- Déclenché automatiquement après gros refactoring
- Utilisé pour audits trimestriels

---

## Sources & Standards

- OWASP Top 10 2025
- ASVS Level 2
- Google Cloud Security Best Practices
- Vercel Production Checklist
- Next.js Security Guide
- Supabase Security Practices
- Core Web Vitals Standards
- CWE Top 25

---

**Mis à jour** : 2026-02-13
**Basé sur** : un audit réel (65 erreurs → 0, 2663 console → 0)
