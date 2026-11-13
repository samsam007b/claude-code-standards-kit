---
name: seo-audit
description: Complete technical SEO audit: Core Web Vitals, Open Graph metadata, JSON-LD structured data, sitemap, robots.txt, crawlability. Sources: Google Search Central, schema.org, OGP.
tags: [seo, metadata, performance, structured-data, sitemap, nextjs]
model: sonnet
---

# /seo-audit: Technical SEO Audit

## When to use

- Before putting a page or site into production
- Complete SEO audit of a Next.js project
- Open Graph verification for social sharing
- Implementing structured data

## Audit criteria

### Metadata (per page)
- [ ] Unique `<title>`, 50-60 characters, main keyword first
- [ ] Unique `<meta description>`, 150-160 characters, call-to-action
- [ ] `og:title`, `og:description`, `og:image` (1200×630px min), `og:url`
- [ ] `twitter:card`, `twitter:title`, `twitter:description`, `twitter:image`
- [ ] `canonical` URL to avoid duplicate content
- [ ] `hreflang` if multilingual

### Structured Data (schema.org + JSON-LD)
Priority types depending on content:
- Product/service pages → `Product`, `Service`, `Organization`
- Articles/blog → `Article`, `BlogPosting`
- FAQ → `FAQPage` + `Question` + `Answer`
- Profiles → `Person`
- Lists → `ItemList`

### Core Web Vitals (Google ranking factor)
- LCP < 2.5s: hero image with `priority`, fonts preload
- CLS < 0.1: explicit dimensions on images, no asynchronous DOM injection
- INP < 200ms: non-blocking events, defer non-critical JS

### Crawlability
- [ ] `robots.txt`: `Allow: /` + `Disallow` on private pages + `Sitemap:` pointer
- [ ] `sitemap.xml` generated dynamically, submitted in Search Console
- [ ] No `noindex` on pages that must be indexed
- [ ] Internal links to all orphan pages
- [ ] URL slug in kebab-case, descriptive, without stopwords

### Actual HTML delivered to the crawler (Next.js App Router, CRITICAL)
The sitemap/robots.txt/meta can be perfect and the page can still remain invisible if the
server HTML does not contain the actual content. A crawler without JS (and Googlebot's
first pass) only sees what is in the DOM, not what is waiting to be hydrated.

Real incident (Next.js project): a provider loaded via
`dynamic(() => import(...), { ssr: false })` wrapped `{children}` in the root layout
→ all of the app's content (homepage + deep pages) bailed out of server rendering,
with a flawless sitemap/robots, yet near-zero indexing for months.

- [ ] `curl -s <url> | grep -A2 '<body'` → the visible text (outside `<script>`/`<style>`)
      must match the actual page content, not a skeleton/loading state
- [ ] Count the actual `<a href=` in the body (outside script tags): it must reflect the real
      navigation, not just 0-1 links (skip-link)
- [ ] Look for `BAILOUT_TO_CLIENT_SIDE_RENDERING` in the raw HTML: if present
      right after the opening `<body>` or before `<main>`, an upstream `ssr:false`
      blocks everything that follows
- [ ] Audit every `dynamic(..., { ssr: false })` that accepts `children` and check
      that it does not wrap them (`<Comp>{children}</Comp>`): only leaf components
      (modals, maps, charts, with no children passed by the parent) should
      use `ssr:false`
- [ ] Compare HTML size with a browser UA vs `curl` without UA: they must be identical
      (a minimal shell served to bots is a red flag)

### Internationalization
- [ ] `lang` on `<html>` (e.g. `lang="fr-BE"`)
- [ ] `hreflang` on each language variant
- [ ] URLs like `/fr/page` or `fr.domain.com`

## Output format (Next.js)

```typescript
// generateMetadata example
export async function generateMetadata({ params }): Promise<Metadata> {
  return {
    title: '[Title 50-60 chars]',
    description: '[Description 150-160 chars]',
    openGraph: {
      title: '[OG Title]',
      description: '[OG Description]',
      images: [{ url: '/og-image.png', width: 1200, height: 630 }],
    },
  }
}
```

```
## SEO Audit: [page/site]

### Score : [0-100]
### 🔴 Blocking | 🟡 Important | 🟢 Suggestion
### JSON-LD to add
[structured data code]
```
