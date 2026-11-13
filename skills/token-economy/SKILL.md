---
name: token-economy
description: Optimizes Claude Code costs and model delegation: RTK shell compression, Haiku/Sonnet/Opus delegation, context strategy, 3x reduction empirically validated.
tags: [tokens, cost, optimization, delegation, haiku, claude-code, rtk]
model: haiku
---

# /token-economy: Claude Code Token & Cost Optimization

## When to use

- Analyze the costs of a session or workflow
- Decide which model to delegate for which task
- Reduce the tokens of a command or prompt
- Audit RTK usage and compression gains

## Delegation hierarchy (empirical, 3.2x reduction validated)

| Task | Model | Why |
|-------|--------|---------|
| Web research, summaries, reading docs | **Haiku** | 20x cheaper, sufficient for synthesis |
| Writing code, modifications | **Sonnet** | Optimal quality/cost ratio |
| Architecture, complex plans, reasoning | **Opus** | When Sonnet is insufficient |
| Never Haiku for: writing critical code | N/A | Insufficient quality, illusory savings |

## RTK: Rust Token Killer (83.7% shell compression)

RTK intercepts shell command outputs and compresses them before injection into the context:
- `git status` → RTK filters out irrelevant files
- `npm test` → RTK extracts only the failures
- `git log` → RTK summarizes the commits

```bash
rtk gain              # compression analytics
rtk discover          # analyzes Claude history for missed opportunities
rtk gain --history    # command history and gains
```

## Context strategy

### What consumes the most
1. Unnecessary whole files read (use `Read` with `offset/limit`)
2. Verbose shell command results (→ RTK)
3. Broad searches without filtering (→ Haiku subagent first)
4. Long conversations without compaction (→ `/compact`)

### 2-phase rule (mandatory in this setup)
1. **Phase 1**: Haiku subagent → summary of max 400 tokens
2. **Phase 2**: Opus reads the summary → selective deep-dive on 1-3 URLs

### Prompt caching
- The Anthropic cache has a 5-minute TTL
- For `/loop` loops: delay < 300s to stay within the cache
- `CLAUDE_CODE_MAX_OUTPUT_TOKENS=128000` in .zshrc for long outputs

## Auditing a workflow

To analyze the real cost of a session:
```bash
ccusage daily          # today's cost
ccusage session        # cost of the current session
rtk gain --history     # commands compressed by RTK
```

## Output format

```
## Token Economy Audit: [workflow/session]

### Current cost: $X.XX
### Estimated optimized cost: $X.XX (-XX%)

### Delegations to review
| Task | Current model | Recommended model | Savings |
|-------|-------------|------------------|---------|

### Missed RTK compressions
[commands that should have gone through RTK]

### Actions
1. [specific action]
```
