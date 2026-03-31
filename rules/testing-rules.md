---
description: "SQWR Testing Rules — coverage thresholds, mocking strategy, test pyramid"
paths:
  - "__tests__/**"
  - "*.test.ts"
  - "*.test.tsx"
  - "*.test.js"
  - "*.spec.ts"
  - "*.spec.js"
  - "e2e/**"
  - "cypress/**"
---

# Testing Rules (SQWR)

Source: Google Testing Blog, Martin Fowler Test Pyramid, ISTQB Foundation Level 2023

## Coverage Thresholds

- Minimum unit test coverage: **80%** (lines and branches)
- Critical paths (auth, payments, data mutations): **95%** coverage
- Never commit code that drops coverage below thresholds

## Test Pyramid Distribution (target)

- Unit tests: ~70% of all tests (fast, isolated, many)
- Integration tests: ~20% of all tests (service boundaries, DB)
- E2E tests: ~10% of all tests (critical user journeys only)

## Mocking Strategy

- Mock at system boundaries (external APIs, file system, databases) — not internal functions
- Prefer real implementations over mocks for internal modules
- Never mock the module under test
- Integration tests should use real databases (test containers or in-memory variants)

## Test Quality

- Each test has ONE clear assertion focus — no "god tests"
- Test names describe behavior: `should return 404 when user does not exist`
- No `console.log` in tests — use structured assertions
- Tests are deterministic — no random data without seeded RNG, no time-dependent assertions without mocking

## Test Data

- Use factories/fixtures for test data — never hardcode realistic-looking PII
- Clean up test data after each test (transactions rollback or explicit deletion)
- Never share mutable state between tests
