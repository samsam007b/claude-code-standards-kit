# SQWR Project-Kit — Plan d'amélioration vers 100/100
> Généré le 2026-03-30 sur la base de l'audit multi-dimensionnel complet

---

## Scores actuels → cibles

| Dimension | Avant | Cible |
|-----------|-------|-------|
| Rigueur des standards (26 contrats) | 82/100 | 100/100 |
| Couche automation (agents + hooks + workflows) | 56/100 | 95/100 |
| Stratégie + DX + positionnement | 72/100 | 95/100 |
| Cohérence interne | 82/100 | 100/100 |
| **Score global** | **73/100** | **97/100** |

---

## Architecture d'exécution — 4 équipes parallèles

Chaque équipe possède des fichiers exclusifs : zéro conflit, exécution 100% parallèle.

---

## Équipe A — Fix 8 contrats existants
**Fichiers exclusifs :** `contracts/CONTRACT-*.md` (8 fichiers ciblés)

### A1. CONTRACT-PDF-GENERATION.md
- Problème : `<10s` et `<5MB` non sourcés — violation règle d'or
- Fix : Sourcer `<10s` → AWS Lambda default timeout (15s) + Nielsen 1993 (10s = tolérance maximale)
- Fix : Sourcer `<5MB` → 5s download at 8 Mbps median mobile (Akamai State of Internet 2024)
- Fix : Promouvoir ISO 14289-1 (PDF/UA) et ISO 32000-2:2020 en introduction
- Fix : Ajouter `> **Last validated:** 2026-03-30`

### A2. CONTRACT-GREEN-SOFTWARE.md
- Problème : "4% of global emissions" sans DOI. Carbon intensity = données temps réel (non-recherche)
- Fix : "1.8–3.9% GHG" → IEA 2022 + Freitag et al., Patterns 2021, DOI:10.1016/j.patter.2021.100340
- Fix : Ancrer carbon intensity dans ISO 14040/44 (LCA) + Green Software Foundation SCI v1.0
- Fix : Clarifier que electricitymap.org est advisory, pas baseline de recherche
- Fix : Ajouter `> **Last validated:** 2026-03-30`

