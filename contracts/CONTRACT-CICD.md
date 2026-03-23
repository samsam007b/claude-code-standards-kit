# Contrat — CI/CD & Automatisation Qualité

> Module de contrat SQWR Project Kit.
> Sources : GitHub Actions docs (docs.github.com/actions), DORA Metrics — Google/DORA Research (dora.dev), Trunk Based Development (trunkbaseddevelopment.com), Conventional Commits (conventionalcommits.org), Semantic Versioning 2.0.0 (semver.org).

---

## Fondements scientifiques

**Les équipes Elite (Google DORA Research, 2023) déploient plusieurs fois par jour et ont un MTTR <1 heure.** Le CI/CD n'est pas un luxe — c'est la différence mesurable entre une équipe capable de livrer de la valeur rapidement et une équipe bloquée par ses propres processus.

**DORA Metrics** (DevOps Research and Assessment, maintenant chez Google Cloud) sont le standard industriel pour mesurer la performance d'une pipeline de livraison :

| Métrique | Elite | High | Medium | Low |
|----------|-------|------|--------|-----|
| **Deployment Frequency** | >1/jour | 1/semaine–1/mois | 1/mois–6 mois | <6 mois |
| **Lead Time for Changes** | <1h | 1j–1 semaine | 1 semaine–1 mois | >1 mois |
| **MTTR** (Mean Time to Restore) | <1h | <1j | 1j–1 semaine | >1 semaine |
| **Change Failure Rate** | <5% | <10% | 10-15% | >15% |

> Source : dora.dev/research/2023

---

## 1. Stratégie de branches — Trunk-Based Development

> Source : trunkbaseddevelopment.com (Paul Hammant, ex-ThoughtWorks)

**Règle : une seule branche principale (`main`), branches de features courtes (<2 jours).**

```
main (branch protégée — jamais de push direct)
 ├── feature/add-auth    → merge < 2 jours → delete
 ├── fix/button-focus    → merge < 1 jour  → delete
 └── chore/update-deps   → merge < 1 jour  → delete
```

**Règle de nommage des branches :**
```
feature/<description-courte>   → nouvelle fonctionnalité
fix/<description-courte>       → correction de bug
chore/<description-courte>     → maintenance (deps, config)
docs/<description-courte>      → documentation
refactor/<description-courte>  → refactoring sans changement de comportement
```

**Branch protection rules (GitHub Settings → Branches) :**
```yaml
# À configurer dans GitHub ou via terraform/code
Require pull request before merging: true
  Required approvals: 1
  Dismiss stale reviews: true
Require status checks to pass:
  - ci/lint
  - ci/typecheck
  - ci/test
Require branches to be up to date: true
Restrict pushes to: main (aucun push direct)
```

---

## 2. Commits — Conventional Commits

> Source : Conventional Commits 1.0.0 (conventionalcommits.org)
> Utilisé par : Angular, Electron, VS Code, Next.js

```
<type>(<scope>): <description>

[body optionnel]

[footer optionnel]
```

**Types autorisés :**

| Type | Usage | Déclenche |
|------|-------|-----------|
| `feat` | Nouvelle fonctionnalité | Minor version bump (SemVer) |
| `fix` | Correction de bug | Patch version bump |
| `chore` | Maintenance, deps, config | Aucun bump |
| `docs` | Documentation seule | Aucun bump |
| `refactor` | Refactoring sans changement comportement | Aucun bump |
| `perf` | Amélioration de performance | Patch bump |
| `test` | Ajout ou correction de tests | Aucun bump |
| `ci` | Changements CI/CD | Aucun bump |
| `BREAKING CHANGE` | Rupture de compatibilité | Major version bump |

```bash
# Exemples corrects
feat(auth): add Google OAuth login
fix(button): restore focus outline on keyboard nav
chore(deps): update next from 14.1.0 to 14.2.0
feat(api)!: remove deprecated v1 endpoints  # BREAKING CHANGE
```

---

## 3. GitHub Actions — Workflows

> Source : GitHub Actions docs (docs.github.com/actions)

### Workflow PR (qualité avant merge)

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
        run: npm run build  # vérifie que le build ne casse pas
```

### Workflow déploiement (main → production)

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

      # Vercel gère le déploiement via son intégration GitHub native
      # Ce job peut aussi appeler vercel CLI si besoin de contrôle fin
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
```

### Secrets GitHub requis

```
VERCEL_TOKEN       → Settings → Secrets → Actions
VERCEL_ORG_ID      → vercel.json ou Vercel dashboard
VERCEL_PROJECT_ID  → vercel.json ou Vercel dashboard
```

**Règle absolue : aucun secret dans le code, dans les logs, ou dans les variables d'environnement en clair dans les workflows.**

---

## 4. Pre-commit hooks — Qualité locale avant push

> Source : lint-staged (github.com/lint-staged/lint-staged), Husky (typicode.github.io/husky)

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

**Ce que les hooks locaux ne remplacent pas :** la CI reste obligatoire. Les hooks locaux peuvent être skippés avec `--no-verify`. La CI est la source de vérité.

---

## 5. Preview Deployments — Vercel

> Source : Vercel docs — Preview Deployments (vercel.com/docs/deployments/preview-deployments)

Chaque PR génère automatiquement une URL de preview unique via l'intégration GitHub native de Vercel. Configuration dans `vercel.json` :

```json
{
  "github": {
    "autoJobCancelation": true
  }
}
```

**Workflow de review avec previews :**
1. PR ouverte → Vercel génère `https://projet-git-feature-xxx.vercel.app`
2. Reviewer teste sur l'URL de preview (pas localhost)
3. Tests passent → merge → déploiement production automatique

---

## 6. Semantic Versioning

> Source : Semantic Versioning 2.0.0 — semver.org

```
MAJOR.MINOR.PATCH
  │      │     └── Fix bug, pas de changement API
  │      └──────── Nouvelle feature, rétrocompatible
  └─────────────── Breaking change (incompatible avec version précédente)

Exemples :
  1.0.0 → 1.0.1  : bugfix
  1.0.1 → 1.1.0  : nouvelle fonctionnalité
  1.1.0 → 2.0.0  : breaking change
```

**Avec Conventional Commits + semantic-release :**
```bash
npm install --save-dev semantic-release @semantic-release/changelog @semantic-release/git
```

`semantic-release` lit les commits depuis le dernier tag, détermine automatiquement le prochain numéro de version, met à jour `CHANGELOG.md` et crée le tag Git.

---

## 7. Variables de scripts package.json

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

**`npm run ci` doit passer à 0 erreur avant tout merge.**

---

## Checklist pré-déploiement CI/CD

### Bloquants

- [ ] Branch protection activée sur `main` (PR + CI obligatoire)
- [ ] Workflow CI configuré (lint + typecheck + test + build)
- [ ] Aucun secret dans le code (utiliser GitHub Secrets)
- [ ] `npm run ci` passe à 0 erreur en local

### Importants

- [ ] Conventional Commits respectés (vérifier avec `commitlint`)
- [ ] Pre-commit hooks configurés (lint-staged + husky)
- [ ] Preview deployments actifs sur chaque PR
- [ ] Workflow de déploiement automatique sur merge `main`

### Souhaitables

- [ ] `semantic-release` configuré (versioning automatique)
- [ ] DORA metrics instrumentées (via GitHub Insights ou LinearB)
- [ ] Notifications Slack/email sur déploiement échoué

---

## Sources

| Référence | Lien |
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
