# Contributing — [PROJECT NAME]

> Standards: Conventional Commits 1.0.0, SemVer 2.0.0, SQWR branch naming.
> This guide applies to both human contributions AND AI-assisted contributions (Claude Code).

---

## Local setup

```bash
# Clone the repo
git clone [REPO_URL]
cd [project-name]

# Install dependencies
npm install

# Copy environment variables
cp .env.example .env.local
# Fill in .env.local with development values

# Start in development mode
npm run dev

# Verify everything works
npm run build
npm run lint
npm run test   # if tests exist
```

**Prerequisites:**
- Node.js ≥ 20
- npm ≥ 10
- Access to services (Supabase, etc.) — ask [CONTACT_NAME]

---

## Branch naming conventions

Format: `[type]/[scope]-[short-description]`

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

**Rules:**
- Hyphens only (no underscores, no uppercase)
- Short description: 2-4 words
- Scope = the module or domain involved

---

## Conventional Commits

All commits must follow [Conventional Commits 1.0.0](https://conventionalcommits.org).

### Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types and SemVer impact

| Type | Usage | SemVer impact | Example |
|------|-------|--------------|---------|
| `feat` | New feature | **MINOR** | `feat(auth): add Google OAuth login` |
| `fix` | Bug fix | **PATCH** | `fix(button): fix hover state on mobile` |
| `docs` | Documentation only | — | `docs: update README` |
| `style` | Formatting, whitespace, semicolons (no logic) | — | `style: reformat imports` |
| `refactor` | Refactoring (neither feat nor fix) | — | `refactor(auth): extract validateToken helper` |
| `perf` | Performance improvement | **PATCH** | `perf(images): implement lazy loading` |
| `test` | Adding or fixing tests | — | `test(auth): add edge case tests for logout` |
| `chore` | Maintenance, dependencies, config | — | `chore(deps): update Next.js 15.1→15.2` |
| `ci` | CI/CD configuration | — | `ci: add npm audit to pipeline` |

### BREAKING CHANGE — two syntaxes

**Method 1 — `!` before the `:`:**
```
feat!: complete overhaul of the authentication system
```

**Method 2 — `BREAKING CHANGE:` footer:**
```
feat(auth): migrate to the new Supabase Auth API

BREAKING CHANGE: The JWT token structure has changed.
Existing sessions will be invalidated after deployment.
Migration required for logged-in users.
```

Both methods trigger a **MAJOR** SemVer increment.

### Concrete SQWR examples

```bash
# Feature
feat(auth): add Google OAuth2 login
feat(dashboard): display listing view counter for izzico
feat(agents): integrate GPT-4 Turbo for CozyGrowth agent planning

# Fix
fix(button): fix hover state on Safari mobile
fix(auth): resolve automatic logout after 15 min
fix(images): fix aspect ratio on profile photos

# Chores
chore(deps): update next-auth 4.24.5 → 4.24.7 (CVE-2026-XXXX)
chore(config): add .github/dependabot.yml

# CI
ci: add npm audit --audit-level=critical to pipeline

# Breaking
feat!: migrate from Pages Router to App Router
```

---

## Pull Request workflow

### Checklist before opening a PR

- [ ] `npm run build` passes without errors
- [ ] `npm run lint` passes with 0 ESLint errors
- [ ] `npm run test` passes (if tests exist)
- [ ] Coverage does not regress compared to `main`
- [ ] No forgotten `console.log` debug statements (`/clean-commit`)
- [ ] `npm audit --audit-level=critical` passes
- [ ] CHANGELOG.md updated if the PR introduces a notable feature or fix
- [ ] If breaking change: document the migration in the PR body

### PR title

The title must follow the Conventional Commits format:

```
feat(scope): short description of the feature
fix(scope): short description of the fix
chore: description of the maintenance
```

### PR description template

```markdown
## What this PR does

[Description in 1-2 sentences — what does it change for the user?]

## Type of change

- [ ] Bug fix (`fix:`)
- [ ] New feature (`feat:`)
- [ ] Breaking change (`feat!:` or `BREAKING CHANGE:`)
- [ ] Documentation (`docs:`)
- [ ] Maintenance (`chore:`)

## Tests performed

- [ ] Manual local test (browser)
- [ ] Automated tests pass (`npm run test`)
- [ ] Tested on mobile (DevTools responsive OR physical device)
- [ ] `npm run build` passes

## Screenshots (if UI change)

[Before / After if applicable]

## Notes for the reviewer

[Additional context, trade-offs, points of attention]
```

---

## AI-Assisted Contributions

This project uses Claude Code for development assistance. Contributions
generated or assisted by AI are welcome but must comply with these rules.

### Mandatory rules for AI contributions

**1. Line-by-line review required**
Do not merge AI-generated code without reading it in full. Code may pass on the
first test while containing suboptimal patterns, security vulnerabilities,
or unhandled edge cases.

**2. Security checklist applied**
Review AI-generated code against `contracts/CONTRACT-SECURITY.md`, section
"AI-Generated Code Review Checklist". Veracode 2025: 45% of AI-generated code contains
security vulnerabilities not visible on the first run.

**3. Packages verified before installation**
Any NPM package suggested by Claude must be verified on npmjs.com before `npm install`:
- The package actually exists
- It has been recently updated
- The download count is consistent with its reputation
- (slopsquatting risk: LLMs hallucinate non-existent package names)

**4. Co-author tag in commits**
Commits significantly assisted by AI must include:
```
Co-Authored-By: Claude Sonnet <noreply@anthropic.com>
```

**5. The developer who merges is responsible**
The mention "AI-generated" does not exempt from review. The developer who approves
and merges a PR remains fully responsible for the merged code.

---

## References

| Reference | Link |
|-----------|------|
| Conventional Commits 1.0.0 | conventionalcommits.org/en/v1.0.0 |
| Semantic Versioning 2.0.0 | semver.org |
| Keep a Changelog 1.1.0 | keepachangelog.com/en/1.1.0 |
| Veracode GenAI Code Security 2025 | veracode.com/blog/research/state-of-software-security-genai |
| SQWR AI Code Review Checklist | contracts/CONTRACT-SECURITY.md |
