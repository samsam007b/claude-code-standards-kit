---
name: perfection-audit
description: "Full perfection audit: security, performance, code quality, type safety - Enterprise standard"
tags: [audit, security, performance, quality, enterprise]
version: 1.0.0
author: Claude Opus 4.6
---

# 🏆 Perfection Audit - Enterprise Grade

Exhaustive audit based on the standards of the best tech companies (Google, Vercel, AWS) and security firms (Cure53, Trail of Bits, NCC Group).

## Objective

Verify that a Next.js/Supabase application reaches **perfection** standards on:
- ✅ Security (OWASP Top 10, ASVS Level 2)
- ✅ Performance (Core Web Vitals, load testing)
- ✅ Code quality (TypeScript strict, zero console, centralized logger)
- ✅ Type safety (zero `any`, complete interfaces)
- ✅ Scalability (100+ concurrent users)

---

## Phase 1: TypeScript Health (5 min)

### Execution
```bash
npx tsc --noEmit --pretty
```

### Metrics
- **Target**: 0 errors
- **Acceptable**: < 5 non-critical errors
- **Blocking**: > 10 errors OR 1+ critical error

### Check
- [ ] 0 TypeScript errors
- [ ] `strict: true` in `tsconfig.json`
- [ ] `noImplicitAny: true`
- [ ] `strictNullChecks: true`
- [ ] No `@ts-ignore` except justified cases

---

## Phase 2: Critical Security (20 min)

### 2.1 API Keys & Secrets

**Automatic search**:
```bash
# Keys exposed to the client
grep -r "NEXT_PUBLIC_.*KEY\|NEXT_PUBLIC_.*SECRET" .env* app/ components/

# Service role keys client-side
grep -r "SERVICE_ROLE_KEY" app/ components/ lib/
```

**Checklist**:
- [ ] Zero `NEXT_PUBLIC_` for API keys (except Maps, Analytics)
- [ ] `SUPABASE_SERVICE_ROLE_KEY` server-side only
- [ ] Stripe secret key never exposed
- [ ] `.env` in `.gitignore`

### 2.2 Debug Endpoints

**Search**:
```bash
find app/api/debug -type f
grep -r "/api/test\|/api/debug" app/api/
```

**Checklist**:
- [ ] Zero `/api/debug/` endpoints
- [ ] Zero `/api/test/` endpoints
- [ ] Admin endpoints protected by an `is_admin` check

### 2.3 Rate Limiting

**Search**:
```bash
# Public routes without rate limit
find app/api -name "route.ts" -exec grep -L "ratelimit\|RateLimit" {} \;
```

**Checklist**:
- [ ] All public routes rate-limited
- [ ] Login: 5/min per IP
- [ ] Signup: 3/hour per IP
- [ ] Upload: 10/hour per user
- [ ] Password reset: 3/hour per email

### 2.4 RLS (Row Level Security)

**SQL to run**:
```sql
-- Tables without RLS
SELECT tablename
FROM pg_tables
WHERE schemaname = 'public'
  AND rowsecurity = false;

-- Suspicious policies
SELECT tablename, policyname, definition
FROM pg_policies
WHERE definition NOT LIKE '%auth.uid()%';
```

**Checklist**:
- [ ] RLS enabled on all sensitive tables
- [ ] Policies tested with different users
- [ ] Service role usage justified (webhooks, cron)

### 2.5 Authentication

**Search**:
```bash
# API routes without auth
find app/api -name "route.ts" -exec grep -L "session\|getUser\|auth" {} \;
```

**Checklist**:
- [ ] Auth check on all protected routes
- [ ] Session timeout configured and ENFORCED
- [ ] Password hashing bcrypt/Argon2 (NOT SHA256)
- [ ] MFA available for critical accounts

---

## Phase 3: Performance & Scalability (15 min)

### 3.1 Database Query Optimization

**Anti-pattern search**:
```bash
# SELECT * instead of specific columns
grep -r "select('\*')" app/ lib/ --include="*.ts"

# Queries without .limit()
grep -r "\.from(" app/ lib/ | grep -v "\.limit(" | grep -v "\.single()"

# N+1 queries (loop with query)
grep -rA 10 "for.*of\|\.map(" lib/services/ | grep "supabase.from"
```

**Checklist**:
- [ ] Zero `SELECT *` count queries
- [ ] `.limit()` on all list queries
- [ ] Zero N+1 queries
- [ ] Indexes created on filtered columns

### 3.2 Image Optimization

**Search**:
```bash
# <img> instead of <Image>
grep -r "<img" app/ components/ --include="*.tsx"
```

