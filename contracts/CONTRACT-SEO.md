# Contrat — SEO Technique

> Module de contrat SQWR Project Kit.
> Sources : Google Search Central (developers.google.com/search), Google Core Web Vitals (web.dev), schema.org, Open Graph Protocol (ogp.me), sitemaps.org Protocol.

---

## Fondements scientifiques

**Le SEO technique est la condition nécessaire du référencement.** Aucune stratégie de contenu ne compense une architecture non-indexable. Depuis juin 2021, Google utilise les Core Web Vitals comme signal de classement (Page Experience Update). Depuis 2024, le passage à l'index mobile-first est total.

**Chiffres de référence :**
- **53% des visites mobiles** sont abandonnées si le chargement dépasse 3 secondes (Google/SOASTA, 2016)
- **Structured data** → rich snippets → CTR +20-30% en moyenne (Google Search Central, cas documentés)
- Une page en `use client` sans SSR n'est **pas indexée** par Googlebot au premier rendu (Google, "JavaScript SEO basics")

---

## 1. Architecture — SSR/SSG obligatoire pour les pages SEO-critiques

> Source : Google Search Central — "JavaScript SEO basics" (developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics)

**Règle absolue : ne jamais mettre `use client` en haut d'une page SEO-critique.**

```tsx
// ❌ Toute la page devient client-side — Googlebot ne voit que le HTML initial vide
'use client'
export default function HomePage() { ... }

// ✅ Page Server Component (défaut Next.js App Router)
// Googlebot reçoit le HTML complet au premier rendu
export default async function HomePage() {
  const data = await fetch('...')
  return <main>...</main>
}

// ✅ Isolation correcte : seul le composant interactif est client
// La page reste un Server Component
import { SearchBar } from './SearchBar' // 'use client' à l'intérieur

export default async function HomePage() {
  return (
    <main>
      <h1>Titre indexable</h1>
      <SearchBar />  {/* seul ce composant est client */}
    </main>
  )
}
```

**Règle de décision :**
```
Page d'accueil, blog, landing, product → Server Component (SSR/SSG)
Dashboard authentifié, app interactive  → Client Component acceptable
```

---

## 2. Metadata API Next.js 14

> Source : Next.js docs — Metadata (nextjs.org/docs/app/building-your-application/optimizing/metadata)

```tsx
// app/layout.tsx — métadonnées globales
import type { Metadata } from 'next'

export const metadata: Metadata = {
  // Title — 50-60 caractères (Google tronque à ~60)
  title: {
    template: '%s | Nom du Site',
    default: 'Nom du Site — Baseline courte',
  },
  // Description — 150-160 caractères
  description: 'Description précise de la valeur, 150-160 caractères maximum pour éviter la troncature dans les SERPs.',
  // Open Graph — obligatoire pour partages sociaux
  openGraph: {
    title: 'Nom du Site',
    description: 'Description OG — peut différer de la meta description',
    url: 'https://www.exemple.com',
    siteName: 'Nom du Site',
    images: [
      {
        url: 'https://www.exemple.com/og-image.jpg',
        width: 1200,
        height: 630,
        alt: 'Description de l\'image OG',
      },
    ],
    locale: 'fr_FR',
    type: 'website',
  },
  // Twitter / X Cards
  twitter: {
    card: 'summary_large_image',
    title: 'Nom du Site',
    description: 'Description Twitter',
    images: ['https://www.exemple.com/twitter-image.jpg'],
  },
  // Robots
  robots: {
    index: true,
    follow: true,
  },
}

// app/blog/[slug]/page.tsx — métadonnées dynamiques
export async function generateMetadata(
  { params }: { params: { slug: string } }
): Promise<Metadata> {
  const post = await getPost(params.slug)
  return {
    title: post.title,  // ≤60 chars
    description: post.excerpt,  // ≤160 chars
    openGraph: {
      title: post.title,
      description: post.excerpt,
      images: [post.coverImage],
      type: 'article',
      publishedTime: post.publishedAt,
    },
  }
}
```

**Thresholds :**
| Champ | Minimum | Optimal | Maximum |
|-------|---------|---------|---------|
| `<title>` | 30 chars | 50-60 chars | 60 chars |
| `<meta description>` | 70 chars | 150-160 chars | 160 chars |
| OG image | — | 1200×630 px | — |

---

## 3. Structured Data — JSON-LD

> Source : schema.org (schema.org), Google Search Central — Structured Data (developers.google.com/search/docs/appearance/structured-data/intro-structured-data)

**Règle : JSON-LD préféré à Microdata ou RDFa** (recommandation Google officielle).

