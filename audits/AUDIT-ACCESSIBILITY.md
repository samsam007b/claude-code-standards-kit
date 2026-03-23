# Accessibility Audit

> Based on WCAG 2.1 AA, Nielsen's 10 Heuristics (NN/G), ARIA Authoring Practices.
> Score: /100 | Recommended threshold: ≥85

---

## Section 1 — Contrast and Colors (20 points)

- [ ] Normal text: contrast ≥4.5:1 (WCAG AA) ................................ (8)
- [ ] Large text (≥18pt): contrast ≥3:1 ..................................... (6)
- [ ] UI elements (buttons, icons, fields): contrast ≥3:1 ................... (6)

**Tool:** WebAIM Contrast Checker — webaim.org/resources/contrastchecker

**Subtotal: /20**

---

## Section 2 — Navigation and Structure (20 points)

- [ ] Skip link present and functional ....................................... (5)
- [ ] Only one `<h1>` per page ............................................... (4)
- [ ] Logical heading hierarchy (h1→h2→h3, no skipping levels) ............... (5)
- [ ] Semantic HTML landmarks (`<header>`, `<nav>`, `<main>`, `<footer>`) .... (6)

**Subtotal: /20**

---

## Section 3 — Keyboard Navigation (15 points)

- [ ] All interactive elements reachable by keyboard ......................... (8)
- [ ] Visible focus on all interactive elements .............................. (7)

**Subtotal: /15**

---

## Section 4 — Images and Media (15 points)

- [ ] All informational images have a descriptive `alt` ...................... (8)
- [ ] Decorative images have `alt=""` (no missing alt) ....................... (4)
- [ ] Icons with `aria-label` or visible text ................................ (3)

**Subtotal: /15**

---

## Section 5 — Forms (15 points)

- [ ] All fields have an associated `<label>` (`htmlFor`) .................... (6)
- [ ] Form errors: descriptive message + suggested solution .................. (5)
- [ ] Required fields marked (`aria-required`, `required`) ................... (4)

**Subtotal: /15**

---

## Section 6 — Nielsen Heuristics (15 points)

Quick evaluation of the 10 heuristics — 0 (ok) / 1 (minor) / 2 (major) / 3 (critical)

| Heuristic | Violations | Score (/3) |
|-----------|-----------|-----------|
| 1. Visibility of system status | | /3 |
| 2. Match between system and real world | | /3 |
| 3. User control and freedom | | /3 |
| 4. Consistency and standards | | /3 |
| 5. Error prevention | | /3 |

Section 6 score = (15 - sum of violations) × 1, minimum 0.

**Subtotal: /15**

---

## Total Score: /100

| Section | Score | /Total |
|---------|-------|--------|
| Contrast | | /20 |
| Navigation/structure | | /20 |
| Keyboard | | /15 |
| Images | | /15 |
| Forms | | /15 |
| Nielsen Heuristics | | /15 |
| **TOTAL** | | **/100** |

---

## Recommended tools

```bash
# Automated (detects ~30% of WCAG issues)
# axe-core in Playwright / Testing Library
# Lighthouse Accessibility (DevTools)

# Manual — mandatory
# VoiceOver macOS: Cmd+F5
# Keyboard only: navigate the interface without a mouse
```
