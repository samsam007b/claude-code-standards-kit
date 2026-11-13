---
name: continuous-testing-guardian
description: Implémente un système de continuous testing avec chaos engineering pour détecter automatiquement les régressions introduites par des modifications de code (IA ou humaines)
tags: [testing, chaos-engineering, continuous, monitoring]
---

# Continuous Testing Guardian - "Mais Codeur" System

## Objectif

Créer un système de tests continus qui :
1. **Emprunte automatiquement tous les user flows critiques**
2. **Détecte les régressions invisibles** introduites par Claude Code
3. **Alerte immédiatement** quand un changement brise une chaîne fonctionnelle
4. **Prévient la dette technique** avant qu'elle s'accumule

## Concept : Le "Mais Codeur"

Inspiré de **Chaos Engineering** (Netflix Chaos Monkey) mais adapté pour la **dette technique du code IA**.

### Problème Identifié
- Claude Code modifie du code rapidement
- Une modification dans `FileA.ts` peut casser `FileB.tsx` qui l'utilisait
- L'erreur n'est pas visible immédiatement
- **Accumulation de dette technique invisible**

### Solution : Testing en Boucle Continue
```
┌─────────────────────────────────────┐
│  1. Code Change (Claude ou Human)   │
└──────────────┬──────────────────────┘
               ↓
┌──────────────────────────────────────┐
│  2. Automated Test Suite Runs        │
│     - E2E Critical Flows              │
│     - API Contract Tests              │
│     - Database Integrity Checks       │
│     - Security Scans                  │
└──────────────┬───────────────────────┘
               ↓
┌──────────────────────────────────────┐
│  3. Results Analysis                 │
│     ✅ All Pass → Deploy              │
│     ❌ Failure → Alert + Block        │
└──────────────┬───────────────────────┘
               ↓
┌──────────────────────────────────────┐
│  4. Continuous Monitoring             │
│     - Random flow execution           │
│     - Chaos injection (failures)      │
│     - Performance regression          │
└───────────────────────────────────────┘
```

---

## PHASE 1 : Test Suite Setup (4h)

### 1.1 Identify Critical User Flows

**Pour votre projet (exemple à adapter)** :

| Role | Flow | Priority | Test Frequency |
|------|------|----------|----------------|
| Seeker | Sign up → Profile → Browse → Match → Message | P0 | Every commit |
| Seeker | Sign up → Payment → Premium features | P0 | Every commit |
| Owner | Sign up → Add property → Publish → Get applicants | P0 | Every commit |
| Owner | Sign up → Bank info → Receive payment | P0 | Every commit |
| Resident | Sign up → Join property → Add expense → Split | P1 | Daily |
| Admin | Login → 2FA → Access dashboard → View metrics | P0 | Every commit |
| All | Password reset flow | P1 | Daily |
| All | File upload (avatar, documents) | P1 | Daily |

### 1.2 E2E Test Structure

**Framework** : Playwright (already in package.json)

