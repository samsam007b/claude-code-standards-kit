---
name: "auto-fix"
description: "Auto-fix simple issues found by SQWR audit agents — console.log, unused imports, missing ARIA attributes, TODO format."
effort: high
model: sonnet
context: fork
agent: "general-purpose"
disable-model-invocation: true
argument-hint: "security|accessibility|quality|all"
paths:
  - "agents/**"
  - "contracts/**"
allowed-tools: ["Read", "Grep", "Glob", "Bash", "Edit", "Write", "Agent"]
---

# /auto-fix — Auto-Fix Audit Issues

**Usage:** `/auto-fix [domain]`

Reads audit findings and automatically applies fixes that are unambiguous, low-risk, and reversible.

**Examples:**
- `/auto-fix quality` → removes console.log, fixes TODO format
- `/auto-fix accessibility` → adds missing alt text, aria-label on buttons
- `/auto-fix all` → all safe auto-fixes across domains

---

## Safe auto-fix scope

This skill ONLY fixes issues that are:
1. **Unambiguous** — one correct fix exists (e.g. remove `console.log`)
2. **Low-risk** — fix cannot break functionality
3. **Reversible** — undoable via `git diff` / `git checkout`

**NEVER auto-fix:**
- Security architecture changes (require human review)
- Performance refactoring
- Accessibility issues requiring content decisions
- Any touch to auth, payments, or data handling logic

---

## Phase 1 — Scan for fixable issues

```bash
echo "=== QUALITY SCAN ==="
# console.log in production code (excluding tests)
grep -rn "console\.log\|console\.debug\|console\.info" src/ --include="*.ts" --include="*.tsx" | grep -v "test\|spec\|\.d\.ts" | head -30

echo "=== ACCESSIBILITY SCAN ==="
# Images without alt text
grep -rn "<img " src/ --include="*.tsx" --include="*.jsx" | grep -v 'alt=' | head -20
# Buttons without accessible name
grep -rn "<button" src/ --include="*.tsx" | grep -v "aria-label\|aria-labelledby\|>.*</button>" | head -20

echo "=== TODO FORMAT SCAN ==="
# TODOs without ticket reference
grep -rn "TODO[^(#]" src/ --include="*.ts" --include="*.tsx" | head -20
```

**Observable truth**: Scan completes, list of fixable issues produced.

---

## Phase 2 — Apply fixes

For each issue found, apply the appropriate fix:

**console.log** → remove the line. Skip if `// eslint-disable` comment present.

**Images without alt** → add `alt=""` for decorative images. For informational images, infer alt text from filename/context, flag for review if unclear.

**TODO without ticket** → change `TODO something` to `TODO(#?) something` and add a comment `// Add ticket number`.

After each fix:
```bash
npm run build 2>&1 | tail -5
```

**Observable truth**: Build passes after each fix applied.

---

## Phase 3 — Final verification

```bash
npm run build && npm test -- --passWithNoTests
```

**Observable truth**: Full build and test suite passes.

---

## Post-fix report

```
AUTO-FIX REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Fixed  : X issues
Skipped: Y issues (require human review)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FIXED:
  ✅ Removed console.log — src/lib/api.ts:42
  ✅ Added alt="" — src/components/Logo.tsx:8
  [...]

REQUIRES HUMAN REVIEW:
  ⚠️  src/auth/middleware.ts:89 — Security pattern
  [...]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Reference

Contracts enforced: `contracts/CONTRACT-TYPESCRIPT.md`, `contracts/CONTRACT-ACCESSIBILITY.md`, `contracts/CONTRACT-TESTING.md`
