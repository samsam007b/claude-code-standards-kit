# Framework — Campaign Strategy

> SQWR Project Kit framework module.
> Sources: Google — See-Think-Do-Care framework (think.storage.googleapis.com), Forrester Research — Owned/Earned/Paid Media, Philip Kotler — *Marketing Management* (Pearson, 14th ed.), Baymard Institute — Conversion Funnel Research, Google Analytics 4 documentation (analytics.google.com/analytics/academy).

---

## When to use this framework

For any product launch, lead generation campaign, or event requiring an audience to take a measurable action. This framework structures the work **before spending the first euro on advertising**.

---

## 1. The SEE–THINK–DO–CARE Model

> Source: Google — Think with Google — See-Think-Do-Care Framework
> [think.storage.googleapis.com/docs/see-think-do-care.pdf](https://think.storage.googleapis.com/docs/see-think-do-care.pdf)

### The 4 phases

| Phase | Audience | Intent | Objective |
|-------|----------|--------|-----------|
| **SEE** | The broadest possible audience | Passive — no purchase behavior | Awareness, discovery |
| **THINK** | Audience with research intent | Active — consideration | Educate, compare |
| **DO** | Audience with intent to buy/act | Strong — conversion | Convert |
| **CARE** | Existing customers | Loyalty | Retain, upgrade |

### Concrete application per phase

```
SEE — Who doesn't know me yet but might need me?
→ Channels: Facebook/Instagram (reach), YouTube pre-roll, display
→ Content: brand awareness, values, recognizable problem
→ KPIs: impressions, reach, brand recall

THINK — Who is looking for a solution to my problem?
→ Channels: Google Search, LinkedIn (B2B), SEO content
→ Content: comparison guides, case studies, FAQ
→ KPIs: CTR, time on page, newsletter subscribers

DO — Who is ready to act?
→ Channels: Google Search (branded), email, retargeting
→ Content: clear offer, testimonials, free demo/trial
→ KPIs: conversions, leads, sign-ups, sales

CARE — How do I retain and grow my customers?
→ Channels: CRM email, app notifications, loyalty program
→ Content: advanced tips, new features, exclusive content
→ KPIs: retention, LTV, NPS, upsell rate
```

---

## 2. Paid–Owned–Earned Architecture

> Source: Forrester Research — "Defining Earned, Owned And Paid Media" (forrester.com)
> Source: Philip Kotler, *Marketing Management*, 14th ed. (Pearson, 2012)

| Type | Definition | Examples | Advantage |
|------|------------|---------|-----------|
| **PAID** | Purchased media | Google Ads, LinkedIn Ads, Meta Ads, influencers | Speed, scalability, precise targeting |
| **OWNED** | Owned media | Website, newsletter, app, blog, SEO | Full control, low marginal cost, durability |
| **EARNED** | Earned media | Press, social shares, reviews, word-of-mouth | Maximum credibility, zero cost |

**Budget rule:** an unbalanced ratio creates dependency. Target: **40% Paid / 40% Owned / 20% Earned** for a launch. Evolve toward **20% Paid / 60% Owned / 20% Earned** at cruising speed.

---

## 3. Conversion Funnel — Template

### Funnel modeling

```
PAID MEDIA (acquisition)
        ↓
    LANDING PAGE (owned)
        ↓
    PRIMARY ACTION (gate — email / sign-up / download)
        ↓
    ACTIVATION (first meaningful use)
        ↓
    SECONDARY CTA (upsell / event sign-up / purchase)
        ↓
    EMAIL NURTURING (owned)
        ↓
    FINAL CONVERSION ✅
        ↓
    LOYALTY (CARE) → Referrers → EARNED
```

### Calculation template

```
Step 1 — Unique visitors          : [target]  → 100%
Step 2 — Primary action (gate)    : [target]  → [target %]
Step 3 — Activation               : [target]  → [target %]
Step 4 — Secondary CTA clicked    : [target]  → [target %]
Step 5 — Final conversion         : [target]  → [target %]

To reach [N] conversions:
Visitors needed = N / (step 2 rate × step 3 rate × step 4 rate × step 5 rate)
```

**Industry benchmarks (B2B SaaS — Baymard / HubSpot Research):**

| Step | B2B Benchmark | B2C Benchmark |
|------|---------------|---------------|
| Visitor → Lead (gate) | 2–5% | 1–3% |
| Lead → Activation | 20–40% | 30–60% |
| Activation → Final conversion | 5–15% | 2–8% |
| Nurturing email open rate | 25–35% | 20–25% |

---

## 4. KPIs by Phase

> Source: Google Analytics 4 Academy (analytics.google.com/analytics/academy)

### Complete KPI Template

```
CAMPAIGN: [Name]
Period: [dates]
Main objective: [e.g., 200 event registrations]

─────────────────────────────────────────────
PHASE SEE (Awareness)
─────────────────────────────────────────────
Total impressions               : target [N]  →  actual [N]
Unique reach                    : target [N]  →  actual [N]
CPM (cost per 1,000 impressions): target <[€] →  actual [€]
Brand recall rate               : +[%]

─────────────────────────────────────────────
PHASE THINK (Consideration)
─────────────────────────────────────────────
CTR (Click-Through Rate)        : target >[%] →  actual [%]
Unique landing page visitors    : target [N]  →  actual [N]
Average time on page            : target >[s] →  actual [s]
Bounce rate                     : target <[%] →  actual [%]
Newsletter subscribers gained   : target [N]  →  actual [N]

─────────────────────────────────────────────
PHASE DO (Conversion)
─────────────────────────────────────────────
Start rate (primary action)     : target [%]  →  actual [%]
Completion rate (full action)   : target [%]  →  actual [%]
Emails captured / Leads         : target [N]  →  actual [N]
Cost per lead (CPL)             : target <[€] →  actual [€]
Final conversions               : target [N]  →  actual [N]
Cost per conversion (CPA)       : target <[€] →  actual [€]

─────────────────────────────────────────────
PHASE CARE (Loyalty)
─────────────────────────────────────────────
M+1 retention rate              : target >[%]
NPS (Net Promoter Score)        : target >[score]
Post-conversion email open rate : target >[%]
Upsell / renewal rate           : target >[%]
```

---

## 5. GA4 Tracking Plan

> Source: Google Analytics 4 Documentation — Events (developers.google.com/analytics/devguides/collection/ga4/events)

### Mandatory events to configure before launch

```typescript
// gtag.ts — Tracking helper
export function trackEvent(
  eventName: string,
  params: Record<string, string | number | boolean> = {}
) {
  if (typeof window !== 'undefined' && window.gtag) {
    window.gtag('event', eventName, params)
  }
}

// Funnel events — adapt to the project
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

### GA4 conversion funnel

```
Explore → Funnel exploration → Create a funnel with the steps:
  1. page_view (landing)
  2. cta_clicked
  3. form_completed
  4. [primary action completed]
  5. [final conversion]
```

---

## 6. Email Nurturing — Standard Sequence

> Source: HubSpot — Email Marketing Benchmarks (hubspot.com/marketing-statistics)

**Rule: trigger the sequence immediately upon email capture (primary action).**

```
D+0  → Email 1: Welcome + immediate deliverable (report, guide, access)
       Subject: "[First name], your [deliverable] is ready"
       CTA: Download / Access

D+2  → Email 2: Education on the problem
       Subject: "3 things [target] often don't know about [problem]"
       CTA: Read the article / Watch the video

D+5  → Email 3: Social proof + benefit
       Subject: "How [typical client] achieved [result in numbers]"
       CTA: Read the case study

D+8  → Email 4: Conversion CTA
       Subject: "[First name], a spot is waiting for you on [event date]"
       CTA: Sign up / Book / Buy

D+12 → Email 5: Urgency / Deadline (if applicable)
       Subject: "Only [N] spots remaining"
       CTA: Act now

D+15 → Email 6: Last chance
       Subject: "Last chance — [benefit]"
       CTA: [final action]
```

**B2B email benchmarks (HubSpot Research, 2025):**
- Average open rate: 28–35%
- Average click rate: 3–5%
- Best day to send: Tuesday–Thursday
- Best time: 10am–11am or 2pm–3pm (recipient's local time)

---

## 7. Pre-launch Campaign Checklist

### Technical (owned)
- [ ] Landing page in Server Component (SSR) for SEO
- [ ] Load time < 2.5s LCP (Google Core Web Vitals)
- [ ] GA4 configured + Funnel exploration ready
- [ ] Email gate (step 0) functional and connected to CRM/newsletter
- [ ] Automatic confirmation email configured

### Content (owned + earned)
- [ ] Main message tested (5-second test — someone understands the offer in < 5s)
- [ ] Social proof visible (testimonials, logos, numbers)
- [ ] Clear and unique CTA on the landing page (not 3 competing CTAs)
- [ ] FAQ addressing the 5 main objections

### Paid
- [ ] Budget defined by phase (SEE / THINK / DO)
- [ ] Tracking pixels installed (Meta Pixel, LinkedIn Insight Tag, Google Ads)
- [ ] Custom audiences configured (site visitors, email list)
- [ ] Retargeting campaigns ready for drop-offs

### Legal
- [ ] Marketing opt-in consent (GDPR Art. 7)
- [ ] Unsubscribe link in every email (mandatory)
- [ ] Data collected documented in Privacy Policy

---

## 8. Post-Campaign Retrospective

```
CAMPAIGN RETROSPECTIVE — [Name]
Date: [end of campaign]

OBJECTIVES vs RESULTS
Main objective     : [N]  →  Result: [N]  →  Gap: [+/- %]
CPL (cost per lead): [€]  →  Result: [€]  →  Gap: [+/- %]
CPA (cost converted): [€] →  Result: [€]  →  Gap: [+/- %]

WHAT WORKED:
→ [Best-performing channel / message / timing]
→ [Most responsive audience segment]

WHAT DID NOT WORK:
→ [Underperforming channel + hypothesis]
→ [Message that underperformed + hypothesis]

LEARNINGS FOR THE NEXT CAMPAIGN:
→ [Concrete change to make]
→ [A/B test to run]

OVERALL CAMPAIGN SCORE: ___/10
```

---

## Sources

| Reference | Link |
|-----------|------|
| Google — See-Think-Do-Care Framework | think.storage.googleapis.com/docs/see-think-do-care.pdf |
| Forrester — Owned/Earned/Paid Media | forrester.com |
| Philip Kotler — *Marketing Management* (Pearson, 14th ed.) | — |
| Baymard Institute — Conversion Research | baymard.com/research |
| HubSpot — Email Marketing Benchmarks | hubspot.com/marketing-statistics |
| Google Analytics 4 Academy | analytics.google.com/analytics/academy |
| Google Core Web Vitals | web.dev/articles/vitals |
