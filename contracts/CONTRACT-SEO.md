# Contract — Technical SEO

> SQWR Project Kit contract module.
> Sources: Google Search Central (developers.google.com/search), Google Core Web Vitals (web.dev), schema.org, Open Graph Protocol (ogp.me), sitemaps.org Protocol.

---

## Scientific Foundations

**Technical SEO is the necessary condition for search visibility.** No content strategy compensates for a non-indexable architecture. Since June 2021, Google has used Core Web Vitals as a ranking signal (Page Experience Update). Since 2024, the transition to a mobile-first index is complete.

**Reference figures:**
- **53% of mobile visits** are abandoned if loading exceeds 3 seconds (Google/SOASTA, 2016)
- **Structured data** → rich snippets → CTR +20–30% on average (Google Search Central, documented cases)
- A page with `use client` and no SSR is **not indexed** by Googlebot on first render (Google, "JavaScript SEO basics")

---

## 1. Architecture — SSR/SSG Mandatory for SEO-Critical Pages

> Source: Google Search Central — "JavaScript SEO basics" (developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics)

**Absolute Rule: never put `use client` at the top of an SEO-critical page.**

```tsx
// ❌ The entire page becomes client-side — Googlebot only sees the initial empty HTML
'use client'
export default function HomePage() { ... }

// ✅ Server Component page (Next.js App Router default)
// Googlebot receives the full HTML on first render
export default async function HomePage() {
  const data = await fetch('...')
  return <main>...</main>
}

// ✅ Correct isolation: only the interactive component is client-side
// The page remains a Server Component
import { SearchBar } from './SearchBar' // 'use client' inside

export default async function HomePage() {
  return (
    <main>
      <h1>Indexable title</h1>
      <SearchBar />  {/* only this component is client-side */}
    </main>
  )
}
```

**Decision rule:**
```
Homepage, blog, landing, product → Server Component (SSR/SSG)
Authenticated dashboard, interactive app  → Client Component acceptable
```

---

## 2. Next.js 14 Metadata API

> Source: Next.js docs — Metadata (nextjs.org/docs/app/building-your-application/optimizing/metadata)

```tsx
// app/layout.tsx — global metadata
import type { Metadata } from 'next'

export const metadata: Metadata = {
  // Title — 50-60 characters (Google truncates at ~60)
  title: {
    template: '%s | Site Name',
    default: 'Site Name — Short Baseline',
  },
  // Description — 150-160 characters
  description: 'Precise description of the value proposition, 150-160 characters maximum to avoid truncation in SERPs.',
  // Open Graph — required for social sharing
  openGraph: {
    title: 'Site Name',
    description: 'OG description — may differ from meta description',
    url: 'https://www.exemple.com',
    siteName: 'Site Name',
    images: [
      {
        url: 'https://www.exemple.com/og-image.jpg',
        width: 1200,
        height: 630,
        alt: 'Description of the OG image',
      },
    ],
    locale: 'fr_FR',
    type: 'website',
  },
  // Twitter / X Cards
  twitter: {
    card: 'summary_large_image',
    title: 'Site Name',
    description: 'Twitter description',
    images: ['https://www.exemple.com/twitter-image.jpg'],
  },
  // Robots
  robots: {
    index: true,
    follow: true,
  },
}

// app/blog/[slug]/page.tsx — dynamic metadata
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

**Thresholds:**
| Field | Minimum | Optimal | Maximum |
|-------|---------|---------|---------|
| `<title>` | 30 chars | 50-60 chars | 60 chars |
| `<meta description>` | 70 chars | 150-160 chars | 160 chars |
| OG image | — | 1200×630 px | — |

---

## 3. Structured Data — JSON-LD

> Source: schema.org (schema.org), Google Search Central — Structured Data (developers.google.com/search/docs/appearance/structured-data/intro-structured-data)

**Rule: JSON-LD preferred over Microdata or RDFa** (official Google recommendation).

```tsx
// components/JsonLd.tsx
// Security: data must come exclusively from internal sources (never user input).
// JSON.stringify escapes special characters — no XSS risk with server data.
// Never pass uncontrolled data to this component.
export function JsonLd({ data }: { data: Record<string, unknown> }) {
  return (
    <script
      type="application/ld+json"
      // data comes exclusively from internal CMS/DB — safe by construction
      // eslint-disable-next-line react/no-danger
      dangerouslySetInnerHTML={{ __html: JSON.stringify(data) }}
    />
  )
}

// Organization (required on the homepage)
const organizationSchema = {
  '@context': 'https://schema.org',
  '@type': 'Organization',
  name: 'Company Name',
  url: 'https://www.exemple.com',
  logo: 'https://www.exemple.com/logo.png',
  sameAs: [
    'https://www.linkedin.com/company/...',
    'https://twitter.com/...',
  ],
}

// WebSite — enables the SearchBox in Google
const websiteSchema = {
  '@context': 'https://schema.org',
  '@type': 'WebSite',
  name: 'Site Name',
  url: 'https://www.exemple.com',
}

// Article (for blog pages)
const articleSchema = {
  '@context': 'https://schema.org',
  '@type': 'Article',
  headline: 'Article Title',
  datePublished: '2026-01-01T00:00:00Z',
  dateModified: '2026-01-15T00:00:00Z',
  author: { '@type': 'Person', name: 'Author' },
  image: 'https://www.exemple.com/article-image.jpg',
}

