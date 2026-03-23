# Methodology — SQWR Project Kit

> This document is addressed simultaneously to two readers:
> — **Claude Code**: which integrates it as behavioural context ("how I should work")
> — **Humans**: who use it as a manifesto and learning guide

---

## The core insight

**Professional quality is not in the code — it is in the research that precedes the code.**

Professionals (audit firms, large tech companies, consulting agencies) do not start from opinions. They start from **documented standards, published research, and verifiable precedents**. Claude Code provides access to this knowledge base and allows it to be applied to any project — including solo or student projects.

This kit exists because a simple observation proved true across dozens of projects:

> The difference between an "amateur" deliverable and a "professional" deliverable is not talent — it is knowledge of the standards that already exist, and the discipline to apply them.

Claude Code can find these standards faster than a human. The human knows what to do with what it finds. **The combination exceeds what either can do alone.**

---

## For Claude Code — Behavioural rules

### Rule 1: Research before implementation

For any non-trivial task, and **before writing the first line of code**, ask the question:

> "What is the professional and academic state of the art on this topic?"

Example:
- Task: "Add a file upload system"
- Prior research: what are the known vulnerabilities (OWASP File Upload), the recommended limits (NIST), the reference implementations (Vercel Blob docs, Supabase Storage docs)
- Implementation: grounded in sources, not in memorised patterns

### Rule 2: Source hierarchy

Respect this order of priority:

```
TIER 1 — Official documentation (technical source of truth)
  ├── Anthropic docs       → docs.anthropic.com
  ├── Vercel docs          → vercel.com/docs
  ├── GitHub / Actions     → docs.github.com
  ├── Apple Developer      → developer.apple.com
  ├── W3C / MDN            → w3.org, developer.mozilla.org
  └── Supabase docs        → supabase.com/docs

TIER 2 — Scientific and academic standards (business source of truth)
  ├── OWASP, NIST, W3C     → Security, accessibility standards
  ├── Nielsen Norman Group → UX research (nngroup.com)
  ├── Baymard Institute    → E-commerce UX (baymard.com)
  ├── Harvard Business Review → Management, strategy (hbr.org)
  ├── Google SRE Book      → Reliability (sre.google)
  └── Academic publications → Nature, arXiv, ACM, CHI, PMC/NIH

TIER 3 — Professional industry reports
  ├── Google Core Web Vitals research   → web.dev
  ├── Snyk State of Open Source Security → snyk.io/reports
  ├── Veracode GenAI Security Report    → veracode.com/state-of-software-security
  └── School publications (ESADE, HBS, MIT Sloan)

TIER 4 — Communities and practitioners (practical source of truth)
  ├── GitHub ★★★★★         → Issues, READMEs, discussions from top-starred projects
  ├── Reddit                → r/webdev, r/ClaudeAI, r/entrepreneur (real-world patterns)
  ├── Hacker News           → news.ycombinator.com (high signal-to-noise ratio)
  └── Dev.to, Engineering blogs (Stripe, Vercel, Shopify)
```

**Critical rule**: numerical thresholds (e.g. contrast 4.5:1, coverage ≥80%, LCP ≤2.5s) may only come from Tier 1 or Tier 2. Tier 4 opinions are valuable for practical patterns — not for measurable thresholds.

### Rule 3: Cite sources in contracts

Every non-trivial rule added to a contract must have a verifiable source. Expected format:

```markdown
**Threshold: 16px minimum** (Rello & Pielot, CHI 2016 — study on eye fatigue)
**Contrast: ≥4.5:1** (W3C WCAG 2.1 SC 1.4.3)
**Coverage: ≥80%** (Google Engineering Practices, eng-practices.github.io)
```

No "it is recommended to" without a source. Either the source exists, or it is an opinion.

### Rule 4: Never invent standards

If a threshold or rule is not in a kit contract or in a verifiable Tier 1-2 source: **say so explicitly**.

> "I have no documented standard for this specific case. Here is what I found in Tier 4 (practitioners) — to be verified before making it a rule."

Anti-hallucination applies to standards as much as to data.

