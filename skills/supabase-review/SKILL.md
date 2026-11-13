---
name: supabase-review
description: Audit sécurité Supabase — vérifie RLS sur toutes les tables, auth.uid() correct, indexes sur colonnes FK, pas de select('*'), Edge Functions sécurisées. Sources : NIST SP 800-63B, OWASP.
tags: [supabase, security, rls, postgresql, auth, database]
model: sonnet
---

# /supabase-review — Audit Sécurité & Qualité Supabase

## Quand utiliser

- Avant chaque PR touchant la DB ou les migrations
- Audit complet du schéma Supabase
- Review d'une nouvelle table ou RPC
- Vérification auth et RLS d'une feature

## Règles absolues (bloquantes)

### RLS
- [ ] **Chaque table a RLS activé** — `ALTER TABLE x ENABLE ROW LEVEL SECURITY`
- [ ] **`(select auth.uid())`** dans USING/WITH CHECK — JAMAIS `auth.uid()` nu (performance -40% sur requêtes volumineuses)
- [ ] Policy distincte pour SELECT / INSERT / UPDATE / DELETE
- [ ] Tables publiques en lecture : policy `USING (true)` explicite + jamais d'écriture publique

### Auth (NIST SP 800-63B)
- [ ] Sessions invalidées server-side au logout (pas juste côté client)
- [ ] MFA disponible pour les actions sensibles
- [ ] Tokens JWT non persistés dans localStorage (cookie HttpOnly préféré)
- [ ] Refresh token rotation activé

### Migrations SQL
- [ ] Idempotentes — `IF NOT EXISTS` partout
- [ ] Rollback possible (pas de `DROP` sans `CREATE` alternatif)
- [ ] RPCs avec prefix `p_` sur tous les paramètres
- [ ] RPCs financières : `p_idempotency_key UUID DEFAULT NULL` obligatoire
- [ ] Indexes sur toutes les colonnes FK (`CREATE INDEX IF NOT EXISTS`)

### Queries côté app
- [ ] Jamais de `select('*')` — utiliser des field selectors explicites
- [ ] Pas de `supabase.from()` dans les composants UI — passer par des services
- [ ] `createServerSupabaseClient()` dans chaque méthode server (pas dans le constructeur)

### Edge Functions
- [ ] Auth vérifiée en première ligne via `supabase.auth.getUser()`
- [ ] Rate limiting sur les fonctions publiques
- [ ] Secrets dans les env vars Supabase, jamais hardcodés

## Format de sortie

```
## Supabase Review — [scope]

### 🔴 Bloquant (à corriger avant merge)
- [problème] → [fix]

### 🟡 Important (à corriger cette semaine)
- [problème] → [fix]

### 🟢 Suggestions
- [amélioration]

### SQL correctif
[migrations/RPCs à appliquer]
```
