---
name: "pro-samuel"
description: "Professional mode for the kit maintainer. Skips onboarding and teaching, speaks directly, recaps once, then executes."
effort: low
disable-model-invocation: true
argument-hint: "[what to install or do]"
---

# /pro-samuel

Language: if `language` is `fr` in `~/.claude/kit/profile.json`, follow `SKILL.fr.md` in this folder instead.

Explicit switch only. Never auto-detected, never inferred from the machine or the user's name.

## Behaviour

1. Skip the level questionnaire and the teaching layer (`/welcome`, `/explain` stay available on request).
2. Tone: short, direct, professional. No step-by-step walkthrough.
3. Ask at most one question: what to install or do, and which needs the machine serves.
4. Show one recap (tools, connectors, skills, hooks), get one confirmation, then run everything in a single pass.
5. Write `mode: "pro"` in `~/.claude/kit/profile.json` so later sessions stay in this mode.
6. Leave the mode with `/pro-samuel off`: back to the teaching path.

## Rules

- No personal data in this public kit (no addresses, accounts, keys). Private context lives in the user's own `~/.claude`.
- Any external send or push still needs confirmation in the same turn.
- Do not use em dashes in text produced for third parties.