---

## The research workflow in 5 steps

### Step 1 — Identify the domain and applicable contracts

The kit's contracts define the rules for covered domains. **Check first whether a contract exists.**

```
Applicable contracts by task type:
├── Security / GDPR    → CONTRACT-SECURITY.md + DEPENDENCY-MANAGEMENT.md
├── Performance        → CONTRACT-PERFORMANCE.md
├── Accessibility      → CONTRACT-ACCESSIBILITY.md
├── UI Design          → CONTRACT-DESIGN.md
├── TypeScript / Code  → CONTRACT-TYPESCRIPT.md
├── Testing            → CONTRACT-TESTING.md
├── Database           → CONTRACT-SUPABASE.md
├── Deployment         → CONTRACT-VERCEL.md
├── Observability      → CONTRACT-OBSERVABILITY.md
├── Resilience         → CONTRACT-RESILIENCE.md
├── AI / LLM           → CONTRACT-AI-PROMPTING.md + CONTRACT-ANTI-HALLUCINATION.md
├── Mobile iOS         → CONTRACT-IOS.md
├── Python / FastAPI   → CONTRACT-PYTHON.md
├── PDF generation     → CONTRACT-PDF-GENERATION.md
├── Green IT           → CONTRACT-GREEN-SOFTWARE.md
├── Technical SEO      → CONTRACT-SEO.md
├── Email (SMTP/DKIM)  → CONTRACT-EMAIL.md
├── CI/CD              → CONTRACT-CICD.md
├── Product analytics  → CONTRACT-ANALYTICS.md
├── Internationalisation → CONTRACT-I18N.md
├── Pricing / SaaS     → CONTRACT-PRICING.md
├── Android            → CONTRACT-ANDROID.md
├── Motion / Animation → CONTRACT-MOTION-DESIGN.md
├── Video production   → CONTRACT-VIDEO-PRODUCTION.md
│
├── UX research        → frameworks/UX-RESEARCH.md  (before any feature)
├── Content strategy   → frameworks/SOCIAL-CONTENT.md  (before any social launch)
│
├── Branding           → frameworks/BRAND-STRATEGY.md  (before any design)
├── Product launch     → frameworks/COMPETITIVE-AUDIT.md + frameworks/CAMPAIGN-STRATEGY.md
├── EU compliance      → frameworks/COMPLIANCE-EU.md
├── New project        → frameworks/PROJECT-SCOPING.md
├── Deadline estimate  → frameworks/ESTIMATION.md
├── Client delivery    → frameworks/CLIENT-HANDOFF.md
├── Prod incident      → frameworks/INCIDENT-RESPONSE.md
├── Arch decision      → frameworks/ADR-TEMPLATE.md
└── Reliability goals  → frameworks/SLO-TEMPLATE.md
```

### Step 2 — Upstream research if the contract does not cover the case

```
Template prompt:
"Before implementing [X], research:
1. What are the best practices documented by Tier 1-2 sources?
2. Which recognised standards apply (OWASP, WCAG, NIST, W3C)?
3. Which authors or organisations are the reference in this domain?"
```

### Step 3 — Community benchmarking (Tier 4)

```
Template prompt:
"Search GitHub for the most-starred projects that implement [X].
What recurs in the top issues and discussions?
What patterns have emerged as de facto standards?"
```

### Step 4 — Grounding in official documentation

```
Template prompt:
"What is the recommended implementation by [Vercel/Anthropic/Apple/W3C]
in their official documentation?
Are there official patterns or examples to follow?"
```

### Step 5 — Synthesis → Contract → Implementation → Audit

Research becomes a contract (rules + sources + thresholds). Implementation follows the contract. The audit verifies that the thresholds are met.

---

## Trusted Claude Code community resources

These GitHub projects are trusted sources for extending Claude Code's capabilities. Trust criteria: >500 stars, recent commits, actively maintained.

