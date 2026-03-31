---
name: "init-project"
description: "Initialize a new project with SQWR standards. Runs init-project.sh and validates the output."
allowed-tools: ["Bash", "Read", "Glob"]
disable-model-invocation: true
---

# /init-project

Bootstrap a new project with SQWR standards.

**Usage:** `/init-project --name "project-name" --stack "nextjs-supabase" --path "/path/to/project"`

**Available stacks:** `nextjs-supabase`, `nextjs`, `python`, `ios`, `android`, `fullstack`

## Steps

1. Run the initialization script with the provided arguments:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-project.sh $ARGUMENTS
```

2. Validate the generated CLAUDE.md. Extract the path from `$ARGUMENTS` and run:

```bash
# Extract path from arguments
PROJECT_PATH=$(echo "$ARGUMENTS" | grep -oE '\-\-path\s+\S+' | awk '{print $2}')
bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate-claude-md.sh "$PROJECT_PATH/CLAUDE.md"
bash ${CLAUDE_PLUGIN_ROOT}/scripts/verify-project.sh "$PROJECT_PATH/CLAUDE.md"
```

3. Report the results to the user, including:
   - Which contracts were copied to `docs/contracts/`
   - Which hooks are configured in `.claude/settings.json`
   - Next steps (activate contracts in CLAUDE.md, first commit)
