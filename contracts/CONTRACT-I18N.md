# Contrat — Internationalisation (i18n)

> Module de contrat SQWR Project Kit.
> Sources : Unicode CLDR (cldr.unicode.org), next-intl (next-intl.dev/docs), Google Search Central — hreflang (developers.google.com/search/docs/specialty/international), W3C Internationalization (w3.org/International), Common Sense Advisory — "Can't Read, Won't Buy" (2014), RGPD Article 7 (consentement dans la langue de l'utilisateur).

---

## Fondements scientifiques

**72% des consommateurs préfèrent acheter dans leur langue maternelle**, et 56% déclarent que la langue de l'interface est plus importante que le prix. (Common Sense Advisory, "Can't Read, Won't Buy", 2014 — étude sur 3000 consommateurs dans 10 pays)

**Obligation légale EU :** le consentement RGPD doit être présenté dans la langue de l'utilisateur (Article 7 + Considérant 32 du RGPD). Un cookie banner en anglais sur un site ciblant des francophones peut invalider le consentement.

---

## 1. Setup — next-intl (recommandé)

> Source : next-intl docs (next-intl.dev/docs/getting-started/app-router)

```bash
npm install next-intl
```

**Structure de fichiers :**
```
app/
  [locale]/
    layout.tsx        ← Provider i18n
    page.tsx
  layout.tsx          ← root layout (lang attribute)
messages/
  fr.json
  en.json
  nl.json
middleware.ts         ← détection de locale
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

## 2. Fichiers de traduction — Structure

**Règle : jamais de texte en dur dans les composants.** Même pour 1 seule langue : la préparer dès le départ coûte moins cher que de refactoriser après.

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
// Utilisation dans un Server Component
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

## 3. ICU Message Format — Pluriels et genre

> Source : Unicode CLDR — ICU Message Format (unicode-org.github.io/icu/userguide/format_parse/messages)
> Source : Unicode Plural Rules (unicode.org/cldr/charts/latest/supplemental/language_plural_rules.html)

**Pourquoi ICU > interpolation simple :** les règles de pluriel varient par langue. En russe, 1 = "файл", 2-4 = "файла", 5+ = "файлов". L'interpolation simple `{count} items` ne gère pas ces cas.

```json
{
  "items": "{count, plural, =0 {Aucun élément} one {# élément} other {# éléments}}",
  "greeting": "{gender, select, male {Bienvenu} female {Bienvenue} other {Bienvenu(e)}}",
  "last_seen": "{minutes, plural, one {Il y a # minute} other {Il y a # minutes}}"
}
```

**Règle :** toujours utiliser ICU pour les chaînes avec des variables numériques ou de genre.

---

## 4. Formatage — Dates, nombres, monnaies

> Source : MDN — Intl API (developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Global_Objects/Intl)
> Source : Unicode CLDR Locale Data (cldr.unicode.org)

**Ne jamais formatter les dates/nombres manuellement.** Utiliser `Intl` (natif, Unicode CLDR).

```typescript
// Dates
const date = new Date('2026-03-23')

new Intl.DateTimeFormat('fr-FR').format(date)  // "23/03/2026"
new Intl.DateTimeFormat('en-US').format(date)  // "3/23/2026"
new Intl.DateTimeFormat('fr-FR', { dateStyle: 'long' }).format(date)  // "23 mars 2026"

// Nombres
new Intl.NumberFormat('fr-FR').format(1234567.89)   // "1 234 567,89"
new Intl.NumberFormat('en-US').format(1234567.89)   // "1,234,567.89"

// Monnaies
new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR' }).format(49.99)
// "49,99 €"

new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(49.99)
// "$49.99"

// Dates relatives
const rtf = new Intl.RelativeTimeFormat('fr', { numeric: 'auto' })
rtf.format(-1, 'day')   // "hier"
rtf.format(-3, 'day')   // "il y a 3 jours"
```

```tsx
// Composant utilitaire avec next-intl
import { useFormatter } from 'next-intl'

export function Price({ amount, currency }: { amount: number; currency: string }) {
  const format = useFormatter()
  return <span>{format.number(amount, { style: 'currency', currency })}</span>
}
```

---

## 5. SEO i18n — hreflang

> Source : Google Search Central — "Tell Google about localized versions of your page" (developers.google.com/search/docs/specialty/international/localized-versions)

**hreflang est obligatoire pour les sites multilingues.** Sans lui, Google peut indexer la mauvaise version de langue et créer du duplicate content.

```tsx
// app/[locale]/page.tsx — metadata avec alternates
import { locales } from '@/i18n'

export async function generateMetadata({ params }: { params: { locale: string } }) {
  return {
    alternates: {
      canonical: `https://www.exemple.com/${params.locale}`,
      languages: Object.fromEntries(
        locales.map((locale) => [locale, `https://www.exemple.com/${locale}`])
      ),
    },
  }
}
// Génère : <link rel="alternate" hreflang="fr" href="https://www.exemple.com/fr" />
//          <link rel="alternate" hreflang="en" href="https://www.exemple.com/en" />
```

**Règle :** toujours inclure `x-default` pointant vers la locale par défaut.

---

## 6. Support RTL (Right-to-Left)

> Source : W3C Internationalization — "Styling HTML: the basics" (w3.org/International/tutorials/bidi-xhtml)

Langues RTL : arabe (ar), hébreu (he), persan (fa), ourdou (ur).

```tsx
// app/[locale]/layout.tsx — direction automatique
const rtlLocales = ['ar', 'he', 'fa', 'ur']

<html lang={locale} dir={rtlLocales.includes(locale) ? 'rtl' : 'ltr'}>
```

```css
/* Tailwind CSS — utiliser les variantes logiques, jamais left/right */

/* ❌ Hardcodé — cassé en RTL */
.card { margin-left: 16px; padding-right: 12px; }

/* ✅ Propriétés logiques — s'adapte automatiquement au dir */
.card { margin-inline-start: 16px; padding-inline-end: 12px; }

/* Tailwind : utiliser ms-* (margin-start) et me-* (margin-end) */
/* ❌ */ <div className="ml-4 pr-3">
/* ✅ */ <div className="ms-4 pe-3">
```

---

## Checklist pré-lancement i18n

### Bloquants

- [ ] 0 texte en dur dans les composants (`grep -r '"[A-Z]' app/` doit retourner 0 résultat)
- [ ] hreflang configuré sur toutes les pages publiques
- [ ] Formatage dates/nombres via `Intl` — jamais `toLocaleDateString()` sans locale explicite
- [ ] Cookie banner RGPD dans la langue de l'utilisateur

### Importants

- [ ] ICU pluriels pour toutes les chaînes avec variable numérique
- [ ] `lang` attribute correct sur `<html>` (ne pas laisser en `en` par défaut)
- [ ] Sitemap multilingue (une URL par locale)
- [ ] Test avec une locale différente de la locale de développement

### Souhaitables

- [ ] RTL supporté si des langues RTL sont prévues
- [ ] Deepl API configuré pour les traductions draft automatiques
- [ ] Pseudo-localisation pour détecter les strings non-traduits en staging

---

## Sources

| Référence | Lien |
|-----------|------|
| Unicode CLDR | cldr.unicode.org |
| ICU Message Format | unicode-org.github.io/icu/userguide/format_parse/messages |
| next-intl docs | next-intl.dev/docs |
| Google — hreflang | developers.google.com/search/docs/specialty/international |
| W3C Internationalization | w3.org/International |
| MDN — Intl API | developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Global_Objects/Intl |
| Common Sense Advisory 2014 | csa-research.com |
| RGPD Art. 7 — Consentement | eur-lex.europa.eu/legal-content/FR/TXT/?uri=CELEX:32016R0679 |
