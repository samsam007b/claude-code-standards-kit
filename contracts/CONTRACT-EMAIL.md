# Contrat — Email Transactionnel

> Module de contrat SQWR Project Kit.
> Sources : RFC 5321 (SMTP), RFC 7489 (DMARC), RFC 8058 (List-Unsubscribe), Google Email Sender Guidelines 2024 (support.google.com/mail/answer/81126), react.email, Resend docs.

---

## Fondements

**L'email transactionnel est une fonctionnalité produit critique.** Un email de confirmation qui arrive en spam détruit le taux d'activation. Un bounce rate >2% dégrade la réputation d'envoi de façon durable.

Depuis **février 2024**, Google et Yahoo ont rendu obligatoires pour les expéditeurs >5000 emails/jour :
1. Authentification SPF
2. Authentification DKIM
3. Politique DMARC
4. Unsubscribe en un clic (RFC 8058)

**Ces exigences sont recommandées même en-dessous de 5000 emails/jour** pour protéger la deliverabilité dès le lancement.

---

## 1. Authentification DNS — SPF, DKIM, DMARC

> Source : Google Email Sender Guidelines (support.google.com/mail/answer/81126)
> Source : RFC 7489 — DMARC (ietf.org/rfc/rfc7489)

### SPF — Sender Policy Framework

Déclare quels serveurs sont autorisés à envoyer pour votre domaine.

```dns
# Enregistrement TXT sur votre domaine (exemple avec Resend)
exemple.com  TXT  "v=spf1 include:amazonses.com include:resend.com ~all"

# ~all = softfail (recommandé — moins agressif que -all au démarrage)
# -all = hardfail (cible finale une fois le domaine établi)
```

### DKIM — DomainKeys Identified Mail

Signature cryptographique sur chaque email. Vérifier que le fournisseur (Resend, SendGrid, etc.) génère les clés et que vous ajoutez les enregistrements DNS fournis.

```dns
# Exemple généré par Resend (à remplacer par les valeurs réelles)
resend._domainkey.exemple.com  CNAME  resend.domainkey.net
```

### DMARC — Domain-based Message Authentication

Politique qui dit aux serveurs quoi faire si SPF/DKIM échouent.

```dns
# Enregistrement TXT — configuration progressive
_dmarc.exemple.com  TXT  "v=DMARC1; p=none; rua=mailto:dmarc@exemple.com"

# Étapes de déploiement DMARC :
# 1. p=none  → monitoring uniquement (0 impact sur deliverabilité)
# 2. p=quarantine → emails suspects en spam (après vérification rapports)
# 3. p=reject → emails non-conformes rejetés (objectif final)
# rua = adresse pour recevoir les rapports d'agrégation
```

**Vérification :**
```bash
# Vérifier SPF
nslookup -type=TXT exemple.com

# Vérifier DMARC
nslookup -type=TXT _dmarc.exemple.com

# Outil en ligne : MXToolbox (mxtoolbox.com/SuperTool.aspx)
```

---

## 2. Fournisseur — Resend (recommandé pour Next.js)

> Source : Resend docs (resend.com/docs), React Email (react.email/docs)

```bash
npm install resend @react-email/components
```

```typescript
// lib/email.ts
import { Resend } from 'resend'

const resend = new Resend(process.env.RESEND_API_KEY)

export async function sendTransactionalEmail({
  to,
  subject,
  react,
}: {
  to: string
  subject: string
  react: React.ReactElement
}) {
  const { data, error } = await resend.emails.send({
    from: 'Nom App <noreply@exemple.com>',  // domaine vérifié dans Resend
    to,
    subject,
    react,
  })

  if (error) {
    // Logguer l'erreur mais ne pas exposer au client
    console.error('[email] Send failed:', error)
    throw new Error('Email send failed')
  }

  return data
}
```

**Domaines d'envoi recommandés :**
```
Transactionnel  → noreply@exemple.com     (confirmations, MFA, factures)
Marketing       → hello@mail.exemple.com  (campagnes, newsletters)
Support         → support@exemple.com     (tickets)

Règle : domaine d'envoi marketing séparé du domaine transactionnel.
Un bounce sur la newsletter ne doit pas pénaliser les emails de confirmation.
```

---

## 3. Templates — React Email

> Source : React Email (react.email), Email on Acid compatibility data

```tsx
// emails/WelcomeEmail.tsx
import {
  Body, Button, Container, Head, Heading,
  Html, Link, Preview, Section, Text,
} from '@react-email/components'

interface WelcomeEmailProps {
  userName: string
  confirmUrl: string
}

export default function WelcomeEmail({ userName, confirmUrl }: WelcomeEmailProps) {
  return (
    <Html lang="fr">
      <Head />
      <Preview>Confirmez votre compte — {userName}</Preview>
      <Body style={{ backgroundColor: '#f6f9fc', fontFamily: 'Arial, sans-serif' }}>
        <Container style={{ maxWidth: '600px', margin: '0 auto', padding: '20px' }}>
          <Heading style={{ color: '#1a1a1a', fontSize: '24px' }}>
            Bienvenue, {userName}
          </Heading>
          <Text style={{ color: '#444', fontSize: '16px', lineHeight: '1.6' }}>
            Confirmez votre adresse email pour activer votre compte.
          </Text>
          <Section>
            <Button
              href={confirmUrl}
              style={{
                backgroundColor: '#000',
                color: '#fff',
                padding: '12px 24px',
                borderRadius: '4px',
                textDecoration: 'none',
                display: 'inline-block',
              }}
            >
              Confirmer mon compte
            </Button>
          </Section>
          <Text style={{ color: '#888', fontSize: '12px' }}>
            Si le bouton ne fonctionne pas :{' '}
            <Link href={confirmUrl}>{confirmUrl}</Link>
          </Text>
        </Container>
      </Body>
    </Html>
  )
}
```

