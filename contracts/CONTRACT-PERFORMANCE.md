# Contrat — Performance Web

> Module de contrat SQWR Project Kit.
> Sources : Google Core Web Vitals (web.dev), DebugBear, Google HEART Framework, PageSpeed Insights.

---

## Fondements scientifiques

**Impact mesurable de la performance sur les comportements :**
- 400ms de délai supplémentaire → -0.44% de recherches (Google Search, 2018)
- 1 visiteur sur 3 abandonne un site lent (Google, 2019)
- Amélioration de 20% des Core Web Vitals → réduction de 20% des abandons de navigation

> Source : [Google Search Central Blog — Page Speed Impact](https://developers.google.com/search/blog/2019/04/user-experience-improvements-with-page)

La performance est un **signal de ranking SEO** depuis 2021 (Google Page Experience Update).

---

## 1. Core Web Vitals — Seuils obligatoires

> Mesure au **75e percentile** des visites, mobile + desktop séparément.

| Métrique | Good ✅ | Needs Improvement ⚠️ | Poor ❌ | Ce qu'elle mesure |
|----------|---------|---------------------|---------|------------------|
| **LCP** (Largest Contentful Paint) | ≤2.5s | 2.5–4s | >4s | Vitesse chargement perçue |
| **INP** (Interaction to Next Paint) | ≤200ms | 200–500ms | >500ms | Réactivité interactions |
| **CLS** (Cumulative Layout Shift) | <0.1 | 0.1–0.25 | >0.25 | Stabilité visuelle |
| **TTFB** (Time to First Byte) | <600ms | 600ms–1.8s | >1.8s | Réponse serveur |

> ⚠️ INP remplace FID (First Input Delay) depuis le **12 mars 2024**.

---

## 2. Budget performance — cibles SQWR

| Métrique | Cible | Seuil bloquant |
|----------|-------|---------------|
| Lighthouse Performance | >90 | <70 = bloquant |
| Lighthouse Accessibility | >95 | <90 = bloquant |
| Lighthouse SEO | >90 | <80 = bloquant |
| First Load JS (par page) | <200KB | >350KB = critique |
| Total Page Weight | <1MB | >3MB = critique |
| LCP | ≤2.0s | >2.5s = bloquant prod |

---

## 3. Images — optimisation obligatoire

```tsx
// ✅ Toujours next/image — jamais <img> raw
import Image from 'next/image'

// LCP image — priority prop obligatoire
<Image
  src="/hero.jpg"
  alt="Description précise de l'image"
  width={1200}
  height={630}
  priority                      // Précharge le LCP
  sizes="(max-width: 768px) 100vw, 50vw"  // Responsive
  quality={85}                  // WebP auto, qualité optimale
/>

// ✅ Images hors viewport — lazy loading
<Image
  src="/portfolio-item.jpg"
  alt="..."
  width={600}
  height={400}
  // Pas de priority → lazy par défaut
/>
```

**Formats :** Next.js convertit automatiquement en WebP/AVIF. Jamais de PNG pour les photos.

---

## 4. Fonts — zéro layout shift

```typescript
// ✅ next/font — chargement optimisé, zéro layout shift
import { Inter, Geist } from 'next/font/google'

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',         // Texte visible pendant le chargement
  variable: '--font-inter', // CSS variable pour Tailwind
})

// ❌ JAMAIS de font via CDN externe dans CSS
// @import url('https://fonts.googleapis.com/...') — bloque le rendu
```

---

## 5. Code splitting et lazy loading

```tsx
// ✅ Composants lourds — lazy load avec SSR activé par défaut
import dynamic from 'next/dynamic'

const HeavyChart = dynamic(() => import('./HeavyChart'), {
  loading: () => <div className="animate-pulse h-64 bg-gray-100 rounded" />,
  // ssr: true par défaut — ne jamais mettre ssr: false sur pages SEO-critiques
})

// ✅ Suspense pour le streaming
import { Suspense } from 'react'
<Suspense fallback={<LoadingSkeleton />}>
  <SlowDataComponent />
</Suspense>
```

---

## 6. Stratégies de cache et revalidation

```typescript
// Server Component — cache explicite

// ISR : revalidation toutes les heures
const data = await fetch('https://api.example.com/data', {
  next: { revalidate: 3600 }
})

// Static : jamais revalidé (SSG)
const data = await fetch('https://api.example.com/data', {
  cache: 'force-cache'
})

// Dynamic : jamais mis en cache (données user-specific)
const data = await fetch('https://api.example.com/user-data', {
  cache: 'no-store'
})
```

---

## 7. Optimisations Tailwind CSS

```javascript
// tailwind.config.ts — purge CSS obligatoire (par défaut en prod Next.js)
export default {
  content: [
    './src/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  // Next.js purge automatiquement en production
}
```

---

## 8. Bundle analysis

```bash
# Analyser le bundle size avant déploiement
npm install --save-dev @next/bundle-analyzer

# next.config.js
const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
})
module.exports = withBundleAnalyzer({})

# Lancer l'analyse
ANALYZE=true npm run build
```

**Seuils d'alerte :**
- Package >50KB ajouté → justifier ou trouver une alternative
- First Load JS dépasse 200KB → analyser et découper

---

## 9. Checklist performance pré-déploiement

Mesurer avec **PageSpeed Insights** (pagespeed.web.dev) sur les pages critiques :

- [ ] LCP ≤2.5s (mobile + desktop)
- [ ] CLS <0.1 (mobile + desktop)
- [ ] INP ≤200ms
- [ ] Lighthouse Performance ≥90
- [ ] Lighthouse SEO ≥90
- [ ] `<img>` raw absent (remplacé par `next/image`)
- [ ] Fonts via `next/font` uniquement
- [ ] Pas de `ssr: false` sur pages indexées
- [ ] Bundle analysé (pas de package inattendu >50KB)

---

## 10. Sources

| Référence | Lien |
|-----------|------|
| Core Web Vitals | web.dev/articles/vitals |
| INP — remplacement FID | web.dev/articles/inp |
| Next.js Production Checklist | nextjs.org/docs/app/guides/production-checklist |
| PageSpeed Insights | pagespeed.web.dev |
| DebugBear — Next.js Performance | debugbear.com/blog/nextjs-performance |
| Google HEART Framework | research.google/pubs/measuring-the-user-experience-on-a-large-scale |
| Google Search — Page Speed Impact | developers.google.com/search/blog/2019/04 |
