# Contract — Monorepo

> Sources: Vercel Turborepo documentation (turbo.build/repo/docs, 2024), Potvin & Levenberg — "Why Google Stores Billions of Lines of Code in a Single Repository" (ACM Queue, 2016), Changesets (github.com/changesets/changesets, 2024)
> Score: /100 | Recommended threshold: ≥70
> Applies to: projects using a monorepo structure (multiple packages in a single Git repository)

---

## Section 1 — Package Boundaries (30 points)

- [ ] Zero circular dependencies between packages (Turborepo enforces via build graph — turbo.build §Caching) .............. (12)
- [ ] Cross-package imports only via official package.json dependencies — no relative path imports across packages .............. (10)
- [ ] All shared packages export TypeScript declaration files (.d.ts) .............. (8)

**Subtotal: /30**

---

## Section 2 — Build & Cache (25 points)

- [ ] Build cache configured (Turborepo/Nx): target ≥80% remote cache hit rate .............. (12)
- [ ] CI runs only affected packages: `turbo --filter=[HEAD^1]` or `nx affected` (Potvin & Levenberg §Scalability) .............. (8)
- [ ] Root-level scripts: `build`, `test`, `lint` work from repo root .............. (5)

**Subtotal: /25**

---

## Section 3 — Versioning & Publishing (25 points)

- [ ] Versioning uses Changesets or equivalent (no manual version bumping in package.json) .............. (10)
- [ ] Internal packages use `workspace:*` protocol (pnpm) or `*` (npm workspaces) — never hardcoded versions .............. (8)
- [ ] Published packages have separate `package.json` with `main`, `module`, `exports` fields .............. (7)

**Subtotal: /25**

---

## Section 4 — Developer Experience (20 points)

- [ ] Each package's tests run independently (`cd packages/foo && npm test` works) .............. (8)
- [ ] `README.md` at repo root explains the monorepo structure and how to add a package .............. (7)
- [ ] New package creation is scripted (generator or template) .............. (5)

**Subtotal: /20**

---

## Sources

| Reference | Contribution |
|-----------|-------------|
| Vercel — *Turborepo documentation* (turbo.build/repo/docs, 2024) | Build caching thresholds, pipeline configuration |
| Potvin, R. & Levenberg, J. — *"Why Google Stores Billions of Lines of Code in a Single Repository"* (ACM Queue, 2016) | Affected-only CI, scalability patterns |
| Changesets — *Changesets documentation* (github.com/changesets/changesets, 2024) | Versioning workflow standard |

> **Last validated:** 2026-03-31 — Turborepo docs 2024, ACM Queue 2016, Changesets 2024
