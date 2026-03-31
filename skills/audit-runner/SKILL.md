---
name: "audit-runner"
description: "Run one or more SQWR audit agents on the current project. Supports individual domains or the full audit suite."
effort: high
model: sonnet
context: fork
agent: "general-purpose"
argument-hint: "security|performance|accessibility|quality|observability|design|ai|deployment|resilience|full"
disable-model-invocation: true
paths:
  - "agents/**"
  - "audits/AUDIT-INDEX.md"
allowed-tools: ["Read", "Grep", "Glob", "Bash", "Agent"]
---

## Contexte projet (injecté automatiquement)

- Branch courante : !`git branch --show-current 2>/dev/null || echo "non-git"`
- Dernier commit : !`git log -1 --format="%H %s" 2>/dev/null || echo "none"`
- Fichiers modifiés : !`git diff --name-only HEAD 2>/dev/null | head -20 || echo "none"`
- Stack détectée : !`[ -f next.config.ts ] || [ -f next.config.js ] && echo "Next.js" || [ -f Package.swift ] && echo "iOS" || [ -f build.gradle.kts ] && echo "Android" || [ -f pyproject.toml ] && echo "Python" || echo "unknown"`

# /audit-runner — Audit Runner

**Usage:** `/audit-runner [domain or "full"]`

Runs the specified SQWR audit agent(s) on the current project.

**Examples:**
- `/audit-runner security` → runs AGENT-SECURITY-AUDIT.md
- `/audit-runner full` → runs AGENT-FULL-AUDIT.md (all 8 domains)
- `/audit-runner security performance` → runs both agents
- `/audit-runner accessibility` → runs AGENT-ACCESSIBILITY-AUDIT.md

---

## Domain mapping

Parse `$ARGUMENTS` and run the corresponding agents:

| Argument | Agent file |
|----------|-----------|
| `security` | `agents/AGENT-SECURITY-AUDIT.md` |
| `performance` | `agents/AGENT-PERFORMANCE-AUDIT.md` |
| `quality`, `code-quality` | `agents/AGENT-CODE-QUALITY-AUDIT.md` |
| `accessibility`, `a11y` | `agents/AGENT-ACCESSIBILITY-AUDIT.md` |
| `observability`, `logging` | `agents/AGENT-OBSERVABILITY-AUDIT.md` |
| `design` | `agents/AGENT-DESIGN-AUDIT.md` |
| `ai`, `ai-governance` | `agents/AGENT-AI-GOVERNANCE-AUDIT.md` |
| `deployment`, `deploy` | `agents/AGENT-DEPLOYMENT-GATE.md` |
| `resilience` | `agents/AGENT-RESILIENCE-AUDIT.md` |
| `full`, `all` | `agents/AGENT-FULL-AUDIT.md` |

---

## Execution

1. Read the corresponding agent file(s)
2. Execute each agent's verification levels (1→4) against the current project
3. Compute the score per agent: `(passed / applicable) × 100`
4. Report findings with specific file references for failures

---

## Output format

```
SQWR AUDIT REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Domain    : [domain]
Score     : XX/100    Status: PASS/FAIL/BLOCKED
Threshold : [blocking threshold]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Level 1 — Exists    : X/Y
Level 2 — Substantive: X/Y
Level 3 — Wired     : X/Y
Level 4 — Data Flows : X/Y

FINDINGS:
  • [finding 1] — [file:line] — [contract reference]
  • [finding 2] — [file:line] — [contract reference]

RECOMMENDED ACTIONS:
  1. [action]
  2. [action]
```

---

## Post-audit

After the audit completes:

```bash
touch .sqwr-last-audit
```

This marks the audit as done for `hook-audit-before-push.sh`.

---

## Reference

Audit weightings and sequencing: `audits/AUDIT-INDEX.md`
