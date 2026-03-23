# Framework — Dependency Management

> Sources: Snyk State of Open Source Security 2024, GitHub Dependabot Documentation,
> Renovate Bot Documentation (Mend.io), OWASP A06:2021 Vulnerable and Outdated Components,
> CISA Known Exploited Vulnerabilities Catalog, NIST National Vulnerability Database.
> When to use: initial setup of any project + monthly review + CI/CD configuration.

---

## Why this is critical

**OWASP A06:2021 — Vulnerable and Outdated Components** has been in the OWASP Top 10 since 2021.
A vulnerable NPM package can compromise an entire application, even if the SQWR code itself is perfect.

**Snyk 2024:** 52% of teams do not meet their vulnerability SLAs for dependencies.
74% define SLAs they do not honor. The consequence: projects deployed with
known critical CVEs, publicly accessible via the NVD.

**SQWR reality:** A Next.js + Supabase project launched in January 2026 can have
15+ critical CVEs by March 2026 without anyone knowing, if no process is in place.

---

## Part 1 — Renovate vs Dependabot

### Comparison

| Criteria | Renovate Bot | Dependabot |
|---------|-------------|-----------|
| **GitHub integration** | Via GitHub App (5-min setup) | Native (0 setup required) |
| **Config** | `renovate.json` (flexible, complex) | `.github/dependabot.yml` (simple) |
| **PR grouping** | Yes — group by category (reduce noise ×10) | Limited |
| **Auto-merge** | Finely configurable | Basic (via GitHub Actions) |
| **Dependency Dashboard** | GitHub issue with global view | No |
| **Ecosystems** | npm, pip, Docker, Actions, Helm, etc. | npm, pip, Docker, Actions, etc. |
| **Cost** | Free (open source) | Free (native GitHub) |
| **Config complexity** | High | Low |
| **Ideal for** | Monorepo, multiple teams, fine-tuning | Solo projects, quick setup |

### SQWR Recommendation

**Dependabot** for all SQWR projects. Reasons:
- Zero external configuration required — enabled from GitHub Settings
- Integrated with GitHub Security Alerts (automatic email on critical CVE)
- Automatic PRs for critical vulnerabilities without manual action
- Sufficient for the size and structure of SQWR projects (solo, separate projects)

**Switch to Renovate if**: monorepo with >5 packages, need for sophisticated grouping,
or if Dependabot PR noise becomes unmanageable.

---

## Part 2 — Dependabot Configuration for the SQWR Stack

### `.github/dependabot.yml` — Complete Template

Create this file at the root of the repo:

```yaml
# .github/dependabot.yml
# Automatic dependency updates via Dependabot
# Source: docs.github.com/en/code-security/dependabot

version: 2

updates:
  # ─── npm (Next.js, Supabase, Tailwind, TypeScript, etc.) ─────────────────
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
      time: "09:00"
      timezone: "Europe/Brussels"
    open-pull-requests-limit: 5
    labels:
      - "dependencies"
      - "npm"
    reviewers:
      - "samuelbaudon"           # Replace with the project's GitHub username
    commit-message:
      prefix: "chore"
      prefix-development: "chore"
      include: "scope"
    # Ignore major versions — manual review required (breaking change risk)
    ignore:
      - dependency-name: "*"
        update-types: ["version-update:semver-major"]

  # ─── GitHub Actions ──────────────────────────────────────────────────────
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
      day: "monday"
      time: "09:00"
      timezone: "Europe/Brussels"
    labels:
      - "dependencies"
      - "github-actions"
    commit-message:
      prefix: "ci"
```

**Configuration notes:**
- `interval: weekly` = sufficient for SQWR (`daily` generates too much noise)
- `open-pull-requests-limit: 5` = avoids paralysis from accumulating PRs
- `ignore: semver-major` = breaking changes (v1→v2) must be reviewed manually + ADR if significant

### Activation on GitHub

1. GitHub repo → Settings → Security → Code security and analysis
2. "Dependabot alerts" → Enable
3. "Dependabot security updates" → Enable
4. "Dependabot version updates" → Enable (requires `.github/dependabot.yml`)

