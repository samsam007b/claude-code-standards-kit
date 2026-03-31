---
name: "new-feature"
description: "Complete RESEARCH → CONTRACT → CODE → AUDIT workflow for a new feature. Identifies applicable standards, activates contracts, and runs audit agents on completion."
effort: high
model: sonnet
context: fork
agent: "general-purpose"
argument-hint: "feature description"
paths:
  - "contracts/**"
  - "audits/**"
  - "workflows/WORKFLOW-NEW-FEATURE.md"
  - "agents/**"
allowed-tools: ["Read", "Grep", "Glob", "Bash", "Agent"]
---

# /new-feature — Complete Feature Workflow

**Usage:** `/new-feature [description of feature]`

This skill runs the full RESEARCH → CONTRACT → CODE → AUDIT cycle for the feature described in `$ARGUMENTS`.

---

## Gate 0 — Scope

Define the feature before writing any code.

1. Read `workflows/WORKFLOW-NEW-FEATURE.md` for the full process
2. Draft a Shape Up Pitch with:
   - **Problem**: What user need does this solve?
   - **Appetite**: How much effort is this worth?
   - **No-Gos**: What is explicitly out of scope?

**Observable truth**: Scoping doc exists before implementation starts.

---

## Gate 1 — Research (identify applicable contracts)

Search across the 29 contracts to find which apply.

1. Run the following to identify relevant contracts:
```bash
grep -l "$ARGUMENTS" contracts/ 2>/dev/null | head -10 || echo "No exact match — use semantic search"
```

2. Check these domains for your feature:
   - Any form input? → `CONTRACT-SECURITY.md §3` (Zod validation), `CONTRACT-ACCESSIBILITY.md §2` (WCAG 1.3.1)
   - Any API call? → `CONTRACT-API-DESIGN.md`, `CONTRACT-RESILIENCE.md`
   - Any UI component? → `CONTRACT-DESIGN.md`, `CONTRACT-ACCESSIBILITY.md`
   - Any data storage? → `CONTRACT-SUPABASE.md`, `CONTRACT-DATABASE-MIGRATIONS.md`
   - Any TypeScript? → `CONTRACT-TYPESCRIPT.md` (always)
   - Any test? → `CONTRACT-TESTING.md` (always)

3. Read each relevant contract and extract the specific rules that apply.

**Observable truth**: List of applicable contracts and specific rules documented in CLAUDE.md "Active contracts" section.

---

## Gate 2 — Implement

Code with active hooks enforcing contracts.

**Before coding**, ensure `.claude/settings.json` references the SQWR hooks.

During implementation, watch for hook warnings:
- `hook-contract-compliance.sh` fires on every Write — address warnings immediately
- `hook-no-dangerous-html.sh` fires on TSX writes — never bypass without DOMPurify

**Observable truth**: `npm run build && npm test` exits 0 (or equivalent for your stack).

---

## Gate 3 — Audit

Run the audit agents relevant to the feature.

```
Ask Claude: "Run agents/AGENT-SECURITY-AUDIT.md on this feature"
Ask Claude: "Run agents/AGENT-CODE-QUALITY-AUDIT.md"
```

For UI features, also run:
```
Ask Claude: "Run agents/AGENT-ACCESSIBILITY-AUDIT.md"
Ask Claude: "Run agents/AGENT-DESIGN-AUDIT.md"
```

Fix all findings above the blocking threshold before continuing.

**Observable truth**: All audit scores above their thresholds (Security ≥70, Code-Quality ≥75, Accessibility ≥80 for EU).

---

## Gate 4 — Ship

Prepare the feature for review and merge.

1. Update `CHANGELOG.md` with the new feature under `[Unreleased]`
2. Create a PR with audit scores in the description
3. Ensure CI passes (`verify-kit.sh` equivalent for the project)

**Observable truth**: PR created with CHANGELOG entry and audit scores visible.

---

## Reference

Full workflow details: `workflows/WORKFLOW-NEW-FEATURE.md`
Source methodology: `METHODOLOGY.md` — "search first, implement after"
