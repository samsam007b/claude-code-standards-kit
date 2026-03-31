---
description: "SQWR Performance Rules — Core Web Vitals, bundle optimization, image handling"
paths:
  - "src/**"
  - "app/**"
  - "pages/**"
  - "next.config.*"
  - "webpack.config.*"
  - "vite.config.*"
---

# Performance Rules (SQWR)

Source: Google Core Web Vitals, web.dev, MDN Web Performance, Lighthouse

## Core Web Vitals Targets (Google, 2024)

- LCP (Largest Contentful Paint) ≤ 2.5s at p75
- INP (Interaction to Next Paint) ≤ 200ms at p75
- CLS (Cumulative Layout Shift) ≤ 0.1 at p75

## Images

- Use next/image or equivalent for automatic optimization
- Specify explicit `width` and `height` attributes to prevent layout shift (CLS)
- Use WebP/AVIF format — never use uncompressed BMP or TIFF
- Lazy load images below the fold (`loading="lazy"`)
- Preload LCP candidate images with `<link rel="preload">`

## JavaScript

- No synchronous `<script>` tags in `<head>` — use `defer` or `async`
- Code-split by route — avoid loading all JS on initial page load
- Tree-shake unused imports — no `import * as X from 'library'` unless necessary
- Minimize main thread blocking — move heavy computation to Web Workers

## Fonts

- Use `font-display: swap` or `optional` to prevent invisible text during font load
- Preload critical fonts with `<link rel="preload" as="font">`
- Subset fonts to only include characters in use

## Caching

- Set appropriate Cache-Control headers for static assets (images, JS, CSS): `max-age=31536000, immutable`
- Use content hashing for cache busting in filenames
