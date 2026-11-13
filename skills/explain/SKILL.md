---
name: "explain"
description: "Academic layer. Explains any Claude Code term or tool (skill, hook, workflow, script, MCP...) at the user's level, with an analogy, an example and what to do next."
effort: low
argument-hint: "<term> | list"
---

# /explain

Language: if `language` is `fr` in `~/.claude/kit/profile.json` (or the person writes in French), follow `SKILL.fr.md` in this folder instead.

Available at any time, for any level. Also use it proactively: when you use a term the person has not met (check `terms_seen` in `~/.claude/kit/profile.json`), explain it in one line, then record it.

## Procedure

1. Read `~/.claude/kit/glossary/<language>/README.md` (`en` or `fr`, from the profile; `docs/glossary/` in the kit repo) and find the term's section (`list` shows all section titles). If absent, answer from general knowledge and say the glossary has no card yet.
2. Read `level` from the profile. Adapt:
   - Discovery: analogy first, no jargon, one concrete example, max 6 lines.
   - Practice: definition, example, when to use it.
   - Autonomous: definition, trade-offs, where the files live.
3. Always end with "Want to see one on your machine?" and offer a safe live demo (read-only).
4. Append the term to `terms_seen`.

## Card format (one `##` section per term)

`Term` / `In one sentence` / `Analogy` / `Example` / `Where it lives` / `Related`.

## Rules

- Simple words first, precise words second.
- Never claim a feature you have not checked in this kit.
- Never use em dashes.
