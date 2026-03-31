# Contract — API Design

> SQWR Project Kit contract module.
> Standards: RFC 7231 (HTTP Semantics), RFC 7807 (Problem Details), RFC 6585 (Rate Limiting), RFC 6750 (Bearer Tokens), RFC 8594 (Sunset Header), OpenAPI 3.1.0, Google API Design Guide, OWASP API Security Top 10 2023.

---

## Scientific Foundations

**REST is not a standard — it is an architectural style** (Roy Fielding, doctoral dissertation, 2000). Strict adherence to HTTP semantics and RFC standards distinguishes professional APIs from fragile, ad-hoc ones. Stripe and GitHub APIs are canonical examples of RFC-compliant, developer-friendly API design.

---

## 1. REST & HTTP Semantics (25 pts)

### 1.1 HTTP Verb Semantics — RFC 7231

| Verb | Semantics | Idempotent | Source |
|------|-----------|------------|--------|
| GET | Read-only, no side effects — never modify state via GET | Yes | RFC 7231 §4.2 |
| POST | Create resource or trigger action — NOT idempotent | No | RFC 7231 §4.3.3 |
| PUT | Full replacement — same request = same result | Yes | RFC 7231 §4.3.4 |
| PATCH | Partial update — apply RFC 7396 JSON Merge Patch | No | RFC 7396 |
| DELETE | Remove resource | Yes | RFC 7231 §4.3.5 |

### 1.2 Status Codes — use semantically correct codes

| Code | Meaning | When to use |
|------|---------|-------------|
| 200 OK | Successful GET/PUT/PATCH with body | Successful reads and updates |
| 201 Created | Successful POST that creates a resource | Include `Location` header pointing to new resource |
| 204 No Content | Successful DELETE or action with no response body | Delete operations |
| 400 Bad Request | Validation failure | Include RFC 7807 Problem Details body |
| 401 Unauthorized | Missing or invalid authentication | Missing/invalid Bearer token |
| 403 Forbidden | Authenticated but not authorized | Valid token, insufficient permissions |
| 404 Not Found | Resource does not exist | Resource not found |
| 409 Conflict | Resource state conflict | Duplicate, concurrent edit |
| 422 Unprocessable Entity | Semantically invalid input | Business rule violation |
| 429 Too Many Requests | Rate limit exceeded | Include `Retry-After` header (RFC 6585) |
| 500 Internal Server Error | Unhandled exception | Never leak stack traces |

Source: RFC 7231 §6, RFC 6585 §4

### 1.3 Error Response Format — RFC 7807 Problem Details

Every 4xx and 5xx response MUST include a Problem Details body:

```json
{
  "type": "https://api.example.com/errors/validation-failed",
  "title": "Validation Failed",
  "status": 400,
  "detail": "The 'email' field must be a valid email address.",
  "instance": "/api/users"
}
```

- `type` — URI identifying the error type (can be documentation URL)
- `title` — short, human-readable summary (same for all instances of this type)
- `status` — the HTTP status code (mirrors the HTTP response status)
- `detail` — instance-specific human-readable explanation
- `instance` — URI identifying the specific occurrence of the problem

Source: RFC 7807 (Problem Details for HTTP APIs)

---

## 2. Versioning & Evolution (20 pts)

### 2.1 URL Path Versioning (recommended for public APIs)

```
/api/v1/users         ← current stable version
/api/v2/users         ← new version with breaking changes
```

- Major versions only in URL — minor changes are backward-compatible additions
- Maintain N and N-1 versions concurrently during migration periods
- Communicate migration timeline at least 6 months in advance

Source: Google API Design Guide (cloud.google.com/apis/design/versioning)

### 2.2 Breaking vs. Non-Breaking Changes

**Breaking changes → new major version:**
- Removing or renaming a field
- Changing a field type
- Changing behavior of an existing endpoint
- Adding a required field to a request body

**Non-breaking additions → same version (backward-compatible):**
- Adding new optional fields to responses
- Adding new optional request parameters
- Adding new endpoints

**Deprecation headers:**
```http
Deprecation: true
Sunset: Sat, 01 Jan 2027 00:00:00 GMT
Link: <https://api.example.com/v2/users>; rel="successor-version"
```

Source: RFC 8594 (The Sunset HTTP Header Field), Stripe API Versioning docs

### 2.3 OpenAPI 3.1.0 Specification

- Every API endpoint MUST be documented in OpenAPI 3.1.0 spec
- Spec MUST stay in sync with implementation (choose code-first or spec-first — never both)
- Expose spec at `/api/openapi.json` or `/api/docs`
- Use schema references (`$ref`) rather than inline schemas for reuse

Source: OpenAPI 3.1.0 Specification (spec.openapis.org/oas/v3.1.0)

---

## 3. Rate Limiting & Pagination (20 pts)

### 3.1 Rate Limiting

All public or authenticated API routes MUST implement rate limiting:

```
X-RateLimit-Limit: 100        ← max requests per window
X-RateLimit-Remaining: 73     ← remaining requests in current window
X-RateLimit-Reset: 1735689600 ← Unix timestamp when window resets
Retry-After: 30               ← seconds to wait (on 429 response only)
```

Recommended limits:
- 100 req/min per authenticated user (reads)
- 20 req/min per authenticated user (writes)
- 10 req/min per IP for unauthenticated auth routes (login, password reset)

Source: RFC 6585 §4, GitHub REST API Rate Limiting documentation, Stripe API Rate Limits

### 3.2 Pagination

**Cursor-based pagination (preferred for large, dynamic datasets >1k records):**