| Resource | Type | Why it is useful |
|-----------|------|---------------------|
| **awesome-claude-code** | Curated list | Index of the best skills, hooks, configs |
| **claude-code-hooks** | Examples | Advanced patterns for custom hooks |
| **anthropics/anthropic-cookbook** | Official | Official Claude API + Agent SDK patterns |
| **r/ClaudeAI** (Reddit) | Community | Real-world feedback, edge cases |
| **r/webdev** (Reddit) | Community | Stack trends, current practices |
| **Hacker News "Ask HN"** | Community | High signal on best practices |

**GitHub trust rule:** a project with >1000 stars, recent commits, and resolved issues is generally reliable. Always read the code before importing an external skill.

---

## For humans — How to use this kit

### If you are discovering Claude Code

**The most important question to ask Claude Code, consistently:**

> "Before doing X, what are the professional best practices and recognised standards in this domain? Search the web."

This habit alone elevates projects from "personal" to "professional" level. Claude Code does not memorise opinions — it knows how to find the standards that exist. The key is to give it this reflex systematically.

### Getting started in 3 commands

```bash
# 1. Bootstrap a project with the full kit
bash scripts/init-project.sh --name "mon-projet" --stack "nextjs-supabase" --path "~/Desktop/mon-projet"

# 2. Validate that the CLAUDE.md is complete
bash scripts/validate-claude-md.sh ~/Desktop/mon-projet/CLAUDE.md

# 3. Run the initial audit (score the starting state)
# → Open audits/AUDIT-INDEX.md in Claude Code and follow the instructions
```

### The 5 reflexes to develop with Claude Code

| Situation | Reflex |
|-----------|---------|
| New feature | "Find the standards and best practices before implementing" |
| Architecture decision | "Create an ADR (frameworks/ADR-TEMPLATE.md) to document the choice" |
| Before delivery | "Run the AUDIT-INDEX.md audit and address points below 70%" |
| New brand/project | "Start with BRAND-STRATEGY.md before any visual design" |
| Deadline estimate | "Use frameworks/ESTIMATION.md — ×1.5 rule is mandatory" |

### How this kit improves

This kit is a foundation, not a ceiling. It is designed to grow.

**Open/Closed principle:** open to extension, closed to unsourced modification.

To add a contract:
1. Identify an uncovered domain
2. Research the domain's Tier 1-2 standards
3. Create `contracts/CONTRACT-[NAME].md` with the standard structure
4. Add to README.md + verify-kit.sh
5. Reference in AUDIT-INDEX.md if an associated audit exists

To improve an existing contract:
1. Identify a missing threshold or rule
2. Find the Tier 1-2 source that justifies the change
3. Update the contract with the cited source

---

## Why this kit exists

This kit was born from an observation made over several years of working with Claude Code: **tools are not lacking — method is.**

Most Claude Code tutorials show how to perform technical tasks. Very few show how to approach **professional quality** — the level where a deliverable holds up against what professionals in the field produce.

This gap exists particularly in two domains that are frequently overlooked:
1. **Branding and brand strategy** — absent from virtually all starter kits
2. **Grounding in professional standards** — replaced by unsourced opinions

This kit is the answer to that gap. It covers the entire project lifecycle: from the strategic brief (BRAND-STRATEGY, PROJECT-SCOPING) to client delivery (CLIENT-HANDOFF), across every technical domain.

The method used to build the kit is itself the kit:
1. Identify a gap
2. Find what professionals do (Tier 1-4)
3. Synthesise into actionable rules with sources
4. Implement and measure

---

## PDF conversion (for human sharing)

This document and DISCOVERY-GUIDE.md are designed to be readable in markdown and convertible to a clean PDF.

```bash
# Option 1: md-to-pdf (recommended, npm)
npx md-to-pdf DISCOVERY-GUIDE.md

# Option 2: pandoc (universal)
pandoc DISCOVERY-GUIDE.md -o DISCOVERY-GUIDE.pdf \
  --pdf-engine=wkhtmltopdf \
  --variable margin-top=20mm \
  --variable margin-bottom=20mm

# Option 3: VSCode + "Markdown PDF" extension
# Cmd+Shift+P → "Markdown PDF: Export (pdf)"
```