```typescript
// tests/e2e/critical-flows/seeker-signup-to-match.spec.ts
import { test, expect } from '@playwright/test';
import { createTestUser, cleanupTestUser } from './helpers';

test.describe('Seeker Critical Flow: Signup → Match', () => {
  let testUser: any;

  test.beforeAll(async () => {
    testUser = await createTestUser('seeker');
  });

  test.afterAll(async () => {
    await cleanupTestUser(testUser.id);
  });

  test('should complete full signup flow', async ({ page }) => {
    // 1. Navigation
    await page.goto('/auth/signup');

    // 2. Form fill
    await page.fill('[name="email"]', testUser.email);
    await page.fill('[name="password"]', testUser.password);
    await page.fill('[name="fullName"]', testUser.fullName);
    await page.click('[data-testid="signup-submit"]');

    // 3. Verification
    await expect(page).toHaveURL(/\/onboarding/);
    await expect(page.locator('[data-testid="welcome-message"]')).toBeVisible();
  });

  test('should complete profile enhancement', async ({ page }) => {
    // Login first
    await page.goto('/auth/login');
    await page.fill('[name="email"]', testUser.email);
    await page.fill('[name="password"]', testUser.password);
    await page.click('[data-testid="login-submit"]');

    // Profile enhancement
    await expect(page).toHaveURL(/\/onboarding/);

    // Fill all required fields
    await page.selectOption('[name="age"]', '25');
    await page.click('[data-testid="gender-male"]');
    await page.fill('[name="budget"]', '800');
    // ... more fields

    await page.click('[data-testid="submit-profile"]');
    await expect(page).toHaveURL(/\/dashboard/);
  });

  test('should browse properties', async ({ page, context }) => {
    // Re-use authenticated session
    await page.goto('/dashboard');
    await page.click('[data-testid="browse-button"]');

    // Verify property cards load
    const propertyCards = page.locator('[data-testid="property-card"]');
    await expect(propertyCards.first()).toBeVisible({ timeout: 10000 });

    // Count should be > 0
    const count = await propertyCards.count();
    expect(count).toBeGreaterThan(0);
  });

  test('should generate matches', async ({ page }) => {
    await page.goto('/dashboard');
    await page.click('[data-testid="matching-tab"]');

    // Wait for matches to load
    const matchCards = page.locator('[data-testid="match-card"]');
    await expect(matchCards.first()).toBeVisible({ timeout: 15000 });

    // Verify match details
    const firstMatch = matchCards.first();
    await expect(firstMatch.locator('[data-testid="match-score"]')).toBeVisible();
    await expect(firstMatch.locator('[data-testid="property-name"]')).toBeVisible();
  });

  test('should send message to match', async ({ page }) => {
    await page.goto('/matching');

    // Click first match
    await page.click('[data-testid="match-card"]:first-child');
    await page.click('[data-testid="contact-button"]');

    // Fill message
    await page.fill('[data-testid="message-input"]', 'Hello, I am interested!');
    await page.click('[data-testid="send-message"]');

    // Verify sent
    await expect(page.locator('text=Message envoyé')).toBeVisible();
  });
});
```

### 1.3 API Contract Tests

**Objectif** : Détecter breaking changes dans les API routes.

```typescript
// tests/api/contracts/auth.contract.spec.ts
import { test, expect } from '@playwright/test';

test.describe('API Contract: /api/auth/login', () => {
  test('should accept valid credentials', async ({ request }) => {
    const response = await request.post('/api/auth/login', {
      data: {
        email: 'test@example.com',
        password: 'ValidPassword123!',
      },
    });

    expect(response.status()).toBe(200);

    const body = await response.json();
    expect(body).toHaveProperty('success', true);
    expect(body).toHaveProperty('user');
    expect(body.user).toHaveProperty('id');
    expect(body.user).toHaveProperty('email');
  });

  test('should reject invalid credentials', async ({ request }) => {
    const response = await request.post('/api/auth/login', {
      data: {
        email: 'test@example.com',
        password: 'WrongPassword',
      },
    });

    expect(response.status()).toBe(401);

    const body = await response.json();
    expect(body).toHaveProperty('success', false);
    expect(body).toHaveProperty('error');
  });

  test('should rate limit after 5 failed attempts', async ({ request }) => {
    for (let i = 0; i < 5; i++) {
      await request.post('/api/auth/login', {
        data: { email: 'test@example.com', password: 'wrong' },
      });
    }

    // 6th attempt should be rate limited
    const response = await request.post('/api/auth/login', {
      data: { email: 'test@example.com', password: 'wrong' },
    });

    expect(response.status()).toBe(429); // Too Many Requests
  });
});
```

### 1.4 Database Integrity Tests

```typescript
// tests/database/integrity.spec.ts
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY! // Test DB only!
);

test.describe('Database Integrity Checks', () => {
  test('all sensitive tables should have RLS enabled', async () => {
    const { data: tables } = await supabase
      .from('pg_tables')
      .select('tablename, rowsecurity')
      .eq('schemaname', 'public')
      .in('tablename', [
        'user_profiles',
        'user_bank_info',
        'messages',
        'properties',
        'payment_settlements',
      ]);

    tables?.forEach((table) => {
      expect(table.rowsecurity).toBe(true);
    });
  });

  test('all tables should have created_at', async () => {
    const { data: columns } = await supabase
      .from('information_schema.columns')
      .select('table_name')
      .eq('column_name', 'created_at')
      .eq('table_schema', 'public');

    const tablesWithCreatedAt = columns?.map((c) => c.table_name);

    // Critical tables must have created_at
    ['user_profiles', 'properties', 'messages'].forEach((table) => {
      expect(tablesWithCreatedAt).toContain(table);
    });
  });

  test('foreign keys should be valid', async () => {
    // Check if all property_id references exist
    const { data: invalidRefs } = await supabase.rpc(
      'check_invalid_foreign_keys'
    );

    expect(invalidRefs).toHaveLength(0);
  });
});
```

