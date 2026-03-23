# Design Audit

> Based on WCAG 2.1, Itten/Munsell (color), Bringhurst (typography), Wertheimer (Gestalt), Baymard Institute.
> Score: /100 | Recommended threshold: ≥80

---

## Section 1 — Colors and Contrast (30 points)

- [ ] Normal text: contrast ≥4.5:1 verified on all combinations ............. (10)
- [ ] Large text and UI elements: contrast ≥3:1 ............................. (8)
- [ ] Consistent palette: defined roles (dominant/secondary/accent) .......... (7)
- [ ] Color harmony system respected (complementary/analogous/triadic) ....... (5)

**Tool:** WebAIM Contrast Checker

**Subtotal: /30**

---

## Section 2 — Typography (25 points)

| Criterion | Measured value | Threshold | OK? | Points |
|-----------|----------------|-----------|-----|--------|
| Minimum body size | ___px | ≥16px | | /8 |
| Line length | ___ CPL | 50-75 | | /8 |
| Line height | ___ | ≥1.5 | | /5 |
| Typographic scale | ratio: ___ | modular scale | | /4 |

**Subtotal: /25**

---

## Section 3 — Gestalt and Visual Hierarchy (25 points)

Application of the 7 laws — note conscious or unjustified violations:

| Law | Applied? | Violations | Points |
|-----|----------|-----------|--------|
| Proximity (related elements grouped) | | | /4 |
| Similarity (same style = same function) | | | /4 |
| Continuity (coherent visual flow) | | | /4 |
| Figure-ground (background/content contrast) | | | /4 |
| Symmetry (balanced layouts) | | | /4 |
| Closure (readable icons) | | | /3 |
| Common fate (grouped animations) | | | /2 |

**Subtotal: /25**

---

## Section 4 — Design System (20 points)

- [ ] Centralized design tokens (`tailwind.config.ts` or `design-system.ts`) .. (8)
- [ ] Systematic spacing (8px or 4px base, no arbitrary values) .............. (6)
- [ ] `prefers-reduced-motion` respected on all animations ................... (6)

**Subtotal: /20**

---

## Total Score: /100

| Section | Score | /Total |
|---------|-------|--------|
| Colors & contrast | | /30 |
| Typography | | /25 |
| Gestalt & hierarchy | | /25 |
| Design System | | /20 |
| **TOTAL** | | **/100** |

---

## Reference sources

- Johannes Itten — Color harmony systems
- WCAG 2.1 SC 1.4.3 — Contrast
- Baymard Institute — CPL 50-75
- Bringhurst — Modular scale
- Wertheimer, Koffka, Köhler — 7 Gestalt laws
