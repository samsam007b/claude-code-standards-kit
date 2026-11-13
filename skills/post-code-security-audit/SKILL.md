---
description: "Execute AFTER generating code to verify security against AI anti-patterns. Auto-detects vulnerabilities based on research patterns."
skillType: security-verification
trigger: post-generation
priority: critical
---

# ✅ Post-Code Security Audit

**Trigger**: Automatically AFTER generating:
- Any API route
- Database function
- Authentication/Authorization code
- File handling code
- Sensitive data operations

**Reference**: `.claude/resources/ai-security-antipatterns.md`

---

## 🔍 AUDIT EXECUTION

### Step 1: Pattern Scanning

Run automated checks against 8 AI anti-patterns:

#### Check 1: Input Validation (70%+ AI failure rate)

```typescript
// Search for these patterns:
🔴 FAIL patterns:
- parseInt() without Zod validation
- parseFloat() without min/max
- request.json() used directly
- searchParams.get() without schema
- No try/catch around parsing

✅ PASS patterns:
- Zod schema defined at top
- All inputs validated before use
- Error handling returns 400
```

**Automated search**:
```bash
# Find API routes without Zod import
grep -r "searchParams.get\|request.json" app/api/ \
  | grep -v "import.*zod"
```

#### Check 2: Authentication Bypass (Frequent AI error)

```sql
-- Search for these patterns:
🔴 FAIL patterns:
- RETURN TRUE (hardcoded)
- RETURN FALSE (placeholder)
- TODO/FIXME in verify/check/validate functions
- Comments: "implement later", "extends this"

✅ PASS patterns:
- Actual verification logic present
- Calls to Supabase Auth
- Checks password_verifications table
- Time-based validation (TTL)
```

**Automated search**:
```bash
# Find functions with hardcoded auth
grep -rn "RETURN TRUE\|RETURN FALSE" supabase/migrations/ \
  | grep -i "verify\|check\|auth"
```

#### Check 3: Log Injection (88% AI failure rate)

```typescript
// Search for these patterns:
🔴 FAIL patterns:
- console.log(`... ${userInput}`)
- logger.info(`... ${variable}`)
- No sanitization before logging
- User-controlled data in template literals

✅ PASS patterns:
- sanitizeLog() wrapper used
- User data JSON.stringify() before log
- Max 200 char limit enforced
- Newlines/tabs replaced
```

**Automated search**:
```bash
# Find unsanitized console.log
grep -rn "console\.\(log\|warn\|error\)" app/ lib/ \
  | grep "\${" \
  | grep -v "sanitize"
```

#### Check 4: Weak Crypto (Frequent AI error)

```sql
-- Search for these patterns:
🔴 FAIL patterns:
- sha256(password)
- md5(password)
- encode(..., 'hex') for passwords
- Base64 for passwords

✅ PASS patterns:
- crypt(password, gen_salt('bf', 10))
- bcrypt with cost ≥ 10
- Supabase Vault encrypt()
```

**Automated search**:
```bash
# Find weak hashing
grep -rn "sha256\|md5\|encode.*hex" supabase/migrations/ \
  | grep -i "password\|pin\|secret"
```

#### Check 5: Insecure Defaults

```typescript
// Search for these patterns:
🔴 FAIL patterns:
- CORS: '*'
- IP_ALLOWLIST_ENABLED = false
- DEBUG = true (hardcoded)
- RATE_LIMIT = 1000 (too high)

✅ PASS patterns:
- Values from process.env
- Secure defaults in production
- Documented in .env.example
```

**Automated search**:
```bash
# Find hardcoded security configs
grep -rn "= true\|= false\|= '\*'" lib/security/ next.config.mjs \
  | grep -i "allow\|enable\|debug\|cors"
```

#### Check 6: Path Traversal (34% Sonnet 4 failure)

```typescript
// Search for these patterns:
🔴 FAIL patterns:
- `${baseDir}/${userInput}` concatenation
- path.join() without validation
- No check for .. sequences

✅ PASS patterns:
- path.basename() used
- path.normalize() + validation
- Checks that result stays in baseDir
```

**Automated search**:
```bash
# Find path operations without sanitization
grep -rn "path\.join\|\${.*}.*\/" app/api/ \
  | grep -v "basename\|normalize"
```

#### Check 7: SQL Injection

```typescript
// Search for these patterns:
🔴 FAIL patterns:
- String concatenation in SQL
- Template literals in .rpc() calls
- EXECUTE with user input

✅ PASS patterns:
- Supabase .from().select().eq()
- PL/pgSQL parameters (p_*, v_*)
- No EXECUTE CONCAT
```

