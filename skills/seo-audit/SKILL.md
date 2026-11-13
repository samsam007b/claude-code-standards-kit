---
name: seo-audit
description: Audit SEO technique complet — Core Web Vitals, metadata Open Graph, structured data JSON-LD, sitemap, robots.txt, crawlabilité. Sources : Google Search Central, schema.org, OGP.
tags: [seo, metadata, performance, structured-data, sitemap, nextjs]
model: sonnet
---

# /seo-audit — Audit SEO Technique

## Quand utiliser

- Avant une mise en production d'une page ou site
- Audit SEO complet d'un projet Next.js
- Vérification Open Graph pour les partages sociaux
- Implémentation de structured data

## Critères d'audit

### Metadata (par page)
- [ ] `<title>` unique, 50–60 caractères, mot-clé principal en premier
- [ ] `<meta description>` unique, 150–160 caractères, call-to-action
- [ ] `og:title`, `og:description`, `og:image` (1200×630px min), `og:url`
- [ ] `twitter:card`, `twitter:title`, `twitter:description`, `twitter:image`
- [ ] `canonical` URL pour éviter le contenu dupliqué
- [ ] `hreflang` si multilingue

### Structured Data (schema.org + JSON-LD)
Types prioritaires selon le contenu :
- Pages produit/service → `Product`, `Service`, `Organization`
- Articles/blog → `Article`, `BlogPosting`
- FAQ → `FAQPage` + `Question` + `Answer`
- Profils → `Person`
- Listes → `ItemList`

### Core Web Vitals (Google ranking factor)
- LCP < 2.5s : image hero avec `priority`, fonts preload
- CLS < 0.1 : dimensions explicites sur images, pas d'injection DOM asynchrone
- INP < 200ms : événements non-bloquants, defer JS non-critique

### Crawlabilité
- [ ] `robots.txt` : `Allow: /` + `Disallow` sur les pages privées + `Sitemap:` pointeur
- [ ] `sitemap.xml` généré dynamiquement, soumis dans Search Console
- [ ] Pas de `noindex` sur des pages qui doivent être indexées
- [ ] Liens internes sur toutes les pages orphelines
- [ ] URL slug en kebab-case, descriptif, sans stopwords

### HTML réel livré au crawler (Next.js App Router — CRITIQUE)
Le sitemap/robots.txt/meta peuvent être parfaits et la page rester invisible si le HTML
serveur ne contient pas le contenu réel — un crawler sans JS (et la première passe de
Googlebot) ne voit que ce qui est dans le DOM, pas ce qui attend d'être hydraté.

Incident réel (projet Next.js) : un provider chargé via
`dynamic(() => import(...), { ssr: false })` enveloppait `{children}` dans le layout
racine → tout le contenu de l'app (homepage + pages profondes) bail-out du rendu serveur,
sitemap/robots pourtant nickel, indexation quasi nulle pendant des mois.

- [ ] `curl -s <url> | grep -A2 '<body'` → le texte visible (hors `<script>`/`<style>`)
      doit correspondre au contenu réel de la page, pas à un skeleton/loading state
- [ ] Compter les `<a href=` réels dans le body (hors script tags) — doit refléter la nav
      réelle, pas juste 0-1 lien (skip-link)
- [ ] Chercher `BAILOUT_TO_CLIENT_SIDE_RENDERING` dans le HTML brut — si présent
      immédiatement après l'ouverture de `<body>` ou avant `<main>`, un `ssr:false` en
      amont bloque tout ce qui suit
- [ ] Auditer tout `dynamic(..., { ssr: false })` qui accepte des `children` et vérifier
      qu'il ne les enveloppe pas (`<Comp>{children}</Comp>`) — seuls les composants
      feuilles (modales, cartes, graphiques, sans enfants passés par le parent) doivent
      utiliser `ssr:false`
- [ ] Comparer taille HTML avec UA navigateur vs `curl` sans UA — doivent être identiques
      (un shell minimal servi aux bots = red flag)

### Internationalisation
- [ ] `lang` sur `<html>` (ex: `lang="fr-BE"`)
- [ ] `hreflang` sur chaque variante linguistique
- [ ] URLs de type `/fr/page` ou `fr.domain.com`

## Format de sortie (Next.js)

```typescript
// generateMetadata example
export async function generateMetadata({ params }): Promise<Metadata> {
  return {
    title: '[Titre 50-60 chars]',
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
## SEO Audit — [page/site]

### Score : [0-100]
### 🔴 Bloquant | 🟡 Important | 🟢 Suggestion
### JSON-LD à ajouter
[code structured data]
```
