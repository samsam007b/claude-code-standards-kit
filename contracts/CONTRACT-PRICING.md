# Contract — Pricing & Monetisation

> SQWR Project Kit contract module.
> Sources: Van Westendorp — Price Sensitivity Meter (ESOMAR, 1976), Price Intelligently / ProfitWell — SaaS Pricing Report (2020), Simon-Kucher & Partners — Pricing Power Research, Kahneman & Tversky — "Judgment under Uncertainty" (Science, 1974), Christoph Janz — "5 Ways to Build a $100M Business" (Point Nine Capital, 2014), SaaStr — SaaS Benchmarks (saastr.com).

---

## Scientific Foundations

**"Pricing is the most powerful lever in SaaS."** A 1% improvement in pricing generates on average **4x more impact** on profit than a 1% improvement in acquisition. (Price Intelligently / ProfitWell, 2016)

The classic startup mistake: setting prices based on costs (cost-plus pricing) rather than perceived value. The price must reflect **the value created for the customer**, not production costs.

**Anchoring bias** (Kahneman & Tversky, Science, 1974): the first price seen irrevocably anchors perception. The display order of tiers directly impacts conversions.

---

## 1. Van Westendorp — Price Sensitivity Meter

> Source: Peter Van Westendorp — "NSS-Price Sensitivity Meter" (ESOMAR, 1976)
> Standard: 30 respondents minimum for statistically interpretable results

**4 questions to ask in a survey (before setting the price):**

```
Q1 — "At what price would this product be too expensive for you to consider?"
     → Rejection due to high cost

Q2 — "At what price would you start to find this product expensive, but still buy it?"
     → Expensive but acceptable

Q3 — "At what price would you think this product is a good deal?"
     → Good value for money

Q4 — "At what price would this product be so cheap that you would doubt its quality?"
     → Rejection due to price being too low (signal of poor quality)
```

**Graphical interpretation:**
```
Plot the 4 cumulative curves.
Intersection of Q1 and Q4 → Point of Marginal Cheapness (PMC)
Intersection of Q2 and Q3 → Point of Marginal Expensiveness (PME)
Zone between PMC and PME → Acceptable price range
```

**Optimal zone:** between the PMC and the PME. The optimal price is often slightly above the PMC (to avoid the perception of poor quality).

---

## 2. Value-Based Pricing — Calculating EVC

> Source: Thomas Nagle — *The Strategy and Tactics of Pricing* (Routledge, 2016)
> Source: Simon-Kucher & Partners — Value-Based Pricing Framework

**Economic Value to Customer (EVC):**
```
EVC = Economic reference of the best alternative
    + Differentiation value (positive or negative)
```

**Golden rule: capture 10-20% of the value created for the customer.** (Source : Simon-Kucher & Partners, *Value-Based Pricing: Drive Sales and Profits with Customer-Value Pricing*, 2012 ; Nagle, Hogan & Zale, *The Strategy and Tactics of Pricing*, 5th ed., 2011)

### EVC Calculation Template

```
PRODUCT: [Name]
TARGET SEGMENT: [Precise description]

1. Cost of the customer's best current alternative:
   Alternative: [e.g. doing it manually, competing tool]
   Annual cost (time × hourly rate + subscription): [€]

2. Differentiation value delivered:
   + Time saved: [hours/month × hourly rate = €/year]
   + Error reduction: [€ of risk avoided]
   + New value created: [€ of revenue generated]
   - Migration cost: [€]
   - Learning curve: [hours × hourly rate = €]

3. Total EVC = Alternative + Differentiation = [€/year]

4. Recommended price = EVC × 10-20% = [€/year]
```

---

## 3. Pricing Structure — 3 Tiers (Good/Better/Best)

> Source: Simon-Kucher & Partners — "Monetize!" (Wiley, 2012)
> Source: Bain & Company — Pricing Research

**3 tiers is the optimal format.** 2 tiers = limited choice, difficult to anchor. 4+ tiers = choice paralysis. (Bain & Company pricing research)

**Display order: always from most expensive to least expensive.** Cognitive anchoring means the first price seen becomes the reference — displaying the higher price first makes the middle price more attractive.

```
┌─────────────┬─────────────┬─────────────┐
│   BUSINESS  │     PRO     │   STARTER   │
│  "Best"     │  "Better"   │   "Good"    │
│  149€/month │  49€/month  │  19€/month  │
│  [featured] │  ← PUSH     │  [entry     │
│             │   THIS TIER │   point]    │
└─────────────┴─────────────┴─────────────┘
```

**Decoy pricing:** the "Pro" tier (middle) must be designed to make the "Business" tier attractive. If Business = 3x Pro but 5x the features → "Pro seems like a bad deal".

**Rule:** never artificially remove features from the lower tier to force upgrades. Differentiate by usage limits (volume, users, projects), not by removing critical functionality.

---

## 4. SaaS Models — Freemium vs Trial vs Paid

> Source: Christoph Janz — "5 Ways to Build a $100M Business" (Point Nine Capital, 2014)
> Source: ProfitWell — "The State of Freemium" (2020)

