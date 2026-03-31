# Contributing to SQWR Project Kit

Thank you for contributing to this kit. A few rules to maintain the quality level.

---

## Core principle

**Every rule added to the kit must have a verifiable source.**

This kit has value because its rules are grounded in real standards (OWASP, W3C, NIST, Google SRE Book, etc.) — not in opinions. Before adding or modifying a contract, find the Tier 1 or Tier 2 source that justifies the rule.

See `METHODOLOGY.md` for the source hierarchy (Tier 1 = official documentation, Tier 2 = academic/industrial standards).

---

## Welcome types of contribution

| Type | Description |
|------|-------------|
| **New contract** | Uncovered domain (e.g. i18n, animations, native mobile) |
| **Contract improvement** | Missing threshold, more recent source, incomplete rule |
| **New framework** | Situational tool (e.g. templates for new use cases) |
| **New skill** | Slash-command workflow wrapping existing kit components |
| **New command** | Thin slash-command wrapper for an existing script or skill |
| **Correction** | Factual error, broken link, outdated threshold |
| **Translation** | Adapt a contract for another language (EN, NL, DE…) |

---

## Contract Quality Requirements

Every contract (new or updated) must meet these requirements before merging:

1. **Last Validated Date** (mandatory)
   Every contract MUST end with:
   ```
   > **Last validated:** YYYY-MM-DD — [list of key sources verified]
   ```
   This date MUST be updated whenever:
   - A source standard is re-verified (even without changes)
   - A threshold is updated to match a new source version
   - A new rule is added

2. **Source Tier Classification** (mandatory)
   Every numerical threshold must cite a Tier 1 (official spec/docs) or Tier 2 (academic/industrial) source.
   - ✅ Tier 1: RFC 7231, WCAG 2.1 W3C, Apple HIG, Google web.dev, NIST, ISO
   - ✅ Tier 2: Nielsen NN/G, Martin Fowler, DORA Research, ACM/IEEE papers, ProfitWell
   - ❌ Tier 3/4: blog posts, personal opinions, "industry best practice" without citation
   - When using Tier 3/4 for practical patterns (not thresholds), add: `(Advisory — Tier 4 source)`

3. **Threshold Precision** (mandatory)
   Vague rules like "good performance" are NOT acceptable.
   Required format: `[metric] [operator] [value] [unit] at [percentile] (source, year)`
   Example: `LCP ≤2.5s at p75 (Google Core Web Vitals — web.dev, 2023)`

---

## Contract structure

Every contract must follow this structure:

```markdown
# Contract — [Domain]

> Sources: [Author/Org (year)], [Author/Org (year)]
> Score: /100 | Recommended threshold: ≥XX

## Section 1 — [Name] (XX points)

- [ ] Measurable criterion with numerical threshold .............. (X)
- [ ] Criterion with cited source ............................. (X)

**Subtotal: /XX**

## Sources

| Reference | Contribution |
|-----------|--------|
| Author — *Title* (Publisher, year) | What it contributes |
```

---

## How to contribute

1. **Fork** the repo
2. **Create a branch**: `feat/contract-i18n` or `fix/wcag-threshold`
3. **Add the source** in the `## Sources` section of the modified file
4. **Update** `README.md` + `scripts/verify-kit.sh` if you add a file
5. **Test**: `bash scripts/verify-kit.sh --verbose` must return exit 0
6. **Pull Request** with a description of the change and a link to the source

---

## What will not be merged

- Rules without a verifiable source
- Personal opinions presented as standards
- Removal of existing sources without a more recent replacement
- Debug code, private hardcoded paths, personal data

---

## Questions

Open a GitHub Issue with the `question` label.

---

## Contributing agents, hooks, and workflows

### Contributing an audit agent (`agents/AGENT-*.md`)

Requirements:
1. **Must map to an existing audit** — each agent enforces one of the audit files in `audits/`
2. **Must have YAML frontmatter** — `description:` and `tools:` fields required
3. **Must have 4-level verification** — Levels 1–4: Exists, Substantive, Wired, Data Flows
4. **Must have a scoring section** — formula + threshold from `AUDIT-INDEX.md`
5. **Must cite sources** — reference the contract and audit it enforces

Structure: copy an existing agent as template, replace the domain-specific content.

### Contributing a hook (`hooks/hook-*.sh`)

Requirements:
1. **Must cite a contract** — comment at the top: `# Source: CONTRACT-X.md §Y — [standard]`
2. **Must be idempotent** — safe to run multiple times with identical inputs
3. **Must be advisory or blocking with clear justification** — blocking hooks need strong contract backing
4. **Must use correct exit codes** — exit 0 (continue), exit 2 (block with message)
5. **Must handle missing dependencies gracefully** — `python3` fallback for JSON parsing

### Contributing a workflow (`workflows/WORKFLOW-*.md`)

Requirements:
1. **Must have Observable Truths** — minimum 3 gates, each with a specific testable condition
2. **Must reference actual kit files** — link to agents, audits, frameworks with backtick paths
3. **Must include bash commands** where they make a check concrete
4. **Must cite METHODOLOGY.md** — all gates must align with the RESEARCH → CONTRACT → CODE → AUDIT cycle

---

### Contributing a skill (`skills/[name]/SKILL.md`)

Requirements:
1. **Must have complete YAML frontmatter** — `name`, `description`, `effort`, `model`, `allowed-tools` (required)
2. **Must serve a specific workflow** — skills wrap existing workflows, agents, or scripts (no free-form tasks)
3. **Must use `$ARGUMENTS`** for user-provided parameters
4. **Must reference existing kit files** — agents, contracts, workflows via relative paths
5. **Must have Observable Truths** — each gate must have a testable completion criterion

Frontmatter reference:
```yaml
---
name: "skill-name"           # kebab-case, matches directory name
description: "..."            # What this skill does (used for auto-discovery)
effort: low|medium|high       # Complexity level
model: haiku|sonnet|opus      # Model selection (haiku for lookup, opus for full audit)
agent: true                   # Required for skills that use the Agent tool
paths:                        # Files pre-loaded into context
  - "contracts/**"
allowed-tools: ["Read", "Grep", "Glob", "Bash", "Agent"]
---
```

## Adding or Updating Rules

Rules in `rules/` are contextual Markdown files with `paths:` frontmatter.

**To add a new rule file:**
1. Create `rules/your-rule-name.md`
2. Add frontmatter with `description:` and `paths:` array
3. Ground every rule in a Tier 1/2 source
4. Add the rule to `scripts/verify-kit.sh` Test 1 REQUIRED_FILES
5. Update README.md and DISCOVERY-GUIDE.md counts

**Rule quality criteria:**
- Each rule must be actionable (not vague guidance)
- Each rule must have a verifiable source
- Each rule must specify the consequence of violation

---

### Contributing a command (`commands/[name].md`)

Requirements:
1. **Must have YAML frontmatter** — `name`, `description`, `allowed-tools`
2. **Must delegate to an existing script or skill** — commands are thin wrappers, not implementations
3. **Must use `${CLAUDE_PLUGIN_ROOT}`** for kit-relative paths
4. **Must use `$ARGUMENTS`** for user-provided parameters

Format:
```yaml
---
name: "command-name"
description: "What this command does"
allowed-tools: ["Bash", "Read"]
---
```
