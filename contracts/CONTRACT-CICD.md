# Contract — CI/CD & Quality Automation

> SQWR Project Kit contract module.
> Sources: GitHub Actions docs (docs.github.com/actions), DORA Metrics — Google/DORA Research (dora.dev), Trunk Based Development (trunkbaseddevelopment.com), Conventional Commits (conventionalcommits.org), Semantic Versioning 2.0.0 (semver.org).

---

## Scientific Foundations

**Elite teams (Google DORA Research, 2023) deploy multiple times per day and have an MTTR <1 hour.** CI/CD is not a luxury — it is the measurable difference between a team capable of delivering value quickly and a team blocked by its own processes.

**DORA Metrics** (DevOps Research and Assessment, now at Google Cloud) are the industry standard for measuring the performance of a delivery pipeline:

| Metric | Elite | High | Medium | Low |
|----------|-------|------|--------|-----|
| **Deployment Frequency** | >1/day | 1/week–1/month | 1/month–6 months | <6 months |
| **Lead Time for Changes** | <1h | 1d–1 week | 1 week–1 month | >1 month |
| **MTTR** (Mean Time to Restore) | <1h | <1d | 1d–1 week | >1 week |
| **Change Failure Rate** | <5% | <10% | 10-15% | >15% |

> Source: dora.dev/research/2023

---

## 1. Branch Strategy — Trunk-Based Development

> Source: trunkbaseddevelopment.com (Paul Hammant, ex-ThoughtWorks)

**Rule: a single main branch (`main`), short feature branches (<2 days).**

```
main (protected branch — never push directly)
 ├── feature/add-auth    → merge < 2 days → delete
 ├── fix/button-focus    → merge < 1 day  → delete
 └── chore/update-deps   → merge < 1 day  → delete
```

**Branch naming rule:**
```
feature/<short-description>   → new functionality
fix/<short-description>       → bug fix
chore/<short-description>     → maintenance (deps, config)
docs/<short-description>      → documentation
refactor/<short-description>  → refactoring without behavior change
```

**Branch protection rules (GitHub Settings → Branches):**
```yaml
# TO FILL IN in GitHub or via terraform/code
Require pull request before merging: true
  Required approvals: 1
  Dismiss stale reviews: true
Require status checks to pass:
  - ci/lint
  - ci/typecheck
  - ci/test
Require branches to be up to date: true
Restrict pushes to: main (no direct push)
```

---

## 2. Commits — Conventional Commits

> Source: Conventional Commits 1.0.0 (conventionalcommits.org)
> Used by: Angular, Electron, VS Code, Next.js

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Allowed types:**

| Type | Usage | Triggers |
|------|-------|-----------|
| `feat` | New feature | Minor version bump (SemVer) |
| `fix` | Bug fix | Patch version bump |
| `chore` | Maintenance, deps, config | No bump |
| `docs` | Documentation only | No bump |
| `refactor` | Refactoring without behavior change | No bump |
| `perf` | Performance improvement | Patch bump |
| `test` | Adding or fixing tests | No bump |
| `ci` | CI/CD changes | No bump |
| `BREAKING CHANGE` | Compatibility break | Major version bump |

```bash
# Correct examples
feat(auth): add Google OAuth login
fix(button): restore focus outline on keyboard nav
chore(deps): update next from 14.1.0 to 14.2.0
feat(api)!: remove deprecated v1 endpoints  # BREAKING CHANGE
```

---

## 3. GitHub Actions — Workflows

> Source: GitHub Actions docs (docs.github.com/actions)

### PR Workflow (quality before merge)

```yaml
# .github/workflows/ci.yml
name: CI

on:
  pull_request:
    branches: [main]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Lint
        run: npm run lint

      - name: Type check
        run: npm run typecheck  # tsc --noEmit

      - name: Tests
        run: npm run test -- --coverage --passWithNoTests

      - name: Build
        run: npm run build  # verifies the build does not break
```