// BreadcrumbList (navigation)
const breadcrumbSchema = {
  '@context': 'https://schema.org',
  '@type': 'BreadcrumbList',
  itemListElement: [
    { '@type': 'ListItem', position: 1, name: 'Home', item: 'https://www.exemple.com' },
    { '@type': 'ListItem', position: 2, name: 'Blog', item: 'https://www.exemple.com/blog' },
  ],
}
```

**Test with:** Google Rich Results Test — search.google.com/test/rich-results

---

## 4. Sitemap.xml

> Source: Sitemaps Protocol — sitemaps.org/protocol.html, Next.js docs — sitemap.ts (nextjs.org/docs/app/api-reference/file-conventions/metadata/sitemap)

```tsx
// app/sitemap.ts — automatically generated by Next.js 14
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

**Rules:**
- Submit the sitemap in Google Search Console (search.google.com/search-console)
- `priority`: 1.0 = homepage, 0.8 = sections, 0.6 = articles, 0.4 = secondary pages
- Exclude `noindex` pages from the sitemap (crawl budget inconsistency)

---

## 5. robots.txt

> Source: Google Search Central — robots.txt specification (developers.google.com/search/docs/crawling-indexing/robots/intro)

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

**Critical rules:**
- Never `Disallow: /` in production (blocks all crawling)
- Always point to `sitemap.xml`
- Exclude `/api/`, `/admin/`, private routes

---

## 6. Canonical URLs

> Source: Google Search Central — Canonical URLs (developers.google.com/search/docs/crawling-indexing/canonicalization)

```tsx
// Avoid duplicate content — declare the canonical version
export const metadata: Metadata = {
  alternates: {
    canonical: 'https://www.exemple.com/blog/my-article',
    languages: {
      'fr-FR': 'https://www.exemple.com/fr/blog/my-article',
      'en-US': 'https://www.exemple.com/en/blog/my-article',
    },
  },
}
```

**Cases requiring a canonical:**
- Paginated pages (`/blog?page=2` → canonical to `/blog`)
- UTM parameters (`?utm_source=...` → canonical without parameter)
- www and non-www versions (choose one, enforce via 301 redirect)

---

## 7. Core Web Vitals — Ranking Signal

> Source: Google — "Understanding page experience in Google Search results" (developers.google.com/search/docs/appearance/page-experience)
> Source: web.dev/vitals (web.dev/articles/vitals)

**Google has used CWV as a ranking signal since June 2021.** Thresholds identical to CONTRACT-PERFORMANCE.md:

| Metric | Good ✅ | Needs improvement ⚠️ | Poor ❌ |
|----------|--------|----------------|-----------|
| **LCP** | ≤2.5s | 2.5-4.0s | >4.0s |
| **INP** | ≤200ms | 200-500ms | >500ms |
| **CLS** | ≤0.1 | 0.1-0.25 | >0.25 |

**For SEO specifically:**
- Lighthouse SEO score: **target ≥90/100**
- Measure at the **75th percentile** (not the average) — this is the Google threshold

---

## 8. Images — SEO Optimization

> Source: Google Search Central — Images best practices (developers.google.com/search/docs/appearance/google-images)

```tsx
// ✅ next/image — automatic optimization (WebP, lazy loading, responsive)
import Image from 'next/image'

<Image
  src="/hero.jpg"
  alt="Precise and informative description of the image"  // required for image indexing
  width={1200}
  height={630}
  priority  // LCP image — do not lazy-load the hero
  sizes="(max-width: 768px) 100vw, 1200px"
/>

// ✅ Decorative images — exclude from image indexing
<Image src="/pattern.svg" alt="" role="presentation" />

// ❌ Native img tag — no optimization, no automatic lazy loading
// <img src="/hero.jpg" />
```

**Rules:**
- Descriptive `alt` on all informative images (dual role: SEO + accessibility)
- `priority` on the LCP image (above-the-fold)
- WebP or AVIF format (automatic with `next/image`)
- Descriptive file names (`hero-presentation.jpg` > `IMG_1234.jpg`)

---

## 9. Lighthouse SEO Checklist

```bash
# Lighthouse CLI
npx lighthouse https://www.exemple.com --only-categories=seo,performance \
  --output=json --output-path=lighthouse-report.json
```

| Check | Threshold |
|-------|-----------|
| `<title>` present and non-empty | Required |
| `<meta description>` present | Required |
| Links with descriptive text | Required |
| Images with `alt` | Required |
| HTTPS | Required |
| Valid robots.txt | Required |
| Lighthouse SEO score | ≥90/100 |

---

## Pre-Launch SEO Checklist

### Blockers

- [ ] No SEO-critical page with `use client` only
- [ ] Unique `<title>` on every page (50-60 chars)
- [ ] Unique `<meta description>` on every page (150-160 chars)
- [ ] Open Graph on all public pages (og:image 1200×630)
- [ ] `sitemap.xml` generated and accessible
- [ ] Valid `robots.txt`
- [ ] Google Search Console — sitemap submitted
- [ ] Core Web Vitals: LCP ≤2.5s, INP ≤200ms, CLS ≤0.1

### Important

- [ ] JSON-LD Organization on the homepage
- [ ] JSON-LD Article on blog pages
- [ ] Descriptive alt on all informative images
- [ ] Lighthouse SEO ≥90/100 (mobile AND desktop)
- [ ] Canonical URLs on pages with parameters

### Nice to have

- [ ] JSON-LD FAQ (if FAQ page)
- [ ] Hreflang (if multilingual)
- [ ] Google Rich Results Test — 0 errors

---

## Sources

| Reference | Link |
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

> **Last validated:** 2026-03-30 — Google Search Central, Core Web Vitals, JSON-LD spec, Next.js Metadata API, Open Graph Protocol