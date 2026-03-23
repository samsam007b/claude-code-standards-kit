# Contrat — Pricing & Monétisation

> Module de contrat SQWR Project Kit.
> Sources : Van Westendorp — Price Sensitivity Meter (ESOMAR, 1976), Price Intelligently / ProfitWell — SaaS Pricing Report (2020), Simon-Kucher & Partners — Pricing Power Research, Kahneman & Tversky — "Judgment under Uncertainty" (Science, 1974), Christoph Janz — "5 Ways to Build a $100M Business" (Point Nine Capital, 2014), SaaStr — SaaS Benchmarks (saastr.com).

---

## Fondements scientifiques

**"Pricing is the most powerful lever in SaaS."** Une amélioration de 1% du pricing génère en moyenne **4x plus d'impact** sur le profit qu'une amélioration de 1% de l'acquisition. (Price Intelligently / ProfitWell, 2016)

L'erreur classique des startups : fixer le prix sur les coûts (cost-plus pricing) plutôt que sur la valeur perçue. Le prix doit refléter **la valeur créée pour le client**, pas les coûts de production.

**Biais d'ancrage** (Kahneman & Tversky, Science, 1974) : le premier prix vu ancre irrémédiablement la perception. L'ordre d'affichage des tiers impacte directement les conversions.

---

## 1. Van Westendorp — Price Sensitivity Meter

> Source : Peter Van Westendorp — "NSS-Price Sensitivity Meter" (ESOMAR, 1976)
> Norme : 30 répondants minimum pour des résultats statistiquement interprétables

**4 questions à poser dans un survey (avant de fixer le prix) :**

```
Q1 — "À quel prix ce produit serait-il trop cher pour que vous l'envisagiez ?"
     → Rejet par coût élevé

Q2 — "À quel prix commenceriez-vous à trouver ce produit cher, mais l'achèteriez quand même ?"
     → Cher mais acceptable

Q3 — "À quel prix penseriez-vous que ce produit est une bonne affaire ?"
     → Bon rapport qualité/prix

Q4 — "À quel prix ce produit serait-il si bon marché que vous douteriez de sa qualité ?"
     → Rejet par prix trop bas (signal de mauvaise qualité)
```

**Interprétation graphique :**
```
Tracer les 4 courbes cumulatives.
Intersection Q1 et Q4 → Point of Marginal Cheapness (PMC)
Intersection Q2 et Q3 → Point of Marginal Expensiveness (PME)
Zone entre PMC et PME → Zone de prix acceptable
```

**Zone optimale :** entre le PMC et le PME. Le prix optimal se situe souvent légèrement au-dessus du PMC (éviter la perception de mauvaise qualité).

---

## 2. Value-Based Pricing — Calculer l'EVC

> Source : Thomas Nagle — *The Strategy and Tactics of Pricing* (Routledge, 2016)
> Source : Simon-Kucher & Partners — Value-Based Pricing Framework

**Economic Value to Customer (EVC) :**
```
EVC = Référence économique de la meilleure alternative
    + Valeur de différenciation (positif ou négatif)
```

**Règle d'or : capturer 10-20% de la valeur créée pour le client.** (Simon-Kucher benchmark)

### Template de calcul EVC

```
PRODUIT : [Nom]
SEGMENT CIBLE : [Description précise]

1. Coût de la meilleure alternative actuelle pour le client :
   Alternative : [ex : faire manuellement, outil concurrent]
   Coût annuel (temps × taux horaire + abonnement) : [€]

2. Valeur de différenciation apportée :
   + Gain de temps : [heures/mois × taux horaire = €/an]
   + Réduction d'erreurs : [€ de risque évité]
   + Nouvelle valeur créée : [€ de revenus générés]
   - Coût de migration : [€]
   - Courbe d'apprentissage : [heures × taux horaire = €]

3. EVC total = Alternative + Différenciation = [€/an]

4. Prix recommandé = EVC × 10-20% = [€/an]
```

---

## 3. Structure de prix — 3 Tiers (Good/Better/Best)

> Source : Simon-Kucher & Partners — "Monetize!" (Wiley, 2012)
> Source : Bain & Company — Pricing Research

**3 tiers est le format optimal.** 2 tiers = peu de choix, difficile d'ancrer. 4+ tiers = paralysie du choix. (Bain & Company pricing research)

**Ordre d'affichage : toujours du plus cher au moins cher.** L'ancrage cognitif fait que le premier prix vu devient la référence — afficher le prix élevé en premier rend le prix moyen plus attractif.

```
┌─────────────┬─────────────┬─────────────┐
│   BUSINESS  │     PRO     │   STARTER   │
│  "Best"     │  "Better"   │   "Good"    │
│  149€/mois  │  49€/mois   │  19€/mois   │
│  [mis en    │  ← POUSSER  │  [point     │
│   avant]    │   CE TIER   │  d'entrée]  │
└─────────────┴─────────────┴─────────────┘
```

**Decoy pricing :** le tier "Pro" (milieu) doit être conçu pour rendre le tier "Business" attractif. Si Business = 3x Pro mais 5x les features → "Pro semble une mauvaise affaire".

**Règle :** jamais retirer artificiellement des features du tier bas pour forcer l'upgrade. Différencier par les limites d'usage (volume, utilisateurs, projets), pas par la suppression de fonctionnalités critiques.

