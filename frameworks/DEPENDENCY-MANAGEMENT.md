# Framework — Gestion des Dépendances

> Sources : Snyk State of Open Source Security 2024, GitHub Dependabot Documentation,
> Renovate Bot Documentation (Mend.io), OWASP A06:2021 Vulnerable and Outdated Components,
> CISA Known Exploited Vulnerabilities Catalog, NIST National Vulnerability Database.
> À utiliser : setup initial de tout projet + revue mensuelle + configuration CI/CD.

---

## Pourquoi c'est critique

**OWASP A06:2021 — Vulnerable and Outdated Components** est dans le Top 10 OWASP depuis 2021.
Un package NPM vulnérable peut compromettre toute l'application, même si le code SQWR est parfait.

**Snyk 2024 :** 52% des équipes ne respectent pas leurs SLA de vulnérabilités sur les dépendances.
74% définissent des SLA qu'elles ne tiennent pas. La conséquence : des projets déployés avec
des CVEs critiques connus, accessibles à n'importe qui via la NVD.

**La réalité SQWR :** Un projet Next.js + Supabase lancé en janvier 2026 peut avoir
15+ CVEs critiques en mars 2026 sans que personne ne le sache, si aucun process n'est en place.

---

## Partie 1 — Renovate vs Dependabot

### Comparatif

| Critère | Renovate Bot | Dependabot |
|---------|-------------|-----------|
| **Intégration GitHub** | Via App GitHub (setup 5 min) | Natif (0 setup requis) |
| **Config** | `renovate.json` (flexible, complexe) | `.github/dependabot.yml` (simple) |
| **Groupement de PRs** | Oui — grouper par catégorie (réduire bruit ×10) | Limité |
| **Auto-merge** | Configurable finement | Basique (via GitHub Actions) |
| **Dependency Dashboard** | Issue GitHub avec vue globale | Non |
| **Écosystèmes** | npm, pip, Docker, Actions, Helm, etc. | npm, pip, Docker, Actions, etc. |
| **Coût** | Gratuit (open source) | Gratuit (natif GitHub) |
| **Complexité de config** | Élevée | Faible |
| **Idéal pour** | Monorepo, équipes multiples, fine-tuning | Projets solo, setup rapide |

### Recommandation SQWR

**Dependabot** pour tous les projets SQWR. Raisons :
- Zéro configuration externe requise — activé depuis GitHub Settings
- Intégré aux GitHub Security Alerts (email automatique sur CVE critique)
- PRs automatiques pour les vulnérabilités critiques sans action manuelle
- Suffisant pour la taille et la structure des projets SQWR (solo, projets séparés)

**Passer à Renovate si** : monorepo avec >5 packages, besoin de groupement sophistiqué,
ou si le bruit des PRs Dependabot devient ingérable.

---

## Partie 2 — Configuration Dependabot pour stack SQWR

### `.github/dependabot.yml` — Template complet

Créer ce fichier à la racine du repo :

