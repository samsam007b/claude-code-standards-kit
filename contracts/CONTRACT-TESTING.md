# Contract — Testing

> SQWR Project Kit contract module.
> Sources: Martin Fowler (test pyramid), Agile Alliance (Definition of Done), React Testing Library, Playwright docs.

---

## Scientific Foundations

**The test pyramid** (Mike Cohn / Martin Fowler) has been the standard industrial model since 2009. It rests on a cost/return principle: unit tests are fast and inexpensive to write; E2E tests are slow and brittle. The inverse (many E2E, few unit tests = "ice cream cone anti-pattern") is the most costly mistake in QA.

---

## 1. The Test Pyramid — Target Distribution

```
           E2E (5%)
          /        \
         / Playwright\
        /─────────────\
       / Integration   \
      /   (15%)         \
     /  Vitest + real DB \
    /─────────────────────\
   /   Unit Tests (80%)   \
  /  Vitest / Jest / RTL  \
 /─────────────────────────\
```

| Level | % of total | Tool | Characteristics |
|--------|-----------|-------|-----------------|
| **Unit** | 80% | Vitest / Jest + RTL | Fast (<1s), isolated, mocks dependencies |
| **Integration** | 15% | Vitest + real DB | Tests interactions between modules |
| **E2E** | 5% | Playwright | Tests the full user flow |

---

## 2. Coverage Thresholds — Non-Negotiable

| Metric | Threshold | Standard |
|----------|-------|---------|
| **Line coverage global** | >80% | Industry (client-facing code) |
| **Branch coverage global** | >75% | Professional |
| **Auth paths** | 100% | Critical — zero tolerance |
| **Payment paths** | 100% | Critical — zero tolerance |
| **API Routes** | >90% | Public exposure |

```json
// vitest.config.ts — automatic coverage thresholds
{
  "coverage": {
    "thresholds": {
      "lines": 80,
      "branches": 75,
      "functions": 80,
      "statements": 80
    }
  }
}
```

---

## 3. Definition of Done (Agile Alliance)

> An increment is only "done" if the tests are written AND passing.

**Mandatory DoD checklist before any merge:**
- [ ] Unit tests written for new logic
- [ ] Integration tests for new API routes
- [ ] `npm run test` passes without errors
- [ ] Coverage does not regress (no merge that lowers the global percentage)
- [ ] E2E updated if the user flow has changed

---

## 4. Next.js Patterns — Unit Tests

```typescript
// components/__tests__/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react'
import { Button } from '../Button'

describe('Button', () => {
  it('renders with correct text', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByRole('button', { name: /click me/i })).toBeInTheDocument()
  })

  it('calls onClick handler when clicked', () => {
    const handleClick = vi.fn()
    render(<Button onClick={handleClick}>Click</Button>)
    fireEvent.click(screen.getByRole('button'))
    expect(handleClick).toHaveBeenCalledTimes(1)
  })

  it('is disabled when disabled prop is true', () => {
    render(<Button disabled>Click</Button>)
    expect(screen.getByRole('button')).toBeDisabled()
  })
})
```

---

## 5. Patterns — Integration Tests

```typescript
// lib/__tests__/actions.integration.test.ts
import { createClient } from '@/lib/supabase/server'
import { createProject } from '@/lib/actions'

// ⚠️ Tests on a REAL database (Supabase test project)
// NEVER mock Supabase for integration tests

describe('createProject action', () => {
  beforeEach(async () => {
    // Setup: create a test user, clean up data
  })

  afterEach(async () => {
    // Cleanup: delete test data
  })

  it('creates a project with valid data', async () => {
    const formData = new FormData()
    formData.set('name', 'Test Project')

    const result = await createProject(formData)
    expect(result.success).toBe(true)
    expect(result.data?.name).toBe('Test Project')
  })

  it('rejects invalid data', async () => {
    const formData = new FormData()
    // name missing

    const result = await createProject(formData)
    expect(result.success).toBe(false)
    expect(result.error).toBeDefined()
  })
})
```

---

## 6. Patterns — E2E Tests (Playwright)

```typescript
// e2e/auth.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Authentication Flow', () => {
  test('user can sign in and access dashboard', async ({ page }) => {
    await page.goto('/login')

    await page.fill('[name=email]', process.env.TEST_USER_EMAIL!)
    await page.fill('[name=password]', process.env.TEST_USER_PASSWORD!)
    await page.click('[type=submit]')

    await expect(page).toHaveURL('/dashboard')
    await expect(page.getByRole('heading', { name: /dashboard/i })).toBeVisible()
  })

  test('unauthenticated user is redirected to login', async ({ page }) => {
    await page.goto('/dashboard')
    await expect(page).toHaveURL('/login')
  })
})
```

---

## 7. Critical Rules

### Never do

- **Mock Supabase in integration tests** — mocks hide real divergences between production and test environments (a classic mistake that has caused incidents)
- **Merge code without tests** on new features
- **Write tests after the bug** — tests must exist before closing a ticket

### Always do

- Tests in the same directory as the code (`Component.test.tsx` co-located)
- Name tests readably: "should [do what] when [condition]"
- Test error cases, not just the happy path
- CI/CD blocks if tests fail (never `--passWithNoTests` in production)

---

## 8. Recommended Configuration

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: ['node_modules/', 'src/test/', '**/*.d.ts', '**/*.config.*'],
      thresholds: { lines: 80, branches: 75, functions: 80 },
    },
  },
  resolve: {
    alias: { '@': path.resolve(__dirname, './src') },
  },
})
```

---

## 9. Sources

| Reference | Link |
|-----------|------|
| Martin Fowler — Test Pyramid | martinfowler.com/articles/practical-test-pyramid.html |
| Agile Alliance — Definition of Done | agilealliance.org/glossary/definition-of-done |
| React Testing Library | testing-library.com/docs/react-testing-library/intro |
| Playwright Documentation | playwright.dev |
| Vitest Documentation | vitest.dev |
