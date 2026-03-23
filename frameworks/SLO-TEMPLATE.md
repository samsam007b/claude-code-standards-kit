# Framework — Service Level Objectives (SLO)

> Framework SQWR Project Kit — fiabilité mesurable et error budgets.
> Sources : Google SRE Book (Ch. 4), Google SRE Workbook (Ch. 2).
> Principe : sans définition de "assez fiable", on ne sait jamais si le service est en bonne santé.

---

## Les 3 concepts fondamentaux (Google SRE)

### SLI — Service Level Indicator

Ce qu'on mesure. Un SLI est une métrique qui reflète l'expérience utilisateur.

```
SLI = (événements bons / total d'événements) × 100%

Ex: SLI uptime = (requêtes avec status 200-499) / (toutes les requêtes) × 100%
```

### SLO — Service Level Objective

La cible. Un SLO est le niveau de fiabilité qu'on s'engage à atteindre.

```
Ex: SLO = 99.5% des requêtes retournent 200-499 par fenêtre de 30 jours
```

### Error Budget

La tolérance. Si SLO = 99.5%, l'error budget = 0.5% de downtime autorisé.

```
Error budget 99.5% sur 30 jours = 0.5% × 30 × 24 × 60 min = 216 min = 3h36 de downtime/mois
```

**L'insight clé :** l'error budget finance l'innovation. Tant que le budget n'est pas épuisé, l'équipe peut déployer des nouvelles features, prendre des risques calculés, et expérimenter. Si le budget est épuisé → stop features, focus fiabilité.

---

## SLIs recommandés par type de service

| Type de service | SLIs à mesurer |
|----------------|---------------|
| **Site web public (sqwr-site)** | Uptime, LCP, taux d'erreur HTTP |
| **App web (izzico)** | Uptime, latence auth, taux d'erreur API |
| **Agents IA (CozyGrowth)** | Uptime, latence LLM, taux de réponses vides/erreur |
| **API REST** | Disponibilité, latence p95, taux d'erreur 5xx |

---

## Template SLO par projet

```markdown
# SLO — [Nom du projet]

**Service :** [description courte]
**Audience :** [utilisateurs finaux / clients / internes]
**Fenêtre de mesure :** 30 jours glissants
**Dernière révision :** [JJ/MM/AAAA]

---

## SLIs & SLOs définis

### 1. Disponibilité

| SLI | Définition | SLO cible | Mesure |
|-----|-----------|-----------|--------|
| Uptime | % de requêtes avec HTTP 200-499 | **99.5%** | Vercel Analytics / UptimeRobot |

Error budget = 0.5% × 30j = **216 min/mois** (3h36)

### 2. Latence

| SLI | Définition | SLO cible | Mesure |
|-----|-----------|-----------|--------|
| LCP p75 | 75e percentile du Largest Contentful Paint | **≤2.5s** | Vercel Speed Insights |
| API latence p95 | 95e percentile du temps de réponse API | **≤1s** | Vercel Analytics |

### 3. Qualité (si applicable)

| SLI | Définition | SLO cible | Mesure |
|-----|-----------|-----------|--------|
| Error rate | % de sessions avec une erreur JS | **≤0.5%** | Sentry |
| AI response quality | % de réponses sans [À CONFIRMER] | **≥95%** | Logs |

---

## Error Budget Policy

| Budget restant | Action |
|---------------|--------|
| >50% | ✅ Déploiements normaux, expérimentation autorisée |
| 25-50% | ⚠️ Revue des risques avant chaque déploiement |
| <25% | 🔴 Stop features non-critiques, focus stabilité |
| 0% | ❌ Freeze déploiements, postmortem obligatoire |

---

## Monitoring SLO

### Outils recommandés SQWR

| Besoin | Outil | Coût |
|--------|-------|------|
| Uptime monitoring | UptimeRobot | Gratuit (5 moniteurs) |
| RUM (LCP, INP, CLS) | Vercel Speed Insights | Inclus Vercel |
| Error tracking | Sentry | Free tier (10k erreurs/mois) |
| Alertes | Slack webhook + Sentry | Inclus |

### Dashboard SLO (à tenir à jour)

| Période | Uptime | LCP p75 | Error rate | Budget restant |
|---------|--------|---------|-----------|---------------|
| [Mois en cours] | ___% | ___s | ___% | ___% |
| [Mois-1] | ___% | ___s | ___% | ___% |
```

---

## SLOs recommandés par type de service SQWR

| Service | SLO Uptime | SLO Latence | Justification |
|---------|-----------|------------|--------------|
| **Site marketing (sqwr-site)** | 99.5% | LCP ≤2.5s | Tolérance plus haute, impact limité |
| **App avec auth (izzico)** | 99.9% | Auth ≤500ms | Utilisateurs actifs, impact direct |
| **Agents IA (CozyGrowth)** | 99.5% | LLM ≤5s | LLMs sont lents par nature |
| **API publique** | 99.9% | p95 ≤500ms | Clients techniques, SLA contractuel |

---

## SLO vs SLA — distinction importante

| Concept | Qui l'utilise | Conséquences si raté |
|---------|--------------|---------------------|
| **SLO** (interne) | L'équipe technique | Processus internes (freeze features) |
| **SLA** (contrat) | Clients, investisseurs | Pénalités contractuelles, remboursements |

**Règle SQWR :** Le SLO interne doit toujours être plus strict que le SLA contractuel.
Ex: Si SLA client = 99%, notre SLO interne = 99.5%.

---

## Sources

| Référence | Source |
|-----------|--------|
| Google SRE Book — Ch. 4 SLOs | sre.google/sre-book/service-level-objectives |
| Google SRE Workbook — SLOs | sre.google/workbook/implementing-slos |
| Google SRE — Error Budget Policy | sre.google/workbook/error-budget-policy |
