---
name: quick-audit
description: "Audit rapide pré-commit : vérifie les 10 checks critiques en < 2 min. À lancer avant chaque commit important."
tags: [audit, quick, pre-commit, ci-cd]
version: 1.0.0
---

# ⚡ Quick Audit (< 2 min)

Audit rapide des 10 checks les plus critiques. À lancer **avant chaque commit** ou **avant chaque PR**.

---

## Exécution Automatique

```bash
# Via pre-commit hook
.git/hooks/pre-commit → lance /quick-audit

# Via Claude Code
/quick-audit

# CI/CD (GitHub Actions)
- name: Quick Audit
  run: claude --skill quick-audit
```

---

## Les 10 Checks Critiques

### 1. TypeScript (5s)

```bash
npx tsc --noEmit 2>&1 | grep "error TS" | wc -l
```

**✅ PASS** : 0 erreurs
**🔴 FAIL** : > 0 erreurs

---

### 2. Console Statements (2s)

```bash
grep -r "console\.\(log\|error\|warn\)" app/ lib/ components/ contexts/ \
  --include="*.ts" --include="*.tsx" \
  | grep -v "logger.ts" \
  | wc -l
```

**✅ PASS** : 0 statements
**🟡 WARN** : < 10 statements
**🔴 FAIL** : > 10 statements

---

### 3. Exposed API Keys (3s)

```bash
# Check 1 : NEXT_PUBLIC_ pour secrets
grep -r "NEXT_PUBLIC_.*KEY\|NEXT_PUBLIC_.*SECRET" .env* app/ components/ \
  | grep -v "NEXT_PUBLIC_SUPABASE_URL\|NEXT_PUBLIC_SUPABASE_ANON_KEY\|NEXT_PUBLIC_STRIPE_PUBLISHABLE"

# Check 2 : Service role en client
grep -r "SERVICE_ROLE_KEY" app/ components/
```

**✅ PASS** : 0 résultats
**🔴 FAIL** : > 0 résultats

---

### 4. Debug Endpoints (1s)

```bash
find app/api/debug -type f 2>/dev/null | wc -l
```

**✅ PASS** : 0 fichiers
**🔴 FAIL** : > 0 fichiers

---

### 5. Unprotected API Routes (10s)

```bash
# Routes publiques sensibles sans rate limit
grep -L "ratelimit\|RateLimit" app/api/auth/*/route.ts app/api/upload/*/route.ts 2>/dev/null | wc -l
```

**✅ PASS** : 0 routes
**🟡 WARN** : < 3 routes
**🔴 FAIL** : > 3 routes

---

### 6. Hardcoded Secrets (5s)

```bash
# Passwords, tokens, keys hardcodés
grep -rn "password.*=.*['\"].\{8,\}['\"]" app/ lib/ \
  | grep -v "placeholder\|example\|test"
```

**✅ PASS** : 0 résultats
**🔴 FAIL** : > 0 résultats

---

### 7. SQL Injection Risk (5s)

```bash
# String concatenation dans SQL
grep -rn "EXECUTE.*||" supabase/migrations/
grep -rn "\${.*}" supabase/migrations/ | grep -v "^--"
```

**✅ PASS** : 0 résultats
**🔴 FAIL** : > 0 résultats

---

### 8. XSS Risk (5s)

```bash
# dangerouslySetInnerHTML sans sanitization
grep -r "dangerouslySetInnerHTML" app/ components/ | grep -v "DOMPurify"
```

**✅ PASS** : 0 résultats
**🟡 WARN** : < 3 avec DOMPurify
**🔴 FAIL** : > 0 sans DOMPurify

---

### 9. Error Information Disclosure (5s)

```bash
# Stack traces dans responses
grep -r "error\.stack\|error\.message" app/api/ \
  | grep "Response.json\|NextResponse.json"
```

**✅ PASS** : 0 résultats
**🟡 WARN** : < 5 résultats
**🔴 FAIL** : > 5 résultats

---

### 10. Build Success (30s)

```bash
npm run build 2>&1 | grep -E "Compiled successfully|Build failed"
```

**✅ PASS** : "Compiled successfully"
**🔴 FAIL** : "Build failed"

---

## Format de Sortie

```
⚡ QUICK AUDIT RESULTS ────────────────────

✅ TypeScript:           0 errors
✅ Console:              0 statements
✅ API Keys:             Secured
✅ Debug endpoints:      0
🟡 Unprotected routes:   2 (non-critical)
✅ Hardcoded secrets:    None
✅ SQL injection:        No risk
✅ XSS:                  Sanitized
✅ Error disclosure:     None
✅ Build:                SUCCESS

Score: 95/100 ─ PASS ✅

Warnings:
- 2 API routes sans rate limit (non-critical)

Recommendation: SAFE TO COMMIT

Time: 1m 23s
──────────────────────────────────────────
```

---

## Auto-Fix Mode

```bash
/quick-audit --auto-fix
```

Si activé, propose de corriger automatiquement :
- Ajouter imports React manquants
- Remplacer console.log par logger.debug
- Ajouter rate limiting sur routes sensibles

---

## Intégration Git Hooks

### Installation

```bash
# Créer pre-commit hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "🔍 Running Quick Audit..."
claude --skill quick-audit --exit-code
EOF

chmod +x .git/hooks/pre-commit
```

### Comportement

- **Score ≥ 90%** : Commit autorisé ✅
- **Score 75-89%** : Warning mais commit autorisé 🟡
- **Score < 75%** : Commit bloqué 🔴 (--no-verify pour bypasser)

---

## CI/CD Integration (GitHub Actions)

```yaml
name: Quick Audit

on: [pull_request]

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npx claude --skill quick-audit
      - name: Comment PR
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              body: process.env.AUDIT_RESULTS
            })
```

---

**Execution time** : 1-2 minutes
**False positive rate** : < 5%
**Recommended usage** : Avant chaque commit > 50 lignes modifiées
