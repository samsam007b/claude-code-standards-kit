# Performance Audit

> Based on Google Core Web Vitals (web.dev), Lighthouse, DebugBear.
> Score: /100 | Recommended threshold: ≥85

---

## How to measure

1. **PageSpeed Insights**: pagespeed.web.dev (real measurement, 75th percentile)
2. **Lighthouse**: DevTools → Lighthouse → Performance (lab data)
3. **Vercel Analytics**: Web Vitals in production

Measure on the **3 most visited pages minimum** (homepage + 2 critical pages).

---

## Section 1 — Core Web Vitals (40 points)

| Metric | Good | Measured value | Points |
|--------|------|----------------|--------|
| **LCP** ≤2.5s | ✅ / ⚠️ / ❌ | ___ s | /15 |
| **INP** ≤200ms | ✅ / ⚠️ / ❌ | ___ ms | /15 |
| **CLS** <0.1 | ✅ / ⚠️ / ❌ | ___ | /10 |

Scoring:
- Good ✅ = 100% of points
- Needs Improvement ⚠️ = 50% of points
- Poor ❌ = 0 points

**Subtotal: /40**

---

## Section 2 — Lighthouse Scores (30 points)

| Score | Value | Points |
|-------|-------|--------|
| Performance ≥90 | ___ | /12 |
| Accessibility ≥95 | ___ | /8 |
| Best Practices ≥95 | ___ | /5 |
| SEO ≥90 | ___ | /5 |

Scoring: ≥target = 100%, -10% per 5-point bracket below target.

**Subtotal: /30**

---

## Section 3 — Bundle & Assets (20 points)

- [ ] First Load JS <200KB per page .......................................... (8)
- [ ] All images use `next/image` (zero raw `<img>`) ......................... (6)
- [ ] Fonts via `next/font` only (zero external CDN) ......................... (6)

**Subtotal: /20**

---

## Section 4 — Configuration (10 points)

- [ ] No `dynamic(..., { ssr: false })` on indexed pages ..................... (5)
- [ ] `revalidate` configured on Server Components with semi-static content ... (3)
- [ ] Images with `priority` on the LCP element ............................. (2)

**Subtotal: /10**

---

## Total Score: /100

| Section | Score | /Total |
|---------|-------|--------|
| Core Web Vitals | | /40 |
| Lighthouse | | /30 |
| Bundle & Assets | | /20 |
| Configuration | | /10 |
| **TOTAL** | | **/100** |

---

## Common causes and remedies

| Problem | Likely cause | Remedy |
|---------|-------------|--------|
| Slow LCP | Non-optimized image, high TTFB | Add `priority`, check server response time |
| High CLS | Images without dimensions, fonts not loaded | `width`+`height` on all images, `next/font` |
| Slow INP | Blocking JS on interaction | Reduce bundle, lazy load heavy components |
| Low Lighthouse Perf | `ssr: false`, bundle too large | Convert to Server Components, analyze bundle |
