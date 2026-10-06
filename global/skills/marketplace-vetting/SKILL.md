---
name: marketplace-vetting
description: Vetting of a third-party marketplace, plugin, skill or repo before integrating it into a Claude Code setup. Load before any `claude plugin marketplace add`, any clone of an external skill/plugin, or any install of a third-party tool into the workflow.
---

# Marketplace vetting

A procedure to verify a third-party source (plugin marketplace, skill or agent copied from a GitHub repo, npm package or CLI added to the workflow) **before** trusting or executing it. A scan of a public marketplace once surfaced an ops script that bulk-copied credential files (`.env`, GPG, SSH) committed in the public repo. Not an active threat to the user, but it exposed a gap: nothing forced a review before adding a marketplace or running one of its scripts.

This skill pairs with two optional hooks: one that blocks execution of scripts under `~/.claude/plugins/marketplaces|cache/`, and one that blocks adding a new marketplace. The hooks create the stopping point. This skill is the procedure to follow during the stop.

## Step 1: check the trust registry

Read `TRUST-REGISTRY.md` next to this file (create it on first use, one row per vetted source). If the source is listed as vetted, only confirm nothing obvious changed (a very recent last commit plus a maintainer change means vet again).

## Step 2: provenance

```bash
gh api repos/<owner>/<repo>                              # real existence, stars, forks, license
gh api repos/<owner>/<repo>/commits --paginate | head    # recent activity, not abandoned
```

Signals: a very recent repo (under 3 months) with few stars and a broad access request deserves extra caution. An established repo (1000+ stars, months of history, identifiable maintainer) lowers the risk without removing the need for the next steps.

## Step 3: static scan

Run a skill/plugin scanner of your choice (for example `skillspector scan <path> --recursive --format json`). **Do not take CRITICAL findings at face value.** Scanners produce many false positives on content that *talks about* security or on standard semver ranges. For each CRITICAL/HIGH finding, read the whole source file and judge in context:
- a script running a hardcoded command with no possible injection: fine;
- a script building a command from unfiltered external input, or touching credentials or paths outside the tool's expected scope: a real signal.

## Step 4: targeted manual reading

Before first real use, read in full (not just grep):
- every script invoked automatically by a hook, command or declared plugin entry point;
- every use of `sudo`, `curl | bash`, `eval`, writes outside the plugin's own folder, or references to `.ssh`, `.aws`, `.gnupg`, `.env`;
- scripts present in the repo but never referenced by an active plugin/skill/command are not a threat until invoked, but note the maintainer as less rigorous.

## Step 5: decide and record

Add a row to `TRUST-REGISTRY.md`: name/URL, vetting date, status (vetted / vetted with reservation / rejected), one sentence of justification. If a hook-blocked action is still needed after approval, the confirmation must be a physical human action (a native OS dialog), not a flag a Bash call could set. **Why**: a flag file or a typed phrase can be satisfied by the agent itself, which defeats the point.

## Verification

- Never execute an unread third-party script to save time. The hook blocks it anyway.
- Every source added to the setup (marketplace, copied skill, third-party CLI) appears in the registry, even a trivial one. The registry is only valuable if exhaustive.