**Checklist**:
- [ ] Next.js `<Image>` everywhere (except SVG)
- [ ] Lazy loading enabled
- [ ] `next.config.js` domains configured
- [ ] WebP/AVIF formats enabled

### 3.3 React Performance

**Search**:
```bash
# Components without memo
grep -r "export.*function.*Props" components/ | grep -v "memo"

# Inline callbacks in props
grep -r "onClick={() =>" app/ components/
```

**Checklist**:
- [ ] Frequently rendered components wrapped in `memo()`
- [ ] Callbacks wrapped in `useCallback`
- [ ] Expensive calculations in `useMemo`
- [ ] Context providers memoized

### 3.4 Load Testing Readiness

**Questions**:
- How many simultaneous connections can Supabase handle?
- How many requests/second do the API routes support?
- Is the Vercel CDN enabled?

**Checklist**:
- [ ] Supabase connection pooling configured
- [ ] API routes stateless (horizontally scalable)
- [ ] Correct cache headers (`Cache-Control`)
- [ ] Rate limiting prevents DoS

**Benchmark targets**:
- 100 simultaneous users: < 500ms p95
- 1000 req/sec: API routes must hold
- Core Web Vitals: LCP < 2.5s, FID < 100ms, CLS < 0.1

---

## Phase 4: Code Quality (10 min)

### 4.1 Console Statements

**Search**:
```bash
grep -r "console\.\(log\|error\|warn\)" app/ lib/ components/ contexts/ \
  --include="*.ts" --include="*.tsx" \
  | grep -v "logger.ts" \
  | wc -l
```

**Target**: 0 console statements in production

**Checklist**:
- [ ] Zero `console.log`
- [ ] Zero `console.error`
- [ ] Centralized logger used everywhere
- [ ] Dev-only logs wrapped in `if (process.env.NODE_ENV === 'development')`

### 4.2 Type Safety

**Search**:
```bash
# as any
grep -r "as any" app/ lib/ components/ --include="*.ts" --include="*.tsx" | wc -l

# @ts-ignore
grep -r "@ts-ignore\|@ts-expect-error" app/ lib/ components/
```

**Checklist**:
- [ ] < 50 `as any` (none in critical code)
- [ ] < 5 `@ts-ignore` (all justified)
- [ ] Interfaces for all data structures
- [ ] Type guards for unions

### 4.3 Error Handling

**Search**:
```bash
# Silent catch
grep -rA 3 "} catch" app/ lib/ | grep -B 3 "^$"

# Error boundaries
find app -name "error.tsx"
```

**Checklist**:
- [ ] Error boundary on each segment (owner, seeker, resident, etc.)
- [ ] All catch blocks log via the logger
- [ ] User-friendly UI errors
- [ ] Stack traces never exposed

### 4.4 Dead Code

**Search**:
```bash
# Archived files
find app lib components -name "*OLD*" -o -name "*BACKUP*" -o -name "_archived"

# Unused imports
npx eslint . --ext .ts,.tsx --rule 'no-unused-vars: error' 2>&1 | grep "is defined but never used"
```

**Checklist**:
- [ ] Zero `*-OLD.tsx` files
- [ ] Zero `_archived/` folders
- [ ] Imports cleaned up (ESLint)

---

## Phase 5: Supabase Specifics (10 min)

### 5.1 Connection Pooling

**Check `DATABASE_URL`**:
```
postgresql://[user]:[password]@[host]:6543/postgres?pgbouncer=true&connection_limit=10
```

**Supabase limits**:
- Free tier: 60 connections max
- Pro tier: 200 connections max
- Enterprise: unlimited

**For 100 simultaneous users**:
- Connection pooling REQUIRED
- `pgbouncer=true` in the connection string
- `connection_limit=10` per instance

### 5.2 Realtime Limits

**Free tier**:
- 200 concurrent connections
- 2 concurrent channels

**If > 200 simultaneous users**:
- Upgrade to Pro ($25/month)
- Or disable non-essential realtime

### 5.3 Storage Limits

**Free tier**:
- 1 GB storage
- 2 GB bandwidth/month

**If the app handles photos**:
- Monitor current usage
- Plan an upgrade or aggressive compression

---

## Phase 6: Build & Deployment (5 min)

### 6.1 Build Verification

```bash
npm run build
```

**Checklist**:
- [ ] Build passes without errors
- [ ] Zero TypeScript warnings
- [ ] Reasonable bundle size (< 500KB First Load JS)
- [ ] Source maps disabled in production

### 6.2 Vercel Configuration