| Model | Conversion rate | Best for | Avoid if |
|-------|----------------|----------|----------|
| **Freemium** | 2-5% (ProfitWell 2020) — (OpenView Product Benchmarks 2024 : taux de conversion freemium-to-paid médian = 3-5% ; top quartile = 8-12% — openviewpartners.com) | Viral, individual usage, very low CAC | Complex product requiring onboarding |
| **Free Trial (14d)** | 15-25% (ProfitWell) | B2B, clear demo, fast time-to-value | Product requiring > 14d to understand value |
| **Demo + Paid** | 20-40% after demo | Enterprise, high price (>500€/month) | SMB (too much effort for the customer) |

**Time-to-Value (TTV):** if TTV > trial duration → extend the trial or switch to freemium.

---

## 5. SaaS Metrics to Track

> Source: David Skok — "SaaS Metrics 2.0" (forentrepreneurs.com), SaaStr benchmarks

| Metric | Formula | Threshold |
|--------|---------|-----------|
| **MRR** | Σ monthly recurring revenue | — |
| **ARR** | MRR × 12 | — |
| **MRR Churn** | MRR lost / MRR at start of period | <2%/month (ProfitWell) |
| **NRR** (Net Revenue Retention) | (Starting MRR + expansion - contraction - churn) / Starting MRR | >100% = expansion revenue |
| **LTV** | ARPU / monthly churn rate | — |
| **CAC** | Total sales+marketing cost / new customers | — |
| **LTV/CAC** | LTV ÷ CAC | ≥3x (SaaStr minimum viable) |
| **CAC Payback** | CAC / monthly ARPU | <12 months (recommended) |

```typescript
// lib/metrics.ts — SaaS calculations
export function calculateLTV(arpu: number, monthlyChurnRate: number): number {
  return arpu / monthlyChurnRate
}

export function calculateLTVCACRatio(ltv: number, cac: number): number {
  return ltv / cac
}

export function calculateCACPayback(cac: number, arpu: number): number {
  return cac / arpu  // in months
}

// Example
const ltv = calculateLTV(49, 0.02)  // ARPU 49€, churn 2%/month → LTV = 2450€
const ratio = calculateLTVCACRatio(2450, 300)  // CAC 300€ → ratio = 8.2x (excellent)
```

---

## 6. Annual Discount

**Rule: always offer an annual subscription with -15 to -20% discount.** (SaaS standard — David Skok, SaaStr)

An annual subscription mechanically reduces churn (12-month commitment), improves cash flow, and increases contracted ARR.

```typescript
// Recommended Stripe configuration
// Use lookup_key rather than hardcoded price_id (Stripe recommendation)
// stripe.com/docs/products-prices/manage-prices#lookup-keys

const prices = {
  starter_monthly: { lookup_key: 'starter_monthly', amount: 1900 },   // 19€
  starter_annual:  { lookup_key: 'starter_annual',  amount: 19000 },  // 190€/year (-17%)
  pro_monthly:     { lookup_key: 'pro_monthly',     amount: 4900 },   // 49€
  pro_annual:      { lookup_key: 'pro_annual',      amount: 49000 },  // 490€/year (-17%)
}
```

---

## Pre-launch Pricing Checklist

### Blocking

- [ ] Van Westendorp or WTP interviews conducted on ≥30 respondents (or 5 qualitative interviews)
- [ ] EVC calculated for the primary segment
- [ ] LTV/CAC ≥3x verified on projection (otherwise the model is not viable)
- [ ] 3 tiers defined with clear differentiation by usage (not by removed features)

### Important

- [ ] Annual subscription with -15 to -20% available
- [ ] NRR instrumented from day 1 (first paying customer)
- [ ] Churn measured and analysed monthly
- [ ] Stripe lookup_keys used (no hardcoded price_id)

### Desirable

- [ ] Cohort analysis by tier (which tier churns the most?)
- [ ] NPS by tier (which tier is most satisfied?)
- [ ] Landing page test: value messaging vs displayed pricing

---

## Sources

| Reference | Link |
|-----------|------|
| Van Westendorp PSM (ESOMAR, 1976) | esomar.org |
| ProfitWell SaaS Pricing Report (2020) | profitwell.com/recur/all |
| Christoph Janz — 5 Ways to Build $100M | christophjanz.blogspot.com/2014/10 |
| David Skok — SaaS Metrics 2.0 | forentrepreneurs.com/saas-metrics-2 |
| SaaStr — SaaS Benchmarks | saastr.com |
| Kahneman & Tversky — Anchoring (Science, 1974) | science.org/doi/10.1126/science.185.4157.1124 |
| Stripe — Lookup Keys | stripe.com/docs/products-prices/manage-prices |
| Simon-Kucher — Pricing Power | simon-kucher.com |
| OpenView Product Benchmarks 2024 | openviewpartners.com |
| Nagle, Hogan & Zale — The Strategy and Tactics of Pricing (5th ed., 2011) | Routledge |

> **Last validated:** 2026-03-30 — Van Westendorp 1976, Simon-Kucher 2012, Nagle et al. 2011, OpenView 2024
