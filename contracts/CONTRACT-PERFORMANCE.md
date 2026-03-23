# Contract — Web Performance

> SQWR Project Kit contract module.
> Sources: Google Core Web Vitals (web.dev), DebugBear, Google HEART Framework, PageSpeed Insights.

---

## Scientific Foundations

**Measurable impact of performance on user behaviour:**
- An additional 400ms delay → -0.44% searches (Google Search, 2018)
- 1 in 3 visitors abandons a slow site (Google, 2019)
- 20% improvement in Core Web Vitals → 20% reduction in navigation abandonment

> Source: [Google Search Central Blog — Page Speed Impact](https://developers.google.com/search/blog/2019/04/user-experience-improvements-with-page)

Performance has been an **SEO ranking signal** since 2021 (Google Page Experience Update).

---

## 1. Core Web Vitals — Mandatory Thresholds

> Measured at the **75th percentile** of visits, mobile + desktop separately.

| Metric | Good ✅ | Needs Improvement ⚠️ | Poor ❌ | What it measures |
|--------|---------|---------------------|---------|-----------------|
| **LCP** (Largest Contentful Paint) | ≤2.5s | 2.5–4s | >4s | Perceived load speed |
| **INP** (Interaction to Next Paint) | ≤200ms | 200–500ms | >500ms | Interaction responsiveness |
| **CLS** (Cumulative Layout Shift) | <0.1 | 0.1–0.25 | >0.25 | Visual stability |
| **TTFB** (Time to First Byte) | <600ms | 600ms–1.8s | >1.8s | Server response |

> ⚠️ INP replaced FID (First Input Delay) since **March 12, 2024**.

---

## 2. Performance Budget — SQWR Targets

| Metric | Target | Blocking threshold |
|--------|--------|--------------------|
| Lighthouse Performance | >90 | <70 = blocking |
| Lighthouse Accessibility | >95 | <90 = blocking |
| Lighthouse SEO | >90 | <80 = blocking |
| First Load JS (per page) | <200KB | >350KB = critical |
| Total Page Weight | <1MB | >3MB = critical |
| LCP | ≤2.0s | >2.5s = blocking in production |

---

## 3. Images — Mandatory Optimisation

```tsx
// ✅ Always next/image — never raw <img>
import Image from 'next/image'

// LCP image — priority prop is mandatory
<Image
  src="/hero.jpg"
  alt="Precise description of the image"
  width={1200}
  height={630}
  priority                      // Preloads the LCP
  sizes="(max-width: 768px) 100vw, 50vw"  // Responsive
  quality={85}                  // Auto WebP, optimal quality
/>

// ✅ Off-viewport images — lazy loading
<Image
  src="/portfolio-item.jpg"
  alt="..."
  width={600}
  height={400}
  // No priority → lazy by default
/>
```

**Formats:** Next.js automatically converts to WebP/AVIF. Never use PNG for photos.

---

## 4. Fonts — Zero Layout Shift

```typescript
// ✅ next/font — optimised loading, zero layout shift
import { Inter, Geist } from 'next/font/google'

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',         // Text visible during loading
  variable: '--font-inter', // CSS variable for Tailwind
})

// ❌ NEVER load a font via external CDN in CSS
// @import url('https://fonts.googleapis.com/...') — blocks rendering
```

---

## 5. Code Splitting and Lazy Loading

```tsx
// ✅ Heavy components — lazy load with SSR enabled by default
import dynamic from 'next/dynamic'

const HeavyChart = dynamic(() => import('./HeavyChart'), {
  loading: () => <div className="animate-pulse h-64 bg-gray-100 rounded" />,
  // ssr: true by default — never set ssr: false on SEO-critical pages
})

// ✅ Suspense for streaming
import { Suspense } from 'react'
<Suspense fallback={<LoadingSkeleton />}>
  <SlowDataComponent />
</Suspense>
```

---

## 6. Cache and Revalidation Strategies

```typescript
// Server Component — explicit cache

// ISR: revalidation every hour
const data = await fetch('https://api.example.com/data', {
  next: { revalidate: 3600 }
})

// Static: never revalidated (SSG)
const data = await fetch('https://api.example.com/data', {
  cache: 'force-cache'
})

// Dynamic: never cached (user-specific data)
const data = await fetch('https://api.example.com/user-data', {
  cache: 'no-store'
})
```

---

## 7. Tailwind CSS Optimisations

```javascript
// tailwind.config.ts — mandatory CSS purge (default in production Next.js)
export default {
  content: [
    './src/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  // Next.js automatically purges in production
}
```

---

## 8. Bundle Analysis

```bash
# Analyse bundle size before deployment
npm install --save-dev @next/bundle-analyzer

# next.config.js
const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
})
module.exports = withBundleAnalyzer({})

# Run the analysis
ANALYZE=true npm run build
```

**Alert thresholds:**
- Package >50KB added → justify or find an alternative
- First Load JS exceeds 200KB → analyse and split

---

## 9. Pre-deployment Performance Checklist

Measure with **PageSpeed Insights** (pagespeed.web.dev) on critical pages:

- [ ] LCP ≤2.5s (mobile + desktop)
- [ ] CLS <0.1 (mobile + desktop)
- [ ] INP ≤200ms
- [ ] Lighthouse Performance ≥90
- [ ] Lighthouse SEO ≥90
- [ ] No raw `<img>` (replaced by `next/image`)
- [ ] Fonts via `next/font` only
- [ ] No `ssr: false` on indexed pages
- [ ] Bundle analysed (no unexpected package >50KB)

---

## 10. Sources

| Reference | Link |
|-----------|------|
| Core Web Vitals | web.dev/articles/vitals |
| INP — FID replacement | web.dev/articles/inp |
| Next.js Production Checklist | nextjs.org/docs/app/guides/production-checklist |
| PageSpeed Insights | pagespeed.web.dev |
| DebugBear — Next.js Performance | debugbear.com/blog/nextjs-performance |
| Google HEART Framework | research.google/pubs/measuring-the-user-experience-on-a-large-scale |
| Google Search — Page Speed Impact | developers.google.com/search/blog/2019/04 |
