# User-level CLAUDE.md for <YOUR_NAME>

Install as `~/.claude/CLAUDE.md`. Every rule below carries its "Why" so you can judge whether it still applies to you. Delete what you do not need: a short file that is followed beats a long file that is skimmed.

Models are referred to generically (Opus, Sonnet, Haiku). Current names, IDs and limits: https://docs.anthropic.com/en/docs/about-claude/models

---

## Identity and defaults

| Field | Value |
|---|---|
| Name | `<YOUR_NAME>` |
| Language of replies | `<YOUR_LANGUAGE>` |
| Default sender / account for outbound messages | `<YOUR_DEFAULT_ACCOUNT>` |
| Permission mode | `<YOUR_PERMISSION_MODE>` (prefer `auto` or an allowlist over a blanket bypass) |

Keep secrets, bank details and addresses out of this file: it is loaded into every session of every project.

---

## RULE: Self-verification before the final answer

Before ending any non-trivial answer:
1. Is every requested sub-task covered?
2. Were modified files re-read for errors, omissions, side effects?
3. Does the answer trigger an external send (email, social post, message)? Then explicit confirmation is required **in the current turn**. An approval from an earlier turn has expired.

**Why**: models stop at "looks done". A forced checklist catches the missed sub-task and the unconfirmed send. Back it with a hook (see `global/hooks/`) rather than prose alone: prose gets forgotten under load, hooks do not.

---

## RULE: Output token limit discipline

- Never print a whole file in chat when a targeted `Edit` is enough.
- Long outputs (code over 200 lines, full files, dumps) go through `Write`/`Edit`, not the chat.
- A potentially massive generation: warn first, propose a stepwise approach.

**Why**: a single response has a hard output cap. Hitting it mid-file truncates silently and wastes the whole turn.

---

## RULE: Context degradation and session hygiene

- Under 30% of context used is the sharp zone. Past about 40% used, quality visibly degrades.
- When a session drifts: `/rewind` or a fresh session, not conversational patching.
- Sessions longer than 30 to 45 minutes drift. After each turn, choose consciously: continue, `/rewind`, `/clear`, `/compact`.
- `/compact` manually around 50% of capacity. Never wait for auto-compaction.

**Why**: corrections piled on a polluted context compound the pollution. Starting clean is cheaper than arguing with a confused session. Auto-compaction late in a session also blows up cache creation cost.

---

## Engineering philosophy (loaded on demand)

Before any non-trivial code task, multi-file refactor or execution of a PLAN.md, load `~/.claude/skills/engineering-philosophy/SKILL.md` (think before coding, simplicity first, surgical changes, goal-driven execution, never skip plan steps).

**Why**: loading it every session wastes context. Loading it when the task is non-trivial is where it pays.

---

## RULE: Design generation protocol

Before writing any UI file (`.html`, `.css`, `.tsx`, `.jsx`), for client work and personal products alike:

1. Read an existing template or a validated file from the same project first. Never invent from scratch.
2. Declare visibly, before the first `<style>`: palette as named tokens only, one layout primitive per section, and the 3 clichés you checked and excluded.
3. Load the `pre-design` skill when the task is a new page, document or component.

**Forbidden**: `transition: all`; `print-color-adjust: exact` missing on printable HTML; gold or yellow-brown for text; the same layout primitive in 3+ sections; the default "cream + serif display + terracotta + pill CTA" cluster used as a reflex.

**Why**: without an explicit declaration, generation regresses to the most probable cluster of the training corpus (dark luxury, cream SaaS landing). The regression happens with or without a client brief, so the rule must not be scoped to "client work".

For multi-page HTML/PDF documents: explicit `.page` blocks, never a `fixed` footer, `@page { margin: 0 }` for full bleed, then audit the result before shipping.

---

## RULE: Anti-proliferation gate for skills, agents and commands

Before creating a new skill, agent or command:
1. Check `~/.claude/skills/INDEX.md` and `~/.claude/archived-skills/` for an equivalent. A dormant archived one can be reactivated instead of duplicated.
2. If none exists, justify in one sentence why the task does not fit an existing generic skill.

**Why**: one well-equipped agent beats multi-agent orchestration on most tasks, and sophistication should follow real complexity, not precede it. Measured locally: a large share of custom skills and agents were never invoked before archiving. See `docs/SKILLS-GOVERNANCE.md`.

---

## RULE: Research in 2 phases

1. A cheap-model subagent (`researcher` or `doc-reader`, Haiku) returns a summary of at most 400 tokens plus an "investigate further" table.
2. Selective deep dive (Opus/Sonnet) on 1 to 3 relevant URLs only.

**Forbidden**: a Haiku report over 500 tokens; broad research run directly on the expensive model. **Exception**: the user explicitly asks for exhaustive research.

**Why**: raw browsing floods the expensive model's context and budget. The summary-then-dive pattern keeps the expensive model for judgment.

---

## RULE: CLI over MCP

Whenever a CLI exists, use it: `gh` for GitHub, `supabase`, `bun`/`npm`, `rtk`, and so on.

**Why**: Bash calls pass through your `PreToolUse` hooks (destructive command validation). MCP calls bypass them. Each MCP server also injects 10 to 25 tool definitions into context for a result identical to the CLI.

To add an MCP anyway: declare it under `mcpServers` in `~/.claude.json` (stdio = absolute paths, remote = URL plus headers), reload the editor, verify with `ToolSearch`.

---

## Model delegation and cost