```tsx
// components/JsonLd.tsx
// Sécurité : data doit provenir uniquement de sources internes (jamais user input).
// JSON.stringify échappe les caractères spéciaux — aucun risque XSS avec données serveur.
// Ne jamais passer de données non-maîtrisées dans ce composant.
export function JsonLd({ data }: { data: Record<string, unknown> }) {
  return (
    <script
      type="application/ld+json"
      // data provient exclusivement du CMS/BDD interne — safe par construction
      // eslint-disable-next-line react/no-danger
      dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }}
    />
  )
}

// Organisation (obligatoire sur la page d'accueil)
const organizationSchema = {
  '@context': 'https://schema.org',
  '@type': 'Organization',
  name: 'Nom de l\'entreprise',
  url: 'https://www.exemple.com',
  logo: 'https://www.exemple.com/logo.png',
  sameAs: [
    'https://www.linkedin.com/company/...',
    'https://twitter.com/...',
  ],
}

// WebSite — active la SearchBox dans Google
const websiteSchema = {
  '@context': 'https://schema.org',
  '@type': 'WebSite',
  name: 'Nom du Site',
  url: 'https://www.exemple.com',
}

// Article (pour les pages de blog)
const articleSchema = {
  '@context': 'https://schema.org',
  '@type': 'Article',
  headline: 'Titre de l\'article',
  datePublished: '2026-01-01T00:00:00Z',
  dateModified: '2026-01-15T00:00:00Z',
  author: { '@type': 'Person', name: 'Auteur' },
  image: 'https://www.exemple.com/article-image.jpg',
}

// BreadcrumbList (navigation)
const breadcrumbSchema = {
  '@context': 'https://schema.org',
  '@type': 'BreadcrumbList',
  itemListElement: [
    { '@type': 'ListItem', position: 1, name: 'Accueil', item: 'https://www.exemple.com' },
    { '@type': 'ListItem', position: 2, name: 'Blog', item: 'https://www.exemple.com/blog' },
  ],
}
```

**Tester avec :** Google Rich Results Test — search.google.com/test/rich-results

---

## 4. Sitemap.xml

> Source : Sitemaps Protocol — sitemaps.org/protocol.html, Next.js docs — sitemap.ts (nextjs.org/docs/app/api-reference/file-conventions/metadata/sitemap)

```tsx
// app/sitemap.ts — généré automatiquement par Next.js 14
import { MetadataRoute } from 'next'

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const posts = await getAllPosts()

  return [
    {
      url: 'https://www.exemple.com',
      lastModified: new Date(),
      changeFrequency: 'weekly',
      priority: 1,
    },
    {
      url: 'https://www.exemple.com/blog',
      lastModified: new Date(),
      changeFrequency: 'daily',
      priority: 0.8,
    },
    ...posts.map((post) => ({
      url: `https://www.exemple.com/blog/${post.slug}`,
      lastModified: new Date(post.updatedAt),
      changeFrequency: 'monthly' as const,
      priority: 0.6,
    })),
  ]
}
```

**Règles :**
- Soumettre le sitemap dans Google Search Console (search.google.com/search-console)
- `priority` : 1.0 = homepage, 0.8 = sections, 0.6 = articles, 0.4 = pages secondaires
- Exclure les pages `noindex` du sitemap (incohérence crawl budget)

---

## 5. robots.txt

> Source : Google Search Central — robots.txt specification (developers.google.com/search/docs/crawling-indexing/robots/intro)

```tsx
// app/robots.ts
import { MetadataRoute } from 'next'

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        disallow: ['/api/', '/admin/', '/_next/'],
      },
    ],
    sitemap: 'https://www.exemple.com/sitemap.xml',
  }
}
```

**Règles critiques :**
- Ne jamais `Disallow: /` en production (bloque tout le crawl)
- Toujours pointer vers `sitemap.xml`
- Exclure `/api/`, `/admin/`, routes privées

---

## 6. URLs canoniques

> Source : Google Search Central — Canonical URLs (developers.google.com/search/docs/crawling-indexing/canonicalization)

```tsx
// Éviter le duplicate content — déclarer la version canonique
export const metadata: Metadata = {
  alternates: {
    canonical: 'https://www.exemple.com/blog/mon-article',
    languages: {
      'fr-FR': 'https://www.exemple.com/fr/blog/mon-article',
      'en-US': 'https://www.exemple.com/en/blog/mon-article',
    },
  },
}
```

**Cas nécessitant un canonical :**
- Pages paginées (`/blog?page=2` → canonical vers `/blog`)
- Paramètres UTM (`?utm_source=...` → canonical sans paramètre)
- Versions www et non-www (choisir une, forcer via redirect 301)

---

## 7. Core Web Vitals — signal de classement

> Source : Google — "Understanding page experience in Google Search results" (developers.google.com/search/docs/appearance/page-experience)
> Source : web.dev/vitals (web.dev/articles/vitals)

**Google utilise les CWV comme signal de classement depuis juin 2021.** Thresholds identiques à CONTRACT-PERFORMANCE.md :

| Métrique | Bon ✅ | À améliorer ⚠️ | Mauvais ❌ |
|----------|--------|----------------|-----------|
| **LCP** | ≤2.5s | 2.5-4.0s | >4.0s |
| **INP** | ≤200ms | 200-500ms | >500ms |
| **CLS** | ≤0.1 | 0.1-0.25 | >0.25 |

**Pour le SEO spécifiquement :**
- Lighthouse SEO score : **≥90/100 cible**
- Mesurer au **75e percentile** (pas la moyenne) — c'est le seuil Google

---

## 8. Images — Optimisation SEO

> Source : Google Search Central — Images best practices (developers.google.com/search/docs/appearance/google-images)

```tsx
// ✅ next/image — optimisation automatique (WebP, lazy loading, responsive)
import Image from 'next/image'

