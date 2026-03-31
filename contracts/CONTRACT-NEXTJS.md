# Contract — Next.js App Router

> SQWR Project Kit contract module — enriched with scientific references.
> Sources: Google Core Web Vitals (web.dev), Next.js Production Checklist, DebugBear, Google HEART Framework.

---

## Foundations

**A 400ms delay reduces user searches by 0.44%** (Google Search, performance study). Performance is not a luxury — it is a measurable retention factor.

> "For 1 in 3 visitors, slow page load causes them to abandon a site" (Google, 2019)

---

## 1. Core Web Vitals — Mandatory Thresholds

> Official Google standard (web.dev/vitals). Measured at the **75th percentile** of visits.
> These metrics directly influence SEO ranking (Google Search ranking signal since 2021).

| Metric | Good ✅ | Needs Improvement ⚠️ | Poor ❌ | What it measures |
|--------|---------|---------------------|---------|-----------------|
| **LCP** (Largest Contentful Paint) | ≤2.5s | 2.5s–4s | >4s | Perceived load speed |
| **INP** (Interaction to Next Paint) | ≤200ms | 200ms–500ms | >500ms | Interaction responsiveness |
| **CLS** (Cumulative Layout Shift) | <0.1 | 0.1–0.25 | >0.25 | Visual stability |
| **TTFB** (Time to First Byte) | <600ms | 600ms–1.8s | >1.8s | Server response |

> ⚠️ **INP replaced FID (First Input Delay) on March 12, 2024.** Any documentation mentioning FID as a Core Web Vital is outdated.

**First Load JS budget per page: <200KB** (professional target — Vercel/Stripe/Airbnb).

**Lighthouse score targets:**
- Performance: >90
- Accessibility: >95
- Best Practices: >95
- SEO: >90

---

## 2. Rendering Strategies — Choosing the Right Mode

| Strategy | When to use | Next.js implementation |
|----------|------------|----------------------|
| **SSR** (Server-Side Rendering) | Per-user dynamic data, critical SEO | `async` Server Component without `cache` |
| **SSG** (Static Site Generation) | Rarely updated content, maximum performance | `generateStaticParams()` + `revalidate: false` |
| **ISR** (Incremental Static Regeneration) | Semi-static content (blog, catalogue) | `revalidate: 3600` (seconds) |
| **CSR** (Client-Side Rendering) | Authenticated dashboards, no SEO required | `'use client'` + fetch in useEffect |

**Default rule: SSR.** Degrade to SSG or ISR when performance justifies it. CSR only when authentication makes it unavoidable.

---

## 3. Server Components vs Client Components

**Server Components first. Client Components only when necessary.**

### `'use client'` permitted ONLY for

- User event handlers (`onClick`, `onSubmit`, `onChange`)
- Client-side React hooks (`useState`, `useEffect`, `useRef`, `useContext`)
- Browser APIs (`window`, `document`, `navigator`, `localStorage`)
- Libraries that require client context (Framer Motion, certain UI components)

### Never do

```tsx
// ❌ FORBIDDEN — breaks SSR and SEO
const DynamicPage = dynamic(() => import('./MyPage'), { ssr: false })

// ❌ FORBIDDEN — unnecessary client component (no hooks, no events)
'use client'
export default function StaticCard({ title }: { title: string }) {
  return <div>{title}</div>
}
```

### Always do

```tsx
// ✅ Server Component by default (no directive)
export default async function Page() {
  const data = await fetch('https://api.example.com/data', { next: { revalidate: 3600 } })
  const json = await data.json()
  return <div>{json.title}</div>
}

// ✅ Justified Client Component
'use client'
export default function SearchInput() {
  const [query, setQuery] = useState('')
  return <input value={query} onChange={e => setQuery(e.target.value)} />
}
```

---

## 4. Complete App Router Structure

