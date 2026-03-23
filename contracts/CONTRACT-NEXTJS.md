# Contrat — Next.js App Router

> Module de contrat SQWR Project Kit — enrichi avec références scientifiques.
> Sources : Google Core Web Vitals (web.dev), Next.js Production Checklist, DebugBear, Google HEART Framework.

---

## Fondements scientifiques

**Un délai de 400ms réduit les recherches des utilisateurs de 0.44%** (Google Search, étude de performance). La performance n'est pas un luxe — c'est un facteur de rétention mesurable.

> "For 1 in 3 visitors, slow page load causes them to abandon a site" (Google, 2019)

---

## 1. Core Web Vitals — Seuils obligatoires

> Standard officiel Google (web.dev/vitals). Mesure au **75e percentile** des visites.
> Ces métriques influencent directement le ranking SEO (Google Search ranking signal depuis 2021).

| Métrique | Good ✅ | Needs Improvement ⚠️ | Poor ❌ | Ce qu'elle mesure |
|----------|---------|---------------------|---------|------------------|
| **LCP** (Largest Contentful Paint) | ≤2.5s | 2.5s–4s | >4s | Vitesse de chargement perçue |
| **INP** (Interaction to Next Paint) | ≤200ms | 200ms–500ms | >500ms | Réactivité aux interactions |
| **CLS** (Cumulative Layout Shift) | <0.1 | 0.1–0.25 | >0.25 | Stabilité visuelle |
| **TTFB** (Time to First Byte) | <600ms | 600ms–1.8s | >1.8s | Réponse serveur |

> ⚠️ **INP a remplacé FID (First Input Delay) le 12 mars 2024.** Toute documentation mentionnant FID comme Core Web Vital est obsolète.

**Budget First Load JS par page : <200KB** (cible professionnelle Vercel/Stripe/Airbnb).

**Lighthouse score targets :**
- Performance : >90
- Accessibility : >95
- Best Practices : >95
- SEO : >90

---

## 2. Stratégies de rendu — choisir le bon mode

| Stratégie | Quand l'utiliser | Next.js implementation |
|-----------|-----------------|----------------------|
| **SSR** (Server-Side Rendering) | Données dynamiques par user, SEO critique | `async` Server Component sans `cache` |
| **SSG** (Static Site Generation) | Contenu rarement modifié, performance max | `generateStaticParams()` + `revalidate: false` |
| **ISR** (Incremental Static Regeneration) | Contenu semi-statique (blog, catalogue) | `revalidate: 3600` (secondes) |
| **CSR** (Client-Side Rendering) | Dashboards authentifiés, pas d'SEO requis | `'use client'` + fetch dans useEffect |

**Règle par défaut : SSR.** Dégradation vers SSG ou ISR si la performance le justifie. CSR uniquement si l'authentification le rend inévitable.

---

## 3. Server Components vs Client Components

**Server Components d'abord. Client Components seulement si nécessaire.**

### `'use client'` autorisé UNIQUEMENT pour

