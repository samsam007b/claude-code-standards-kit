# Contributing — [NOM DU PROJET]

> Standards : Conventional Commits 1.0.0, SemVer 2.0.0, Branch naming SQWR.
> Ce guide s'applique aux contributions humaines ET aux contributions assistées par IA (Claude Code).

---

## Mise en place locale

```bash
# Cloner le repo
git clone [URL_REPO]
cd [nom-du-projet]

# Installer les dépendances
npm install

# Copier les variables d'environnement
cp .env.example .env.local
# Remplir .env.local avec les valeurs de développement

# Lancer en développement
npm run dev

# Vérifier que tout fonctionne
npm run build
npm run lint
npm run test   # si des tests existent
```

**Prérequis :**
- Node.js ≥ 20
- npm ≥ 10
- Accès aux services (Supabase, etc.) — demander à [NOM_CONTACT]

---

## Conventions de branches

Format : `[type]/[scope]-[description-courte]`

```bash
# Features
feat/auth-social-login
feat/dashboard-analytics
feat/profile-photo-upload

# Fixes
fix/button-hover-mobile
fix/auth-session-expiry
fix/image-lazy-load

# Maintenance
chore/update-dependencies
chore/setup-github-actions

# Documentation
docs/api-endpoints
docs/deployment-guide

# Releases
release/v1.2.0
```

**Règles :**
- Tirets uniquement (pas d'underscores, pas de majuscules)
- Description courte : 2-4 mots
- Scope = le module ou domaine concerné

---

## Conventional Commits

Tous les commits doivent suivre [Conventional Commits 1.0.0](https://conventionalcommits.org).

### Format

```
<type>[scope optionnel]: <description>

[corps optionnel]

[footer(s) optionnel(s)]
```

### Types et impact SemVer

| Type | Usage | Impact SemVer | Exemple |
|------|-------|--------------|---------|
| `feat` | Nouvelle fonctionnalité | **MINOR** | `feat(auth): ajouter connexion Google OAuth` |
| `fix` | Correction de bug | **PATCH** | `fix(button): corriger hover sur mobile` |
| `docs` | Documentation uniquement | — | `docs: mettre à jour le README` |
| `style` | Formatting, espaces, semicolons (pas de logique) | — | `style: reformater les imports` |
| `refactor` | Refactoring (ni feat ni fix) | — | `refactor(auth): extraire helper validateToken` |
| `perf` | Amélioration de performance | **PATCH** | `perf(images): implémenter lazy loading` |
| `test` | Ajout ou correction de tests | — | `test(auth): ajouter tests edge cases logout` |
| `chore` | Maintenance, dépendances, config | — | `chore(deps): mettre à jour Next.js 15.1→15.2` |
| `ci` | Configuration CI/CD | — | `ci: ajouter npm audit dans la pipeline` |

### BREAKING CHANGE — deux syntaxes

**Méthode 1 — `!` avant le `:` :**
```
feat!: refonte complète du système d'authentification
```

**Méthode 2 — footer `BREAKING CHANGE:` :**
```
feat(auth): migrer vers la nouvelle API Supabase Auth

BREAKING CHANGE: La structure des tokens JWT a changé.
Les sessions existantes seront invalidées après déploiement.
Migration requise pour les utilisateurs connectés.
```

Les deux méthodes déclenchent un increment **MAJOR** en SemVer.

### Exemples concrets SQWR

```bash
# Feature
feat(auth): ajouter la connexion Google OAuth2
feat(dashboard): afficher le compteur de vues des annonces izzico
feat(agents): intégrer GPT-4 Turbo pour CozyGrowth agent planning

# Fix
fix(button): corriger l'état hover sur Safari mobile
fix(auth): résoudre la déconnexion automatique après 15 min
fix(images): corriger le ratio d'aspect sur les photos de profil

# Chores
chore(deps): mettre à jour next-auth 4.24.5 → 4.24.7 (CVE-2026-XXXX)
chore(config): ajouter .github/dependabot.yml

# CI
ci: ajouter npm audit --audit-level=critical dans la pipeline

# Breaking
feat!: migrer de Pages Router vers App Router
```

---

## Workflow Pull Request

### Checklist avant d'ouvrir une PR

- [ ] `npm run build` passe sans erreur
- [ ] `npm run lint` passe avec 0 erreur ESLint
- [ ] `npm run test` passe (si des tests existent)
- [ ] Coverage ne régresse pas par rapport à `main`
- [ ] Aucun `console.log` de debug oublié (`/clean-commit`)
- [ ] `npm audit --audit-level=critical` passe
- [ ] CHANGELOG.md mis à jour si la PR introduit une feature ou un fix notable
- [ ] Si breaking change : documenter la migration dans le corps de la PR

### Titre de la PR

Le titre doit suivre le format Conventional Commits :

```
feat(scope): description courte de la feature
fix(scope): description courte du fix
chore: description de la maintenance
```

### Template de description PR

```markdown
## Ce que fait cette PR

[Description en 1-2 phrases — qu'est-ce que ça change pour l'utilisateur ?]

## Type de changement

- [ ] Bug fix (`fix:`)
- [ ] Nouvelle feature (`feat:`)
- [ ] Breaking change (`feat!:` ou `BREAKING CHANGE:`)
- [ ] Documentation (`docs:`)
- [ ] Maintenance (`chore:`)

## Tests effectués

- [ ] Test manuel en local (navigateur)
- [ ] Tests automatiques passent (`npm run test`)
- [ ] Testé sur mobile (DevTools responsive OU device physique)
- [ ] `npm run build` passe

## Screenshots (si changement UI)

[Avant / Après si applicable]

## Notes pour le reviewer

[Contexte supplémentaire, trade-offs, points d'attention]
```

---

## IA-Assisted Contributions

Ce projet utilise Claude Code pour l'assistance au développement. Les contributions
générées ou assistées par IA sont les bienvenues mais doivent respecter ces règles.

### Règles obligatoires pour les contributions IA

**1. Revue ligne par ligne obligatoire**
Ne pas merger du code IA sans l'avoir lu intégralement. Le code peut fonctionner au
premier test tout en contenant des patterns sous-optimaux, des failles de sécurité,
ou des edge cases non gérés.

**2. Checklist sécurité appliquée**
Vérifier le code IA contre `contracts/CONTRACT-SECURITY.md`, section
"AI-Generated Code Review Checklist". Veracode 2025 : 45% du code IA généré contient
des failles de sécurité non visibles au premier run.

**3. Packages vérifiés avant installation**
Tout package NPM suggéré par Claude doit être vérifié sur npmjs.com avant `npm install` :
- Le package existe réellement
- Il a été mis à jour récemment
- Le nombre de téléchargements est cohérent avec sa réputation
- (risque slopsquatting : les LLMs hallucinent des noms de packages inexistants)

**4. Co-author tag dans les commits**
Les commits significativement assistés par IA doivent inclure :
```
Co-Authored-By: Claude Sonnet <noreply@anthropic.com>
```

**5. Le développeur qui merge est responsable**
La mention "généré par IA" ne dispense pas de la revue. Le développeur qui approuve
et merge un PR reste entièrement responsable du code fusionné.

---

## Sources

| Référence | Lien |
|-----------|------|
| Conventional Commits 1.0.0 | conventionalcommits.org/en/v1.0.0 |
| Semantic Versioning 2.0.0 | semver.org |
| Keep a Changelog 1.1.0 | keepachangelog.com/en/1.1.0 |
| Veracode GenAI Code Security 2025 | veracode.com/blog/research/state-of-software-security-genai |
| SQWR AI Code Review Checklist | contracts/CONTRACT-SECURITY.md |