**Règles de compatibilité email :**
- Largeur max : **600px** (compatibilité universelle)
- CSS inline uniquement (la majorité des clients email ignorent `<style>`)
- `@react-email/components` gère la compatibilité automatiquement
- Tester sur : Litmus (litmus.com) ou Email on Acid (emailonacid.com)

---

## 4. Route API Next.js — Envoi

```typescript
// app/api/auth/confirm/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { sendTransactionalEmail } from '@/lib/email'
import WelcomeEmail from '@/emails/WelcomeEmail'

export async function POST(request: NextRequest) {
  const { email, userName, confirmUrl } = await request.json()

  // Validation obligatoire avant envoi (input sanitization)
  if (!email || !email.includes('@')) {
    return NextResponse.json({ error: 'Invalid email' }, { status: 400 })
  }

  try {
    await sendTransactionalEmail({
      to: email,
      subject: `Confirmez votre compte`,
      react: WelcomeEmail({ userName, confirmUrl }),
    })
    return NextResponse.json({ success: true })
  } catch {
    return NextResponse.json({ error: 'Email failed' }, { status: 500 })
  }
}
```

---

## 5. Gestion des bounces et unsubscribes

> Source : RFC 8058 — List-Unsubscribe (ietf.org/rfc/rfc8058)
> Source : RGPD Article 6 — base légale du traitement

### Bounces

| Type | Signification | Action |
|------|---------------|--------|
| **Hard bounce** | Adresse inexistante | Supprimer immédiatement de la liste |
| **Soft bounce** | Boîte pleine, serveur temporairement indispo | Retry 3× sur 48h, puis supprimer |

**Threshold critique : bounce rate <2%.** Au-delà, la réputation d'envoi se dégrade et Gmail commence à rejeter les emails.

```typescript
// Webhook Resend pour gérer les bounces automatiquement
// app/api/webhooks/resend/route.ts
export async function POST(request: NextRequest) {
  const event = await request.json()

  if (event.type === 'email.bounced') {
    // Marquer l'email comme invalide en base de données
    await markEmailAsBounced(event.data.email_id)
  }

  return NextResponse.json({ received: true })
}
```

### Unsubscribe (obligatoire — RFC 8058 + Google 2024)

Resend gère le `List-Unsubscribe` automatiquement si configuré. Pour les emails marketing (pas les transactionnels) :

```typescript
await resend.emails.send({
  from: 'hello@mail.exemple.com',
  to,
  subject,
  react: NewsletterEmail({ ... }),
  headers: {
    'List-Unsubscribe': '<https://exemple.com/unsubscribe?token=...>',
    'List-Unsubscribe-Post': 'List-Unsubscribe=One-Click',  // RFC 8058
  },
})
```

---

## 6. Thresholds de deliverabilité

> Source : Google Postmaster Tools guidelines, SendGrid Email Deliverability Guide (2024)

| Métrique | Seuil acceptable | Action si dépassé |
|----------|-----------------|-------------------|
| **Bounce rate** | <2% | Nettoyer la liste immédiatement |
| **Spam rate** | <0.1% | Revoir le contenu et les opt-ins |
| **Unsubscribe rate** | <0.5% | Revoir la fréquence et le ciblage |
| **Open rate** (transactionnel) | >50% | En-dessous : vérifier deliverabilité |
| **Open rate** (marketing) | >25% | En-dessous : retravailler le sujet/segment |

**Surveiller avec :** Google Postmaster Tools (postmaster.google.com) — gratuit, données sur la réputation de domaine.

---

## 7. Variables d'environnement

```bash
# .env.example
RESEND_API_KEY=re_xxxxxxxxxxxx          # Clé API Resend (jamais exposée côté client)
EMAIL_FROM=noreply@exemple.com          # Adresse d'envoi vérifiée dans Resend
EMAIL_FROM_NAME="Nom App"               # Nom affiché dans la boîte de réception
```

---

## Checklist pré-lancement Email

### Bloquants

- [ ] SPF configuré sur le domaine d'envoi
- [ ] DKIM configuré (enregistrements DNS fournis par le fournisseur)
- [ ] DMARC configuré (`p=none` au minimum pour monitoring)
- [ ] Domaine vérifié dans Resend/SendGrid
- [ ] Template testé sur Gmail, Outlook, Apple Mail (Litmus ou preview Resend)
- [ ] Lien de désabonnement présent dans les emails marketing
- [ ] `RESEND_API_KEY` dans les variables d'environnement (jamais hardcodée)

### Importants

- [ ] Domaine transactionnel séparé du domaine marketing
- [ ] Webhook bounce configuré → suppression automatique des hard bounces
- [ ] Google Postmaster Tools configuré pour surveillance
- [ ] DMARC passé à `p=quarantine` après 2 semaines de monitoring
- [ ] Email de confirmation testé de bout en bout (clic → activation compte)

### Souhaitables

- [ ] DMARC `p=reject` (objectif final)
- [ ] BIMI configuré (logo dans la boîte de réception — Gmail/Apple Mail)
- [ ] Litmus test sur 15+ clients email

---

## Sources

| Référence | Lien |
|-----------|------|
| Google Email Sender Guidelines 2024 | support.google.com/mail/answer/81126 |
| RFC 5321 — SMTP | ietf.org/rfc/rfc5321 |
| RFC 7489 — DMARC | ietf.org/rfc/rfc7489 |
| RFC 8058 — List-Unsubscribe | ietf.org/rfc/rfc8058 |
| Resend docs | resend.com/docs |
| React Email | react.email/docs |
| MXToolbox | mxtoolbox.com/SuperTool.aspx |
| Google Postmaster Tools | postmaster.google.com |
