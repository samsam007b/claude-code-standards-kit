# Contrat — Génération de PDF

> Module de contrat SQWR Project Kit.
> Sources : W3C CSS Paged Media Module Level 3 (w3.org/TR/css-page-3), MDN Web Docs Print CSS (developer.mozilla.org/en-US/docs/Web/CSS/CSS_paged_media), Puppeteer Documentation (pptr.dev), react-pdf (react-pdf.org).

---

## Fondements

La génération de PDF côté serveur est un besoin récurrent : rapports brandés, devis clients, exports de résultats, contrats. Deux approches principales dominent — HTML/CSS → PDF via headless browser, et React-to-PDF via librairies dédiées. **Le choix de l'approche conditionne la fidélité visuelle, la maintenabilité et les performances.**

---

## 1. Choix de l'Approche

| Approche | Stack | Cas d'usage | Fidélité visuelle |
|----------|-------|-------------|-----------------|
| **HTML/CSS → PDF** (Puppeteer/Playwright) | Node.js + CSS Paged Media | Rapports brandés complexes, mise en page précise | ★★★★★ |
| **React → PDF** (react-pdf/renderer) | React + PDF primitives | Documents programmatiques, données dynamiques | ★★★★☆ |
| **PDF-lib** | Node.js pur | Modification de PDFs existants, signatures | ★★★☆☆ |

**Règle de sélection :**
- Design fidèle au web existant → **Puppeteer/Playwright**
- Document PDF-natif structuré (pas un clone web) → **react-pdf**
- Modifier/fusionner des PDFs existants → **pdf-lib**

---

## 2. Approche HTML/CSS → PDF (Puppeteer)

