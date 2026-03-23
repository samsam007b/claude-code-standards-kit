# Audit Performance

> Basé sur Google Core Web Vitals (web.dev), Lighthouse, DebugBear.
> Score : /100 | Seuil recommandé : ≥85

---

## Comment mesurer

1. **PageSpeed Insights** : pagespeed.web.dev (mesure réelle, 75e percentile)
2. **Lighthouse** : DevTools → Lighthouse → Performance (lab data)
3. **Vercel Analytics** : Web Vitals en production

Mesurer sur les **3 pages les plus visitées minimum** (homepage + 2 pages critiques).

---

## Section 1 — Core Web Vitals (40 points)

| Métrique | Good | Valeur mesurée | Points |
|----------|------|----------------|--------|
| **LCP** ≤2.5s | ✅ / ⚠️ / ❌ | ___ s | /15 |
| **INP** ≤200ms | ✅ / ⚠️ / ❌ | ___ ms | /15 |
| **CLS** <0.1 | ✅ / ⚠️ / ❌ | ___ | /10 |

Barème :
- Good ✅ = 100% des points
- Needs Improvement ⚠️ = 50% des points
- Poor ❌ = 0 points

**Sous-total : /40**

---

## Section 2 — Lighthouse Scores (30 points)

| Score | Valeur | Points |
|-------|--------|--------|
| Performance ≥90 | ___ | /12 |
| Accessibility ≥95 | ___ | /8 |
| Best Practices ≥95 | ___ | /5 |
| SEO ≥90 | ___ | /5 |

Barème : ≥cible = 100%, -10% par tranche de 5 points sous la cible.

**Sous-total : /30**

---

## Section 3 — Bundle & Assets (20 points)

- [ ] First Load JS <200KB par page ......................................... (8)
- [ ] Toutes les images utilisent `next/image` (zéro `<img>` raw) ........... (6)
- [ ] Fonts via `next/font` uniquement (zéro CDN externe) ................... (6)

**Sous-total : /20**

---

## Section 4 — Configuration (10 points)

- [ ] Aucun `dynamic(..., { ssr: false })` sur pages indexées ............... (5)
- [ ] `revalidate` configuré sur les Server Components de contenu semi-statique (3)
- [ ] Images avec `priority` sur le LCP element ............................ (2)

**Sous-total : /10**

---

## Score total : /100

| Section | Score | /Total |
|---------|-------|--------|
| Core Web Vitals | | /40 |
| Lighthouse | | /30 |
| Bundle & Assets | | /20 |
| Configuration | | /10 |
| **TOTAL** | | **/100** |

---

## Causes fréquentes et remèdes

| Problème | Cause probable | Remède |
|---------|----------------|--------|
| LCP lent | Image non optimisée, TTFB élevé | Ajouter `priority`, vérifier server response time |
| CLS élevé | Images sans dimensions, fonts non chargées | `width`+`height` sur toutes images, `next/font` |
| INP lent | JS bloquant sur interaction | Réduire bundle, lazy load composants lourds |
| Lighthouse Perf faible | `ssr: false`, bundle trop gros | Convertir en Server Components, analyser bundle |
