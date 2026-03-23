# Contract — Internationalisation (i18n)

> SQWR Project Kit contract module.
> Sources: Unicode CLDR (cldr.unicode.org), next-intl (next-intl.dev/docs), Google Search Central — hreflang (developers.google.com/search/docs/specialty/international), W3C Internationalization (w3.org/International), Common Sense Advisory — "Can't Read, Won't Buy" (2014), GDPR Article 7 (consent in the user's language).

---

## Scientific Foundations

**72% of consumers prefer to buy in their native language**, and 56% state that the interface language matters more than price. (Common Sense Advisory, "Can't Read, Won't Buy", 2014 — study on 3,000 consumers in 10 countries)

**EU legal obligation:** GDPR consent must be presented in the user's language (Article 7 + Recital 32 of the GDPR). A cookie banner in English on a site targeting French speakers can invalidate consent.

---

## 1. Setup — next-intl (recommended)

> Source: next-intl docs (next-intl.dev/docs/getting-started/app-router)

```bash
npm install next-intl
```

**File structure:**
```
app/
  [locale]/
    layout.tsx        ← i18n Provider
    page.tsx
  layout.tsx          ← root layout (lang attribute)
messages/
  fr.json
  en.json
  nl.json
middleware.ts         ← locale detection
i18n.ts               ← configuration
```

```typescript
// i18n.ts
import { notFound } from 'next/navigation'
import { getRequestConfig } from 'next-intl/server'

export const locales = ['fr', 'en', 'nl'] as const
export type Locale = (typeof locales)[number]
export const defaultLocale: Locale = 'fr'

export default getRequestConfig(async ({ locale }) => {
  if (!locales.includes(locale as Locale)) notFound()
  return {
    messages: (await import(`./messages/${locale}.json`)).default,
  }
})
```

```typescript
// middleware.ts
import createMiddleware from 'next-intl/middleware'
import { locales, defaultLocale } from './i18n'

export default createMiddleware({
  locales,
  defaultLocale,
  localeDetection: true,  // detect via Accept-Language header
})

export const config = {
  matcher: ['/((?!api|_next|_vercel|.*\\..*).*)'],
}
```

```tsx
// app/[locale]/layout.tsx
import { NextIntlClientProvider } from 'next-intl'
import { getMessages } from 'next-intl/server'

export default async function LocaleLayout({
  children,
  params: { locale },
}: {
  children: React.ReactNode
  params: { locale: string }
}) {
  const messages = await getMessages()
  return (
    <html lang={locale}>
      <body>
        <NextIntlClientProvider messages={messages}>
          {children}
        </NextIntlClientProvider>
      </body>
    </html>
  )
}
```

---

## 2. Translation Files — Structure

**Rule: never hardcode text in components.** Even for a single language: preparing it from the start costs less than refactoring afterwards.

```json
// messages/fr.json
{
  "auth": {
    "login": "Se connecter",
    "logout": "Se déconnecter",
    "email": "Adresse email",
    "password": "Mot de passe",
    "errors": {
      "invalid_credentials": "Email ou mot de passe incorrect.",
      "email_required": "L'adresse email est requise."
    }
  },
  "dashboard": {
    "title": "Tableau de bord",
    "welcome": "Bonjour, {name} !",
    "items_count": "{count, plural, =0 {Aucun élément} one {# élément} other {# éléments}}"
  },
  "common": {
    "save": "Enregistrer",
    "cancel": "Annuler",
    "delete": "Supprimer",
    "loading": "Chargement..."
  }
}
```

```tsx
// Usage in a Server Component
import { useTranslations } from 'next-intl'

export default function DashboardPage() {
  const t = useTranslations('dashboard')
  return (
    <main>
      <h1>{t('title')}</h1>
      <p>{t('welcome', { name: 'Samuel' })}</p>
      <p>{t('items_count', { count: 5 })}</p>
    </main>
  )
}
```

---

## 3. ICU Message Format — Plurals and Gender

> Source: Unicode CLDR — ICU Message Format (unicode-org.github.io/icu/userguide/format_parse/messages)
> Source: Unicode Plural Rules (unicode.org/cldr/charts/latest/supplemental/language_plural_rules.html)

**Why ICU > simple interpolation:** plural rules vary by language. In Russian, 1 = "файл", 2-4 = "файла", 5+ = "файлов". Simple interpolation `{count} items` does not handle these cases.

```json
{
  "items": "{count, plural, =0 {Aucun élément} one {# élément} other {# éléments}}",
  "greeting": "{gender, select, male {Bienvenu} female {Bienvenue} other {Bienvenu(e)}}",
  "last_seen": "{minutes, plural, one {Il y a # minute} other {Il y a # minutes}}"
}
```

**Rule:** always use ICU for strings with numeric or gender variables.

---

## 4. Formatting — Dates, Numbers, Currencies

> Source: MDN — Intl API (developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Global_Objects/Intl)
> Source: Unicode CLDR Locale Data (cldr.unicode.org)

**Never format dates/numbers manually.** Use `Intl` (native, Unicode CLDR).

```typescript
// Dates
const date = new Date('2026-03-23')

new Intl.DateTimeFormat('fr-FR').format(date)  // "23/03/2026"
new Intl.DateTimeFormat('en-US').format(date)  // "3/23/2026"
new Intl.DateTimeFormat('fr-FR', { dateStyle: 'long' }).format(date)  // "23 mars 2026"

// Numbers
new Intl.NumberFormat('fr-FR').format(1234567.89)   // "1 234 567,89"
new Intl.NumberFormat('en-US').format(1234567.89)   // "1,234,567.89"

// Currencies
new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR' }).format(49.99)
// "49,99 €"

new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(49.99)
// "$49.99"

// Relative dates
const rtf = new Intl.RelativeTimeFormat('fr', { numeric: 'auto' })
rtf.format(-1, 'day')   // "hier"
rtf.format(-3, 'day')   // "il y a 3 jours"
```

```tsx
// Utility component with next-intl
import { useFormatter } from 'next-intl'

export function Price({ amount, currency }: { amount: number; currency: string }) {
  const format = useFormatter()
  return <span>{format.number(amount, { style: 'currency', currency })}</span>
}
```

---

## 5. SEO i18n — hreflang

> Source: Google Search Central — "Tell Google about localized versions of your page" (developers.google.com/search/docs/specialty/international/localized-versions)

**hreflang is mandatory for multilingual sites.** Without it, Google may index the wrong language version and create duplicate content.

```tsx
// app/[locale]/page.tsx — metadata with alternates
import { locales } from '@/i18n'

export async function generateMetadata({ params }: { params: { locale: string } }) {
  return {
    alternates: {
      canonical: `https://www.example.com/${params.locale}`,
      languages: Object.fromEntries(
        locales.map((locale) => [locale, `https://www.example.com/${locale}`])
      ),
    },
  }
}
// Generates: <link rel="alternate" hreflang="fr" href="https://www.example.com/fr" />
//            <link rel="alternate" hreflang="en" href="https://www.example.com/en" />
```

**Rule:** always include `x-default` pointing to the default locale.

---

## 6. RTL (Right-to-Left) Support

> Source: W3C Internationalization — "Styling HTML: the basics" (w3.org/International/tutorials/bidi-xhtml)

RTL languages: Arabic (ar), Hebrew (he), Persian (fa), Urdu (ur).

```tsx
// app/[locale]/layout.tsx — automatic direction
const rtlLocales = ['ar', 'he', 'fa', 'ur']

