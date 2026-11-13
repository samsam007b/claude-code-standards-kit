---
name: nextjs-review
description: Audit Next.js App Router — Core Web Vitals (LCP/CLS/FID), Server vs Client Components, caching stratégie, bundle size, image optimization, SEO metadata. Sources : Google web.dev, Next.js Production Checklist.
tags: [nextjs, performance, web-vitals, seo, react, app-router]
model: sonnet
---

# /nextjs-review — Audit Next.js App Router

## Quand utiliser

- Avant une mise en production
- Audit de performance (LCP > 2.5s, CLS > 0.1)
- Review d'une nouvelle page ou feature
- Optimisation bundle size

## Critères (Google HEART + Core Web Vitals)

### Server vs Client Components
- [ ] Par défaut Server Component — `"use client"` uniquement si nécessaire
- [ ] Raisons valides de `"use client"` : hooks React, événements browser, state local
- [ ] Jamais de fetch dans un Client Component si évitable
- [ ] `Suspense` + `loading.tsx` sur toutes les routes avec data fetching

### Core Web Vitals cibles
| Métrique | Cible | Critique |
|---------|-------|---------|
| LCP (Largest Contentful Paint) | < 2.5s | > 4s |
| CLS (Cumulative Layout Shift) | < 0.1 | > 0.25 |
| FID/INP (Interaction to Next Paint) | < 200ms | > 500ms |

### Images
- [ ] `next/image` sur toutes les images — jamais `<img>` natif
- [ ] `priority` sur le LCP image (above the fold)
- [ ] `sizes` configuré selon le layout réel
- [ ] Format WebP/AVIF (auto via Next.js)
- [ ] `placeholder="blur"` sur les images non-critiques

### Caching
- [ ] `fetch` avec `{ cache: 'force-cache' }` pour les données statiques
- [ ] `revalidate` configuré pour les données semi-dynamiques
- [ ] `unstable_cache` pour les requêtes DB coûteuses
- [ ] Pas de `no-store` par défaut sauf si vraiment dynamique

### Metadata & SEO
- [ ] `generateMetadata()` sur chaque page (title + description uniques)
- [ ] `opengraph-image.tsx` ou `og.png` pour les social cards
- [ ] `sitemap.ts` généré dynamiquement
- [ ] `robots.ts` configuré
- [ ] Structured data (JSON-LD) sur les pages produit/article

### Bundle & Performance
- [ ] `next/dynamic` pour les composants lourds (éditeurs, charts, maps)
- [ ] `next/font` pour les fonts (pas Google Fonts CDN externe)
- [ ] Bundle analyzer lancé (`ANALYZE=true npm run build`) si bundle > 500KB
- [ ] Tree shaking vérifié sur les gros packages (lodash → lodash-es, etc.)

## Format de sortie

```
## Next.js Review — [page/feature]

### Core Web Vitals estimés
- LCP : [valeur / cible]
- CLS : [valeur / cible]
- INP : [valeur / cible]

### 🔴 Bloquant
### 🟡 Important
### 🟢 Suggestions

### Optimisations code
[extraits de code corrigés]
```
