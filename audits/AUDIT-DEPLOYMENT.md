# Deployment Audit — Pre-Production Gate

> Exhaustive checklist to complete before any production deployment.
> All boxes must be checked before merging to `main`.

---

## 🔴 Blocking — zero exceptions

- [ ] `npm run build` passes without errors
- [ ] `npm run lint` passes with 0 ESLint errors
- [ ] `npm audit --audit-level=critical` passes
- [ ] No debug `console.log` (`grep -r "console.log" src/`)
- [ ] No secret keys in the diff (`git diff main...HEAD`)
- [ ] Environment variables configured in Vercel dashboard
- [ ] `.env.local` NOT committed (check `.gitignore`)

---

## 🟡 Quality — strongly recommended

**Performance:**
- [ ] LCP ≤2.5s on critical pages (PageSpeed Insights)
- [ ] CLS <0.1 on critical pages
- [ ] Lighthouse Performance ≥85
- [ ] Lighthouse SEO ≥90

**Code:**
- [ ] Tests pass (`npm run test`)
- [ ] Coverage does not regress
- [ ] TypeScript strict — no `any` error introduced

**Accessibility:**
- [ ] Lighthouse Accessibility ≥90
- [ ] Contrasts verified on new UI

**SEO:**
- [ ] Metadata (title + description) on all new pages
- [ ] No `ssr: false` added on indexed pages
- [ ] JSON-LD schema updated if site structure was modified

**Release & Dependencies:**
- [ ] CHANGELOG.md updated with changes from this release
- [ ] Full `npm audit` — no open High or Critical vulnerabilities
- [ ] Dependabot PRs reviewed (no pending P0/P1 vulnerabilities)

---

## 🟢 Post-deployment checks (within 30 minutes)

- [ ] Homepage loads correctly
- [ ] Contact form works (real test)
- [ ] Auth flow works (login + logout)
- [ ] Vercel logs without 500 errors
- [ ] Google Search Console: no new critical errors

---

## Quick verification commands

```bash
# Build
npm run build

# Lint + tests
npm run lint && npm run test

# Secrets in diff
git diff main...HEAD | grep -E "(KEY|SECRET|PASSWORD|TOKEN)"

# Forgotten console.log
grep -r "console\.log" src/ --include="*.ts" --include="*.tsx"

# Verify .env.local not committed
git status | grep ".env"
```

---

## If a blocker is overridden without resolution

Document here with date, reason, and remediation plan:

| Date | Blocker overridden | Reason | Plan |
|------|--------------------|--------|------|
| [DD/MM] | [item] | [reason] | [correction planned for] |
