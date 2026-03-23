# Contract — PDF Generation

> SQWR Project Kit contract module.
> Sources: W3C CSS Paged Media Module Level 3 (w3.org/TR/css-page-3), MDN Web Docs Print CSS (developer.mozilla.org/en-US/docs/Web/CSS/CSS_paged_media), Puppeteer Documentation (pptr.dev), react-pdf (react-pdf.org).

---

## Foundations

Server-side PDF generation is a recurring need: branded reports, client quotes, results exports, contracts. Two main approaches dominate — HTML/CSS → PDF via headless browser, and React-to-PDF via dedicated libraries. **The choice of approach determines visual fidelity, maintainability, and performance.**

---

## 1. Choosing an Approach

| Approach | Stack | Use case | Visual fidelity |
|----------|-------|----------|----------------|
| **HTML/CSS → PDF** (Puppeteer/Playwright) | Node.js + CSS Paged Media | Complex branded reports, precise layout | ★★★★★ |
| **React → PDF** (react-pdf/renderer) | React + PDF primitives | Programmatic documents, dynamic data | ★★★★☆ |
| **PDF-lib** | Pure Node.js | Modifying existing PDFs, signatures | ★★★☆☆ |

**Selection rule:**
- Design that must faithfully match the existing web → **Puppeteer/Playwright**
- Native-structured PDF document (not a web clone) → **react-pdf**
- Modifying/merging existing PDFs → **pdf-lib**

---

## 2. HTML/CSS → PDF Approach (Puppeteer)

> Source: Puppeteer — [pptr.dev](https://pptr.dev), W3C CSS Paged Media — [w3.org/TR/css-page-3](https://www.w3.org/TR/css-page-3/)

### Next.js Setup (API Route)

```typescript
// app/api/generate-pdf/route.ts
import puppeteer from 'puppeteer'
import { NextRequest, NextResponse } from 'next/server'

export async function POST(req: NextRequest) {
  const { data } = await req.json()

  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox'],  // Required on Vercel/Cloud
  })

  const page = await browser.newPage()

  // Inject report HTML
  await page.setContent(generateReportHTML(data), {
    waitUntil: 'networkidle0',  // Wait for fonts and images
  })

  const pdf = await page.pdf({
    format: 'A4',
    printBackground: true,  // CRITICAL: include background colors and gradients
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
      © ${new Date().getFullYear()} — Confidential report
    </div>`,
  })

  await browser.close()

  return new NextResponse(pdf, {
    headers: {
      'Content-Type': 'application/pdf',
      'Content-Disposition': 'attachment; filename="report.pdf"',
    },
  })
}
```

### CSS Paged Media — W3C Standards

> Source: W3C CSS Paged Media Module Level 3 — [w3.org/TR/css-page-3](https://www.w3.org/TR/css-page-3/)

```css
/* styles/print.css — W3C print rules */

@page {
  size: A4;
  margin: 20mm 15mm;

  /* Native @page headers/footers */
  @top-right {
    content: counter(page) " / " counter(pages);
    font-size: 9pt;
    color: #999;
  }
}

@page :first {
  margin-top: 0;  /* No margin on the first page (cover) */
}

/* Page break control */
.page-break-before { break-before: page; }
.page-break-after  { break-after: page; }
.no-break          { break-inside: avoid; }  /* Prevents splitting a block across 2 pages */

/* Sections that must not be split */
.card, .table-row, .section-header {
  break-inside: avoid;
}

/* Headings — always kept with their content */
h1, h2, h3 {
  break-after: avoid;  /* No page break after a heading */
}

/* Hide UI elements not relevant for print */
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

## 3. React → PDF Approach (react-pdf)

> Source: react-pdf — [react-pdf.org](https://react-pdf.org) — React PDF Renderer v3.x

```tsx
// components/ReportPDF.tsx
import { Document, Page, Text, View, StyleSheet, Image, Font } from '@react-pdf/renderer'

// Register custom fonts
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

        {/* Header with logo */}
        <View style={styles.header}>
          <Image src="/logo.png" style={styles.logo} />
          <Text style={{ fontSize: 10, color: '#999' }}>
            {new Date().toLocaleDateString('fr-BE')}
          </Text>
        </View>

        {/* Overall score */}
        <Text style={styles.title}>Overall score: {data.score}/100</Text>
        <View style={styles.scoreBar}>
          <View style={[styles.scoreBarFilled, { width: `${data.score}%` }]} />
        </View>

      </Page>
    </Document>
  )
}
```

### Generation in API Route

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
      'Content-Disposition': `attachment; filename="report-${Date.now()}.pdf"`,
    },
  })
}
```

---

## 4. Design System in the PDF

> Source: W3C CSS Paged Media, Puppeteer printBackground

**Critical rule: the PDF must respect the same design system as the application.**

```css
/* print.css — CSS variables replicated for print */
:root {
  --brand-primary: #1600FF;
  --brand-secondary: #001489;
  --text-primary: #222223;
  --text-secondary: #666;
  --surface: #F8F8FF;
}

