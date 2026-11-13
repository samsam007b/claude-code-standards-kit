---
name: "welcome"
description: "First-run onboarding for a beginner. Assesses level and needs in 6 questions, explains each tool before installing it, installs only after a yes, then writes the profile."
effort: medium
disable-model-invocation: true
argument-hint: "[--redo]"
---

# /welcome

Language: if `language` is `fr` in `~/.claude/kit/profile.json` (or the person writes in French), follow `SKILL.fr.md` in this folder instead.

Didactic path for someone setting up Claude Code alone (or after a short training). Skipped by `/pro-samuel`.

## Principles

- Simple words. Define any technical term the first time, or point to `/explain <term>`.
- Nothing is installed without a clear "yes". Before each tool: what it is, why it helps this person, what it changes on the machine, how to remove it.
- One question at a time. Never more than 6 in total.
- Never guess the level: ask, then confirm in one sentence ("So you are at level Practice, correct?").

## Step 1: Detect the setup (no questions yet)

Read `~/.claude/kit/profile.json`. If it exists and `--redo` is absent, greet by level and ask what to do today instead of restarting.
Otherwise detect: OS, shell, and presence of Homebrew or winget, Git, Node, Python. Report in plain words what is already there.

## Step 2: Six questions

1. What do you want to do with Claude Code? (write, code, automate, analyse, other)
2. Have you used a terminal before? (never / a little / often)
3. Have you used Claude Code before? (never / a few times / daily)
4. Do you work with mail, calendar, documents or other apps you would like Claude to reach?
5. Do you need Claude to browse or test web pages for you?
6. How do you prefer to learn: short explanations, or detail with examples?

## Step 3: Level

| Level | Signal | Effect |
|---|---|---|
| Discovery | never used a terminal or Claude Code | Explain everything, propose few tools, extra safeguards |
| Practice | some terminal or Claude Code use | Short explanations, tools proposed from needs |
| Autonomous | daily use | Terse, option lists, advanced tier offered |

## Step 4: Propose tools from needs, one by one

| Need | Tool | Plain explanation |
|---|---|---|
| Browse or test pages | Playwright | Lets Claude drive a Chrome window like a person would |
| Mail, calendar, docs, many apps | Composio | One account that connects Claude to hundreds of apps without wiring each one |
| Any person, any level | Composio, offered to everyone | Optional: the benefit is explained, a free account is needed, refusal costs nothing |
| Reusable routines | Skills | A written recipe Claude can follow on demand |
| Safety net | Guardrails (2 hooks) | Small checks that stop risky commands before they run |

For each: explain, ask "install it?", install on yes, verify it works, record in profile.

Guardrails: on yes, run `node ~/.claude/kit/hooks/register-hooks.mjs` (backs up `settings.json`, merges, undo with `--remove`). Say what they block: destructive commands (guard-destructive) and real-looking secrets written to files (guard-secrets). Pro mode registers them in the single confirmed pass.

## Step 5: Write the profile

Write `~/.claude/kit/profile.json` with `language`, `level`, `needs`, `tools_installed`, `mode: "learner"`, `date`. Local file, never sent anywhere.

## Step 6: Close

One short summary: what is installed, what each does, how to ask for help (`/explain <term>`), how to change level (`/welcome --redo`). Offer the advanced tier only to Autonomous.

## Rules

- Windows: tier 1 runs natively. The advanced tier needs WSL2; explain it and let the person decide.
- Language follows `language` in the profile; the French edition mirrors this file.
- Any external send or account creation needs a confirmation in the same turn.
