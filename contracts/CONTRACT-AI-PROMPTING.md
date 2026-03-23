# Contract — AI Prompting & LLM Governance

> SQWR Project Kit contract module.
> Sources: Anthropic docs, OpenAI Prompt Engineering Guide, Nature (2025), Lakera, PMC/NIH, eval.16x.engineer.

---

## Scientific Foundations

**The context window is not an unlimited buffer.** LLMs show **significant performance degradation beyond 80% context utilization** (PMC/NIH, 2025). "Lost in the middle": information in the middle of a long context is processed less effectively than information at the beginning or end (Stanford research, 2023).

**Few-shot prompting:** 2-5 curated examples are optimal. Beyond that, returns diminish — and context is consumed needlessly (Lakera, 2025).

---

## 1. Architecture of a Reliable System Prompt

### Standard Structure (Anthropic + Lakera)

```
[ROLE]
You are [precise role] for [specific context].

[ABSOLUTE CONSTRAINTS]
You must never:
- [exhaustive list of prohibitions]
- [with reason for each prohibition]

[WHAT YOU MUST ALWAYS DO]
- [required behaviors]

[RESPONSE FORMAT]
Your responses must:
- [expected format — length, structure, language]

[EXAMPLES — 2-5 maximum]
Input: [example 1]
Output: [expected response 1]

[CONTEXT INJECTED BY RAG]
{relevant_data_only}
```

---

## 2. Context Window Optimization

> Source: LLM Context Management Guide — eval.16x.engineer

| Usage | Result | Action |
|-------------|---------|--------|
| 0-40% | Optimal | ✅ |
| 40-60% | Good | ✅ |
| 60-80% | Degradation starting | ⚠️ Prune the context |
| >80% | Proven degradation | ❌ New session required |

### Optimization Rules

- **New session for new task** — do not contaminate the context with unrelated exchanges
- **RAG rather than exhaustive context** — inject only the relevant sections, not the entire project
- **Local CLAUDE.md** — replaces manual context injection at each session
- **Limited few-shot**: 2-5 curated examples, never more
- **Contracts per module**: load only the contracts relevant to the current project

### Backend Selector Pattern

```
Instead of loading all context at once:
1. Identify the task (frontend, backend, DB, copy...)
2. Load only the relevant contract(s)
3. Inject only the concerned files
```

---

## 3. Hallucination Reduction Techniques

> Source: Nature (2025), PMC/NIH (2025), Springer Nature

| Technique | Reduction | SQWR Application |
|-----------|----------|-----------------|
| **RAG** | 15-50% | Always for KB/client data |
| **Chain-of-thought** | +25% accuracy | Complex multi-step tasks |
| **Verification step** | Variable | Critical data (prices, contacts) |
| **Confidence scoring** | 20-40% | Do not treat all outputs the same |
| **Explicit uncertainty** | Variable | Ask "if you're not sure, say so" |

### Chain-of-Thought for Complex Tasks

```
# ✅ Chain-of-thought prompt example
"Before responding:
1. List the information you need
2. Identify what you have vs. what is missing
3. For missing items, indicate [TO CONFIRM]
4. Only then, produce the response"
```

---

## 4. Prompt Engineering — Key Principles (2025)

> Source: Lakera Prompt Engineering Guide, Palantir, Google Cloud

### Clarity Takes Precedence Over Cleverness

```
❌ "Explain climate change"
✅ "Write a 3-paragraph summary of climate change for high school students,
    in a neutral style, with concrete examples. Language: English."
```

### Role-Based Prompting

```
✅ "You are a senior Next.js engineer reviewing code for security.
    Analyze this component and list potential OWASP vulnerabilities."
```

### Scaffolding (Security)

```
✅ Template maintained for user inputs:
"The user says: [INPUT]
Only respond to questions about [DOMAIN].
If the question is outside the domain, respond: 'I only cover [DOMAIN].'"
```

---

## 5. Model Selection (Cost vs. Capability)

| Task | Recommended Model | Reason |
|-------|-----------------|--------|
| Simple content generation | Claude Haiku / GPT-4o-mini | Fast, low cost |
| Code review, architecture | Claude Sonnet | Quality/cost balance |
| Complex tasks, critical KBs | Claude Opus / GPT-4o | Maximum quality |
| Autonomous agents | Claude Sonnet / Opus | Long reasoning |

**Rule:** never use the most powerful model by default. Use the minimum model sufficient for the task.

---

## 6. CLAUDE.md — Quality Standard

Every project collaborating with Claude Code must have a `CLAUDE.md` including:

| Section | Mandatory? | Content |
|---------|--------------|--------|
| Who works with you | ✅ | Samuel's identity + contacts |
| This project | ✅ | Name, description, stack, status |
| Architecture | ✅ | Directory tree + critical files |
| Active contracts | ✅ | List of contracts to read |
| Absolute Rules | ✅ | Project-specific Never/Always |
| Error history | ✅ | Tracking table |

**Absent CLAUDE.md = ungoverned work = uncontrolled risks.**

---

## 7. Session Management and Continuity

```
✅ One session = one coherent task
✅ MEMORY.md for cross-session persistence
✅ Always read the CLAUDE.md at the start of a session on a new project
✅ Update the error history after each fix

❌ Continuing a session with a saturated context
❌ Asking the AI to "remember what we did" without persistent memory
❌ Working on multiple unrelated projects in the same session
```

---

## 8. Sources

| Reference | Link |
|-----------|------|
| AI hallucinations — Nature 2025 | nature.com/articles/d41586-025-00068-5 |
| Why LLMs Hallucinate — OpenAI | openai.com/index/why-language-models-hallucinate |
| Reducing Hallucinations — PMC/NIH | pmc.ncbi.nlm.nih.gov/articles/PMC12425422 |
| LLM Context Management | eval.16x.engineer/blog/llm-context-management-guide |
| Prompt Engineering 2025 — Lakera | lakera.ai/blog/prompt-engineering-guide |
| Prompt Engineering — Palantir | palantir.com/docs/foundry/aip/best-practices-prompt-engineering |
| Prompt Engineering — Google Cloud | cloud.google.com/discover/what-is-prompt-engineering |