### Deployment Workflow (main → production)

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install & Build
        run: npm ci && npm run build

      # Vercel handles deployment via its native GitHub integration
      # This job can also call the vercel CLI if fine-grained control is needed
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
```

### Required GitHub Secrets

```
VERCEL_TOKEN       → Settings → Secrets → Actions
VERCEL_ORG_ID      → vercel.json or Vercel dashboard
VERCEL_PROJECT_ID  → vercel.json or Vercel dashboard
```

**Absolute Rule: no secrets in code, in logs, or in plaintext environment variables in workflows.**

---

## 4. Pre-Commit Hooks — Local Quality Before Push

> Source: lint-staged (github.com/lint-staged/lint-staged), Husky (typicode.github.io/husky)

```bash
npm install --save-dev husky lint-staged
npx husky init
```

```json
// package.json
{
  "lint-staged": {
    "*.{ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{json,md,css}": [
      "prettier --write"
    ]
  }
}
```

```bash
# .husky/pre-commit
#!/bin/sh
npx lint-staged
```

**What local hooks do not replace:** CI remains mandatory. Local hooks can be skipped with `--no-verify`. CI is the source of truth.

---

## 5. Preview Deployments — Vercel

> Source: Vercel docs — Preview Deployments (vercel.com/docs/deployments/preview-deployments)

Each PR automatically generates a unique preview URL via Vercel's native GitHub integration. Configuration in `vercel.json`:

```json
{
  "github": {
    "autoJobCancelation": true
  }
}
```

**Review workflow with previews:**
1. PR opened → Vercel generates `https://project-git-feature-xxx.vercel.app`
2. Reviewer tests on the preview URL (not localhost)
3. Tests pass → merge → automatic production deployment

---

## 6. Semantic Versioning

> Source: Semantic Versioning 2.0.0 — semver.org

```
MAJOR.MINOR.PATCH
  │      │     └── Bug fix, no API change
  │      └──────── New feature, backward compatible
  └─────────────── Breaking change (incompatible with previous version)

Examples:
  1.0.0 → 1.0.1  : bugfix
  1.0.1 → 1.1.0  : new feature
  1.1.0 → 2.0.0  : breaking change
```

**With Conventional Commits + semantic-release:**
```bash
npm install --save-dev semantic-release @semantic-release/changelog @semantic-release/git
```

`semantic-release` reads commits since the last tag, automatically determines the next version number, updates `CHANGELOG.md`, and creates the Git tag.

---

## 7. package.json Script Variables

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "typecheck": "tsc --noEmit",
    "test": "vitest",
    "test:coverage": "vitest --coverage",
    "test:e2e": "playwright test",
    "ci": "npm run lint && npm run typecheck && npm run test:coverage && npm run build"
  }
}
```

**`npm run ci` must pass with 0 errors before any merge.**

---

## Pre-Deployment CI/CD Checklist

### Blockers

- [ ] Branch protection enabled on `main` (PR + CI mandatory)
- [ ] CI workflow configured (lint + typecheck + test + build)
- [ ] No secrets in code (use GitHub Secrets)
- [ ] `npm run ci` passes with 0 errors locally

### Important

- [ ] Conventional Commits followed (verify with `commitlint`)
- [ ] Pre-commit hooks configured (lint-staged + husky)
- [ ] Preview deployments active on each PR
- [ ] Automatic deployment workflow on `main` merge

### Desirable

- [ ] `semantic-release` configured (automatic versioning)
- [ ] DORA metrics instrumented (via GitHub Insights or LinearB)
- [ ] Slack/email notifications on failed deployment

---

## Sources

| Reference | Link |
|-----------|------|
| GitHub Actions docs | docs.github.com/actions |
| DORA Research 2023 | dora.dev/research/2023 |
| Trunk Based Development | trunkbaseddevelopment.com |
| Conventional Commits 1.0.0 | conventionalcommits.org |
| Semantic Versioning 2.0.0 | semver.org |
| lint-staged | github.com/lint-staged/lint-staged |
| Husky | typicode.github.io/husky |
| Vercel Preview Deployments | vercel.com/docs/deployments/preview-deployments |
| semantic-release | github.com/semantic-release/semantic-release |
