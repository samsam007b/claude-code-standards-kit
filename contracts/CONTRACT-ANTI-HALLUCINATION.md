# Contract — Zero Hallucination & AI Governance

> SQWR Project Kit contract module — enriched with scientific research.
> Sources: Nature (2025), OpenAI Research (2025), PMC/NIH (2025), Springer Nature, Lakera.
> Inspired by the CozyGrowth CLAUDE.md (March 15, 2026).

---

## Scientific Foundations

**Why LLMs hallucinate** (OpenAI Research, 2025): language models are trained to optimize textual plausibility, not factual truth. Traditional evaluation penalizes uncertainty and rewards confidence — even when wrong. As a result, the model prefers to invent a confident answer rather than admitting it does not know.

**Measurable reduction:** RAG (Retrieval-Augmented Generation) techniques reduce hallucinations by **15-82%** depending on the combination of techniques used (PMC/NIH, 2025).

> Source: *"AI hallucinations can't be stopped — but these techniques can limit their damage"* — Nature, 2025

---

## 1. Absolute Rule — Zero Hallucination on Real Data

**An incorrect piece of data in this project = a real problem for a real client or user.**

This contract applies to any project containing factual data: prices, contacts, schedules, URLs, statistics, proper names, addresses.

---

## 2. What the AI Must NEVER Do

- **Invent numbers**: prices, stats, capacities, years, schedules
- **Complete missing data** through "business logic" or approximation
- **Write URLs, emails, phone numbers** without a verified source
- **Add "plausible" information** without explicit confirmation
- **Infer from a similar context** ("this space looks like the other one, so...")
- **Reuse data from a previous session** without fresh verification

---

## 3. What the AI Must ALWAYS Do

- Missing information → write `[TO FILL IN]` and flag it
- Number of unknown origin → ask for the source before writing
- Before adding any data → explicitly identify the source
- If <100% certain → ask the question, do not guess
- **Confidence scoring**: do not treat all outputs the same — distinguish verified statements from hypotheses

---

## 4. Valid Sources

1. **Screenshots or text provided directly** in the conversation
2. **Content scraped live** from the official source (`WebFetch`)
3. **Explicit verbal confirmation** from Samuel in the current conversation

## Invalid Sources

- What "seems logical" for this type of project
- Data seen in a previous session (outside explicit persistent memory)
- Numbers interpolated or extrapolated from similar cases
- Information generated without an identified source

---

## 5. Format for Missing Data

```markdown
Monthly rate: [TO FILL IN — source required]
Contact email: [TO FILL IN — unverified]
Capacity: [TO FILL IN — data not available in provided sources]
Statistic: [TO FILL IN — no source found for this figure]
```

---

## 6. Context Window Optimization (LLM Research 2025)

> Source: LLM Context Management Guide — eval.16x.engineer, Redis Blog, GetMaxim

**Maximally filling the context degrades performance.**

| Context window usage | Result |
|---------------------------|---------|
| 40-60% | Optimal performance |
| 60-80% | Degradation starting |
| >80% | Significant proven degradation |

**Optimization rules:**

- **New sessions for new tasks** — do not contaminate the context with previous tasks
- **RAG rather than exhaustive context** — retrieve only the relevant sections
- **Limited few-shot**: 2-5 curated examples (beyond = proven diminishing returns)
- **Smart context selection**: load only the contracts relevant to the current project

---

## 7. Recommended Hallucination Reduction Techniques

> Source: PMC/NIH (2025), Springer Nature — Hierarchical Semantic Piece method

| Technique | Hallucination Reduction | When to Use |
|-----------|------------------------|-----------------|
| **RAG** (Retrieval-Augmented Generation) | 15-50% | Always for external data |
| **Chain-of-thought prompting** | +25% accuracy | Complex multi-step tasks |
| **Verification step** | Variable | Critical data (prices, contacts) |
| **Confidence scoring** | 20-40% | Distinguish certain statements/hypotheses |
| **HSP method** | 20-50% | Multi-granularity extraction (sentence + entity) |

---

## 8. Structure of a Reliable System Prompt (Anthropic + Lakera)

```
[ROLE] You are [specific role] for [precise context].

[CONSTRAINTS] You must never:
- [explicit list of prohibitions]

[FORMAT] Your responses must:
- [expected format]

[EXAMPLES] Here are 2-3 examples of expected responses:
- [curated examples]

[AVAILABLE DATA]
{rag_injected_context}
```

---

## 9. Advanced AI Risks (2025-2026)

> Sources: Anthropic Research, CSA 2025, OWASP LLM03:2025, OpenAI pricing history.

### Context Poisoning / RAG Poisoning

**Anthropic Research and CSA 2025: 5 carefully crafted documents are sufficient to manipulate AI outputs 90% of the time** in a RAG system. An attacker or even poorly formatted client content can contaminate all system responses.

**For CozyGrowth (RAG KBs with client data):**
- Validate each document before inserting it into the KB (see CONTRACT-SECURITY.md section 10)
- Isolate KBs by space/client — never allow cross-client contamination
- Regularly audit KBs with `/verify-kb` to detect abnormal patterns
- Client data sources carry limited trust — treat them as external inputs

### Provider Lock-In & Fallback Strategy

**OpenAI deprecated GPT-3.5 without sufficient notice in 2024.** Anthropic may change its prices or capabilities. Any project that depends on a single LLM provider without a fallback is fragile.

**Recommended abstraction pattern:**

