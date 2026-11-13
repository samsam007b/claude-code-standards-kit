---
name: nextjs-review
description: Next.js App Router audit: Core Web Vitals (LCP/CLS/FID), Server vs Client Components, caching strategy, bundle size, image optimization, SEO metadata. Sources: Google web.dev, Next.js Production Checklist.
tags: [nextjs, performance, web-vitals, seo, react, app-router]
model: sonnet
---

# /nextjs-review: Next.js App Router Audit

## When to use

- Before a production release
- Performance audit (LCP > 2.5s, CLS > 0.1)
- Review of a new page or feature
- Bundle size optimization

## Criteria (Google HEART + Core Web Vitals)

### Server vs Client Components
- [ ] Server Component by default: `"use client"` only when necessary
- [ ] Valid reasons for `"use client"`: React hooks, browser events, local state
- [ ] Never fetch in a Client Component if avoidable
- [ ] `Suspense` + `loading.tsx` on all routes with data fetching

### Core Web Vitals targets
| Metric | Target | Critical |
|---------|-------|---------|
| LCP (Largest Contentful Paint) | < 2.5s | > 4s |
| CLS (Cumulative Layout Shift) | < 0.1 | > 0.25 |
| FID/INP (Interaction to Next Paint) | < 200ms | > 500ms |

### Images
- [ ] `next/image` on all images, never native `<img>`
- [ ] `priority` on the LCP image (above the fold)
- [ ] `sizes` configured according to the actual layout
- [ ] WebP/AVIF format (automatic via Next.js)
- [ ] `placeholder="blur"` on non-critical images

### Caching
- [ ] `fetch` with `{ cache: 'force-cache' }` for static data
- [ ] `revalidate` configured for semi-dynamic data
- [ ] `unstable_cache` for expensive DB queries
- [ ] No `no-store` by default unless truly dynamic

### Metadata & SEO
- [ ] `generateMetadata()` on every page (unique title + description)
- [ ] `opengraph-image.tsx` or `og.png` for social cards
- [ ] `sitemap.ts` generated dynamically
- [ ] `robots.ts` configured
- [ ] Structured data (JSON-LD) on product/article pages

### Bundle & Performance
- [ ] `next/dynamic` for heavy components (editors, charts, maps)
- [ ] `next/font` for fonts (no external Google Fonts CDN)
- [ ] Bundle analyzer run (`ANALYZE=true npm run build`) if bundle > 500KB
- [ ] Tree shaking verified on large packages (lodash → lodash-es, etc.)

## Output format

```
## Next.js Review: [page/feature]

### Estimated Core Web Vitals
- LCP: [value / target]
- CLS: [value / target]
- INP: [value / target]

### 🔴 Blocking
### 🟡 Important
### 🟢 Suggestions

### Code optimizations
[corrected code excerpts]
```
