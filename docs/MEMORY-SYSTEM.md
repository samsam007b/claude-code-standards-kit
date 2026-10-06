# Memory system

Claude Code starts every session blank. A memory system turns corrections and decisions into durable context. This kit uses two complementary layers.

| Layer | Form | Best for | Loaded |
|---|---|---|---|
| File-based memory | `MEMORY.md` index plus one-fact files | Narrative facts, preferences, project state, lessons ("Why" and "How to apply") | Index is auto-loaded each session, files on demand |
| MCP memory graph | Entities, relations, dated observations | Structured cross-session facts you query by entity | On demand via `mcp__memory__*` tools |

## Layer 1: file-based memory

Location (per project): `~/.claude/projects/<project-slug>/memory/`

```
memory/
  MEMORY.md              index, one line per memory, always loaded
  feedback_testing.md    one fact per file
  project_billing_v2.md
  reference_ci_dashboard.md
```

### MEMORY.md: the index

One line per memory: link, then a hook that says when it matters. No content in the index. Keep it under about 150 lines, because it is loaded every session.

```markdown
# Memory

- [Testing preference](feedback_testing.md): integration tests hit a real database, never mocks
- [Billing v2](project_billing_v2.md): migration in progress, freeze on schema changes until the cutover
- [CI dashboard](reference_ci_dashboard.md): where to find flaky-test stats
```

### One-fact files

Each file carries frontmatter, then the fact, then why it holds and how to act on it.

```markdown
---
name: feedback-testing
description: Integration tests must use a real database, not mocks
type: feedback
---

Integration tests hit a real database. Do not mock the data layer.

**Why**: a mocked suite passed while a production migration failed. Mocks hid the divergence.

**How to apply**: when writing or reviewing tests that touch persistence, use the test database fixture. Mock only external HTTP services. Related: [[project-billing-v2]].
```

Frontmatter fields:

| Field | Meaning |
|---|---|
| `name` | Stable identifier, kebab-case |
| `description` | One line, specific enough to decide relevance without opening the file |
| `type` | `user` (who the user is, preferences), `feedback` (corrections and confirmed approaches), `project` (state of ongoing work), `reference` (pointers to external systems) |

Conventions:
- **One fact per file.** If two facts have different lifetimes, they are two files.
- **`[[links]]`** between related memories, by `name`. They let you traverse without duplicating.
- **Why and How to apply** on every `feedback` and `project` memory. A rule without its reason cannot be judged against edge cases, and goes stale silently.
- **Absolute dates**, never "yesterday" or "last week". Convert relative dates when saving.
- **Do not store** what the code or git history already says (architecture, file paths, recent changes). Store what is not derivable: decisions, constraints, preferences, external pointers.
- **Never store secrets.**
- Update or delete a memory the moment it turns out wrong. A stale memory is worse than none, because it is trusted.
- Before acting on a memory that names a file, function or flag, verify it still exists. A memory is a claim about the past.

### Search before saying "unknown"

Before writing "I have no information" or flagging a fact as "to confirm", search locally: the memory files, the repo (`grep`, `find`), and the MCP graph. A hook can enforce this on the final answer.

## Layer 2: MCP memory graph

The `memory` MCP server stores a knowledge graph in a local JSONL file: **entities** (a person, project, tool), **relations** between them, and **observations** (atomic facts attached to an entity).

### Observation convention

Every observation starts with an ISO date: `[2026-03-14] Chose Postgres over MySQL for the billing service`. Dates let you resolve contradictions (the newer wins unless said otherwise) and age out stale facts.

### Novelty gate

Left alone, a graph accumulates paraphrased duplicates ("uses Postgres", "database is Postgres", "Postgres chosen"). A `PreToolUse` hook on `mcp__memory__add_observations` compares each new observation to the existing ones of the same entity with a string-similarity ratio (for example `difflib.SequenceMatcher`) and warns on stderr at about 0.62 similarity or more.

Design choices:
- **Advisory, always exit 0.** A near-duplicate can be a legitimate update of a fact that changed. Blocking would punish exactly those.
- Done client-side because the MCP server has no novelty check of its own.
- The threshold is a tunable constant. Raise it if you get too many warnings on short observations.

### Monthly sync

A `memory-sync` agent (a small model is enough, see `global/agents/memory-sync.md`) bridges the two layers on a schedule, monthly is enough:
1. Read the whole graph and the memory files.
2. Facts in files but not in the graph: add them, with the date prefix.
3. Graph observations without a date: flag for later migration.
4. Contradictions: report, never overwrite.
5. Never delete. Deletion is a human decision.

For a manual push at the end of an important session, a tiny script `memory-add-observation.sh <entity> "<observation>"` that prefixes the date and appends to the graph is enough.

## When to use which

| You want to remember... | Put it in |
|---|---|
| "Do not mock the DB in tests, and why" | file memory, type `feedback` |
| "Project X is frozen until the 14th" | file memory, type `project` |
| "Alice owns the payments service" | MCP graph (entity plus observation) |
| "Bugs are tracked in board Y" | file memory, type `reference` |
| Something the code already shows | nowhere |

## Failure modes this design avoids

| Failure | Mitigation |
|---|---|
| Index grows until it eats the context | One line per memory, content lives in files |
| Rules that nobody can judge | Mandatory Why and How to apply |
| Silent duplicates in the graph | Novelty gate plus monthly sync |
| Stale facts trusted forever | Absolute dates, verify before acting, delete when wrong |
| "I don't know" about something on disk | Search-before-uncertainty rule |
