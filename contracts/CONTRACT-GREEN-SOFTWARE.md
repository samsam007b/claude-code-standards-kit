# Contract — Green Software & Environmental Impact

> SQWR Project Kit contract module.
> Sources: ISO/IEC 21031:2024 (SCI), Green Software Foundation, GHG Protocol.
> Principle: Le secteur ICT représente 1.8–3.9% des émissions mondiales de GES (IEA 2022 ; Freitag et al., *The Real Climate and Transformative Impact of ICT: A Critique of Common Approaches and Toward New Avenues of Action*, Patterns 2021, DOI:10.1016/j.patter.2021.100340) — every technical decision has a carbon cost.

---

## Foundations

**The Software Carbon Intensity (SCI)** is the global standard for measuring the carbon footprint of software, ratified by ISO in March 2024.

**SCI Formula:**
```
SCI = (E × I) + M  per functional unit

E = energy consumed (kWh)
I = carbon intensity of electricity (gCO2e/kWh — variable by region)
M = embodied carbon (server manufacturing)
Functional unit = per request / per user / per transaction
```

> Source: *ISO/IEC 21031:2024 — Software Carbon Intensity Specification*
> Source: *Green Software Foundation — SCI Specification (sci.greensoftware.foundation)*
> Méthode LCA de référence : ISO 14040:2006 + ISO 14044:2006 (référence formelle : ISO 14040:2006 + ISO 14044:2006 — LCA methodology)
> Standard de calcul : Green Software Foundation SCI Specification v1.0 (Green Software Foundation SCI Specification v1.0 — greensoftware.foundation/articles/software-carbon-intensity)

---

## 1. Why This Matters for SQWR

- Le secteur ICT représente **1.8–3.9%** des émissions mondiales de GES (IEA 2022 ; Freitag et al., *The Real Climate and Transformative Impact of ICT*, Patterns 2021, DOI:10.1016/j.patter.2021.100340)
- European B2B clients are beginning to require proof of carbon impact
- The European Commission is working on carbon reporting obligations for SMEs
- LLMs have a significant carbon cost — **SCI for AI** (Green Software Foundation, 2025)
- This is a competitive differentiator for SQWR in 2026-2027

---

## 2. Carbon-Conscious Architecture Decisions

### Region Selection — Variable Carbon Intensity

The carbon intensity of electricity varies considerably by region.

| Region | Carbon intensity | Dominant energy source |
|--------|-----------------|------------------------|
| `eu-central-1` (Frankfurt) | ~300 gCO2e/kWh | European mix |
| `eu-west-1` (Ireland) | ~200 gCO2e/kWh | Wind + EU mix |
| `us-east-1` (N. Virginia) | ~350 gCO2e/kWh | Coal + gas |
| `ap-southeast-1` (Singapore) | ~450 gCO2e/kWh | Natural gas |

**Real-time tool:** electricitymap.org — carbon intensity by region/country (données opérationnelles temps réel — non certifiées LCA ; utiliser comme estimation advisory, pas comme baseline de recherche)

**SQWR Recommendation:** For Vercel, choose `eu-central-1` or `eu-west-1` by default for European projects — lower latency AND lower emissions.

### Serverless > Always-on

Serverless functions (Vercel Edge Functions, Vercel Serverless) only consume energy during execution. An always-on server consumes continuously.

```
// ✅ Serverless (Vercel) — consumes only during requests
// ❌ Always-on VPS — consumes 24/7 even without traffic
```

**For SQWR projects:** Vercel + Supabase Edge Functions = naturally carbon-aware architecture.

### Aggressive Caching — Less Compute

Every compute = energy. Caching avoids recalculating what is already known.

```typescript
// ✅ Static data — aggressive caching
export const revalidate = 3600  // recalculate at most once/hour

// ✅ Static pages — zero compute per visit
export const dynamic = 'force-static'

// ⚠️ 'no-store' — compute on every request — justify if used
export const dynamic = 'force-dynamic'  // only if data is truly real-time
```

---

## 3. LLM Carbon Cost

The Green Software Foundation published in 2025 the **SCI for AI** — a standardized method for measuring the carbon impact of LLM calls.

**Order of magnitude (estimates):**

| Operation | Estimated energy |
|-----------|-----------------|
| 1 GPT-4 request | ~0.001-0.01 kWh |
| 1 Claude Sonnet request | ~0.0005-0.005 kWh |
| 1,000 LLM calls/day | ~0.5-10 kWh/day |
| Fine-tuning a model | ~100-1000 kWh |

