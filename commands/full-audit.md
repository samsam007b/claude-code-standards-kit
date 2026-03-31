---
name: "full-audit"
description: "Run the full SQWR audit suite on the current project — all 8 domains, weighted global score."
allowed-tools: ["Bash", "Read", "Grep", "Glob", "Agent"]
disable-model-invocation: true
---

# /full-audit

Run the complete SQWR audit suite on the current project.

**Usage:** `/full-audit`

## What this runs

Executes `agents/AGENT-FULL-AUDIT.md` which orchestrates all 8 audit agents:

| Domain | Weight | Blocking threshold |
|--------|--------|-------------------|
| Security | 22% | <70 = BLOCKED |
| Performance | 18% | <70 recommended |
| Code Quality | 18% | <75 recommended |
| Observability | 12% | <60 recommended |
| Accessibility | 12% | <80 (+ EU legal) |
| Design | 8% | <70 recommended |
| AI Governance | 5% | <80 recommended |
| Deployment | 5% | pre-prod gate |

**Target: ≥85/100 global score**

## Steps

1. Read `${CLAUDE_PLUGIN_ROOT}/agents/AGENT-FULL-AUDIT.md`
2. Execute the full audit per the agent instructions
3. After completion:

```bash
touch .sqwr-last-audit
```

4. Report the global score and all domain scores with findings and recommended actions
