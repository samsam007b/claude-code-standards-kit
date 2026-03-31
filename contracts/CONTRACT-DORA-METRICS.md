# CONTRACT-DORA-METRICS — DORA DevOps Performance Metrics

**Version**: 1.0 | **Last validated**: 2026-03-31 | **Applies to**: All software products with continuous delivery pipelines

## Sources

| Standard | Reference | Tier |
|----------|-----------|------|
| DORA State of DevOps Report | Accelerate State of DevOps 2024, Google Cloud/DORA, dora.dev | Tier 1 |
| Accelerate Book | Forsgren, Humble, Kim — Accelerate: Building and Scaling High Performing Technology Organizations, 2018 | Tier 1 |
| DORA Metrics Framework | DORA Research Program, dora.dev/research, 2014-2024 | Tier 1 |
| AI Rework Rate | DORA State of DevOps 2025, AI & DevOps supplement, 2025 | Tier 2 |

---

## Section 1 — Core DORA Metrics (60 points)

The 4 core DORA metrics are empirically validated predictors of software delivery performance.

### 1.1 Deployment Frequency (15 points)

How often the organization deploys to production.

| Performance Level | Frequency | Points |
|------------------|-----------|--------|
| **Elite** | Multiple times per day | 15 |
| **High** | Between once per day and once per week | 12 |
| **Medium** | Between once per week and once per month | 8 |
| **Low** | Less than once per month | 3 |

Measure by: counting production deployments per month / 30.

### 1.2 Lead Time for Changes (15 points)

Time from code commit to running in production.

| Performance Level | Lead Time | Points |
|------------------|-----------|--------|
| **Elite** | Less than 1 hour | 15 |
| **High** | Between 1 day and 1 week | 12 |
| **Medium** | Between 1 week and 1 month | 8 |
| **Low** | More than 1 month | 3 |

Measure by: `git log` timestamps vs deployment timestamps.

### 1.3 Change Failure Rate (15 points)

Percentage of deployments causing a degraded service that requires remediation.

| Performance Level | Rate | Points |
|------------------|------|--------|
| **Elite** | 0-5% | 15 |
| **High** | 5-10% | 12 |
| **Medium** | 10-15% | 8 |
| **Low** | > 15% | 3 |

Measure by: (failed deployments / total deployments) × 100.

### 1.4 Time to Restore Service (15 points)

How long it takes to recover from a failure in production.

| Performance Level | Time to Restore | Points |
|------------------|-----------------|--------|
| **Elite** | Less than 1 hour | 15 |
| **High** | Less than 1 day | 12 |
| **Medium** | Less than 1 week | 8 |
| **Low** | More than 1 week | 3 |

Measure by: incident duration from MTTR tracking or incident log.

---

## Section 2 — AI-Augmented Development Metrics (25 points)

New metrics for teams using AI-assisted development (DORA 2025).

### 2.1 AI Rework Rate (15 points)

Percentage of AI-generated code that requires significant rework (> 30% modification) before merge.

| Performance Level | Rework Rate | Points |
|------------------|-------------|--------|
| **Elite** | < 5% | 15 |
| **High** | 5-15% | 12 |
| **Medium** | 15-30% | 8 |
| **Low** | > 30% | 3 |

Measure by: PR review data — count PRs where AI-generated code was substantially modified.

### 2.2 AI Adoption Coverage (10 points)

- [ ] AI assistance used in code review process (3 points)
- [ ] AI assistance used in test generation (3 points)
- [ ] AI assistance used in documentation (2 points)
- [ ] Team trained on responsible AI use in development (2 points)

---

## Section 3 — Operational Readiness (15 points)

### 3.1 Deployment Pipeline Automation

- [ ] CI/CD pipeline exists and automates build + test on every commit (5 points)
- [ ] Deployment to production is automated (no manual steps) (5 points)
- [ ] Rollback mechanism is documented and tested (5 points)

**Threshold**: ≥ 2 of 3 criteria met = PASS.

---

## Section 4 — Elite Performance Benchmark

To achieve Elite status (target for high-performing teams):
1. All 4 core metrics at Elite tier
2. AI Rework Rate < 5%
3. Fully automated CI/CD pipeline

**Observable truth**: DORA dashboard showing all metrics. Elite teams deploy 973× more frequently than low performers (DORA 2024).

---

## Section 5 — Scoring Grid

| Score | Level | Meaning |
|-------|-------|---------|
| 85-100 | **Elite** | Top-tier DevOps performance |
| 70-84 | **High** | Strong performance — optimize AI metrics |
| 50-69 | **Medium** | Improvement plan required |
| < 50 | **Low** | Critical bottlenecks — address immediately |