---

## Part 3 — CVE Response SLAs (SQWR)

Standards based on CVSS classification + CISA guidelines:

| Severity | CVSS Score | Maximum Deadline | Required Action |
|----------|-----------|----------------|----------------|
| **P0 — Critical** | 9.0 – 10.0 | **< 48 hours** | Patch and deploy urgently. Notify stakeholders if user data is at risk. |
| **P1 — High** | 7.0 – 8.9 | **< 1 week** | PR created within 24h, deployed within the week. |
| **P2 — Medium** | 4.0 – 6.9 | **< 4 weeks** | Include in the next maintenance sprint. |
| **P3 — Low** | 0.1 – 3.9 | **Backlog** | Handle during monthly maintenance. |

**SQWR Rule:** any P0 vulnerability blocks the deployment of new features
until resolution. The production SLO (see `frameworks/SLO-TEMPLATE.md`) includes
P0 CVE resolution as a SEV-2 incident.

---

## Part 4 — GitHub Actions Security Workflow

Integrate security auditing into CI/CD:

```yaml
# .github/workflows/security.yml
name: Security Audit

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  schedule:
    # Automatic weekly audit — Monday 9am UTC
    - cron: '0 9 * * 1'

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      # Blocking — exit 1 if critical vulnerability
      - name: Security audit (critical — blocks merge)
        run: npm audit --audit-level=critical

      # Non-blocking — generates a report for tracking
      - name: Security audit (high — report only)
        run: npm audit --audit-level=high || echo "⚠️ High vulnerabilities detected — review required"
        continue-on-error: true
```

**Behavior:**
- **Critical** vulnerability → workflow fails → merge blocked (mandatory gate)
- **High** vulnerability → workflow passes but generates a visible warning
- No vulnerability → workflow passes, everything is green

---

## Part 5 — Monthly Maintenance Workflow

### Monthly checklist (1× per month, approximately 30 min)

- [ ] `npm audit` run on each active project — report reviewed
- [ ] Dependabot PRs reviewed: merge safe patch/minor updates, document skips
- [ ] `npm outdated` consulted — identify packages significantly behind (>6 months)
- [ ] Packages with unresolved P0/P1 CVEs patched without exception
- [ ] If a major update is available for a critical dependency → create ADR to decide

### Diagnostic commands

```bash
# ─── Security audit ─────────────────────────────────────────────
# Full report (JSON for parsing)
npm audit --json

# Critical vulnerabilities only (exit code 1 if found)
npm audit --audit-level=critical

# High+ only
npm audit --audit-level=high

# ─── Dependency view ────────────────────────────────────────────
# Outdated packages with available versions
npm outdated

# ─── Updates ────────────────────────────────────────────────────
# Safe update (patch + minor only — respects semver)
npm update

# Force update of a specific package to a precise version
npm install [package]@[version]

# Force update to the latest version (watch out for breaking changes)
npm install [package]@latest
```

---

## Initial Setup Checklist (new project)

- [ ] `.github/dependabot.yml` created and pushed to the repo
- [ ] GitHub Security Alerts enabled (Settings → Security → Enable all)
- [ ] `npm audit --audit-level=critical` in the CI/CD workflow (blocking)
- [ ] `npm audit` clean at launch (zero critical and high vulnerabilities at start)
- [ ] `dependencies` label created on the repo (to filter Dependabot PRs)

---

## Sources

| Reference | Link |
|-----------|------|
| OWASP A06:2021 — Vulnerable Components | owasp.org/Top10/A06_2021-Vulnerable_and_Outdated_Components |
| GitHub Dependabot Documentation | docs.github.com/en/code-security/dependabot |
| Renovate Bot — Mend.io | docs.renovatebot.com/bot-comparison |
| Snyk State of Open Source Security 2024 | snyk.io/reports/open-source-security |
| NIST National Vulnerability Database | nvd.nist.gov |
| CISA Known Exploited Vulnerabilities | cisa.gov/known-exploited-vulnerabilities-catalog |