<html lang={locale} dir={rtlLocales.includes(locale) ? 'rtl' : 'ltr'}>
```

```css
/* Tailwind CSS — use logical variants, never left/right */

/* ❌ Hardcoded — broken in RTL */
.card { margin-left: 16px; padding-right: 12px; }

/* ✅ Logical properties — automatically adapts to dir */
.card { margin-inline-start: 16px; padding-inline-end: 12px; }

/* Tailwind: use ms-* (margin-start) and me-* (margin-end) */
/* ❌ */ <div className="ml-4 pr-3">
/* ✅ */ <div className="ms-4 pe-3">
```

---

## Pre-launch i18n Checklist

### Blockers

- [ ] 0 hardcoded text in components (`grep -r '"[A-Z]' app/` must return 0 results)
- [ ] hreflang configured on all public pages
- [ ] Date/number formatting via `Intl` — never `toLocaleDateString()` without explicit locale
- [ ] GDPR cookie banner in the user's language

### Important

- [ ] ICU plurals for all strings with numeric variables
- [ ] Correct `lang` attribute on `<html>` (do not leave as `en` by default)
- [ ] Multilingual sitemap (one URL per locale)
- [ ] Test with a locale different from the development locale

### Desirable

- [ ] RTL supported if RTL languages are planned
- [ ] Deepl API configured for automatic draft translations
- [ ] Pseudo-localization to detect untranslated strings in staging

---

## Sources

| Reference | Link |
|-----------|------|
| Unicode CLDR | cldr.unicode.org |
| ICU Message Format | unicode-org.github.io/icu/userguide/format_parse/messages |
| next-intl docs | next-intl.dev/docs |
| Google — hreflang | developers.google.com/search/docs/specialty/international |
| W3C Internationalization | w3.org/International |
| MDN — Intl API | developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Global_Objects/Intl |
| Common Sense Advisory 2014 | csa-research.com |
| GDPR Art. 7 — Consent | eur-lex.europa.eu/legal-content/FR/TXT/?uri=CELEX:32016R0679 |
