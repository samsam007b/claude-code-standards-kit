# Contract — Documentation

> Sources: Diátaxis framework (diataxis.fr — Daniele Procida, 2021), TSDoc Specification v1.0 (tsdoc.org — Microsoft, 2023), Google Developer Documentation Style Guide (developers.google.com/style, 2024)
> Score: /100 | Recommended threshold: ≥65
> Applies to: any project with public APIs, shared components, or team contributors

---

## Section 1 — Code Documentation (35 points)

- [ ] 100% of exported functions, classes, and interfaces have TSDoc/JSDoc comments .............. (15)
- [ ] Code comments explain WHY, not WHAT (no comment restating the code — Google Style Guide §Comments) .............. (10)
- [ ] Functions with >5 parameters or complex logic have a `@example` tag (TSDoc §Tags) .............. (5)
- [ ] No commented-out code in the codebase (use git history instead — Google Style Guide) .............. (5)

**Subtotal: /35**

---

## Section 2 — Project Documentation (30 points)

- [ ] README contains: Installation, Usage, API reference, Contributing sections (Diátaxis §Structure) .............. (12)
- [ ] CHANGELOG follows Keep a Changelog format (keepachangelog.com): Added/Changed/Deprecated/Removed/Fixed/Security .............. (10)
- [ ] Architecture decisions documented using ADR format (frameworks/ADR-TEMPLATE.md) .............. (8)

**Subtotal: /30**

---

## Section 3 — Documentation Types (Diátaxis) (20 points)

At least 3 of 4 Diátaxis documentation types present (Procida, 2021):

- [ ] **Tutorials** — learning-oriented step-by-step guide for beginners .............. (5)
- [ ] **How-to guides** — task-oriented instructions for practitioners .............. (5)
- [ ] **Reference** — information-oriented API/config documentation .............. (5)
- [ ] **Explanation** — understanding-oriented conceptual documentation .............. (5)

**Subtotal: /20**

---

## Section 4 — Component Documentation (15 points)

- [ ] Design system components have Storybook stories (≥80% component coverage — if Storybook is used) .............. (10)
- [ ] Props documented with types and descriptions (React/Vue/Svelte) .............. (5)

**Subtotal: /15**

---

## Sources

| Reference | Contribution |
|-----------|-------------|
| Procida, D. — *Diátaxis: A systematic approach to technical documentation* (diataxis.fr, 2021) | 4 documentation types framework, quality criteria |
| Microsoft — *TSDoc Specification v1.0* (tsdoc.org, 2023) | TSDoc/JSDoc coverage requirements, tag standard |
| Google — *Developer Documentation Style Guide* (developers.google.com/style, 2024) | Comment quality standards, no-commented-code rule |
| Nygard, M. et al. — *Keep a Changelog* (keepachangelog.com, 2023) | CHANGELOG format standard |

> **Last validated:** 2026-03-31 — Diátaxis 2021, TSDoc v1.0, Google Style Guide 2024, Keep a Changelog