---

## PHASE 2 : Chaos Engineering (3h)

### 2.1 Fault Injection

**Concept** : Injecter des failures aléatoires pour tester la résilience.

```typescript
// tests/chaos/api-failure-injection.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Chaos Engineering: API Failures', () => {
  test.use({
    // Intercept API calls and randomly fail them
    extraHTTPHeaders: {
      'X-Chaos-Monkey': 'enabled',
    },
  });

  test('should handle Supabase timeout gracefully', async ({ page, context }) => {
    // Intercept Supabase calls
    await context.route('https://**.supabase.co/**', (route) => {
      // 20% chance of timeout
      if (Math.random() < 0.2) {
        route.abort('timedout');
      } else {
        route.continue();
      }
    });

    await page.goto('/dashboard');

    // UI should show error message, not crash
    // Wait for either success or error state
    await expect(
      page.locator('[data-testid="error-message"], [data-testid="dashboard-content"]')
    ).toBeVisible({ timeout: 10000 });

    // No unhandled console errors
    const errors: string[] = [];
    page.on('console', (msg) => {
      if (msg.type() === 'error') errors.push(msg.text());
    });

    // Allow network recovery
    await page.waitForTimeout(2000);

    expect(errors.filter((e) => e.includes('Unhandled'))).toHaveLength(0);
  });

  test('should retry failed requests', async ({ page, context }) => {
    let attemptCount = 0;

    await context.route('**/api/matching/matches', (route) => {
      attemptCount++;

      // Fail first 2 attempts
      if (attemptCount <= 2) {
        route.fulfill({ status: 500, body: 'Internal Server Error' });
      } else {
        route.continue();
      }
    });

    await page.goto('/matching');

    // Should eventually succeed after retries
    await expect(page.locator('[data-testid="match-card"]')).toBeVisible({
      timeout: 20000,
    });

    expect(attemptCount).toBeGreaterThanOrEqual(3);
  });
});
```

### 2.2 Performance Regression Detection

```typescript
// tests/chaos/performance.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Performance Regression Detection', () => {
  test('dashboard should load in < 3 seconds', async ({ page }) => {
    const startTime = Date.now();

    await page.goto('/dashboard');
    await page.waitForLoadState('networkidle');

    const loadTime = Date.now() - startTime;

    // Alert if regression
    expect(loadTime).toBeLessThan(3000);

    // Log for trend analysis
    console.log(`Dashboard load time: ${loadTime}ms`);
  });

  test('property search should return in < 2 seconds', async ({ page }) => {
    await page.goto('/search');

    const startTime = Date.now();
    await page.fill('[name="location"]', 'Bruxelles');
    await page.click('[data-testid="search-submit"]');

    await page.waitForSelector('[data-testid="property-card"]');
    const searchTime = Date.now() - startTime;

    expect(searchTime).toBeLessThan(2000);
  });

  test('API response time should be < 500ms', async ({ request }) => {
    const responses = [];

    for (let i = 0; i < 10; i++) {
      const start = Date.now();
      await request.get('/api/properties');
      responses.push(Date.now() - start);
    }

    const avgTime = responses.reduce((a, b) => a + b) / responses.length;
    expect(avgTime).toBeLessThan(500);
  });
});
```

### 2.3 Security Regression Detection

```typescript
// tests/chaos/security-regression.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Security Regression Detection', () => {
  test('should block XSS attempts in profile fields', async ({ page }) => {
    await page.goto('/profile/edit');

    const xssPayload = '<script>alert("XSS")</script>';
    await page.fill('[name="bio"]', xssPayload);
    await page.click('[data-testid="save-profile"]');

    // Reload and check
    await page.reload();
    const bioContent = await page.locator('[data-testid="profile-bio"]').innerHTML();

    // Should be escaped
    expect(bioContent).not.toContain('<script>');
    expect(bioContent).toContain('&lt;script&gt;');
  });

  test('should prevent IDOR on bank info endpoint', async ({ request }) => {
    // Login as user A
    const userA = await request.post('/api/auth/login', {
      data: { email: 'userA@test.com', password: 'password' },
    });
    const cookieA = userA.headers()['set-cookie'];

    // Try to access user B's bank info
    const response = await request.get('/api/user/bank-info', {
      headers: { cookie: cookieA },
      params: { user_id: 'user-B-id' }, // ← Attempting IDOR
    });

    // Should be denied
    expect(response.status()).toBe(403);
  });

  test('should enforce rate limiting', async ({ request }) => {
    const promises = [];

    // Send 20 requests in parallel
    for (let i = 0; i < 20; i++) {
      promises.push(
        request.post('/api/auth/login', {
          data: { email: 'test@test.com', password: 'wrong' },
        })
      );
    }

    const responses = await Promise.all(promises);
    const rateLimited = responses.filter((r) => r.status() === 429);

    // At least some should be rate limited
    expect(rateLimited.length).toBeGreaterThan(0);
  });
});
```

