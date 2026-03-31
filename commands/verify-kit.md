---
name: "verify-kit"
description: "Run the SQWR kit integrity checker — validates all 13 structural dimensions of the kit itself."
allowed-tools: ["Bash"]
disable-model-invocation: true
---

# /verify-kit

Validate the integrity of the SQWR Project Kit installation.

**Usage:** `/verify-kit` or `/verify-kit --verbose`

## What this checks

Runs `scripts/verify-kit.sh` which validates 13 dimensions:
1. All required files present (contracts, audits, agents, hooks, templates)
2. CLAUDE.md template has required sections
3. Each contract cites at least one source
4. Audits have numerical thresholds
5. init-project.sh references existing contracts
6. IDENTITY-TEMPLATE.md structure
7. README.md references all contracts
8. Agent files have frontmatter + 4-level verification
9. Hook scripts cite contract sources and are executable
10. Workflows have gates and observable truths
11. settings.json references existing hooks
12. All contracts have `Last validated` field
13. Plugin structure (.claude-plugin/plugin.json + hooks.json)

## Steps

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/verify-kit.sh $ARGUMENTS
```

**Exit codes:**
- 0 = Kit valid (0 errors, 0 warnings) or acceptable (0 errors, N warnings)
- 1 = Kit invalid (errors detected) — fix before using on projects

If errors are found, report each one with the specific file and the fix required.
