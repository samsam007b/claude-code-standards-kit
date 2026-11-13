---
description: "Execute BEFORE generating code to identify security requirements based on AI error patterns. Automatically consults anti-patterns reference."
skillType: security-preventive
autoTrigger: code-generation
priority: critical
---

# 🔒 Pre-Code Security Check

**Trigger**: Automatically BEFORE generating:
- API routes
- Database functions
- Authentication/Authorization logic
- File operations
- Any code handling user input or sensitive data

**Reference**: `.claude/resources/ai-security-antipatterns.md`

---

## 🎯 EXECUTION FLOW

### Step 1: Classify Code Type

Determine which category applies:

```
□ API Route (Next.js /app/api/*)
□ Database Function (SQL/PL/pgSQL)
□ Authentication Logic
□ File Upload/Download
□ Payment/Banking
□ Admin Panel
□ Messaging/Chat
□ Search/Query
```

### Step 2: Identify Security Requirements

Based on classification, check anti-patterns resource for:

1. **Required validations**:
   - Input validation (Zod schema)
   - File type/size limits
   - Query param min/max
   - Path sanitization

2. **Required protections**:
   - Authentication level (public, authenticated, admin)
   - Authorization checks (RLS, role-based)
   - Rate limiting tier
   - Encryption needs

3. **Required logging**:
   - Audit log entry
   - IP + User-Agent capture
   - Log sanitization

### Step 3: Generate Security Specification

Create a spec BEFORE writing code:

```markdown
## Security Specification for [Feature Name]

### Input Validation
- Field X: Zod schema with min/max
- Field Y: Enum whitelist
- Field Z: Regex pattern

### Authentication
- Level: authenticated users only
- Re-verification: YES (password required)
- Session timeout: 30min

### Authorization
- RLS: user_id = auth.uid()
- Role check: admin_only

### Rate Limiting
- Tier: 5 requests/minute (sensitive)

### Encryption
- IBAN: Supabase Vault (AES-256-GCM)
- Password: bcrypt cost 10

### Logging
- Action: BANK_INFO_UPDATED
- Fields: IP, UA, timestamp
- Sanitization: YES (remove newlines)

### BLOCKER Checks
- No hardcoded secrets: ✓
- No always-true auth: ✓
- No SQL concatenation: ✓
- No plaintext sensitive data: ✓
```

### Step 4: Present to User

Before generating code, show:

```
★ Security Requirements Identified ─────────────

Based on anti-patterns research, this feature needs:
• Input validation (Zod) for [fields]
• Password re-verification (sensitive data)
• Rate limiting: [tier]
• Encryption: [what needs encrypting]

Proceeding with secure implementation...
───────────────────────────────────────────────
```

---

## 📋 QUICK REFERENCE CHECKLIST

### For API Routes
```
□ Zod validation schema defined?
□ Authentication required?
□ RLS authorization checked?
□ Rate limiting configured?
□ Errors generic (not verbose)?
□ Audit logging present?
□ Input sanitized (logs, paths)?
```

### For Database Functions
```
□ bcrypt used for passwords (NOT SHA256)?
□ Parameters used (NOT concatenation)?
□ SECURITY DEFINER only if needed?
□ RLS policies defined?
□ Sensitive columns encrypted?
□ Audit triggers configured?
```

### For File Operations
```
□ File type whitelist?
□ Size limit enforced?
□ Filename sanitized (basename)?
□ Path traversal blocked (no ..)?
□ Virus scanning (if prod)?
□ Storage RLS configured?
```

---

## 🚨 AUTO-STOP CONDITIONS

If ANY blocker detected, STOP and warn user:

```
❌ BLOCKER DETECTED: [Pattern name]

Found: [Code snippet]
Risk: [Security impact]
Source: Anti-pattern #X (AI failure rate: Y%)

Recommendation: [Fix]

Proceed? (y/n)
```

**Blocker patterns** (from anti-patterns resource):
1. Hardcoded secrets
2. Always-true/false auth
3. SQL string concatenation
4. Plaintext sensitive data
5. No input validation on API routes
6. SHA256/MD5 for passwords
7. Unvalidated redirects
8. Debug endpoints in production

---

## 📊 TRACKING

Log each security check execution:

```json
{
  "timestamp": "2026-01-18T12:00:00Z",
  "feature": "API route for bank info update",
  "classification": "Payment/Banking",
  "requirements_identified": 8,
  "blockers_found": 0,
  "estimated_security_coverage": "90%"
}
```

Track over time to measure improvement:
- % of code generated with pre-check
- % of blockers caught before generation
- Reduction in post-audit vulnerabilities

---

**Usage**: This skill auto-loads when code generation starts
**Override**: Use `--skip-security-check` flag if absolutely needed (not recommended)