---

## PHASE 3 : CI/CD Integration (2h)

### 3.1 GitHub Actions Workflow

```yaml
# .github/workflows/continuous-testing.yml
name: Continuous Testing Guardian

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]
  schedule:
    # Run every 6 hours
    - cron: '0 */6 * * *'

jobs:
  e2e-critical-flows:
    name: E2E Critical User Flows
    runs-on: ubuntu-latest
    timeout-minutes: 20

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright
        run: npx playwright install --with-deps

      - name: Run E2E tests
        run: npm run test:e2e:critical
        env:
          NEXT_PUBLIC_SUPABASE_URL: ${{ secrets.TEST_SUPABASE_URL }}
          NEXT_PUBLIC_SUPABASE_ANON_KEY: ${{ secrets.TEST_SUPABASE_ANON_KEY }}
          SUPABASE_SERVICE_ROLE_KEY: ${{ secrets.TEST_SERVICE_ROLE_KEY }}

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: playwright-report
          path: playwright-report/

      - name: Notify on failure
        if: failure()
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: '🚨 E2E Critical Flow FAILED! Regression detected.'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}

  api-contract-tests:
    name: API Contract Tests
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - run: npm ci
      - run: npm run test:api:contracts

      - name: Notify on contract break
        if: failure()
        run: |
          echo "⚠️ API CONTRACT BROKEN - Breaking change detected"
          exit 1

  security-regression:
    name: Security Regression Tests
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4
      - run: npm ci

      # Run security tests
      - run: npm run test:security

      # npm audit
      - name: Dependency audit
        run: npm audit --production --audit-level=high

      - name: Notify on security issue
        if: failure()
        uses: 8398a7/action-slack@v3
        with:
          status: 'danger'
          text: '🔴 SECURITY REGRESSION DETECTED'
          webhook_url: ${{ secrets.SLACK_WEBHOOK }}

  chaos-engineering:
    name: Chaos Engineering Tests
    runs-on: ubuntu-latest
    # Only run on schedule or manual trigger
    if: github.event_name == 'schedule' || github.event_name == 'workflow_dispatch'

    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npx playwright install --with-deps

      - name: Run chaos tests
        run: npm run test:chaos

      - name: Analyze resilience
        run: |
          echo "Chaos test results:"
          cat chaos-report.json | jq '.resilience_score'
```

### 3.2 Pre-commit Hook

```bash
# .claude/hooks/pre-commit-testing.sh
#!/bin/bash

echo "🧪 Running pre-commit tests..."

# 1. Type check
echo "1/4 TypeScript check..."
npm run type-check
if [ $? -ne 0 ]; then
  echo "❌ Type errors detected"
  exit 1
fi

# 2. Lint
echo "2/4 Linting..."
npm run lint
if [ $? -ne 0 ]; then
  echo "❌ Lint errors detected"
  exit 1
fi

# 3. Unit tests
echo "3/4 Unit tests..."
npm run test:unit
if [ $? -ne 0 ]; then
  echo "❌ Unit tests failed"
  exit 1
fi

# 4. Quick E2E smoke test
echo "4/4 Smoke test..."
npm run test:e2e:smoke
if [ $? -ne 0 ]; then
  echo "❌ Smoke test failed - critical flow broken!"
  exit 1
fi

echo "✅ All pre-commit tests passed!"
```

---

## PHASE 4 : Monitoring & Alerting (2h)

### 4.1 Real-time Flow Monitoring

