# CONTRACT-TOKEN-ECONOMY — Claude Code Cost & Context Optimization

> **Claude Code Standards Kit** by [SQWR Studio](https://sqwr.be)
>
> **Domain:** Token economy, model delegation, context management, shell output compression
> **Sources:** Anthropic API pricing (2025), Claude Code docs, empirical testing (3.2x cost reduction validated), RTK empirical data (83.7% shell compression validated)

---

## Why this matters

Claude Code bills per token. **99.4% of cost is input tokens** (context), not output. Every file Claude reads, every CLAUDE.md line, every agent spawn multiplies context. Without optimization, a single session can burn $5-15 in tokens for work that should cost $1-3.

This contract provides measurable thresholds for token economy across 7 domains: model delegation, context reduction, research patterns, output control, shell output compression, MCP server hygiene, and monitoring.

---

## 1. Model Delegation Strategy

### Principle

Use the cheapest model capable of each sub-task. Never use an expensive model for work a cheaper one handles equally well.

### Pricing reference (Anthropic, 2025)

| Model | Input (per MTok) | Output (per MTok) | Cache read |
|-------|------------------|--------------------|------------|
| Opus | $15 | $75 | 0.1x |
| Sonnet | $3 | $15 | 0.1x |
| Haiku | $0.80 | $4 | 0.1x |

### Rules

| ID | Rule | Threshold | Source |
|----|------|-----------|--------|
| TE-1.1 | **Subagents for research MUST use Haiku** | `CLAUDE_CODE_SUBAGENT_MODEL=haiku` | Anthropic pricing — 18x cheaper than Opus input |
| TE-1.2 | **Code generation MUST NOT use Haiku** | Minimum Sonnet for any code edit | Empirical: Haiku produces 40-60% more errors on complex code tasks |
| TE-1.3 | **Planning uses the primary model** | Opus or Sonnet depending on mode | Planning quality directly impacts execution quality |
| TE-1.4 | **Agent Teams MUST be disabled** unless explicitly needed | `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` unset | Agent Teams = ~7x token overhead (full context per agent) |

### Model assignment matrix

| Task type | Model | Why |
|-----------|-------|-----|
| Web research (5+ sources) | Haiku (subagent) | Isolates context, cheap |
| Documentation reading (>5k tokens) | Haiku (subagent) | Avoids polluting primary context |
| Quick lookup (1-2 sources) | Primary model direct | WebFetch uses Haiku internally |
| Codebase exploration | Built-in Explore agent | Optimized for search |
| Code writing/editing | Sonnet minimum | Quality threshold |
| Architecture planning | Opus | Highest reasoning quality |

---

## 2. Two-Phase Research Pattern (CRITICAL)

### Principle

Never dump raw research into the primary model's context. Research in two phases: summarize first, deep-dive selectively.

### The pattern

```
Phase 1: Haiku subagent → summary (max 400 tokens) + "dig deeper" table
Phase 2: Primary model reads summary → selective deep-dive on 1-3 URLs only
```

### Validated results

| Approach | Cost per research task | Signal quality |
|----------|----------------------|----------------|
| A. Haiku dump (no limit) | $3.68 | Low (noise buried signal) |
| B. Direct Opus research | $4.12 | Medium (expensive) |
| **C. Two-phase (this pattern)** | **$1.15** | **High (filtered, ranked)** |

**Measured improvement: 3.2x cheaper than dump, better signal-to-noise ratio.**

### Rules

| ID | Rule | Threshold |
|----|------|-----------|
| TE-2.1 | **All broad research (5+ sources) MUST use two-phase pattern** | Haiku summary first, then selective deep-dive |
| TE-2.2 | **Haiku summary MUST NOT exceed 400 tokens** | Hard limit — ignore surplus if exceeded |
| TE-2.3 | **Summary MUST include a ranked "dig deeper" table** | Format: Priority / Source / Why / URL |
| TE-2.4 | **Deep-dive limited to 1-3 URLs** from the ranked table | Prevents context bloat |
| TE-2.5 | **Exception: user explicitly requests exhaustive research** | Only override when asked |

### Mandatory subagent output format

```markdown
## [Topic] - [N] sources analyzed

### Executive summary (3-5 bullet points)
- ...

### Dig deeper
| # | Source | Why | URL |
|---|--------|-----|-----|
| 1 | ... | ... | ... |

### Discarded (not relevant or redundant)
- ...
```

---

## 3. Context Reduction

### Principle

Every token in context costs money on every request. Reduce what Claude reads at session start.

### Rules

| ID | Rule | Threshold | Impact |
|----|------|-----------|--------|
| TE-3.1 | **CLAUDE.md MUST be under 400 lines** | Hard limit | Each line = ~10 tokens loaded on every request |
| TE-3.2 | **Reference docs MUST be in skills/commands** (lazy-loaded) | Skills load ~100 tokens metadata, full content on invocation only | 80-90% savings on reference content |
| TE-3.3 | **Every project MUST have a `.claudeignore`** | Exclude: node_modules, build, lock files, binaries | Single fastest win — zero quality tradeoff |
| TE-3.4 | **Monorepo root MUST have a `.claudeignore`** | Common patterns across all sub-projects | Prevents duplicate scanning |
| TE-3.5 | **`autoCompactWindow` SHOULD be 60000-80000** | Aggressive compaction prevents context overflow | Lower = more frequent compaction = cheaper sessions |
| TE-3.6 | **Unused plugins MUST be disabled** | Set to `false` in `enabledPlugins` | Each plugin adds metadata to context |

### .claudeignore essential patterns

Every project MUST exclude at minimum:

```gitignore
# Dependencies (largest single source of token waste)
node_modules/
.pnpm-store/
Pods/

# Build outputs
.next/
dist/
build/
DerivedData/

# Lock files (huge, zero information value for Claude)
package-lock.json
pnpm-lock.yaml
yarn.lock

# Binary assets (Claude can't meaningfully process these)
*.png
*.jpg
*.jpeg
*.gif
*.ico
*.webp
*.mp4
*.pdf
*.zip
```

### CLAUDE.md optimization strategy

| Content type | Keep in CLAUDE.md | Move to skill |
|-------------|-------------------|---------------|
| Business rules & philosophy | YES | - |
| Brand identity & voice | YES | - |
| Architecture overview | YES (condensed) | - |
| Tips for Claude (behavioral) | YES | - |
| Common commands | - | `/reference` skill |
| Security patterns | - | `/reference` skill |
| DB query patterns | - | `/reference` skill |
| Known bugs & workarounds | - | `/reference` skill |
| Environment variables | - | `/reference` skill |
| Sprint/focus (ephemeral) | DELETE | Memory system |

---

## 4. Output Control

### Principle

Thinking tokens and output tokens are billed at output rates (5x input on Opus). Limit them.

### Rules

| ID | Rule | Threshold | Source |
|----|------|-----------|--------|
| TE-4.1 | **`MAX_THINKING_TOKENS` SHOULD be 10000** | Default can be 32k-80k — 3-8x waste | Anthropic billing: thinking tokens = output price |
| TE-4.2 | **`CLAUDE_CODE_MAX_OUTPUT_TOKENS` SHOULD be 16384** | Prevents runaway generation | Sufficient for any single response |
| TE-4.3 | **`effortLevel` SHOULD be "medium"** for routine work | "high" = more thinking tokens per request | Switch to "high" only for complex architecture tasks |
| TE-4.4 | **Env var and setting MUST be aligned** | `effortLevel` in settings = `CLAUDE_CODE_EFFORT_LEVEL` in env | Env var wins — contradictions cause confusion |

---

## 5. Shell Output Compression (RTK)

### Principle

When Claude Code runs shell commands (`git diff`, `npm run build`, `eslint .`, `cargo test`…), the raw output enters the context window. A single ESLint run on a large project can inject 300k+ tokens. **RTK (Rust Token Killer)** intercepts these commands and compresses output before it reaches the model.

### Validated results (RTK empirical data, 2025)

| Command | Raw tokens | With RTK | Compression |
|---------|-----------|----------|-------------|
| `cargo test` (262 tests) | 4,823 | 11 | 99% |
| `git diff` (large changeset) | 21,500 | 1,259 | 94% |
| `eslint .` (large project) | ~322,000 | ~400 | 99.9% |
| 30-minute Claude Code session | ~150,000 | ~45,000 | **70%** |

### Rules

| ID | Rule | Threshold |
|----|------|-----------|
| TE-5.1 | **RTK MUST be installed** on any machine using Claude Code for development | `brew install rtk-ai/tap/rtk` or `cargo install rtk` |
| TE-5.2 | **RTK hook MUST be registered** as PreToolUse Bash hook | After security hooks, before execution |
| TE-5.3 | **RTK telemetry SHOULD be disabled** | `RTK_TELEMETRY_DISABLED=1` in env |
| TE-5.4 | **Measure savings weekly** | `rtk gain --history` |

### Installation

```bash
# Install
brew install rtk-ai/tap/rtk

# Initialize for Claude Code (creates hook file)
rtk init -g

# Add to ~/.claude/settings.json PreToolUse hooks:
# { "type": "command", "command": "~/.claude/hooks/rtk-rewrite.sh" }

# Verify
rtk gain
```

### Hook order (important)

```
Bash command → [1] security-validate.sh → [2] rtk-rewrite.sh → Claude Code
```

Security check runs first. RTK compression runs second on the validated command.

### RTK + opusplan mode

The recommended full setup uses three models in sequence:

```
User request
  → Phase 1: Haiku subagent (web/doc research, max 400 tokens)
  → Phase 2: Opus (reads summary, writes plan)
  → Phase 3: Sonnet (executes plan — code, edits, shell commands)
        ↳ Shell commands → RTK compression before entering context
```

**Settings to activate this pipeline:**

```json
{
  "model": "opusplan",
  "env": {
    "CLAUDE_CODE_SUBAGENT_MODEL": "haiku",
    "RTK_TELEMETRY_DISABLED": "1"
  }
}
```

---

## 6. MCP Server Hygiene

### Principle

Every active MCP server loads its tool definitions into every session's context. With 5+ MCP servers active, this overhead can reach 50-100K tokens before you write a single line of code — and RTK cannot compress this overhead (it's context, not shell output).