**LLM frugality rules:**

```typescript
// ✅ Use the model suited to the task complexity
const MODEL_BY_TASK = {
  'classification-simple': 'claude-haiku-4-5',    // simple task → lightweight model
  'generation-contenu': 'claude-sonnet-4-5',       // medium task → medium model
  'analyse-complexe': 'claude-opus-4-5',           // complex task → powerful model
} as const

// ❌ Never use claude-opus for simple tasks
// ❌ Do not call the LLM if the result can be cached
```

**LLM cache to reduce calls:**

```typescript
// lib/ai/cached-call.ts
import { createClient } from '@supabase/ssr'

async function cachedAICall(prompt: string, ttl = 3600): Promise<string> {
  const cacheKey = `ai:${hash(prompt)}`

  // Check the cache first
  const cached = await supabase
    .from('ai_cache')
    .select('response, created_at')
    .eq('key', cacheKey)
    .gt('created_at', new Date(Date.now() - ttl * 1000).toISOString())
    .single()

  if (cached.data) return cached.data.response

  // Call the LLM only if not cached
  const response = await callAI(prompt)

  // Store in cache
  await supabase.from('ai_cache').upsert({ key: cacheKey, response })

  return response
}
```

---

## 4. Measuring Your SCI

**For a typical SQWR project (Next.js + Supabase):**

```
SCI = (E_vercel × I_region + E_supabase × I_region + E_llm × I_llm_datacenter) + M
    / number of transactions per month

// In practice, estimates are approximate without specialized tools
// What matters: track the trend, not the absolute value
```

**Measurement tools:**

| Tool | Measures | Usage |
|------|---------|-------|
| Vercel Carbon | Vercel infrastructure emissions | Vercel dashboard |
| electricitymap.org | Real-time carbon intensity by region | Region selection |
| Green Software Foundation SCI Guide | Full SCI methodology | Carbon report |
| Cloud Carbon Footprint | AWS/GCP/Azure emissions | If multi-cloud |

---

## 5. Green Software Checklist

### Architecture
- [ ] Vercel/Supabase regions selected on carbon + latency criteria (not latency alone)
- [ ] Caching configured on all semi-static data
- [ ] `force-dynamic` justified (not used by default)
- [ ] Serverless or Edge Functions rather than always-on

### LLM & AI
- [ ] Model suited to task complexity (Haiku/mini for simple tasks)
- [ ] LLM cache implemented for repetitive prompts
- [ ] Hard token limit configured (prevent abusive calls)
- [ ] `revalidate` configured on components with LLM calls

### Assets & Frontend
- [ ] Images optimized (WebP, next/image)
- [ ] Fonts subsetted (next/font, avoid loading all glyphs)
- [ ] Minimal JS bundle (<200KB First Load)
- [ ] Unused CSS purged (Tailwind does this automatically in production)

---

## 6. Absolute Rules

### Never do
- Use `force-dynamic` by default (recalculation on every request = waste)
- Use claude-opus or gpt-4 for tasks that can be handled by a lightweight model
- Call the LLM without cache if the same question can be asked multiple times
- Choose a server region based on latency alone without considering carbon intensity

### Always do
- Prefer caching over dynamic generation when possible
- Use the lightest AI model capable of completing the task
- Check electricitymap.org before choosing a region for a new project

---

## 7. Sources

| Reference | Source |
|-----------|--------|
| SCI Specification | sci.greensoftware.foundation |
| ISO/IEC 21031:2024 | iso.org/standard/86612.html |
| SCI for AI (2025) | greensoftware.foundation/articles/sci-ai-specification-ratified |
| Electricity Maps | electricitymap.org |
| Cloud Carbon Footprint | cloudcarbonfootprint.org |
| Green Software Principles | principles.green |
| ISO 14040:2006 + ISO 14044:2006 — LCA Methodology | iso.org/standard/37456.html |
| IEA — Tracking Clean Energy Progress 2022 | iea.org |
| Freitag et al. 2021 — ICT emissions | doi.org/10.1016/j.patter.2021.100340 |

> **Last validated:** 2026-03-30 — ISO/IEC 21031:2024 (SCI), ISO 14040/44 (LCA), GSF SCI v1.0, IEA 2022, Freitag et al. 2021
