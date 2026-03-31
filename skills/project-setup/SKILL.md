---
name: "project-setup"
description: "Bootstrap a new project with SQWR standards. Detects stack, selects contracts, copies templates, and configures hooks."
effort: high
model: sonnet
agent: true
disable-model-invocation: true
argument-hint: "--name project-name --stack nextjs-supabase"
paths:
  - "scripts/init-project.sh"
  - "contracts/**"
  - "templates/**"
allowed-tools: ["Read", "Bash", "Write", "Glob"]
---

# /project-setup — Project Setup

**Usage:** `/project-setup [project name] [stack] [path]`

Bootstraps a new project with SQWR standards.

**Example:** `/project-setup my-app nextjs-supabase ~/Desktop/my-app`

---

## Step 1 — Gather parameters

From `$ARGUMENTS`, extract:
- `PROJECT_NAME`: name of the project
- `STACK`: one of `nextjs-supabase`, `nextjs`, `python`, `ios`, `android`, `fullstack`
- `PATH`: destination path (default: `~/Desktop/$PROJECT_NAME`)

If any parameter is missing, prompt the user:
- "What is the project name?"
- "Which stack? (nextjs-supabase / nextjs / python / ios / android / fullstack)"
- "Where should the project be created? (default: ~/Desktop/[name])"

---

## Step 2 — Run init-project.sh

```bash
bash scripts/init-project.sh \
  --name "$PROJECT_NAME" \
  --stack "$STACK" \
  --path "$PATH"
```

This creates:
- `$PATH/CLAUDE.md` — pre-filled AI contract
- `$PATH/docs/contracts/` — stack-relevant contracts
- `$PATH/.claude/settings.json` — hooks configuration
- `$PATH/.claude/agents/` — audit agents
- `$PATH/CHANGELOG.md`, `.gitignore`, `.env.example`

---

## Step 3 — Verify the generated project

```bash
bash scripts/validate-claude-md.sh "$PATH/CLAUDE.md"
bash scripts/verify-project.sh "$PATH/CLAUDE.md"
```

Fix any warnings before proceeding.

---

## Step 4 — Post-setup instructions

Output a summary with:

1. **Contracts to activate**: tell the user which contracts to check `[x]` in CLAUDE.md
2. **Hooks status**: confirm `.claude/settings.json` is configured
3. **First steps**:
   ```
   cd $PATH
   git init && git add . && git commit -m "chore: initialize project with SQWR standards"
   ```
4. **Next workflow**: suggest running `/new-feature` for the first feature

---

## Stack → contracts mapping

| Stack | Contracts included |
|-------|-------------------|
| `nextjs-supabase` | TYPESCRIPT, SECURITY, TESTING, CICD, NEXTJS, SUPABASE, VERCEL, PERFORMANCE, ACCESSIBILITY, SEO, DESIGN, OBSERVABILITY, RESILIENCE |
| `nextjs` | TYPESCRIPT, SECURITY, TESTING, CICD, NEXTJS, VERCEL, PERFORMANCE, ACCESSIBILITY, SEO, DESIGN, OBSERVABILITY |
| `python` | PYTHON, SECURITY, TESTING, CICD, API-DESIGN, OBSERVABILITY |
| `ios` | IOS, ACCESSIBILITY, SECURITY, TESTING, CICD |
| `android` | ANDROID, ACCESSIBILITY, SECURITY, TESTING, CICD |
| `fullstack` | All 29 contracts |

---

## Reference

Script: `scripts/init-project.sh`
Validation: `scripts/verify-project.sh`