```json
{
  "data": [...],
  "pagination": {
    "next_cursor": "eyJpZCI6MTAwfQ==",
    "previous_cursor": "eyJpZCI6ODF9",
    "has_more": true
  }
}
```

- Cursor is opaque to clients (base64-encoded offset, timestamp, or UUID)
- Stable across concurrent writes — offset pagination skips or duplicates records on write
- Maximum page size: **100 items per page** (reject requests above this limit with 400)

**Offset pagination (acceptable for small, stable datasets <1k records):**

```json
{
  "data": [...],
  "pagination": {
    "page": 2,
    "per_page": 20,
    "total": 143
  }
}
```

- Include `total` count only when computationally affordable (avoid COUNT(*) on large tables)

Source: Stripe API Pagination docs, Slack API Cursor-Based Pagination, Martin Fowler "REST in Practice" (2010)

---

## 4. Authentication & Security (20 pts)

### 4.1 Bearer Token Authentication — RFC 6750

```http
Authorization: Bearer eyJhbGciOiJSUzI1NiJ9...
```

Rules:
- Always use the `Authorization` header — never pass tokens in URL query parameters (they appear in server logs and browser history)
- Tokens must be validated on every request — no session caching without explicit TTL
- Return 401 (not 403) when token is missing or expired

Source: RFC 6750 (The OAuth 2.0 Authorization Framework: Bearer Token Usage)

### 4.2 Idempotency Keys (for non-idempotent POST operations)

POST endpoints that trigger financial, messaging, or irreversible operations SHOULD accept an `Idempotency-Key` header:

```http
POST /api/payments
Idempotency-Key: e4f8d3c2-9b1a-4e6f-8c7d-2b0a3e9f1d5c
```

- Server stores result for 24 hours — repeated requests with same key return cached result
- Return 422 if the same key is reused with a different request body

Source: Stripe API Idempotent Requests documentation

### 4.3 Input Validation

- All request bodies MUST be validated with a schema (Zod, Yup, JSON Schema) **before** any DB write or external call
- Validate and sanitize all user-provided strings (SQL injection, XSS)
- Never trust client-provided IDs for authorization — verify resource ownership server-side

Source: OWASP API Security Top 10 2023 — API1 (Broken Object Level Authorization), API3 (Broken Object Property Level Authorization)

---

## 5. Performance Thresholds (15 pts)

### 5.1 Response Time SLOs

| Endpoint type | p99 SLO | Source |
|---------------|---------|--------|
| GET (read) | ≤200ms p99 | seuil empirique industrie; cf. Google SRE Book Ch.4 (SLO framework), Akamai 2017 |
| POST/PUT/PATCH/DELETE (write) | ≤500ms p99 | seuil empirique industrie; cf. Google SRE Book Ch.4 (SLO framework) |
| Report/aggregation (documented) | ≤2000ms p99 | seuil empirique industrie; cf. Google SRE Book Ch.4 (SLO framework) |

### 5.2 GraphQL-Specific Rules

| Rule | Threshold | Source |
|------|-----------|--------|
| Query depth limit | 10 levels maximum | Apollo Server docs |
| Query complexity limit | 1000 complexity units maximum | Apollo Server docs |
| N+1 prevention | All list resolvers MUST use DataLoader | DataLoader library (npm) |
| Production queries | Persisted queries required | Apollo Server docs |

Source: GraphQL Foundation specification (June 2018); Apollo Server query complexity documentation

---

## 6. Measurable Thresholds Summary

| Rule | Threshold | Standard |
|------|-----------|---------|
| GET p99 response time | ≤200ms | industry standard — Google SRE Book Ch.4 (SLO framework), Akamai 2017 |
| Write p99 response time | ≤500ms | industry standard — Google SRE Book Ch.4 (SLO framework) |
| Maximum page size | 100 items | Stripe/GitHub convention |
| Rate limit (auth routes, unauthenticated) | 10 req/min/IP | OWASP API Security Top 10 2023 |
| Rate limit (authenticated user) | 100 req/min/user | GitHub REST API convention |
| GraphQL depth limit | 10 levels | Apollo/GraphQL Foundation |
| GraphQL complexity limit | 1000 units | Apollo Server docs |
| Idempotency key retention | 24 hours | Stripe Idempotency docs |

---

## 7. Sources

| Reference | Link |
|-----------|------|
| RFC 7231 — HTTP/1.1 Semantics and Content | tools.ietf.org/html/rfc7231 |
| RFC 7807 — Problem Details for HTTP APIs | tools.ietf.org/html/rfc7807 |
| RFC 6585 — Additional HTTP Status Codes (429) | tools.ietf.org/html/rfc6585 |
| RFC 6750 — Bearer Token Usage | tools.ietf.org/html/rfc6750 |
| RFC 7396 — JSON Merge Patch | tools.ietf.org/html/rfc7396 |
| RFC 8594 — The Sunset HTTP Header Field | tools.ietf.org/html/rfc8594 |
| OpenAPI 3.1.0 Specification | spec.openapis.org/oas/v3.1.0 |
| Google API Design Guide | cloud.google.com/apis/design |
| OWASP API Security Top 10 2023 | owasp.org/API-Security/editions/2023/en/0x11-t10 |
| Google SRE Book | sre.google/sre-book/service-level-objectives |
| Stripe API Reference | stripe.com/docs/api |
| Roy Fielding — Architectural Styles (REST) | ics.uci.edu/~fielding/pubs/dissertation/top.htm |

---

> **Last validated:** 2026-03-30 — RFC 7231, RFC 7807, RFC 6585, RFC 6750, RFC 8594, OpenAPI 3.1.0, Google API Design Guide, OWASP API Security Top 10 2023, Google SRE Book