```typescript
// lib/monitoring/flow-monitor.ts
export class FlowMonitor {
  private static instance: FlowMonitor;
  private flowMetrics: Map<string, FlowMetric> = new Map();

  static getInstance() {
    if (!FlowMonitor.instance) {
      FlowMonitor.instance = new FlowMonitor();
    }
    return FlowMonitor.instance;
  }

  trackFlow(flowName: string, step: string, success: boolean, duration: number) {
    const key = `${flowName}:${step}`;
    const metric = this.flowMetrics.get(key) || {
      flowName,
      step,
      successCount: 0,
      failureCount: 0,
      totalDuration: 0,
      lastFailure: null,
    };

    if (success) {
      metric.successCount++;
    } else {
      metric.failureCount++;
      metric.lastFailure = new Date();
    }
    metric.totalDuration += duration;

    this.flowMetrics.set(key, metric);

    // Alert if failure rate > 10%
    const failureRate = metric.failureCount / (metric.successCount + metric.failureCount);
    if (failureRate > 0.1) {
      this.alert(`High failure rate for ${key}: ${(failureRate * 100).toFixed(1)}%`);
    }
  }

  private alert(message: string) {
    // Send to Sentry, Slack, etc.
    console.error(`🚨 FLOW ALERT: ${message}`);

    // Sentry
    if (typeof window !== 'undefined' && window.Sentry) {
      window.Sentry.captureMessage(message, 'error');
    }
  }

  getMetrics() {
    return Array.from(this.flowMetrics.values());
  }
}

// Usage in components
export function useFlowTracking(flowName: string) {
  const trackStep = (step: string, success: boolean, duration: number) => {
    FlowMonitor.getInstance().trackFlow(flowName, step, success, duration);
  };

  return { trackStep };
}
```

### 4.2 Automated Regression Detection

```typescript
// scripts/detect-regressions.ts
import { FlowMonitor } from '../lib/monitoring/flow-monitor';

interface RegressionResult {
  flowName: string;
  step: string;
  previousSuccessRate: number;
  currentSuccessRate: number;
  severity: 'critical' | 'high' | 'medium';
}

export async function detectRegressions(): Promise<RegressionResult[]> {
  const monitor = FlowMonitor.getInstance();
  const currentMetrics = monitor.getMetrics();

  // Load historical metrics from DB
  const historicalMetrics = await loadHistoricalMetrics();

  const regressions: RegressionResult[] = [];

  for (const current of currentMetrics) {
    const key = `${current.flowName}:${current.step}`;
    const historical = historicalMetrics.get(key);

    if (!historical) continue;

    const currentSuccessRate =
      current.successCount / (current.successCount + current.failureCount);
    const historicalSuccessRate =
      historical.successCount / (historical.successCount + historical.failureCount);

    const drop = historicalSuccessRate - currentSuccessRate;

    // Regression detected if success rate drops > 5%
    if (drop > 0.05) {
      regressions.push({
        flowName: current.flowName,
        step: current.step,
        previousSuccessRate: historicalSuccessRate,
        currentSuccessRate,
        severity: drop > 0.2 ? 'critical' : drop > 0.1 ? 'high' : 'medium',
      });
    }
  }

  return regressions;
}

// Run detection
detectRegressions().then((regressions) => {
  if (regressions.length > 0) {
    console.error(`🚨 ${regressions.length} regressions detected:`);
    regressions.forEach((r) => {
      console.error(`  - ${r.flowName}/${r.step}: ${(r.previousSuccessRate * 100).toFixed(1)}% → ${(r.currentSuccessRate * 100).toFixed(1)}% [${r.severity}]`);
    });

    // Alert
    sendSlackAlert({
      text: `🚨 Regressions detected in ${regressions.length} flows`,
      attachments: regressions.map((r) => ({
        color: r.severity === 'critical' ? 'danger' : 'warning',
        text: `${r.flowName}/${r.step}: ${(r.currentSuccessRate * 100).toFixed(1)}%`,
      })),
    });
  } else {
    console.log('✅ No regressions detected');
  }
});
```

---

## PHASE 5 : Dashboard & Reporting (2h)

### 5.1 Test Status Dashboard