**Required `vercel.json`**:
```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "Strict-Transport-Security", "value": "max-age=63072000" }
      ]
    }
  ],
  "env": {
    "NODE_ENV": "production"
  }
}
```

**Checklist**:
- [ ] Security headers configured
- [ ] Environment variables defined on Vercel
- [ ] Custom domain with HTTPS
- [ ] Edge config if needed (rate limiting, feature flags)

---

## Phase 7: Monitoring & Observability (5 min)

### 7.1 Error Tracking

**Checklist**:
- [ ] Sentry configured and working
- [ ] Source maps uploaded (Vercel + Sentry)
- [ ] Error boundaries capture and log
- [ ] Alerts configured (Slack, email)

### 7.2 Performance Monitoring

**Core Web Vitals**:
- [ ] LCP < 2.5s (75th percentile)
- [ ] FID < 100ms
- [ ] CLS < 0.1

**API Performance**:
- [ ] p95 < 500ms on critical routes
- [ ] Timeouts configured (10s max)
- [ ] Slow query logging

---

## Phase 8: Compliance & Legal (5 min)

### GDPR (if EU users)

**Checklist**:
- [ ] Cookie consent banner
- [ ] Privacy policy accessible
- [ ] User data export available
- [ ] Right to be forgotten implemented
- [ ] Data retention policy documented

### PCI DSS (if payments)

**Checklist**:
- [ ] NO credit card storage
- [ ] Stripe Checkout OR Elements (PCI compliant)
- [ ] HTTPS mandatory
- [ ] Logs do NOT contain card numbers

---

## Audit Report - Template

```markdown
# PERFECTION AUDIT - [Project Name]

**Date**: [YYYY-MM-DD]
**Duration**: [Xh]
**Auditor**: Claude Opus 4.6 Perfection Audit

---

## 📊 OVERALL RESULTS

| Phase | Score | Status |
|-------|-------|--------|
| TypeScript | X/100 | [✅ PASS / 🔴 FAIL] |
| Security | X/100 | [✅ PASS / 🔴 FAIL] |
| Performance | X/100 | [✅ PASS / 🔴 FAIL] |
| Code Quality | X/100 | [✅ PASS / 🔴 FAIL] |
| Scalability | X/100 | [✅ PASS / 🔴 FAIL] |

**Overall score**: XX/100

**Verdict**:
- ≥ 95%: 🏆 PERFECTION - Production ready
- 85-94%: ✅ EXCELLENT - Minor improvements
- 75-84%: 🟡 GOOD - Fix non-critical issues
- < 75%: 🔴 INSUFFICIENT - Blocking issues

---

## 🔴 CRITICAL FINDINGS

### [CRIT-001] [Title]
- **Severity**: CRITICAL
- **Location**: `[file:line]`
- **Issue**: [Description]
- **Impact**: [Security/Performance consequence]
- **Fix**: [Action required]
- **Effort**: [Xh]

---

## 🟠 HIGH PRIORITY

[List of high priority issues]

---

## 🟡 MEDIUM PRIORITY

[List of medium priority issues]

---

## ✅ PASSED CHECKS

- TypeScript: 0 errors
- console.log: 0 statements
- API keys: Secured
- [etc.]

---

## 📈 RECOMMENDATIONS

### Immediate (P0)
1. [Action]

### Short-term (P1)
1. [Action]

### Long-term
1. [Action]

---

## 📊 METRICS SUMMARY

```
TypeScript errors:        0
console.log:              0
console.error:            0
as any:                   XX
Critical security:        0 issues
Rate limiting:            100%
Error boundaries:         6
Logger usage:             XXX occurrences
Build:                    CLEAN
```

---

## 🔄 NEXT STEPS

1. Fix CRITICAL findings
2. Address HIGH priority
3. Schedule follow-up audit in 3 months
4. Update security patterns document
```

---

## Usage

### Full audit
```bash
/perfection-audit
```

### Targeted audit (security only)
```bash
/perfection-audit --security-only
```

### Audit with auto-fix
```bash
/perfection-audit --auto-fix
```

---

## Continuous Integration

This skill can be:
- Run manually before each release
- Integrated into CI/CD (GitHub Actions)
- Triggered automatically after a major refactoring
- Used for quarterly audits

---

## Sources & Standards

- OWASP Top 10 2025
- ASVS Level 2
- Google Cloud Security Best Practices
- Vercel Production Checklist
- Next.js Security Guide
- Supabase Security Practices
- Core Web Vitals Standards
- CWE Top 25

---

**Updated**: 2026-02-13
**Based on**: a real audit (65 errors → 0, 2663 console → 0)
