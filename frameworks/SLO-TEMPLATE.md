# Framework — Service Level Objectives (SLO)

> SQWR Project Kit Framework — measurable reliability and error budgets.
> Sources: Google SRE Book (Ch. 4), Google SRE Workbook (Ch. 2).
> Principle: without a definition of "reliable enough", you never know if a service is healthy.

---

## The 3 Core Concepts (Google SRE)

### SLI — Service Level Indicator

What you measure. An SLI is a metric that reflects the user experience.

```
SLI = (good events / total events) × 100%

Ex: SLI uptime = (requests with status 200-499) / (all requests) × 100%
```

### SLO — Service Level Objective

The target. An SLO is the level of reliability you commit to achieving.

```
Ex: SLO = 99.5% of requests return 200-499 over a 30-day window
```

### Error Budget

The tolerance. If SLO = 99.5%, the error budget = 0.5% of allowed downtime.

```
Error budget 99.5% over 30 days = 0.5% × 30 × 24 × 60 min = 216 min = 3h36 of downtime/month
```

**The key insight:** the error budget finances innovation. As long as the budget is not exhausted, the team can deploy new features, take calculated risks, and experiment. If the budget is exhausted → stop features, focus on reliability.

---

## Recommended SLIs by service type

| Service type | SLIs to measure |
|--------------|----------------|
| **Public website (sqwr-site)** | Uptime, LCP, HTTP error rate |
| **Web app ([ClientApp])** | Uptime, auth latency, API error rate |
| **AI agents ([YourProject])** | Uptime, LLM latency, empty/error response rate |
| **REST API** | Availability, p95 latency, 5xx error rate |

---

## SLO Template per project

```markdown
# SLO — [Project Name]

**Service:** [short description]
**Audience:** [end users / clients / internal]
**Measurement window:** 30 rolling days
**Last reviewed:** [DD/MM/YYYY]

---

## Defined SLIs & SLOs

### 1. Availability

| SLI | Definition | SLO Target | Measurement |
|-----|-----------|-----------|-------------|
| Uptime | % of requests with HTTP 200-499 | **99.5%** | Vercel Analytics / UptimeRobot |

Error budget = 0.5% × 30d = **216 min/month** (3h36)

### 2. Latency

| SLI | Definition | SLO Target | Measurement |
|-----|-----------|-----------|-------------|
| LCP p75 | 75th percentile of Largest Contentful Paint | **≤2.5s** | Vercel Speed Insights |
| API latency p95 | 95th percentile of API response time | **≤1s** | Vercel Analytics |

### 3. Quality (if applicable)

| SLI | Definition | SLO Target | Measurement |
|-----|-----------|-----------|-------------|
| Error rate | % of sessions with a JS error | **≤0.5%** | Sentry |
| AI response quality | % of responses without [TO CONFIRM] | **≥95%** | Logs |

---

## Error Budget Policy

| Budget remaining | Action |
|-----------------|--------|
| >50% | ✅ Normal deployments, experimentation allowed |
| 25-50% | ⚠️ Risk review before each deployment |
| <25% | 🔴 Stop non-critical features, focus on stability |
| 0% | ❌ Deployment freeze, postmortem mandatory |

---

## SLO Monitoring

### Recommended SQWR Tools

| Need | Tool | Cost |
|------|-------|------|
| Uptime monitoring | UptimeRobot | Free (5 monitors) |
| RUM (LCP, INP, CLS) | Vercel Speed Insights | Included with Vercel |
| Error tracking | Sentry | Free tier (10k errors/month) |
| Alerts | Slack webhook + Sentry | Included |

### SLO Dashboard (keep up to date)

| Period | Uptime | LCP p75 | Error rate | Budget remaining |
|--------|--------|---------|-----------|-----------------|
| [Current month] | ___% | ___s | ___% | ___% |
| [Month-1] | ___% | ___s | ___% | ___% |
```

---

## Recommended SLOs by SQWR service type

| Service | SLO Uptime | SLO Latency | Justification |
|---------|-----------|------------|--------------|
| **Marketing site (sqwr-site)** | 99.5% | LCP ≤2.5s | Higher tolerance, limited impact |
| **App with auth ([ClientApp])** | 99.9% | Auth ≤500ms | Active users, direct impact |
| **AI agents ([YourProject])** | 99.5% | LLM ≤5s | LLMs are slow by nature |
| **Public API** | 99.9% | p95 ≤500ms | Technical clients, contractual SLA |

---

## SLO vs SLA — an important distinction

| Concept | Who uses it | Consequences if missed |
|---------|------------|----------------------|
| **SLO** (internal) | The engineering team | Internal processes (feature freeze) |
| **SLA** (contract) | Clients, investors | Contractual penalties, refunds |

**SQWR Rule:** The internal SLO must always be stricter than the contractual SLA.
Ex: If client SLA = 99%, our internal SLO = 99.5%.

---

## Sources

| Reference | Source |
|-----------|--------|
| Google SRE Book — Ch. 4 SLOs | sre.google/sre-book/service-level-objectives |
| Google SRE Workbook — SLOs | sre.google/workbook/implementing-slos |
| Google SRE — Error Budget Policy | sre.google/workbook/error-budget-policy |