```
src/app/
├── layout.tsx          → Root layout (global metadata, providers)
├── page.tsx            → Homepage — MUST be a Server Component
├── loading.tsx         → Automatic Suspense loading UI
├── error.tsx           → Error handling (MUST be 'use client')
├── not-found.tsx       → Custom 404 page
├── global-error.tsx    → Root layout errors
├── [locale]/           → Internationalisation if applicable
└── api/
    └── [route]/
        └── route.ts    → Route Handlers (GET, POST, PUT, DELETE)
```

**Mandatory patterns:**
```tsx
// error.tsx — always 'use client'
'use client'
export default function Error({ error, reset }: { error: Error; reset: () => void }) {
  return (
    <div>
      <h2>An error occurred</h2>
      <button onClick={reset}>Try again</button>
    </div>
  )
}

// loading.tsx — automatic skeleton UI during streaming
export default function Loading() {
  return <div className="animate-pulse">Loading...</div>
}
```

---

## 5. Metadata and SEO

Always export `metadata` or `generateMetadata` from each page:

```tsx
// ✅ Static metadata
export const metadata: Metadata = {
  title: 'Page Title | Site Name',
  description: '150-160 characters maximum',
  openGraph: {
    title: '...',
    description: '...',
    images: [{ url: '/og-image.jpg', width: 1200, height: 630 }],
    type: 'website',
  },
  twitter: { card: 'summary_large_image' },
  alternates: { canonical: 'https://example.com/page' },
}

// ✅ Dynamic metadata (product pages, blog)
export async function generateMetadata({ params }: { params: { slug: string } }): Promise<Metadata> {
  const post = await getPost(params.slug)
  return { title: post.title, description: post.excerpt }
}
```

**Mandatory JSON-LD Schema** for SQWR sites (LocalBusiness, CreativeWork):
```tsx
// In layout.tsx — structured data injection for SEO
<script
  type="application/ld+json"
  dangerouslySetInnerHTML={{
    __html: JSON.stringify({
      "@context": "https://schema.org",
      "@type": "LocalBusiness",
      "name": "[YOUR COMPANY NAME]",
      "url": "https://[your-domain].com"
    })
  }}
/>
```

---

## 6. Middleware (Edge)

```typescript
// middleware.ts — runs at the Edge before each request
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  // Auth check (Supabase session)
  const token = request.cookies.get('sb-access-token')
  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url))
  }
  return NextResponse.next()
}

export const config = {
  matcher: ['/dashboard/:path*', '/admin/:path*'],  // Minimal scope
}
```

---

## 7. Performance — Best Practices

```tsx
// ✅ Images: always next/image
import Image from 'next/image'
<Image src="/hero.jpg" alt="Hero" width={1200} height={630} priority sizes="100vw" />

// ✅ Fonts: always next/font (zero layout shift)
import { Inter } from 'next/font/google'
const inter = Inter({ subsets: ['latin'], display: 'swap' })

// ✅ Lazy loading with SSR enabled
const HeavyComponent = dynamic(() => import('./HeavyComponent'))  // ssr: true by default
```

---

## 8. File Conventions

| Convention | Rule |
|-----------|------|
| Pages | `page.tsx` in the route folder |
| Layouts | `layout.tsx` |
| Components | `PascalCase.tsx` in `components/` |
| Utilities | `camelCase.ts` in `lib/` |
| Types | `types.ts` or `types/index.ts` |
| Server Actions | `actions.ts` in the relevant folder |
| Route groups | `(group)` — group without affecting the URL |

---

## 9. Sources

| Reference | Link |
|-----------|------|
| Google Core Web Vitals | web.dev/articles/vitals |
| Next.js Production Checklist | nextjs.org/docs/app/guides/production-checklist |
| DebugBear — Next.js Performance | debugbear.com/blog/nextjs-performance |
| Google Search Blog — Page Speed | developers.google.com/search/blog/2019/04/user-experience-improvements-with-page |
| Google HEART Framework | research.google/pubs/measuring-the-user-experience-on-a-large-scale |

> **Last validated:** 2026-03-30 — Next.js docs, React docs, W3C, Vercel, Google Core Web Vitals, Google HEART Framework