---
description: "SQWR API Rules — REST/GraphQL design, rate limiting, validation, error handling"
paths:
  - "api/**"
  - "src/app/api/**"
  - "pages/api/**"
  - "src/routes/**"
  - "server/**"
---

# API Rules (SQWR)

Source: REST API Design Rulebook (Masse), Google API Design Guide, OpenAPI Specification 3.x

## Input Validation

- Validate ALL request inputs before processing — never trust client data
- Use schema validation (Zod, Joi, Yup) on all request bodies and query params
- Return 400 Bad Request with a descriptive error for invalid inputs
- Never pass unvalidated user input to database queries

## Rate Limiting

- ALL public API endpoints must have rate limiting
- Recommended: 100 req/min per IP for unauthenticated, 1000 req/min for authenticated
- Return 429 Too Many Requests with `Retry-After` header when limit exceeded
- Rate limit by user ID (not just IP) for authenticated endpoints

## Authentication

- Use Authorization header with Bearer token — not query parameters
- Never log authorization headers or tokens
- Validate JWT signatures on every request — never trust decoded payload without verification
- Implement token expiration and refresh mechanisms

## Error Handling

- Never expose internal error details in production responses (stack traces, SQL errors)
- Use consistent error response format: `{ "error": { "code": "...", "message": "..." } }`
- Log full error details server-side for debugging
- Return appropriate HTTP status codes (400 client errors, 500 server errors — not always 200)

## Response Design

- Use JSON consistently — set `Content-Type: application/json` on all JSON responses
- Paginate list endpoints — never return unbounded lists
- Use HTTP methods semantically: GET (read), POST (create), PUT/PATCH (update), DELETE (delete)