### Rules

| ID | Rule | Threshold |
|----|------|-----------|
| TE-6.1 | **Disable MCP servers not used in daily workflow** | Each unused MCP = 10-20K tokens overhead per session |
| TE-6.2 | **Never configure cloud MCP servers (Gmail, Notion, Calendar) locally** if they duplicate integrations already in your primary MCP hub | One integration platform is sufficient |
| TE-6.3 | **Audit active MCP servers monthly** | `claude mcp list` → disable unused |
| TE-6.4 | **Never store API keys in mcp.json** | Use environment variables or secret managers |

### MCP server cost model

```
Session cost = base context + (N_mcp × 10-20K tokens) + conversation
```

With 5 MCP servers: +50-100K tokens before any work = +$0.75-1.50/session on Opus.

### Recommended: minimal MCP config

Keep only what you use daily. Prefer one MCP hub that aggregates multiple integrations (e.g. Composio, RUBE) over many individual MCP servers.

### RTK bypass for test commands (Critical)

RTK over-compresses test output (Issue #690 — 3.6M tokens wasted in one session). **Add bypass rules for all test commands:**

```toml
# ~/.config/rtk/filters.toml or equivalent
[filters.test-bypass]
match_command = "^(npm|npx)\\s+(run\\s+)?(test|e2e|playwright|jest|vitest)"
max_lines = -1  # No compression on test output
```

---

## 7. Monitoring & Enforcement

### Rules

| ID | Rule | Threshold |
|----|------|-----------|
| TE-7.1 | **PostToolUse hook on Agent matcher** to monitor subagent output | Alert if subagent output > 800 words |
| TE-7.2 | **Compact instructions in CLAUDE.md** to survive compaction | Section header: `# Compact instructions` |
| TE-7.3 | **Memory system documents the pattern** for cross-session persistence | Feedback memory with validated test results |
| TE-7.4 | **Measure cost weekly** with `ccusage daily --breakdown` + `rtk gain --history` | Target: 30-50% reduction from baseline |

### Recommended settings.json

```json
{
  "env": {
    "CLAUDE_CODE_EFFORT_LEVEL": "medium",
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "16384",
    "MAX_THINKING_TOKENS": "10000",
    "CLAUDE_CODE_SUBAGENT_MODEL": "haiku",
    "CLAUDE_CODE_DISABLE_1M_CONTEXT": "1"
  },
  "autoCompactWindow": 60000,
  "effortLevel": "medium",
  "skipDangerousModePermissionPrompt": true,
  "permissions": {
    "defaultMode": "bypassPermissions"
  }
}
```

---

## Scoring

| Criterion | Weight | Score |
|-----------|--------|-------|
| Model delegation configured correctly | 20% | 0-100 |
| Two-phase research enforced | 25% | 0-100 |
| .claudeignore on all projects | 20% | 0-100 |
| CLAUDE.md under 400 lines with skills migration | 15% | 0-100 |
| Output controls configured | 10% | 0-100 |
| RTK installed, hooked, and test bypass configured | 15% | 0-100 |
| MCP servers audited (only essentials active) | 10% | 0-100 |
| Monitoring hooks active | 5% | 0-100 |

**Delivery threshold: >= 85/100**

---

## Sources

| Source | Reference |
|--------|-----------|
| Anthropic API Pricing | anthropic.com/pricing (2025) |
| Claude Code Documentation | code.claude.com/docs |
| Prompt Caching | Anthropic docs — cache reads at 0.1x input cost |
| Two-phase pattern | Empirical testing, validated 2025-04-04 (3.2x cost reduction) |
| arXiv 2601.08815 | Contract-based prompting reduces token usage by 90% |
| DORA State of DevOps 2024 | Efficiency metrics for AI-assisted development |
