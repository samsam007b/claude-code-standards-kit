# Framework — Stratégie de Campagne

> Module de framework SQWR Project Kit.
> Sources : Google — See-Think-Do-Care framework (think.storage.googleapis.com), Forrester Research — Owned/Earned/Paid Media, Philip Kotler — *Marketing Management* (Pearson, 14e éd.), Baymard Institute — Conversion Funnel Research, Google Analytics 4 documentation (analytics.google.com/analytics/academy).

---

## Quand utiliser ce framework

Pour tout lancement de produit, campagne de génération de leads, ou événement nécessitant d'amener une audience vers une action mesurable. Ce framework structure le travail **avant de dépenser le premier euro en publicité**.

---

## 1. Le Modèle SEE–THINK–DO–CARE

> Source : Google — Think with Google — See-Think-Do-Care Framework
> [think.storage.googleapis.com/docs/see-think-do-care.pdf](https://think.storage.googleapis.com/docs/see-think-do-care.pdf)

### Les 4 phases

| Phase | Audience | Intention | Objectif |
|-------|----------|-----------|----------|
| **SEE** | La plus large audience possible | Passive — pas de comportement d'achat | Notoriété, découverte |
| **THINK** | Audience avec l'intention de chercher | Active — considération | Éduquer, comparer |
| **DO** | Audience avec intention d'acheter/agir | Forte — conversion | Convertir |
| **CARE** | Clients existants | Fidélisation | Retenir, upgrader |

### Application concrète par phase

```
SEE — Qui ne me connaît pas encore mais pourrait avoir besoin de moi ?
→ Canaux : Facebook/Instagram (reach), YouTube pre-roll, display
→ Contenu : brand awareness, valeurs, problème reconnaissable
→ KPI : impressions, reach, brand recall

THINK — Qui cherche une solution à mon problème ?
→ Canaux : Google Search, LinkedIn (B2B), SEO content
→ Contenu : guides comparatifs, études de cas, FAQ
→ KPI : CTR, temps sur page, abonnés newsletter

DO — Qui est prêt à agir ?
→ Canaux : Google Search (branded), email, retargeting
→ Contenu : offre claire, témoignages, démo/essai gratuit
→ KPI : conversions, leads, inscriptions, ventes

CARE — Comment garder et développer mes clients ?
→ Canaux : email CRM, notifications app, programme fidélité
→ Contenu : tips avancés, nouvelles features, contenus exclusifs
→ KPI : rétention, LTV, NPS, upsell rate
```

---

## 2. Architecture Paid–Owned–Earned

> Source : Forrester Research — "Defining Earned, Owned And Paid Media" (forrester.com)
> Source : Philip Kotler, *Marketing Management*, 14e éd. (Pearson, 2012)

| Type | Définition | Exemples | Avantage |
|------|------------|---------|---------|
| **PAID** | Médias achetés | Google Ads, LinkedIn Ads, Meta Ads, influenceurs | Rapidité, scalabilité, ciblage précis |
| **OWNED** | Médias possédés | Site web, newsletter, app, blog, SEO | Contrôle total, coût marginal faible, durabilité |
| **EARNED** | Médias méritées | Presse, partages sociaux, avis, bouche-à-oreille | Crédibilité maximale, coût nul |

**Règle de budget :** Un ratio déséquilibré crée une dépendance. Cible : **40% Paid / 40% Owned / 20% Earned** pour un lancement. Évoluer vers **20% Paid / 60% Owned / 20% Earned** en régime de croisière.

---

## 3. Funnel de Conversion — Template

### Modélisation du funnel

```
PAID MEDIA (acquisition)
        ↓
    LANDING PAGE (owned)
        ↓
    ACTION PRIMAIRE (gate — email / inscription / téléchargement)
        ↓
    ACTIVATION (premier usage significatif)
        ↓
    CTA SECONDAIRE (upsell / inscription événement / achat)
        ↓
    EMAIL NURTURING (owned)
        ↓
    CONVERSION FINALE ✅
        ↓
    FIDÉLISATION (CARE) → Référents → EARNED
```

### Template de calcul

```
Étape 1 — Visiteurs uniques           : [objectif]  → 100%
Étape 2 — Action primaire (gate)      : [objectif]  → [% objectif]
Étape 3 — Activation                  : [objectif]  → [% objectif]
Étape 4 — CTA secondaire cliqué       : [objectif]  → [% objectif]
Étape 5 — Conversion finale           : [objectif]  → [% objectif]

Pour atteindre [N] conversions :
Visiteurs nécessaires = N / (taux étape 2 × taux étape 3 × taux étape 4 × taux étape 5)
```

**Benchmarks sectoriels (B2B SaaS — Baymard / HubSpot Research) :**

| Étape | Benchmark B2B | Benchmark B2C |
|-------|---------------|---------------|
| Visiteur → Lead (gate) | 2–5% | 1–3% |
| Lead → Activation | 20–40% | 30–60% |
| Activation → Conversion finale | 5–15% | 2–8% |
| Taux d'ouverture email nurturing | 25–35% | 20–25% |

---

## 4. KPIs par Phase

> Source : Google Analytics 4 Academy (analytics.google.com/analytics/academy)

### Template KPI complet

```
CAMPAGNE : [Nom]
Période : [dates]
Objectif principal : [ex: 200 inscriptions à l'événement]

─────────────────────────────────────────────
PHASE SEE (Notoriété)
─────────────────────────────────────────────
Impressions totales         : objectif [N]  →  réel [N]
Reach unique                : objectif [N]  →  réel [N]
CPM (coût pour 1000 impr.)  : objectif <[€] →  réel [€]
Taux de mémorisation (brand recall) : +[%]

─────────────────────────────────────────────
PHASE THINK (Considération)
─────────────────────────────────────────────
CTR (Click-Through Rate)    : objectif >[%] →  réel [%]
Visiteurs uniques landing   : objectif [N]  →  réel [N]
Temps moyen sur page        : objectif >[s] →  réel [s]
Taux de rebond              : objectif <[%] →  réel [%]
Abonnés newsletter gagnés   : objectif [N]  →  réel [N]

─────────────────────────────────────────────
PHASE DO (Conversion)
─────────────────────────────────────────────
Taux de démarrage (action primaire)   : objectif [%]  →  réel [%]
Taux de complétion (action complète)  : objectif [%]  →  réel [%]
Emails capturés / Leads               : objectif [N]  →  réel [N]
Coût par lead (CPL)                   : objectif <[€] →  réel [€]
Conversions finales                   : objectif [N]  →  réel [N]
Coût par conversion (CPA)             : objectif <[€] →  réel [€]

─────────────────────────────────────────────
PHASE CARE (Fidélisation)
─────────────────────────────────────────────
Taux de rétention M+1                 : objectif >[%]
NPS (Net Promoter Score)              : objectif >[score]
Taux d'ouverture emails post-conv.    : objectif >[%]
Taux d'upsell / renouvellement        : objectif >[%]
```

---

## 5. Tracking Plan GA4

> Source : Google Analytics 4 Documentation — Events (developers.google.com/analytics/devguides/collection/ga4/events)

### Events obligatoires à configurer avant lancement

```typescript
// gtag.ts — Helper de tracking
export function trackEvent(
  eventName: string,
  params: Record<string, string | number | boolean> = {}
) {
  if (typeof window !== 'undefined' && window.gtag) {
    window.gtag('event', eventName, params)
  }
}

// Funnel events — à adapter au projet
trackEvent('page_view')

trackEvent('cta_clicked', {
  cta_text: 'Démarrer gratuitement',
  cta_location: 'hero',
})

trackEvent('form_started', {
  form_name: 'registration',
  step: 1,
})

trackEvent('form_completed', {
  form_name: 'registration',
  user_segment: 'pme',
})

trackEvent('scan_started', {
  source: 'landing_hero',
})

trackEvent('scan_completed', {
  score: 67,
  duration_seconds: 890,
})

trackEvent('pdf_downloaded', {
  report_type: 'compliance',
  score: 67,
})

trackEvent('event_signup', {
  source: 'post_scan_cta',
})
```

### Funnel de conversion GA4

```
Explorer → Funnel exploration → Créer un funnel avec les étapes :
  1. page_view (landing)
  2. cta_clicked
  3. form_completed
  4. [action principale complétée]
  5. [conversion finale]
```

---

## 6. Email Nurturing — Séquence Type

> Source : HubSpot — Email Marketing Benchmarks (hubspot.com/marketing-statistics)

**Règle : déclencher la séquence dès la capture email (action primaire).**

```
J+0  → Email 1 : Bienvenue + livrable immédiat (rapport, guide, accès)
       Objet : "[Prénom], votre [livrable] est prêt"
       CTA : Télécharger / Accéder

J+2  → Email 2 : Éducation sur le problème
       Objet : "3 choses que [cible] ignorent souvent sur [problème]"
       CTA : Lire l'article / Voir la vidéo

J+5  → Email 3 : Preuve sociale + bénéfice
       Objet : "Comment [client type] a [résultat en chiffres]"
       CTA : Lire le case study

J+8  → Email 4 : CTA conversion
       Objet : "[Prénom], une place vous attend le [date événement]"
       CTA : S'inscrire / Réserver / Acheter

J+12 → Email 5 : Urgence / Deadline (si applicable)
       Objet : "Plus que [N] places disponibles"
       CTA : Agir maintenant

J+15 → Email 6 : Last chance
       Objet : "Dernière chance — [bénéfice]"
       CTA : [action finale]
```

**Benchmarks emails B2B (HubSpot Research, 2025) :**
- Taux d'ouverture moyen : 28–35%
- Taux de clic moyen : 3–5%
- Meilleur jour d'envoi : mardi–jeudi
- Meilleure heure : 10h–11h ou 14h–15h (heure locale destinataire)

---

## 7. Checklist pré-lancement de campagne

### Technique (owned)
- [ ] Landing page en Server Component (SSR) pour le SEO
- [ ] Temps de chargement < 2.5s LCP (Google Core Web Vitals)
- [ ] GA4 configuré + Funnel exploration prêt
- [ ] Gate email (étape 0) fonctionnel et connecté au CRM/newsletter
- [ ] Email de confirmation automatique configuré

### Contenu (owned + earned)
- [ ] Message principal testé (5 secondes test — quelqu'un comprend l'offre en < 5s)
- [ ] Preuve sociale visible (témoignages, logos, chiffres)
- [ ] CTA clair et unique sur la landing (pas 3 CTAs en compétition)
- [ ] FAQ répondant aux 5 objections principales

### Paid
- [ ] Budget défini par phase (SEE / THINK / DO)
- [ ] Tracking pixels installés (Meta Pixel, LinkedIn Insight Tag, Google Ads)
- [ ] Audiences personnalisées configurées (visiteurs site, liste emails)
- [ ] Campagnes de retargeting prêtes pour les abandonneurs

### Légal
- [ ] Consentement marketing opt-in (RGPD Art. 7)
- [ ] Lien désabonnement dans chaque email (obligatoire)
- [ ] Données collectées documentées dans Privacy Policy

---

## 8. Rétrospective Post-Campagne

```
RÉTROSPECTIVE CAMPAGNE — [Nom]
Date : [fin de campagne]

OBJECTIFS vs RÉSULTATS
Objectif principal   : [N]  →  Résultat : [N]  →  Écart : [+/- %]
CPL (coût par lead)  : [€]  →  Résultat : [€]  →  Écart : [+/- %]
CPA (coût converti)  : [€]  →  Résultat : [€]  →  Écart : [+/- %]

CE QUI A FONCTIONNÉ :
→ [Canal / message / timing le plus performant]
→ [Segment d'audience le plus réactif]

CE QUI N'A PAS FONCTIONNÉ :
→ [Canal décevant + hypothèse]
→ [Message qui a sous-performé + hypothèse]

APPRENTISSAGES POUR LA PROCHAINE CAMPAGNE :
→ [Changement concret à apporter]
→ [Test A/B à lancer]

SCORE GLOBAL CAMPAGNE : ___/10
```

---

## Sources

| Référence | Lien |
|-----------|------|
| Google — See-Think-Do-Care Framework | think.storage.googleapis.com/docs/see-think-do-care.pdf |
| Forrester — Owned/Earned/Paid Media | forrester.com |
| Philip Kotler — *Marketing Management* (Pearson, 14e éd.) | — |
| Baymard Institute — Conversion Research | baymard.com/research |
| HubSpot — Email Marketing Benchmarks | hubspot.com/marketing-statistics |
| Google Analytics 4 Academy | analytics.google.com/analytics/academy |
| Google Core Web Vitals | web.dev/articles/vitals |