> Source : Puppeteer — [pptr.dev](https://pptr.dev), W3C CSS Paged Media — [w3.org/TR/css-page-3](https://www.w3.org/TR/css-page-3/)

### Setup Next.js (API Route)

```typescript
// app/api/generate-pdf/route.ts
import puppeteer from 'puppeteer'
import { NextRequest, NextResponse } from 'next/server'

export async function POST(req: NextRequest) {
  const { data } = await req.json()

  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox'],  // Requis sur Vercel/Cloud
  })

  const page = await browser.newPage()

  // Injecter le HTML du rapport
  await page.setContent(generateReportHTML(data), {
    waitUntil: 'networkidle0',  // Attendre les fonts et images
  })

  const pdf = await page.pdf({
    format: 'A4',
    printBackground: true,  // CRUCIAL : inclure les couleurs de fond et gradients
    margin: {
      top: '20mm',
      bottom: '20mm',
      left: '15mm',
      right: '15mm',
    },
    displayHeaderFooter: true,
    headerTemplate: `<div style="font-size:9px; width:100%; text-align:right; padding-right:15mm; color:#999;">
      <span class="pageNumber"></span> / <span class="totalPages"></span>
    </div>`,
    footerTemplate: `<div style="font-size:9px; width:100%; text-align:center; color:#999;">
      © ${new Date().getFullYear()} — Rapport confidentiel
    </div>`,
  })

  await browser.close()

  return new NextResponse(pdf, {
    headers: {
      'Content-Type': 'application/pdf',
      'Content-Disposition': 'attachment; filename="rapport.pdf"',
    },
  })
}
```

### CSS Paged Media — Standards W3C

> Source : W3C CSS Paged Media Module Level 3 — [w3.org/TR/css-page-3](https://www.w3.org/TR/css-page-3/)

```css
/* styles/print.css — Règles d'impression W3C */

@page {
  size: A4;
  margin: 20mm 15mm;

  /* Headers/footers natifs @page */
  @top-right {
    content: counter(page) " / " counter(pages);
    font-size: 9pt;
    color: #999;
  }
}

@page :first {
  margin-top: 0;  /* Pas de margin sur la première page (cover) */
}

/* Contrôle des sauts de page */
.page-break-before { break-before: page; }
.page-break-after  { break-after: page; }
.no-break          { break-inside: avoid; }  /* Évite de couper un bloc en 2 pages */

/* Sections qui ne doivent pas être coupées */
.card, .table-row, .section-header {
  break-inside: avoid;
}

/* Titres — toujours avec leur contenu */
h1, h2, h3 {
  break-after: avoid;  /* Pas de saut de page après un titre */
}

/* Masquer les éléments UI non pertinents pour le print */
@media print {
  .no-print,
  nav,
  .sidebar,
  .cookie-banner,
  button:not(.print-visible) {
    display: none !important;
  }
}
```

---

## 3. Approche React → PDF (react-pdf)

> Source : react-pdf — [react-pdf.org](https://react-pdf.org) — React PDF Renderer v3.x

```tsx
// components/ReportPDF.tsx
import { Document, Page, Text, View, StyleSheet, Image, Font } from '@react-pdf/renderer'

// Enregistrer les fonts custom
Font.register({
  family: 'Inter',
  fonts: [
    { src: '/fonts/Inter-Regular.ttf', fontWeight: 'normal' },
    { src: '/fonts/Inter-Bold.ttf', fontWeight: 'bold' },
  ],
})

const styles = StyleSheet.create({
  page: {
    flexDirection: 'column',
    backgroundColor: '#FFFFFF',
    padding: '20mm',
    fontFamily: 'Inter',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 24,
    paddingBottom: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#E5E5E5',
  },
  logo: {
    width: 120,
    height: 40,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#0A0A0A',
    marginBottom: 8,
  },
  scoreBar: {
    height: 8,
    backgroundColor: '#E5E5E5',
    borderRadius: 4,
    marginVertical: 4,
  },
  scoreBarFilled: {
    height: 8,
    backgroundColor: '#1600FF',  // Brand color
    borderRadius: 4,
  },
})

export function ReportPDF({ data }: { data: ReportData }) {
  return (
    <Document>
      <Page size="A4" style={styles.page}>

        {/* Header avec logo */}
        <View style={styles.header}>
          <Image src="/logo.png" style={styles.logo} />
          <Text style={{ fontSize: 10, color: '#999' }}>
            {new Date().toLocaleDateString('fr-BE')}
          </Text>
        </View>

        {/* Score global */}
        <Text style={styles.title}>Score global : {data.score}/100</Text>
        <View style={styles.scoreBar}>
          <View style={[styles.scoreBarFilled, { width: `${data.score}%` }]} />
        </View>

      </Page>
    </Document>
  )
}
```

### Génération en API Route

```typescript
// app/api/generate-report/route.ts
import { renderToBuffer } from '@react-pdf/renderer'
import { ReportPDF } from '@/components/ReportPDF'

export async function POST(req: Request) {
  const data = await req.json()

  const buffer = await renderToBuffer(<ReportPDF data={data} />)

  return new Response(buffer, {
    headers: {
      'Content-Type': 'application/pdf',
      'Content-Disposition': `attachment; filename="rapport-${Date.now()}.pdf"`,
    },
  })
}
```

---

## 4. Design System dans le PDF

> Source : W3C CSS Paged Media, Puppeteer printBackground

**Règle critique : le PDF doit respecter le même design system que l'application.**

```css
/* print.css — Variables CSS répliquées pour le print */
:root {
  --brand-primary: #1600FF;
  --brand-secondary: #001489;
  --text-primary: #222223;
  --text-secondary: #666;
  --surface: #F8F8FF;
}

/* Scores avec couleurs sémantiques */
.score-excellent { color: #00AC00; }  /* > 80% */
.score-good      { color: #FFB639; }  /* 60-80% */
.score-poor      { color: #FF4D00; }  /* < 60% */
```

**Pour Puppeteer : toujours `printBackground: true`** — sinon les backgrounds CSS sont ignorés.

---

## 5. QR Codes dans les PDFs

> Source : qrcode (npmjs.com/package/qrcode), node-qrcode

```typescript
// Générer un QR code comme data URL (SVG ou PNG)
import QRCode from 'qrcode'

const qrDataUrl = await QRCode.toDataURL('https://example.com/report/123', {
  width: 120,
  margin: 1,
  color: {
    dark: '#000000',
    light: '#FFFFFF',
  },
})

// Injecter dans le HTML Puppeteer
const html = `<img src="${qrDataUrl}" width="120" height="120" alt="QR Code" />`

// Ou dans react-pdf
<Image src={qrDataUrl} style={{ width: 80, height: 80 }} />
```

---

## 6. Performance et Déploiement

> Source : Vercel Documentation — Serverless Functions (vercel.com/docs/functions)

**Attention : Puppeteer est trop lourd pour Vercel Serverless (timeout 10s, taille 250MB).**

| Environnement | Solution recommandée |
|---------------|---------------------|
| Vercel Serverless | react-pdf (léger, pur JS) |
| Vercel Edge Functions | ❌ Pas de Puppeteer |
| Vercel avec Chromium | `@sparticuz/chromium` (20MB) |
| Railway / Render / VPS | Puppeteer standard |

```typescript
// Puppeteer sur Vercel — utiliser @sparticuz/chromium
import chromium from '@sparticuz/chromium'
import puppeteer from 'puppeteer-core'

const browser = await puppeteer.launch({
  args: chromium.args,
  defaultViewport: chromium.defaultViewport,
  executablePath: await chromium.executablePath(),
  headless: chromium.headless,
})
```

**Thresholds de performance :**
| Opération | Threshold cible | Action si dépassé |
|-----------|-----------------|-------------------|
| Génération PDF simple (react-pdf) | < 2 secondes | Optimiser les fonts custom |
| Génération PDF complexe (Puppeteer) | < 10 secondes | Utiliser un worker asynchrone |
| Taille du fichier PDF | < 5 MB | Compresser les images (< 72 DPI pour screen, 150 DPI pour print) |

---

## 7. Accessibilité des PDFs

> Source : PDF/UA standard (ISO 14289-1), Adobe Accessibility (helpx.adobe.com/acrobat/using/create-verify-pdf-accessibility.html)

```typescript
// react-pdf — Toujours ajouter les métadonnées d'accessibilité
<Document
  title="Rapport de conformité — Agoria Scan"
  author="Votre Organisation"
  subject="Rapport de diagnostic conformité"
  language="fr"
>
```

**Checklist accessibilité PDF minimum :**
- [ ] Métadonnées du document renseignées (titre, auteur, langue)
- [ ] Texte sélectionnable (pas une image scannée)
- [ ] Ordre de lecture logique (pas des éléments positionnés aléatoirement)
- [ ] Images décoratives masquées (alt="" ou artifact)
- [ ] Contraste texte ≥ 4.5:1 (WCAG AA — même règle que le web)

---

## 8. Checklist pré-production

- [ ] `printBackground: true` (Puppeteer) ou fonts enregistrées (react-pdf)
- [ ] `break-inside: avoid` sur cartes et tableaux (pas de coupure en milieu de bloc)
- [ ] En-têtes et pieds de page avec numéros de page
- [ ] Design system cohérent avec l'app (mêmes couleurs/fonts)
- [ ] Performance < 10 secondes pour génération
- [ ] Taille du fichier < 5 MB
- [ ] Headers HTTP corrects (`Content-Type: application/pdf`)
- [ ] Rate limiting sur l'endpoint de génération (coût serveur élevé)
- [ ] Métadonnées accessibilité renseignées

---

## 9. Sources

| Référence | Lien |
|-----------|------|
| W3C CSS Paged Media Module Level 3 | w3.org/TR/css-page-3 |
| MDN — CSS Paged Media | developer.mozilla.org/en-US/docs/Web/CSS/CSS_paged_media |
| Puppeteer Documentation | pptr.dev |
| react-pdf / @react-pdf/renderer | react-pdf.org |
| @sparticuz/chromium (Vercel) | npmjs.com/package/@sparticuz/chromium |
| pdf-lib | pdf-lib.js.org |
| qrcode (npm) | npmjs.com/package/qrcode |
| PDF/UA — ISO 14289-1 | pdfa.org/pdf-ua |