```typescript
// app/admin/testing-dashboard/page.tsx
import { FlowMonitor } from '@/lib/monitoring/flow-monitor';

export default function TestingDashboard() {
  const metrics = FlowMonitor.getInstance().getMetrics();

  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-8">Continuous Testing Dashboard</h1>

      {/* Overall Health */}
      <div className="grid grid-cols-4 gap-4 mb-8">
        <MetricCard
          title="Total Flows Monitored"
          value={metrics.length}
          icon="🎯"
        />
        <MetricCard
          title="Success Rate"
          value={`${calculateOverallSuccessRate(metrics)}%`}
          icon="✅"
          color={calculateOverallSuccessRate(metrics) > 95 ? 'green' : 'red'}
        />
        <MetricCard
          title="Active Regressions"
          value={countRegressions(metrics)}
          icon="🚨"
          color={countRegressions(metrics) > 0 ? 'red' : 'green'}
        />
        <MetricCard
          title="Last Test Run"
          value="2 min ago"
          icon="⏱️"
        />
      </div>

      {/* Flow Details */}
      <div className="bg-white rounded-lg shadow">
        <table className="w-full">
          <thead>
            <tr className="border-b">
              <th>Flow</th>
              <th>Step</th>
              <th>Success Rate</th>
              <th>Avg Duration</th>
              <th>Last Failure</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            {metrics.map((metric) => (
              <tr key={`${metric.flowName}:${metric.step}`}>
                <td>{metric.flowName}</td>
                <td>{metric.step}</td>
                <td>
                  <SuccessRateBadge
                    rate={metric.successCount / (metric.successCount + metric.failureCount)}
                  />
                </td>
                <td>{(metric.totalDuration / (metric.successCount + metric.failureCount)).toFixed(0)}ms</td>
                <td>{metric.lastFailure ? formatDistance(metric.lastFailure, new Date()) : 'Never'}</td>
                <td><StatusBadge metric={metric} /></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
```

---

## PHASE 6 : Automated Fixes (Advanced)

### 6.1 Self-Healing Tests

```typescript
// tests/helpers/self-healing.ts
export async function retryWithHealing(
  testFn: () => Promise<void>,
  maxRetries: number = 3
) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      await testFn();
      return; // Success
    } catch (error) {
      console.log(`Attempt ${attempt} failed:`, error.message);

      if (attempt < maxRetries) {
        // Try to heal
        await attemptHeal(error);
      } else {
        throw error; // Give up
      }
    }
  }
}

async function attemptHeal(error: Error) {
  // Example: If selector not found, wait and retry
  if (error.message.includes('selector not found')) {
    await new Promise((resolve) => setTimeout(resolve, 2000));
  }

  // Example: If API call failed, clear cache
  if (error.message.includes('API')) {
    // Implement cache clear
  }
}
```

---

## Test Execution Strategy

### Priority Levels

| Priority | When to Run | Examples |
|----------|-------------|----------|
| P0 - Critical | Every commit, before merge | Auth, payment, data access |
| P1 - High | Daily, before deploy | Profile edit, search, messaging |
| P2 - Medium | Weekly | Analytics, reporting |
| P3 - Low | Monthly | Edge cases, rarely used features |

### package.json Scripts

```json
{
  "scripts": {
    "test:e2e:critical": "playwright test tests/e2e/critical-flows/",
    "test:e2e:smoke": "playwright test tests/e2e/smoke/",
    "test:api:contracts": "playwright test tests/api/contracts/",
    "test:security": "playwright test tests/chaos/security-regression.spec.ts",
    "test:chaos": "playwright test tests/chaos/",
    "test:all": "npm run test:e2e:critical && npm run test:api:contracts && npm run test:security",
    "test:detect-regressions": "ts-node scripts/detect-regressions.ts"
  }
}
```

---

## Benefits & ROI

### Problem Solved
- ✅ Détection immédiate des régressions
- ✅ Prévention de la dette technique
- ✅ Confiance dans les modifications IA
- ✅ Documentation vivante (tests = specs)

### Metrics to Track
- **Mean Time to Detection** (MTTD) : Temps entre introduction du bug et détection
- **Regression Rate** : % de commits qui introduisent une régression
- **Test Coverage** : % des flows critiques couverts
- **False Positive Rate** : Tests qui échouent sans raison

---

## Continuous Improvement

1. **Add tests for each bug found** : Chaque bug devient un nouveau test
2. **Refine chaos scenarios** : Ajouter de nouveaux failure modes
3. **Monitor test performance** : Tests trop lents = tech debt
4. **Review test relevance** : Supprimer tests obsolètes

---

## Sources

- Netflix Chaos Engineering : https://netflixtechblog.com/tagged/chaos-engineering
- Playwright Best Practices : https://playwright.dev/docs/best-practices
- Continuous Testing Guide : https://www.qatouch.com/blog/chaos-testing/
- Google Testing Blog : https://testing.googleblog.com/