**Automated search**:
```bash
# Find SQL concatenation
grep -rn "EXECUTE.*||" supabase/migrations/
grep -rn "supabase.rpc.*\${" app/
```

#### Check 8: Verbose Errors

```typescript
// Search for these patterns:
🔴 FAIL patterns:
- Response.json({ error: error.message })
- Returning stack traces
- SQL queries in errors

✅ PASS patterns:
- Generic error messages to users
- Detailed errors logged internally
- console.error('[INTERNAL]', ...)
```

**Automated search**:
```bash
# Find verbose error returns
grep -rn "error\.message\|error\.stack" app/api/ \
  | grep "Response.json\|return.*json"
```

---

### Step 2: Generate Audit Report

For each FAIL pattern found, generate:

```markdown
## Security Audit Results - [Feature Name]

### Vulnerabilities Found: X

#### VULN-XXX: [Pattern Name]
- **Severity**: 🔴 CRITICAL / 🟠 HIGH / 🟡 MEDIUM / 🟢 LOW
- **Location**: [file:line]
- **Pattern**: Anti-Pattern #X ([AI failure rate]%)
- **Issue**: [What's wrong]
- **Impact**: [Security consequence]
- **Fix**: [Code correction]
- **Effort**: [Time estimate]

### Passed Checks: Y

- ✅ [Pattern name]: No issues found
- ✅ [Pattern name]: Properly implemented

### Security Score: Y/(X+Y) = Z%

Recommendation:
- Score ≥ 90%: ✅ DEPLOY
- Score 75-89%: 🟡 FIX non-critical issues
- Score < 75%: 🔴 DO NOT DEPLOY (fix blockers)
```

---

### Step 3: Auto-Fix Suggestions

For each vulnerability, provide executable fix:

```typescript
// BEFORE (vulnerable):
const limit = parseInt(searchParams.get('limit') || '20');

// AFTER (fixed):
import { z } from 'zod';

const querySchema = z.object({
  limit: z.coerce.number().int().min(1).max(100).default(20),
});

const { limit } = querySchema.parse({
  limit: searchParams.get('limit'),
});
```

Present user with option:
```
🔧 Auto-fix available for X vulnerabilities

Apply fixes automatically? (y/n)
- VULN-XXX: Add Zod validation
- VULN-YYY: Sanitize logs
- VULN-ZZZ: Use bcrypt instead of SHA256

Note: Review changes before committing.
```

---

## 📊 REPORTING

### Format for User

Present audit results in clear format:

```
★ Security Audit Results ──────────────────────

Feature: [Name]
Files checked: X
Patterns scanned: 8

Results:
🔴 CRITICAL: X found
🟠 HIGH: Y found
🟡 MEDIUM: Z found
✅ PASSED: W checks

Overall Score: XX/100

Recommendation: [DEPLOY / FIX FIRST / BLOCK]

Details in: AUDIT_[FEATURE]_[DATE].md
───────────────────────────────────────────────
```

### Format for Notion Integration

Append to ANALYSE_COMPLETE.md:

```markdown
## [Date] - [Feature] Security Audit

**Score**: XX/100
**Vulnerabilities**: X CRITICAL, Y HIGH, Z MEDIUM
**Status**: FIXED / PENDING / ACCEPTED RISK

[Link to detailed report]
```

---

## 🎯 ANTI-PATTERN REFERENCE INTEGRATION

This skill automatically reads:
- `.claude/resources/ai-security-antipatterns.md` for patterns
- Searches codebase for each pattern
- Compares against research failure rates
- Prioritizes based on severity + probability

**Learning loop**:
1. Find vulnerability in audit
2. Add to anti-patterns if new pattern
3. Future code scanned for this pattern
4. Continuous improvement

---

## 🔄 CONTINUOUS LEARNING

After each audit, update anti-patterns resource if:

1. **New pattern discovered** not in catalog
2. **False positive** identified (remove from checks)
3. **New research** published (update failure rates)
4. **Project-specific** pattern (project-only)

**Update format**:
```markdown
### ANTI-PATTERN X: [Name]

**Discovered**: [Date] in [Project]
**AI Failure Rate**: [X%] (if known) or "Unknown (project-specific)"
**Example**: [Code snippet]
**Fix**: [Correction]
```

---

**Execution time**: 30-60 seconds per feature
**False positive rate**: ~5% (review recommendations)
**Coverage**: 8 most common AI security patterns
