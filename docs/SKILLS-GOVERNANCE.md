# Skills governance

Skills, agents and commands are cheap to write and expensive to keep: each one adds routing ambiguity, description text in context, and maintenance. This document describes a lightweight governance loop: **index, archive, measure**.

## Why

- A single well-equipped agent beats multi-agent orchestration on most tasks. Add structure when the complexity is real, not in advance.
- In a measured setup, a large share of custom skills, agents and commands had never been invoked once before an audit archived them. People create what they imagine they will use.
- Delegation behaves asymmetrically: skills and agents that **read** (research, doc reading) get used heavily; those that **act** (debug, performance, security, PR) are almost never invoked, because a subagent that acts pays a context round trip that direct work does not. Measure before promising an automatic route.

## The three parts

### 1. Index: `~/.claude/skills/INDEX.md`

One file listing every skill, agent and command with a one-line description and a collection label. Rules:
- Regenerate counts from disk, never by hand (a script counts files per collection and rewrites the header).
- Consult it before saying "I cannot do that" and before creating anything new.
- Keep descriptions as **triggers** (when to use), not summaries.

### 2. Archive: `~/.claude/archived-skills/`

Dormant items move here instead of being deleted. Subfolders mirror the live ones (`skills/`, `commands/`, `agents/`), optionally grouped by audit batch.
- Archiving removes the item from the live routing surface and from context.
- Reactivating is a `mv` back, so an archived equivalent is always cheaper than a duplicate.
- Deleting is a separate, later decision.

### 3. Measurement: usage from transcripts

Session transcripts under `~/.claude/projects/**/*.jsonl` already contain the full history of tool calls. A scanner reads them and counts, per skill, agent and command, the invocations over a sliding window (180 days is a good default):
- Agent invocations: `Agent`/`Task` tool calls with `subagent_type`.
- Skill invocations: `Skill` tool calls, plus slash commands in user messages.
- Output: a state file (counts, last used) and a ranked list of items never invoked.

Why transcripts rather than a hook: a hook only sees the future, so the first useful number arrives months later, and it requires editing `settings.json`. Transcripts give the history retroactively and without touching configuration.

Making the scan cheap on a large corpus:
- A cache keyed on (path, size, mtime) so unchanged files are skipped.
- A substring pre-filter before `json.loads`, since most lines are irrelevant.
- Run it daily or weekly from a scheduler.

The scripts live in `global/scripts/` (`usage-scan.py`, `skills-index-refresh.py`).

## The gate

Before creating a skill, agent or command:
1. Search `INDEX.md` and `archived-skills/` for an equivalent. Reactivate an archived one rather than duplicate.
2. If nothing fits, write one sentence explaining why the task does not fit an existing generic skill.
3. Make the description a trigger.
4. After a quarter, check the usage scan. Zero invocations: archive it.

## Review cadence

| Frequency | Action |
|---|---|
| Daily or weekly (automatic) | Usage scan, index count refresh |
| Quarterly | Archive items with zero invocations in the window, check that routing rules in `CLAUDE.md` still match real usage |
| On each new skill | The gate above |

A routing rule that never fired in the window is worse than no rule: you keep counting on it. Publish the "promised but never invoked" list at each review and make every such item earn its place or leave.
