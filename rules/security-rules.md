---
description: "SQWR Security Rules — XSS prevention, injection protection, secrets management"
paths:
  - "src/**"
  - "api/**"
  - "lib/**"
  - "app/**"
  - "pages/**"
---

# Security Rules (SQWR)

Source: OWASP Top 10 2021, NIST SSDF, CWE/SANS Top 25

## Input Validation

- NEVER construct SQL queries with string concatenation — always use parameterized queries or ORM
- NEVER insert user input directly into HTML — always escape or use safe DOM APIs
- Validate ALL external inputs at system boundaries (user input, API responses, file contents)
- Reject inputs that exceed expected length, format, or character set

## Secrets Management

- NEVER hardcode secrets, API keys, tokens, or passwords in source code
- NEVER commit `.env` files — use `.env.example` with placeholder values
- Use environment variables for all secrets in production
- Rotate secrets immediately if accidentally committed (even in a private repo)

## Authentication & Authorization

- Never roll your own crypto — use established libraries (bcrypt, argon2 for passwords)
- Always check authorization on every request — never rely on client-side access control
- Use HTTP-only, Secure, SameSite=Strict cookies for session tokens
- Implement CSRF protection on all state-changing requests

## Output Encoding

- Escape HTML special characters in all user-supplied output: `&`, `<`, `>`, `"`, `'`
- Use Content Security Policy (CSP) headers
- Set `X-Content-Type-Options: nosniff` and `X-Frame-Options: DENY`
- Never use `dangerouslySetInnerHTML` without sanitization (React/JSX)
