# Security Audit

> Based on OWASP Top 10, NIST SP 800-63B, CWE Top 25.
> Score: /100 | Blocking threshold: <70

---

## Section 1 — Access Control (30 points)

- [ ] RLS enabled on all tables containing user data ......................... (10)
- [ ] Auth middleware verifies authentication on all protected routes ......... (8)
- [ ] No protected route accessible without valid authentication .............. (7)
- [ ] Separate RLS policy per operation (SELECT/INSERT/UPDATE/DELETE) ......... (5)

**Subtotal: /30**

---

## Section 2 — Secrets Management (20 points)

- [ ] No secret keys in source code or git history ........................... (8)
- [ ] `SUPABASE_SERVICE_ROLE_KEY` never prefixed with `NEXT_PUBLIC_` .......... (7)
- [ ] `.env.local` in `.gitignore` and not committed ......................... (5)

**Subtotal: /20**

---

## Section 3 — XSS/Injection Protection (20 points)

- [ ] `dangerouslySetInnerHTML` absent (or justified + sanitized) ............ (8)
- [ ] All user inputs validated with Zod before DB ........................... (7)
- [ ] User-provided URLs validated (no `javascript:`) ........................ (5)

**Subtotal: /20**

---

## Section 4 — Dependencies and Supply Chain (15 points)

- [ ] `npm audit --audit-level=critical` passes with no critical vulnerabilities (8)
- [ ] `npm audit --audit-level=high` passes or vulnerabilities are documented . (7)

**Subtotal: /15**

---

## Section 5 — Security Headers (15 points)

- [ ] `X-Content-Type-Options: nosniff` configured ........................... (3)
- [ ] `X-Frame-Options: DENY` configured ..................................... (3)
- [ ] `Strict-Transport-Security` configured (HTTPS enforced) ................ (3)
- [ ] `Referrer-Policy` configured ........................................... (3)
- [ ] `Permissions-Policy` configured ........................................ (3)

**Subtotal: /15**

---

## Total Score: /100

| Section | Score | /Total |
|---------|-------|--------|
| Access Control | | /30 |
| Secrets | | /20 |
| XSS/Injection | | /20 |
| Dependencies | | /15 |
| Headers | | /15 |
| **TOTAL** | | **/100** |

**Threshold: <70 = deployment blocked**

---

## Quick verification tools

```bash
npm audit --audit-level=critical   # Dependencies
git log -S "service_role" --all    # Secrets in git
grep -r "dangerouslySetInnerHTML" src/  # XSS risk
```