### A3. CONTRACT-MOTION-DESIGN.md
- Problème : `200ms = immédiateté` sans citation vérifiable. Stagger sans source.
- Fix : Citer Doherty & Thadhani, IBM Systems Journal 1982 (Vol 21, No 1) pour 400ms + Nielsen 1993 pour 100ms
- Fix : Stagger 0.08-0.1s → Material Design Motion docs (advisory, pas recherche — l'indiquer)
- Fix : Monter `prefers-reduced-motion` (WCAG 2.3.3) en Règle #1 absolue, pas en footnote
- Fix : Ajouter `> **Last validated:** 2026-03-30`

### A4. CONTRACT-PRICING.md
- Problème : "Capturer 10-20% de la valeur créée" — source Simon-Kucher non présente dans le corps
- Fix : Ajouter "(Simon-Kucher & Partners, *Value-Based Pricing*, 2012; Nagle, Hogan & Zale, *The Strategy and Tactics of Pricing*, 5th ed., 2011)"
- Fix : Ajouter OpenView 2024 SaaS Benchmarks pour freemium conversion rates
- Fix : Ajouter `> **Last validated:** 2026-03-30`

### A5. CONTRACT-ANALYTICS.md
- Problème : Benchmarks datés (HEART 2010, AARRR 2007). Activation >40% sans source.
- Fix : Activation → "B2C SaaS 40-60%, B2B SaaS 20-40% (Reforge Benchmarks 2023; OpenView Product Benchmarks 2023)"
- Fix : Ajouter benchmarks D30 par catégorie : "games 25-30%, productivity 30-35%, B2B SaaS 40-50% (a16z 2024 SaaS Metrics)"
- Fix : Ajouter `> **Last validated:** 2026-03-30`

### A6. CONTRACT-SECURITY.md
- Problème : NIST CSF 2.0 (2024) absent. CIS Controls v8 absent. OWASP LLM01 absent.
- Fix : Ajouter NIST Cybersecurity Framework 2.0 (CSF 2.0, February 2024) en contexte
- Fix : Ajouter OWASP LLM Top 10 LLM01:2023 (Prompt Injection) pour routes AI-enabled
- Fix : Ajouter CIS Controls v8 pour configuration hardening
- Fix : Ajouter `> **Last validated:** 2026-03-30`

### A7. CONTRACT-TESTING.md
- Problème : Mutation testing absent. BVA (Boundary-Value Analysis) absent.
- Fix : Ajouter mutation testing → Stryker/pitest. Mutation score ≥60% critique (Delahaye et al., IEEE TSE 2015)
- Fix : Ajouter BVA → Beizer, *Software Testing Techniques*, 2nd ed., 1995; IEEE Std 829-2008
- Fix : Ajouter `> **Last validated:** 2026-03-30`

### A8. CONTRACT-ACCESSIBILITY.md
- Problème : Inclusive Design patterns absents. Color blindness simulation absente. APCA non mentionné.
- Fix : Ajouter Microsoft Inclusive Design Toolkit (microsoft.com/design/inclusive)
- Fix : Ajouter color blindness guidance (8% of males — Birch 2012) + Sim Daltonism / Chrome DevTools
- Fix : Ajouter note APCA → W3C WCAG 3 draft (improved perceptual uniformity)
- Fix : Ajouter `> **Last validated:** 2026-03-30`

---

## Équipe B — 3 nouveaux contrats + audit + agent + scripts
**Fichiers exclusifs :** `contracts/` (3 nouveaux), `audits/AUDIT-RESILIENCE.md`, `agents/AGENT-RESILIENCE-AUDIT.md`, `scripts/init-project.sh`, `scripts/verify-kit.sh`

### B1. contracts/CONTRACT-API-DESIGN.md (NOUVEAU)
Sources : RFC 7231, RFC 7807 (Problem Details), RFC 6750 (Bearer), OpenAPI 3.1.0, Google API Design Guide, Stripe API Design
Règles : REST verbs, versioning (/v1/ vs header), status codes, rate limiting (429 + Retry-After RFC 6585), pagination cursor-based, RFC 7807 error format, idempotency (Stripe pattern), GraphQL depth/complexity limits, DataLoader N+1 prevention
Seuils : p99 ≤200ms read / ≤500ms write ; max 100 items/page ; OpenAPI spec en sync avec impl

### B2. contracts/CONTRACT-DATABASE-MIGRATIONS.md (NOUVEAU)
Sources : Martin Fowler "Evolutionary Database Design" (martinfowler.com, 2016), AWS Well-Architected, Supabase Migration docs, Flyway docs
Règles : Expand-Contract pattern (Fowler 2016), migration naming (YYYYMMDD_HHMMSS_description.sql), rollback obligatoire, batching >1M rows (1000 rows/batch), CREATE INDEX CONCURRENTLY (zero-downtime), ADD CONSTRAINT NOT VALID + VALIDATE CONSTRAINT
Seuils : migrations <30min pour tables <10M rows ; rollback testé avant production

### B3. contracts/CONTRACT-ERROR-HANDLING.md (NOUVEAU)
Sources : Nielsen NN/G Error Message Guidelines (Nielsen 2001, revisited 2023), React Error Boundaries docs, Next.js error.tsx docs, Google SRE Book Chapter 6
Règles : 4 principes Nielsen (what happened / why / solution / human language), error.tsx + global-error.tsx, error boundaries ≥90% des composants interactifs, aucune stack trace visible utilisateur, logging Sentry avec contexte complet, retry UI avec backoff exponentiel
Seuils : error rate <0.1% par session (Google SRE SLO) ; time to error display <200ms (Nielsen 1993)

### B4. audits/AUDIT-RESILIENCE.md (NOUVEAU)
Format : identique aux autres audits (score /100, checkboxes avec points)
Sections : Circuit Breaker (25pts), Retry+Backoff (20pts), Graceful Degradation (20pts), Health Checks (15pts), Timeouts (10pts), Dependency Isolation (10pts)
Seuil : ≥70 recommandé

### B5. agents/AGENT-RESILIENCE-AUDIT.md (NOUVEAU)
Format : frontmatter (description + tools), 4 niveaux de vérification, scoring, output format
Source : CONTRACT-RESILIENCE.md + AUDIT-RESILIENCE.md (le nouveau)

### B6. scripts/init-project.sh
- Ajouter CONTRACT-API-DESIGN à : nextjs, nextjs-supabase, nextjs-supabase-ai, python, fullstack
- Ajouter CONTRACT-DATABASE-MIGRATIONS à : nextjs-supabase, nextjs-supabase-ai, fullstack
- Ajouter CONTRACT-ERROR-HANDLING à : tous les stacks sauf la liste exclue
- Ajouter AUDIT-RESILIENCE aux AUDITS_TO_INCLUDE pertinents

### B7. scripts/verify-kit.sh
- Ajouter les 5 nouveaux fichiers à REQUIRED_FILES[]
- Mettre à jour le header comment (nombres de fichiers)

---

## Équipe C — Fix couche automation
**Fichiers exclusifs :** `hooks/hook-no-secrets.sh`, `templates/settings.json`, `agents/AGENT-SECURITY-AUDIT.md`, `agents/AGENT-PERFORMANCE-AUDIT.md`, `agents/AGENT-ACCESSIBILITY-AUDIT.md`, `workflows/WORKFLOW-PRE-DEPLOYMENT.md`, `workflows/WORKFLOW-NEW-FEATURE.md`

### C1. hooks/hook-no-secrets.sh
Ajouter les patterns manquants :
- `sk_live_[a-zA-Z0-9_]+` / `sk_test_[a-zA-Z0-9_]+` / `rk_live_[a-zA-Z0-9_]+` (Stripe)
- `AKIA[0-9A-Z]{16}` (AWS Access Key ID)
- `ghp_[a-zA-Z0-9]{36}` / `github_pat_[a-zA-Z0-9_]+` (GitHub PAT)
- `sk-ant-[a-zA-Z0-9-]+` (Anthropic API key)
- `npm_[a-zA-Z0-9]+` (npm auth token)
Ajouter un check stdin vide pour éviter les échecs silencieux

### C2. templates/settings.json
Déplacer `hook-build-before-commit.sh` de PreToolUse(Bash/git commit) vers PreToolUse(Bash/git push) — avec commentaire explicatif (performance : 40s/commit bloque le workflow)

### C3. agents/AGENT-SECURITY-AUDIT.md
Ajouter en Level 2 :
- 2.8 : CSRF via SameSite=Strict/Lax cookies (OWASP CSRF Prevention Cheat Sheet)
- 2.9 : Rate limiting sur routes sensibles (10 req/min par IP pour routes auth — Upstash ou middleware)
- 2.10 : Content Security Policy header (OWASP CSP Cheat Sheet — default-src 'self')
Ajouter en Level 3 :
- 3.6 : OWASP LLM01:2023 Prompt Injection — user input jamais directement dans system prompt
Mettre à jour le scoring (+15 points distribués sur les nouvelles vérifications)

### C4. agents/AGENT-PERFORMANCE-AUDIT.md
Ajouter en Level 2 :
- FCP (First Contentful Paint) ≤1.8s p75 (Google web.dev — "Good" threshold)
- TTI (Time to Interactive) ≤3.8s p75 (Google Lighthouse v10)
- TTFB ≤800ms p75 (Google CrUX — "Good" threshold)
Mettre à jour le scoring

### C5. agents/AGENT-ACCESSIBILITY-AUDIT.md
Ajouter en Level 2 :
- Interactive divs/spans role="button" → tabIndex="0" + keyboard handlers obligatoires (WCAG 2.1.1)
- Form groups → `<fieldset>/<legend>` (WCAG 1.3.1)
Ajouter en Level 4 :
- Color blindness simulation (Sim Daltonism, DevTools vision deficiencies emulator — deuteranopia, protanopia)

### C6. workflows/WORKFLOW-PRE-DEPLOYMENT.md
Ajouter après le Quick Gate :
- **Database Migration Gate** : migrations testées en staging + rollback scripts testés. Observable Truth : `supabase db diff` output is empty (no pending migrations) OR all migrations documented in CHANGELOG.md
- **Feature Flag Gate** : nouvelles features derrière flags si >10% de changement de surface. Observable Truth : feature flag config exists in environment OR PR confirms no rollout risk
- **Smoke Test Gate** : core user journeys automatisés. Observable Truth : `npm run test:e2e` exits 0 OR smoke test checklist manually verified and documented

### C7. workflows/WORKFLOW-NEW-FEATURE.md
Corriger les 3 Observable Truths subjectifs :
- Gate 0 : "Appetite = durée spécifique en jours/semaines (ex: '2 weeks'), pas 'TBD' ou 'open-ended'"
- Gate 3 : "Rapport d'audit existe dans `audits/reports/YYYY-MM-DD-[feature].md` OU tous les domaines scorés explicitement dans la description de la PR avec les seuils atteints"
- Gate 2 : "Tous les contrats actifs référencés dans CLAUDE.md sont vérifiés — pas seulement ceux pour lesquels des violations ont été trouvées"

---

## Équipe D — Documentation & stratégie
**Fichiers exclusifs :** `README.md`, `AUDIT-INDEX.md`, `DISCOVERY-GUIDE.md`, `METHODOLOGY.md`, `CONTRIBUTING.md`

### D1. README.md
- Supprimer/remplacer le claim `51→85` (violation règle d'or) → message factuel et vérifiable
- Ajouter un "Stack Decision Tree" entre Quick start et "How it works"
- Renforcer le positionnement "brand strategy + EU compliance" — c'est le vrai avantage concurrentiel
- Mentionner les 3 nouveaux contrats (API Design, Database Migrations, Error Handling)
- Mettre à jour les compteurs de fichiers dans les badges et tableaux

### D2. AUDIT-INDEX.md
- Ajouter section "Weighting Methodology" justifiant Security 22%, Performance 18%, etc.
- Corriger nomenclature CLIENT-HANDOFF / COMPETITIVE-AUDIT (ce sont des frameworks, pas des audits)
- Ajouter AUDIT-RESILIENCE à la table des audits pondérés

### D3. DISCOVERY-GUIDE.md
- Ajouter une section "Worked Example" : feature "User Signup Form" de Research → Contract → Code → Audit
- 2-3 pages avec les 4 étapes concrètes, scores d'audit, et résultats attendus

### D4. METHODOLOGY.md
- Ajouter section "Standards Update Process" : quand OWASP/WCAG/Apple HIG/CWV changent, comment et dans quel délai mettre à jour les contrats

### D5. CONTRIBUTING.md
- Ajouter requirement : tout nouveau contrat doit inclure `> **Last validated:** YYYY-MM-DD` en dernière ligne
- Ajouter requirement : toute mise à jour de contrat doit mettre à jour cette date

---

## Vérification finale

Après que les 4 équipes ont terminé :
```bash
bash scripts/verify-kit.sh --verbose  # → 0 errors, 0 warnings
bash scripts/init-project.sh --name test --stack fullstack --path /tmp/test-kit
# → tous les nouveaux contrats présents dans /tmp/test-kit/docs/contracts/
```

---

## Score cible post-amélioration

| Dimension | Score attendu |
|-----------|---------------|
| Rigueur des standards | 97/100 |
| Couche automation | 88/100 |
| Stratégie + DX | 93/100 |
| Cohérence interne | 98/100 |
| **Global** | **94/100** |