- Gestionnaires d'événements utilisateur (`onClick`, `onSubmit`, `onChange`)
- Hooks React côté client (`useState`, `useEffect`, `useRef`, `useContext`)
- APIs browser (`window`, `document`, `navigator`, `localStorage`)
- Bibliothèques qui exigent le contexte client (Framer Motion, certains composants d'UI)

### Ne jamais faire

```tsx
// ❌ INTERDIT — casse le SSR et le SEO
const DynamicPage = dynamic(() => import('./MyPage'), { ssr: false })

// ❌ INTERDIT — composant client inutile (aucun hook, aucun événement)
'use client'
export default function StaticCard({ title }: { title: string }) {
  return <div>{title}</div>
}
```

### Toujours faire

```tsx
// ✅ Server Component par défaut (pas de directive)
export default async function Page() {
  const data = await fetch('https://api.example.com/data', { next: { revalidate: 3600 } })
  const json = await data.json()
  return <div>{json.title}</div>
}

// ✅ Client Component justifié
'use client'
export default function SearchInput() {
  const [query, setQuery] = useState('')
  return <input value={query} onChange={e => setQuery(e.target.value)} />
}
```

---

## 4. Structure App Router complète

```
src/app/
├── layout.tsx          → Layout racine (metadata globale, providers)
├── page.tsx            → Homepage — DOIT être Server Component
├── loading.tsx         → UI de chargement Suspense automatique
├── error.tsx           → Gestion erreurs (DOIT être 'use client')
├── not-found.tsx       → Page 404 personnalisée
├── global-error.tsx    → Erreurs layout racine
├── [locale]/           → Internationalisation si applicable
└── api/
    └── [route]/
        └── route.ts    → Route Handlers (GET, POST, PUT, DELETE)
```

**Patterns obligatoires :**
```tsx
// error.tsx — toujours 'use client'
'use client'
export default function Error({ error, reset }: { error: Error; reset: () => void }) {
  return (
    <div>
      <h2>Une erreur est survenue</h2>
      <button onClick={reset}>Réessayer</button>
    </div>
  )
}

// loading.tsx — skeleton UI automatique pendant le streaming
export default function Loading() {
  return <div className="animate-pulse">Chargement...</div>
}
```

---

## 5. Metadata et SEO

Toujours exporter `metadata` ou `generateMetadata` depuis chaque page :

```tsx
// ✅ Static metadata
export const metadata: Metadata = {
  title: 'Page Title | Site Name',
  description: '150-160 caractères maximum',
  openGraph: {
    title: '...',
    description: '...',
    images: [{ url: '/og-image.jpg', width: 1200, height: 630 }],
    type: 'website',
  },
  twitter: { card: 'summary_large_image' },
  alternates: { canonical: 'https://example.com/page' },
}

// ✅ Dynamic metadata (pages produit, blog)
export async function generateMetadata({ params }: { params: { slug: string } }): Promise<Metadata> {
  const post = await getPost(params.slug)
  return { title: post.title, description: post.excerpt }
}
```

**JSON-LD Schema obligatoire** pour les sites SQWR (LocalBusiness, CreativeWork) :
```tsx
// Dans layout.tsx
<script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify({
  "@context": "https://schema.org",
  "@type": "LocalBusiness",
  "name": "SQWR Studio",
  "url": "https://sqwr.be"
}) }} />
```

---

## 6. Middleware (Edge)

```typescript
// middleware.ts — s'exécute à la Edge avant chaque requête
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
  matcher: ['/dashboard/:path*', '/admin/:path*'],  // Scope minimal
}
```

---

## 7. Performance — bonnes pratiques

```tsx
// ✅ Images : always next/image
import Image from 'next/image'
<Image src="/hero.jpg" alt="Hero" width={1200} height={630} priority sizes="100vw" />

// ✅ Fonts : always next/font (zero layout shift)
import { Inter } from 'next/font/google'
const inter = Inter({ subsets: ['latin'], display: 'swap' })

// ✅ Lazy loading avec SSR activé
const HeavyComponent = dynamic(() => import('./HeavyComponent'))  // ssr: true par défaut
```

---

## 8. Conventions fichiers

| Convention | Règle |
|-----------|-------|
| Pages | `page.tsx` dans le dossier de la route |
| Layouts | `layout.tsx` |
| Composants | `PascalCase.tsx` dans `components/` |
| Utilitaires | `camelCase.ts` dans `lib/` |
| Types | `types.ts` ou `types/index.ts` |
| Server Actions | `actions.ts` dans le dossier concerné |
| Route groups | `(group)` — grouper sans affecter l'URL |

---

## 9. Sources

| Référence | Lien |
|-----------|------|
| Google Core Web Vitals | web.dev/articles/vitals |
| Next.js Production Checklist | nextjs.org/docs/app/guides/production-checklist |
| DebugBear — Next.js Performance | debugbear.com/blog/nextjs-performance |
| Google Search Blog — Page Speed | developers.google.com/search/blog/2019/04/user-experience-improvements-with-page |
| Google HEART Framework | research.google/pubs/measuring-the-user-experience-on-a-large-scale |