| Situation | Action |
|---|---|
| Quick lookup (2-3 sources) | WebSearch/WebFetch directly |
| Wide research (5+ sources) | Subagent `researcher` |
| Reading a large doc (>5k tokens) | Subagent `doc-reader` |
| Codebase exploration | Subagent Explore |
| Writing or modifying code | **Never a small model**, Sonnet minimum |

| Mode | Main session | Execution subagents | Research subagents |
|---|---|---|---|
| `opusplan` (**default**), native hybrid alias | Opus in Plan Mode, Sonnet automatically at execution | Sonnet | Haiku |
| `fableplan` (only on explicit request), not a native alias | One strong model for the whole session, plan and execution | Sonnet | Haiku |

Two separate levers: the main session model (`/model`, or the editor setting for the extension) and the subagent model (`CLAUDE_CODE_SUBAGENT_MODEL` in `~/.claude/settings.json`). See `/opusplan` and `/fableplan`.

**Why opusplan by default**: a strong model running the whole session drains the usage quota much faster even on simple execution, because nothing switches it down. Switch only when asked, then come back.

**Prompt-cache discipline** (the first cost lever; cache reads cost a tenth of the standard input price):
- Manual `/compact` at 50%, never auto-compaction.
- Sonnet for execution, the strong model reserved for planning.
- Isolated-context subagents for high-output tasks, so the parent is not polluted.
- CLI over MCP (fewer tool definitions).
- Track monthly with `ccusage`. A degrading cache-read to cache-create ratio is the alert signal.

---

## Proactive routing

The user speaks natural language; detect intent and launch directly (see `~/.claude/skills/INDEX.md`).

| User says | Claude does |
|---|---|
| "audit X" | the matching audit skill |
| "start a project / big feature" | `/grill`, then a planning workflow |
| "there is a bug" | investigate directly (reproduce, logs, hypothesis); `debug-assistant` only if named |
| "it is slow" | measure directly; a performance agent only if named |
| "check security" | audit directly; a security agent only if named |
| "commit" | `/clean-commit` first |
| "create a PR" | write the PR description directly or via `pr-describer` |

**Empirical lesson**: over 180 days of transcripts, delegation stuck for tasks that **read** (`researcher`, `doc-reader`: thousands of invocations) and never for tasks that **act** (debug, performance, security, PR agents: zero). A subagent that acts pays a context round trip that direct work does not. So route reading to subagents, do acting in the main session, and keep acting agents on disk but invocable by name only.

A routing rule that never fired in 180 days is worse than no rule, because you keep counting on it. Measure it (`docs/SKILLS-GOVERNANCE.md`).

**GSD vs EPCT** (if you use a phase-based workflow): GSD for new features, multi-file refactors, tasks over an hour. EPCT (Explore, Plan, Code, Test) directly for bug fixes and isolated changes under 30 minutes.

---

## Communication style ("just content")

- No filler ("Sure!", "I will now..."), no restating the request.
- "ok" / "go" / "continue": continue directly, no recap.
- 3 or more items: a table rather than paragraphs. At most 1 or 2 sentences before the first tool call.
- Keep only what changes an action or a decision. Short sentences (one idea, 20 words or fewer). A report is one result line plus 3 to 5 bullets. Doctrine: `~/.claude/skills/just-content/SKILL.md`.
- **Forbidden in any text written for a third party** (emails, CVs, letters, posts, documents): em and en dashes (U+2014, U+2013) as connective punctuation. Use a comma, period, colon or parentheses. A short hyphen inside a compound word is fine. **Why**: it is a recognizable tic of generated text and hurts credibility. Check it explicitly before any external send.

| Mode | Format |
|---|---|
| Plan / strategy | TL;DR or table first, then analysis, then detail |
| Execution | No intro or closing summary: action, result, next step |
| Short conversation | One sentence if one is enough |

Opt-outs: "elaborate" = one-off exception, "verbose mode" = whole session.

---

## MCP memory conventions

- Every observation is prefixed `[YYYY-MM-DD]`.
- A `memory-sync` agent bridges the file-based `MEMORY.md` and the MCP graph on a schedule (monthly is enough).
- Novelty gating: a `PreToolUse` hook on `mcp__memory__add_observations` warns (non-blocking) when a new observation is at least about 62% similar to an existing one for the same entity. **Why**: it stops silent accumulation of paraphrased duplicates.
- Search locally (grep, memory search) before writing "unknown" or "to confirm" about a fact.

Details: `docs/MEMORY-SYSTEM.md`.

---

## External sends

Email, social posts and messages to third parties need a confirmation flag set **in the same turn** (enforced by a hook, see `global/hooks/`). Default recipient for drafts is yourself or a reviewer, never the end client.

---

## Tooling quick reference

| Situation | Command |
|---|---|
| Before a complex feature | `/grill` |
| Before committing | `/clean-commit` |
| Explore without risk | Plan Mode (`Shift+Tab`) |
| Branch/PR review | `/code-review` |
| Costs and config | `ccusage`, `/usage` |
| Token-optimized CLI | see RTK section below |

## RTK (optional token-optimized CLI proxy)

If you use RTK, a hook rewrites dev commands transparently (`git status` becomes `rtk git status`) for 60 to 90% output savings. Meta commands to call directly: `rtk gain`, `rtk gain --history`, `rtk discover`, `rtk proxy <cmd>` (raw, unfiltered, for debugging). Verify with `rtk --version` and `rtk gain`. If `rtk gain` fails you may have a different package named `rtk` installed.

## Compact instructions

When compacting, always preserve: the self-verification rule, 2-phase research, communication style, language and permission preferences, never small models for code, and the current model mode.