```yaml
# .github/dependabot.yml
# Mise à jour automatique des dépendances via Dependabot
# Source : docs.github.com/en/code-security/dependabot

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
      - "samuelbaudon"           # Remplacer par le username GitHub du projet
    commit-message:
      prefix: "chore"
      prefix-development: "chore"
      include: "scope"
    # Ignorer les major versions — review manuelle requise (risque breaking change)
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

**Notes de configuration :**
- `interval: weekly` = suffisant pour SQWR (`daily` génère trop de bruit)
- `open-pull-requests-limit: 5` = évite la paralysie par accumulation de PRs
- `ignore: semver-major` = les breaking changes (v1→v2) doivent être reviewés manuellement + ADR si significatif

### Activation sur GitHub

1. GitHub repo → Settings → Security → Code security and analysis
2. "Dependabot alerts" → Enable
3. "Dependabot security updates" → Enable
4. "Dependabot version updates" → Enable (nécessite `.github/dependabot.yml`)

---

## Partie 3 — SLA de Réponse aux CVEs (SQWR)

Standards basés sur la classification CVSS + guidelines CISA :

| Sévérité | CVSS Score | Délai maximum | Action requise |
|----------|-----------|---------------|----------------|
| **P0 — Critical** | 9.0 – 10.0 | **< 48 heures** | Patcher et déployer en urgence. Notifier les parties prenantes si données utilisateurs à risque. |
| **P1 — High** | 7.0 – 8.9 | **< 1 semaine** | PR créée dans les 24h, déployée dans la semaine. |
| **P2 — Medium** | 4.0 – 6.9 | **< 4 semaines** | Inclure dans le prochain sprint de maintenance. |
| **P3 — Low** | 0.1 – 3.9 | **Backlog** | Traiter lors de la maintenance mensuelle. |

**Règle SQWR :** toute vulnérabilité P0 bloque le déploiement de nouvelles features
jusqu'à résolution. Le SLO de production (voir `frameworks/SLO-TEMPLATE.md`) intègre
la résolution de CVEs P0 comme incident SEV-2.

---

## Partie 4 — GitHub Actions Security Workflow

Intégrer l'audit de sécurité dans la CI/CD :

```yaml
# .github/workflows/security.yml
name: Security Audit

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  schedule:
    # Audit hebdomadaire automatique — lundi 9h UTC
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

      # Bloquant — exit 1 si vulnérabilité critique
      - name: Security audit (critical — bloque le merge)
        run: npm audit --audit-level=critical

      # Non-bloquant — génère un rapport pour suivi
      - name: Security audit (high — rapport uniquement)
        run: npm audit --audit-level=high || echo "⚠️ Vulnérabilités High détectées — review requise"
        continue-on-error: true
```

**Comportement :**
- Vulnérabilité **Critical** → le workflow échoue → merge bloqué (gate obligatoire)
- Vulnérabilité **High** → le workflow passe mais génère un avertissement visible
- Aucune vulnérabilité → workflow passe, tout est vert

---

## Partie 5 — Workflow mensuel de maintenance

### Checklist mensuelle (1× par mois, environ 30 min)

- [ ] `npm audit` lancé sur chaque projet actif — rapport consulté
- [ ] Dependabot PRs reviewées : merger les patch/minor sûres, documenter les skips
- [ ] `npm outdated` consulté — identifier les packages très en retard (>6 mois)
- [ ] Packages avec CVE P0/P1 non traités patchés sans exception
- [ ] Si major update disponible sur une dépendance critique → créer ADR pour décider

### Commandes de diagnostic

```bash
# ─── Audit de sécurité ─────────────────────────────────────────
# Rapport complet (JSON pour parsing)
npm audit --json

# Uniquement les critiques (exit code 1 si trouvé)
npm audit --audit-level=critical

# Uniquement les high+
npm audit --audit-level=high

# ─── Vue des dépendances ───────────────────────────────────────
# Packages outdated avec versions disponibles
npm outdated

# ─── Mises à jour ─────────────────────────────────────────────
# Mise à jour sécurisée (patch + minor uniquement — respecte semver)
npm update

# Force update d'un package spécifique vers une version précise
npm install [package]@[version]

# Force update vers la dernière version (attention aux breaking changes)
npm install [package]@latest
```

---

## Checklist Setup Initial (nouveau projet)

- [ ] `.github/dependabot.yml` créé et poussé sur le repo
- [ ] GitHub Security Alerts activé (Settings → Security → Enable tout)
- [ ] `npm audit --audit-level=critical` dans le workflow CI/CD (bloquant)
- [ ] `npm audit` propre au launch (zéro vulnérabilité critique et high au démarrage)
- [ ] Label `dependencies` créé sur le repo (pour filtrer les PRs Dependabot)

---

## Sources

| Référence | Lien |
|-----------|------|
| OWASP A06:2021 — Vulnerable Components | owasp.org/Top10/A06_2021-Vulnerable_and_Outdated_Components |
| GitHub Dependabot Documentation | docs.github.com/en/code-security/dependabot |
| Renovate Bot — Mend.io | docs.renovatebot.com/bot-comparison |
| Snyk State of Open Source Security 2024 | snyk.io/reports/open-source-security |
| NIST National Vulnerability Database | nvd.nist.gov |
| CISA Known Exploited Vulnerabilities | cisa.gov/known-exploited-vulnerabilities-catalog |
