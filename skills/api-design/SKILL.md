---
name: api-design
description: REST API design and audit: REST conventions, correct HTTP codes, RFC 7807 error format, rate limiting, versioning, OWASP API Top 10 security. Standards: RFC 7231, RFC 7807, OpenAPI 3.1.
tags: [api, rest, http, security, openapi, rate-limiting, design]
model: sonnet
---

# /api-design: REST API Design & Audit

## When to use

- Create a new API route
- Audit existing routes
- Check REST and security conformance
- Generate OpenAPI documentation

## Standards (RFC 7231 + Google API Design Guide)

### REST conventions
| Action | Method | URL | Success status |
|--------|---------|-----|---------------|
| List | GET | `/resources` | 200 |
| Create | POST | `/resources` | 201 |
| Read | GET | `/resources/:id` | 200 |
| Replace | PUT | `/resources/:id` | 200 |
| Update | PATCH | `/resources/:id` | 200 |
| Delete | DELETE | `/resources/:id` | 204 |

### Correct HTTP codes
- `400`: Validation failed (malformed body, missing field)
- `401`: Not authenticated (missing or expired token)
- `403`: Authenticated but not authorized
- `404`: Resource not found
- `409`: Conflict (duplicate, invalid state)
- `422`: Unprocessable entity (business logic failed)
- `429`: Rate limit reached
- `500`: Server error (log it, do not expose it)

### Error format (RFC 7807 Problem Details)
```json
{
  "type": "https://api.example.com/errors/validation-failed",
  "title": "Validation Failed",
  "status": 400,
  "detail": "The 'email' field is required",
  "instance": "/api/users/register"
}
```

### Security (OWASP API Security Top 10 2023)
- [ ] Auth verified on all non-public routes
- [ ] Rate limiting: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `Retry-After`
- [ ] Zod validation on ALL inputs (body, query params, path params)
- [ ] No sequential IDs exposed (IDOR): use UUID or CUID
- [ ] Sensitive fields filtered from responses (password_hash, internal_ids)
- [ ] Pagination mandatory on lists (max 100 items, default 20)
- [ ] `Sunset` header on deprecated routes (RFC 8594)

### Rate Limiting (Upstash pattern)
```typescript
const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '10 s'),
  analytics: true,
})
```

## Output format

```
## API Review: [route/module]

### REST conformance: [X/10]
### OWASP security: [X/10]

### 🔴 Blocking
### 🟡 Important
### 🟢 Suggestions

### OpenAPI 3.1 schema
[yaml snippet for the route]
```