```typescript
// lib/ai/client.ts — multi-provider abstraction layer
const AI_PROVIDERS = {
  primary: 'anthropic',     // Claude (quality)
  fallback: 'openrouter',   // OpenRouter (resilience)
} as const

async function callAI(prompt: string, options: AIOptions = {}): Promise<string> {
  try {
    return await callAnthropic(prompt, options)
  } catch (err) {
    // Automatic fallback if primary provider is unavailable
    console.warn('Anthropic unavailable, falling back to OpenRouter', err)
    return await callOpenRouter(prompt, options)
  }
}
```

**Via OpenRouter (recommended for client projects):**
```typescript
// OpenRouter allows changing models without changing code
const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
  headers: { Authorization: `Bearer ${process.env.OPENROUTER_API_KEY}` },
  body: JSON.stringify({
    model: process.env.AI_MODEL ?? 'anthropic/claude-sonnet-4-5',  // configurable via env
    messages: [{ role: 'user', content: prompt }],
  }),
})
```

### Denial of Wallet — Limits & Cost Alerts

**A malicious prompt or infinite loop can generate thousands of LLM calls in a few minutes**, causing costs to explode. Without hard limits, this is a financial attack vector.

```typescript
// Hard limits per LLM call
const LLM_LIMITS = {
  maxInputTokens: 10_000,    // ~7500 words input max
  maxOutputTokens: 4_000,    // ~3000 words output max
  maxRequestsPerUser: 50,    // per hour
  maxRequestsPerSession: 20, // per session
} as const

// Validation before each call
function validateLLMRequest(input: string, userId: string) {
  const tokenEstimate = Math.ceil(input.length / 4)  // approximation
  if (tokenEstimate > LLM_LIMITS.maxInputTokens) {
    throw new Error(`Input too long: ${tokenEstimate} estimated tokens (max ${LLM_LIMITS.maxInputTokens})`)
  }
  // Rate limiting by userId...
}
```

**Cost alerts to configure:**
- Anthropic Console: budget alert at 80% of monthly budget
- OpenRouter: hard limit in dollars/month
- Vercel: alert if edge function calls spike (may indicate a loop)

### Model Drift — Behavioral Monitoring

Fine-tuned models or prompts that worked in January may produce different outputs 6 months later, with no visible code change.

**Mitigation:**
```typescript
// tests/ai-baseline.test.ts — behavioral regression test
describe('AI Baseline Tests', () => {
  const BASELINE_PROMPTS = [
    {
      input: 'Summarize this co-living space in 2 sentences.',
      mustContain: ['rooms', 'space'],    // expected words
      mustNotContain: ['TO FILL IN', '['],   // signs of hallucination
    },
  ]

  // Run in monthly CI or after model change
  BASELINE_PROMPTS.forEach(({ input, mustContain, mustNotContain }) => {
    it(`Baseline: "${input.slice(0, 30)}..."`, async () => {
      const output = await callAI(input)
      mustContain.forEach(word => expect(output).toContain(word))
      mustNotContain.forEach(word => expect(output).not.toContain(word))
    })
  })
})
```

**Rule:** after any model change (version upgrade, provider change), re-test the baseline prompts before deploying to production.

---

## 10. Real Case — CozyGrowth Hallucinations (March 15, 2026)

> Documented example from a real SQWR project. Source: CozyGrowth CLAUDE.md.
> These 3 errors were detected and corrected on the same day.

**Context**: CozyGrowth is a marketing content generation platform for co-living spaces. The KBs (Knowledge Bases) contain the real data for each space — rates, capacities, contacts, certifications.

| Date | Invented Data | Source of Error | Impact | Status |
|------|----------------|-------------------|--------|--------|
| 03/15/2026 | Smash Academy: "3,000 young people/year" | Inference from the "national network" context — never mentioned in the KB | False figure in client marketing content | Corrected — `[TO FILL IN]` added |
| 03/15/2026 | "AFT 14/15" label | Interpretation of an internal label not defined in the KB | Unverifiable information published | Corrected — label removed from content |
| 03/15/2026 | LEGIO phone number | Reuse of another similar space's number from the session | Incorrect contact disseminated | Corrected — `[TO FILL IN]` + direct verification |

**Lessons learned:**
- Round numbers ("3,000") must systematically trigger a verification — they are often invented
- Labels/certifications not explicitly defined in the KB must never be emitted
- In multi-space sessions, contacts are never transferable from one space to another

**RAG pattern applied since**: each space has a dedicated KB loaded in isolation. Sessions do not mix data from multiple spaces.

---

## 10. Hallucination History (to be maintained per project)

> Track detected errors to prevent recurrence. CozyGrowth model.

| Date | Invented Data | Source of Error | Status |
|------|----------------|-------------------|--------|
| [MM/DD/YYYY] | [description] | [what caused the error] | Corrected / Flagged |

---

## 11. Sources

| Reference | Link |
|-----------|------|
| AI hallucinations can't be stopped | nature.com/articles/d41586-025-00068-5 |
| Why Language Models Hallucinate — OpenAI | openai.com/index/why-language-models-hallucinate |
| Reducing Hallucinations in LLMs — PMC/NIH | pmc.ncbi.nlm.nih.gov/articles/PMC12425422 |
| HSP Method — Springer Nature | link.springer.com/article/10.1007/s40747-025-01833-9 |
| LLM Context Management | eval.16x.engineer/blog/llm-context-management-guide |
| Context Windows Explained — Redis | redis.io/blog/llm-context-windows |
| Prompt Engineering 2025 — Lakera | lakera.ai/blog/prompt-engineering-guide |
