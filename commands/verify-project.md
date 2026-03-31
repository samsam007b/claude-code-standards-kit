---
name: "verify-project"
description: "Validate a project CLAUDE.md against SQWR standards — checks completeness, active contracts, and hook configuration."
allowed-tools: ["Bash", "Read", "Glob"]
disable-model-invocation: true
---

# /verify-project

Validate a project's SQWR configuration.

**Usage:** `/verify-project [path/to/CLAUDE.md]`

**Default:** If no path is provided, uses `./CLAUDE.md` in the current directory.

## What this checks

Runs `scripts/verify-project.sh` which validates:
1. CLAUDE.md exists and passes `validate-claude-md.sh`
2. Active contracts in CLAUDE.md exist in `docs/contracts/`
3. `.claude/settings.json` exists and references hooks
4. All `[TO FILL IN]` placeholders have been replaced
5. At least one contract is checked `[x]`

## Steps

```bash
# Determine the CLAUDE.md path
CLAUDE_PATH="${ARGUMENTS:-./CLAUDE.md}"

bash ${CLAUDE_PLUGIN_ROOT}/scripts/verify-project.sh "$CLAUDE_PATH"
```

If issues are found, report each one with the specific fix required:
- Missing contract file → re-run `/init-project` for the correct stack
- Unchecked contracts → open CLAUDE.md and activate the relevant contracts
- Missing settings.json → copy from `${CLAUDE_PLUGIN_ROOT}/templates/settings.json`
- Unfilled placeholders → replace all `[TO FILL IN]` with project-specific values
