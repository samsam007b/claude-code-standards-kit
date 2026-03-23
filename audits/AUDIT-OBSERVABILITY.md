# Audit Observabilité & Fiabilité

> Basé sur Google SRE Book, OpenTelemetry, Sentry Best Practices.
> Score : /100 | Seuil recommandé : ≥70

---

## Section 1 — Logging structuré (10 points)

- [ ] Logs en format JSON structuré (pas de `console.log` string brut) ............. (4)
- [ ] Niveaux de log utilisés correctement (debug/info/warn/error/fatal) ........... (3)
- [ ] Aucune donnée PII dans les logs (email, password, tokens) ..................... (3)

**Vérification rapide :**
```bash
# Chercher les console.log non structurés
grep -r "console\.log\|print(" src/ --include="*.ts" --include="*.tsx" --include="*.py"
```

**Sous-total : /10**

---

## Section 2 — Error Tracking (20 points)

- [ ] Sentry (ou équivalent) configuré avec DSN ..................................... (8)
- [ ] Source maps uploadés (erreurs lisibles, pas minifiées) ........................ (4)
- [ ] Tags d'environnement configurés (production/staging/development) .............. (4)
- [ ] Alertes Sentry configurées (error rate > seuil → notification) ................ (4)

**Vérification :**
```bash
# Vérifier la présence de la config Sentry
ls sentry.client.config.ts sentry.server.config.ts sentry.edge.config.ts 2>/dev/null
grep -r "NEXT_PUBLIC_SENTRY_DSN\|SENTRY_DSN" .env.example
```

**Sous-total : /20**

---

## Section 3 — Performance Monitoring / RUM (20 points)

- [ ] Real User Monitoring configuré (Vercel Speed Insights ou équivalent) .......... (8)
- [ ] LCP mesuré sur les pages critiques (valeur réelle, pas Lighthouse local) ...... (6)
- [ ] INP mesuré (interactivité réelle utilisateurs) ................................ (3)
- [ ] Alertes sur régressions CWV (comparaison semaine précédente) .................. (3)

**Valeurs mesurées :**

| Métrique | Valeur actuelle | Seuil cible | OK ? |
|----------|----------------|-------------|------|
| LCP (p75) | ___s | ≤2.5s | |
| INP (p75) | ___ms | ≤200ms | |
| CLS (p75) | ___ | <0.1 | |

**Sous-total : /20**

---

## Section 4 — Backup & Disaster Recovery (20 points)

- [ ] PITR Supabase activé (ou export automatique configuré) ........................ (8)
- [ ] Procédure de restauration documentée (et testée au moins une fois) ............ (8)
- [ ] Contacts d'urgence définis et accessibles (Supabase support, Vercel support) .. (4)

**Vérification :**
```bash
# Vérifier la présence d'une procédure DR
ls docs/disaster-recovery.md docs/runbook.md 2>/dev/null || echo "MANQUANT"
```

**Sous-total : /20**

---

## Section 5 — SLO & Monitoring (30 points)

- [ ] SLI définis (uptime, latence, error rate) ..................................... (10)
- [ ] SLO documentés avec cibles numériques ......................................... (8)
- [ ] Error budget calculé et suivi ................................................. (6)
- [ ] Dashboard de monitoring accessible (Vercel, UptimeRobot, ou équivalent) ....... (6)

**SLO actuels :**

| SLI | Cible SLO | Mesure actuelle | Budget restant |
|-----|-----------|-----------------|---------------|
| Uptime | ___% | ___% | ___% |
| API latence p95 | ≤___ms | ___ms | N/A |
| Error rate | ≤___% | ___% | ___% |

**Sous-total : /30**

---

## Score total : /100

| Section | Score | /Total |
|---------|-------|--------|
| Logging structuré | | /10 |
| Error Tracking | | /20 |
| Performance Monitoring | | /20 |
| Backup & DR | | /20 |
| SLO & Monitoring | | /30 |
| **TOTAL** | | **/100** |

---

## Outils recommandés

| Besoin | Outil | Plan |
|--------|-------|------|
| Error tracking | Sentry | Free tier (10k erreurs/mois) |
| RUM | Vercel Speed Insights | Inclus Vercel |
| Uptime | UptimeRobot | Free (5 moniteurs) |
| Backup | Supabase PITR | Pro plan requis |
| SLO dashboard | Grafana Cloud | Free tier |

---

## Sources de référence

- Google SRE Book — Monitoring Distributed Systems : sre.google/sre-book/monitoring-distributed-systems
- OpenTelemetry : opentelemetry.io/docs
- Sentry Next.js : docs.sentry.io/platforms/javascript/guides/nextjs
- Vercel Speed Insights : vercel.com/docs/speed-insights