/* Scores with semantic colours */
.score-excellent { color: #00AC00; }  /* > 80% */
.score-good      { color: #FFB639; }  /* 60-80% */
.score-poor      { color: #FF4D00; }  /* < 60% */
```

**For Puppeteer: always `printBackground: true`** — otherwise CSS backgrounds are ignored.

---

## 5. QR Codes in PDFs

> Source: qrcode (npmjs.com/package/qrcode), node-qrcode

```typescript
// Generate a QR code as a data URL (SVG or PNG)
import QRCode from 'qrcode'

const qrDataUrl = await QRCode.toDataURL('https://example.com/report/123', {
  width: 120,
  margin: 1,
  color: {
    dark: '#000000',
    light: '#FFFFFF',
  },
})

// Inject into Puppeteer HTML
const html = `<img src="${qrDataUrl}" width="120" height="120" alt="QR Code" />`

// Or in react-pdf
<Image src={qrDataUrl} style={{ width: 80, height: 80 }} />
```

---

## 6. Performance and Deployment

> Source: Vercel Documentation — Serverless Functions (vercel.com/docs/functions)

**Warning: Puppeteer is too heavy for Vercel Serverless (10s timeout, 250MB size limit).**

| Environment | Recommended solution |
|-------------|---------------------|
| Vercel Serverless | react-pdf (lightweight, pure JS) |
| Vercel Edge Functions | ❌ No Puppeteer |
| Vercel with Chromium | `@sparticuz/chromium` (20MB) |
| Railway / Render / VPS | Standard Puppeteer |

```typescript
// Puppeteer on Vercel — use @sparticuz/chromium
import chromium from '@sparticuz/chromium'
import puppeteer from 'puppeteer-core'

const browser = await puppeteer.launch({
  args: chromium.args,
  defaultViewport: chromium.defaultViewport,
  executablePath: await chromium.executablePath(),
  headless: chromium.headless,
})
```

**Performance thresholds:**
| Operation | Target threshold | Action if exceeded |
|-----------|-----------------|-------------------|
| Simple PDF generation (react-pdf) | < 2 seconds | Optimise custom fonts |
| Complex PDF generation (Puppeteer) | < 10 seconds | Use an async worker |
| PDF file size | < 5 MB | Compress images (< 72 DPI for screen, 150 DPI for print) |

---

## 7. PDF Accessibility

> Source: PDF/UA standard (ISO 14289-1), Adobe Accessibility (helpx.adobe.com/acrobat/using/create-verify-pdf-accessibility.html)

```typescript
// react-pdf — Always add accessibility metadata
<Document
  title="Compliance Report — Agoria Scan"
  author="Your Organisation"
  subject="Compliance diagnostic report"
  language="en"
>
```

**Minimum PDF accessibility checklist:**
- [ ] Document metadata filled in (title, author, language)
- [ ] Text is selectable (not a scanned image)
- [ ] Logical reading order (no randomly positioned elements)
- [ ] Decorative images hidden (alt="" or artifact)
- [ ] Text contrast ≥ 4.5:1 (WCAG AA — same rule as the web)

---

## 8. Pre-production Checklist

- [ ] `printBackground: true` (Puppeteer) or fonts registered (react-pdf)
- [ ] `break-inside: avoid` on cards and tables (no mid-block page breaks)
- [ ] Headers and footers with page numbers
- [ ] Design system consistent with the app (same colours/fonts)
- [ ] Performance < 10 seconds for generation
- [ ] File size < 5 MB
- [ ] Correct HTTP headers (`Content-Type: application/pdf`)
- [ ] Rate limiting on the generation endpoint (high server cost)
- [ ] Accessibility metadata filled in

---

## 9. Sources

| Reference | Link |
|-----------|------|
| W3C CSS Paged Media Module Level 3 | w3.org/TR/css-page-3 |
| MDN — CSS Paged Media | developer.mozilla.org/en-US/docs/Web/CSS/CSS_paged_media |
| Puppeteer Documentation | pptr.dev |
| react-pdf / @react-pdf/renderer | react-pdf.org |
| @sparticuz/chromium (Vercel) | npmjs.com/package/@sparticuz/chromium |
| pdf-lib | pdf-lib.js.org |
| qrcode (npm) | npmjs.com/package/qrcode |
| PDF/UA — ISO 14289-1 | pdfa.org/pdf-ua |