---

## 4. Modèles SaaS — Freemium vs Trial vs Paid

> Source : Christoph Janz — "5 Ways to Build a $100M Business" (Point Nine Capital, 2014)
> Source : ProfitWell — "The State of Freemium" (2020)

| Modèle | Conversion rate | Best pour | Éviter si |
|--------|----------------|-----------|-----------|
| **Freemium** | 2-5% (ProfitWell 2020) | Viral, usage individuel, CAC très bas | Produit complexe néeding onboarding |
| **Free Trial (14j)** | 15-25% (ProfitWell) | B2B, demo claire, time-to-value rapide | Produit nécessitant > 14j pour comprendre la valeur |
| **Demo + Paid** | 20-40% après demo | Enterprise, prix élevé (>500€/mois) | SMB (trop d'efforts pour le client) |

**Time-to-Value (TTV)** : si le TTV > durée du trial → allonger le trial ou passer à freemium.

---

## 5. Métriques SaaS à piloter

> Source : David Skok — "SaaS Metrics 2.0" (forentrepreneurs.com), SaaStr benchmarks

| Métrique | Formule | Threshold |
|----------|---------|-----------|
| **MRR** | Σ revenus récurrents mensuels | — |
| **ARR** | MRR × 12 | — |
| **MRR Churn** | MRR perdu / MRR début de période | <2%/mois (ProfitWell) |
| **NRR** (Net Revenue Retention) | (MRR début + expansion - contraction - churn) / MRR début | >100% = expansion revenue |
| **LTV** | ARPU / Churn rate mensuel | — |
| **CAC** | Coût total sales+marketing / nouveaux clients | — |
| **LTV/CAC** | LTV ÷ CAC | ≥3x (SaaStr minimum viable) |
| **CAC Payback** | CAC / ARPU mensuel | <12 mois (recommandé) |

```typescript
// lib/metrics.ts — calculs SaaS
export function calculateLTV(arpu: number, monthlyChurnRate: number): number {
  return arpu / monthlyChurnRate
}

export function calculateLTVCACRatio(ltv: number, cac: number): number {
  return ltv / cac
}

export function calculateCACPayback(cac: number, arpu: number): number {
  return cac / arpu  // en mois
}

// Exemple
const ltv = calculateLTV(49, 0.02)  // ARPU 49€, churn 2%/mois → LTV = 2450€
const ratio = calculateLTVCACRatio(2450, 300)  // CAC 300€ → ratio = 8.2x (excellent)
```

---

## 6. Discount annuel

**Règle : toujours proposer un abonnement annuel avec -15 à -20% de réduction.** (standard SaaS — David Skok, SaaStr)

L'abonnement annuel réduit le churn mécaniquement (engagement sur 12 mois), améliore le cash flow, et augmente l'ARR contractualisé.

```typescript
// Configuration Stripe recommandée
// Utiliser lookup_key plutôt que price_id hardcodé (Stripe recommandation)
// stripe.com/docs/products-prices/manage-prices#lookup-keys

const prices = {
  starter_monthly: { lookup_key: 'starter_monthly', amount: 1900 },   // 19€
  starter_annual:  { lookup_key: 'starter_annual',  amount: 19000 },  // 190€/an (-17%)
  pro_monthly:     { lookup_key: 'pro_monthly',     amount: 4900 },   // 49€
  pro_annual:      { lookup_key: 'pro_annual',      amount: 49000 },  // 490€/an (-17%)
}
```

---

## Checklist pré-lancement pricing

### Bloquants

- [ ] Van Westendorp ou entretiens WTP réalisés sur ≥30 répondants (ou 5 entretiens qualitatifs)
- [ ] EVC calculé pour le segment principal
- [ ] LTV/CAC ≥3x vérifié sur projection (sinon le modèle n'est pas viable)
- [ ] 3 tiers définis avec differentiation claire par usage (pas par features retirées)

### Importants

- [ ] Abonnement annuel avec -15 à -20% disponible
- [ ] NRR instrumenté dès J1 (premier client payant)
- [ ] Churn mesuré et analysé mensuellement
- [ ] Stripe lookup_keys utilisés (pas de price_id hardcodé)

### Souhaitables

- [ ] Cohort analysis par tier (quel tier churne le plus ?)
- [ ] NPS par tier (quel tier est le plus satisfait ?)
- [ ] Test landing page : messaging valeur vs pricing affiché

---

## Sources

| Référence | Lien |
|-----------|------|
| Van Westendorp PSM (ESOMAR, 1976) | esomar.org |
| ProfitWell SaaS Pricing Report (2020) | profitwell.com/recur/all |
| Christoph Janz — 5 Ways to Build $100M | christophjanz.blogspot.com/2014/10 |
| David Skok — SaaS Metrics 2.0 | forentrepreneurs.com/saas-metrics-2 |
| SaaStr — SaaS Benchmarks | saastr.com |
| Kahneman & Tversky — Anchoring (Science, 1974) | science.org/doi/10.1126/science.185.4157.1124 |
| Stripe — Lookup Keys | stripe.com/docs/products-prices/manage-prices |
| Simon-Kucher — Pricing Power | simon-kucher.com |