<Image
  src="/hero.jpg"
  alt="Description précise et informative de l'image"  // obligatoire pour indexation images
  width={1200}
  height={630}
  priority  // LCP image — ne pas lazy-loader le hero
  sizes="(max-width: 768px) 100vw, 1200px"
/>

// ✅ Images décoratives — exclure de l'indexation images
<Image src="/pattern.svg" alt="" role="presentation" />

// ❌ Balise img native — pas d'optimisation, pas de lazy loading auto
// <img src="/hero.jpg" />
```

**Règles :**
- `alt` descriptif sur toutes les images informatives (double rôle : SEO + accessibilité)
- `priority` sur l'image LCP (above-the-fold)
- Format WebP ou AVIF (automatique avec `next/image`)
- Noms de fichiers descriptifs (`hero-presentation.jpg` > `IMG_1234.jpg`)

---

## 9. Checklist Lighthouse SEO

```bash
# Lighthouse CLI
npx lighthouse https://www.exemple.com --only-categories=seo,performance \
  --output=json --output-path=lighthouse-report.json
```

| Check | Threshold |
|-------|-----------|
| `<title>` présent et non vide | Obligatoire |
| `<meta description>` présente | Obligatoire |
| Liens avec texte descriptif | Obligatoire |
| Images avec `alt` | Obligatoire |
| HTTPS | Obligatoire |
| robots.txt valide | Obligatoire |
| Lighthouse SEO score | ≥90/100 |

---

## Checklist pré-lancement SEO

### Bloquants

- [ ] Aucune page SEO-critique en `use client` seul
- [ ] `<title>` unique sur chaque page (50-60 chars)
- [ ] `<meta description>` unique sur chaque page (150-160 chars)
- [ ] Open Graph sur toutes les pages publiques (og:image 1200×630)
- [ ] `sitemap.xml` généré et accessible
- [ ] `robots.txt` valide
- [ ] Google Search Console — sitemap soumis
- [ ] Core Web Vitals : LCP ≤2.5s, INP ≤200ms, CLS ≤0.1

### Importants

- [ ] JSON-LD Organization sur la page d'accueil
- [ ] JSON-LD Article sur les pages de blog
- [ ] Alt descriptifs sur toutes les images informatives
- [ ] Lighthouse SEO ≥90/100 (mobile ET desktop)
- [ ] URLs canoniques sur les pages avec paramètres

### Souhaitables

- [ ] JSON-LD FAQ (si page FAQ)
- [ ] Hreflang (si multilingue)
- [ ] Google Rich Results Test — 0 erreur

---

## Sources

| Référence | Lien |
|-----------|------|
| Google Search Central | developers.google.com/search |
| JavaScript SEO basics | developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics |
| Core Web Vitals | web.dev/articles/vitals |
| Structured Data intro | developers.google.com/search/docs/appearance/structured-data |
| schema.org | schema.org |
| Sitemaps Protocol | sitemaps.org/protocol.html |
| robots.txt spec | developers.google.com/search/docs/crawling-indexing/robots/intro |
| Next.js Metadata API | nextjs.org/docs/app/building-your-application/optimizing/metadata |
| Open Graph Protocol | ogp.me |
| Google Rich Results Test | search.google.com/test/rich-results |
| Page Experience update | developers.google.com/search/docs/appearance/page-experience |
