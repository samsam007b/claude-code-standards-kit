# Glossary (English, source)

One card per term, read by `/explain`. Format: In one sentence / Analogy / Example / Where it lives / Related.

## skill

- **In one sentence**: a written recipe Claude follows when you ask for a specific kind of task.
- **Analogy**: a recipe card in a kitchen. The cook (Claude) knows cooking, the card says how you like this dish.
- **Example**: `/explain hook` runs the `explain` skill.
- **Where it lives**: `~/.claude/skills/<name>/SKILL.md`.
- **Related**: command, workflow, agent.

## hook

- **In one sentence**: a small script that runs automatically when something happens, such as before a command runs.
- **Analogy**: a smoke detector. You do not call it, it reacts on its own.
- **Example**: a hook that blocks `rm -rf` before Claude executes it.
- **Where it lives**: declared in `~/.claude/settings.json`, script in `~/.claude/hooks/`.
- **Related**: guardrail, script, permission.

## workflow

- **In one sentence**: a fixed sequence of steps, sometimes split across several agents, for a task you repeat.
- **Analogy**: an assembly line: same stations, same order, each time.
- **Example**: review, fix, test, then commit.
- **Where it lives**: in a skill, or as a script that chains steps.
- **Related**: skill, agent, script.

## script

- **In one sentence**: a text file of instructions the computer runs for you, with no thinking involved.
- **Analogy**: a washing machine program: the same cycle every time.
- **Example**: `setup.sh` installs the tools.
- **Where it lives**: any folder, usually `scripts/`.
- **Related**: hook, terminal.

## MCP

- **In one sentence**: a standard plug that lets Claude use an outside tool or data source.
- **Analogy**: a universal power adapter between Claude and an app.
- **Example**: an MCP server that lets Claude read your calendar.
- **Where it lives**: declared in `.mcp.json` or `~/.claude.json`.
- **Related**: connector, Composio.

## connector

- **In one sentence**: a ready-made link between Claude and one app (Gmail, Drive, Slack).
- **Analogy**: a key cut for one door.
- **Example**: the Gmail connector reads and drafts mail.
- **Where it lives**: provided by an MCP server or by Composio.
- **Related**: MCP, Composio.

## Composio

- **In one sentence**: one account that connects Claude to hundreds of apps so you do not set each up yourself.
- **Analogy**: a hotel concierge who has the keys to many buildings.
- **Example**: send a mail, add a calendar event, read a sheet, from one place.
- **Where it lives**: external service (free tier), key stored locally in a secrets file.
- **Related**: MCP, connector. Optional: you can decline.

## Playwright

- **In one sentence**: a tool that lets Claude drive a real Chrome window: open pages, click, read, take screenshots.
- **Analogy**: an assistant sitting at your browser.
- **Example**: "open this page and tell me the price".
- **Where it lives**: installed through Node.
- **Related**: MCP, Node.

## CLAUDE.md

- **In one sentence**: a text file of standing instructions Claude reads at the start of every session.
- **Analogy**: the briefing note you leave a new colleague.
- **Example**: "Answer in French. Keep replies short."
- **Where it lives**: project folder, or `~/.claude/CLAUDE.md` for all projects.
- **Related**: memory, rule.

## agent and subagent

- **In one sentence**: a separate Claude instance given one job, with its own working memory.
- **Analogy**: a specialist you delegate to, who reports back a summary.
- **Example**: a research agent reads 10 pages and returns 5 lines.
- **Where it lives**: `~/.claude/agents/<name>.md`.
- **Related**: skill, context.

## context

- **In one sentence**: everything Claude can see right now in the conversation; it is limited.
- **Analogy**: a desk: when it is full, older papers fall off.
- **Example**: a very long session gets summarised to make room.
- **Where it lives**: in the session, not on disk.
- **Related**: token, compact.

## token

- **In one sentence**: a small chunk of text, the unit Claude reads, writes and bills in.
- **Analogy**: a word-ish piece; about 4 characters.
- **Example**: a page is roughly 500 tokens.
- **Where it lives**: counted per message.
- **Related**: context.

## permission

- **In one sentence**: the question Claude asks before an action that changes things on your machine.
- **Analogy**: a colleague asking "may I?" before moving your files.
- **Example**: allow once, allow always, or refuse.
- **Where it lives**: `~/.claude/settings.json`.
- **Related**: hook, guardrail.

## guardrail

- **In one sentence**: a check that stops a risky action before it happens.
- **Analogy**: the railing on a staircase.
- **Example**: refusing to delete the whole home folder.
- **Where it lives**: implemented as hooks.
- **Related**: hook, permission.

## plan mode

- **In one sentence**: Claude explores and proposes a plan without changing anything until you approve.
- **Analogy**: an architect's drawing before the builders arrive.
- **Example**: press Shift+Tab to enter it.
- **Where it lives**: a mode of the session.
- **Related**: permission.

## terminal

- **In one sentence**: a window where you type commands instead of clicking.
- **Analogy**: texting your computer.
- **Example**: `claude` starts Claude Code.
- **Where it lives**: Terminal (macOS), Windows Terminal or PowerShell.
- **Related**: script, shell.

## Homebrew

- **In one sentence**: an installer for developer tools on macOS.
- **Analogy**: an app store you drive by typing.
- **Example**: `brew install node`.
- **Where it lives**: `/opt/homebrew`. Remove with its uninstall script.
- **Related**: winget, Node.

## winget

- **In one sentence**: the built-in installer for tools on Windows.
- **Analogy**: Homebrew's Windows cousin.
- **Example**: `winget install OpenJS.NodeJS`.
- **Where it lives**: ships with Windows 10 and 11.
- **Related**: Homebrew.

## Node.js

- **In one sentence**: a program that runs JavaScript outside the browser; Claude Code and Playwright need it.
- **Analogy**: the engine under several tools.
- **Example**: `node --version` shows it is installed.
- **Where it lives**: installed by Homebrew or winget.
- **Related**: Playwright, npm.

## Python

- **In one sentence**: a general-purpose programming language many scripts and tools use.
- **Analogy**: a Swiss army knife.
- **Example**: `python3 --version`.
- **Where it lives**: installed by Homebrew or winget.
- **Related**: script.

## Git

- **In one sentence**: a tool that records every version of your files so you can go back.
- **Analogy**: unlimited undo with a history book.
- **Example**: `git commit` saves a snapshot.
- **Where it lives**: a hidden `.git` folder in the project.
- **Related**: commit, branch.

## commit and branch

- **In one sentence**: a commit is a saved snapshot; a branch is a parallel line of work.
- **Analogy**: a save point in a game, and an alternate timeline.
- **Example**: work on `v5-starter` without touching `main`.
- **Where it lives**: inside `.git`.
- **Related**: Git.

## WSL2

- **In one sentence**: a Linux system running inside Windows, needed for the kit's advanced hooks.
- **Analogy**: a second room inside your house with different furniture.
- **Example**: `wsl --install`.
- **Where it lives**: Windows feature.
- **Related**: hook, terminal.

## memory

- **In one sentence**: notes Claude keeps between sessions so you do not repeat yourself.
- **Analogy**: a notebook that stays on the desk.
- **Example**: "I prefer short answers".
- **Where it lives**: `~/.claude/projects/<project>/memory/`.
- **Related**: CLAUDE.md, context.
