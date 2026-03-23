# Contrat — Testing

> Module de contrat SQWR Project Kit.
> Sources : Martin Fowler (test pyramid), Agile Alliance (Definition of Done), React Testing Library, Playwright docs.

---

## Fondements scientifiques

**La pyramide de tests** (Mike Cohn / Martin Fowler) est le modèle industriel standard depuis 2009. Elle repose sur un principe de coût/retour : les tests unitaires sont rapides et peu coûteux à écrire ; les tests E2E sont lents et fragiles. L'inverse (beaucoup d'E2E, peu d'unitaires = "ice cream cone anti-pattern") est l'erreur la plus coûteuse en QA.

---

## 1. La pyramide de tests — répartition cible

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

| Niveau | % du total | Outil | Caractéristiques |
|--------|-----------|-------|-----------------|
| **Unit** | 80% | Vitest / Jest + RTL | Rapide (<1s), isolé, mocke les dépendances |
| **Integration** | 15% | Vitest + vraie DB | Teste les interactions entre modules |
| **E2E** | 5% | Playwright | Teste le flux complet utilisateur |

---

## 2. Seuils de couverture — non négociables

| Métrique | Seuil | Standard |
|----------|-------|---------|
| **Line coverage global** | >80% | Industrie (client-facing code) |
| **Branch coverage global** | >75% | Professionnel |
| **Auth paths** | 100% | Critique — zero tolerance |
| **Payment paths** | 100% | Critique — zero tolerance |
| **API Routes** | >90% | Exposition publique |

```json
// vitest.config.ts — coverage thresholds automatiques
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

> Un incrément n'est "done" que si les tests sont écrits ET passants.

**Checklist DoD obligatoire avant tout merge :**
- [ ] Tests unitaires écrits pour la nouvelle logique
- [ ] Tests d'intégration pour les nouvelles routes API
- [ ] `npm run test` passe sans erreur
- [ ] Coverage ne régresse pas (pas de merge qui fait descendre le % global)
- [ ] E2E mis à jour si le flux utilisateur a changé

---

## 4. Patterns Next.js — Tests unitaires

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

## 5. Patterns — Tests d'intégration

```typescript
// lib/__tests__/actions.integration.test.ts
import { createClient } from '@/lib/supabase/server'
import { createProject } from '@/lib/actions'

// ⚠️ Tests sur VRAIE base de données (Supabase test project)
// NE JAMAIS mocker Supabase pour les tests d'intégration

describe('createProject action', () => {
  beforeEach(async () => {
    // Setup : créer un user test, nettoyer les données
  })

  afterEach(async () => {
    // Cleanup : supprimer les données de test
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
    // name manquant

    const result = await createProject(formData)
    expect(result.success).toBe(false)
    expect(result.error).toBeDefined()
  })
})
```

---

## 6. Patterns — Tests E2E (Playwright)

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

## 7. Règles critiques

### Ne jamais faire

- **Mocker Supabase dans les tests d'intégration** — les mocks masquent les divergences réelles prod/test (erreur classique qui a causé des incidents)
- **Merger du code sans tests** sur des features nouvelles
- **Écrire des tests après le bug** — les tests doivent exister avant de clore un ticket

### Toujours faire

- Tests dans le même dossier que le code (`Component.test.tsx` colocalisé)
- Nommer les tests de façon lisible : "doit [faire quoi] quand [condition]"
- Tester les cas d'erreur, pas seulement le happy path
- CI/CD bloque si les tests échouent (jamais `--passWithNoTests` en prod)

---

## 8. Configuration recommandée

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

| Référence | Lien |
|-----------|------|
| Martin Fowler — Test Pyramid | martinfowler.com/articles/practical-test-pyramid.html |
| Agile Alliance — Definition of Done | agilealliance.org/glossary/definition-of-done |
| React Testing Library | testing-library.com/docs/react-testing-library/intro |
| Playwright Documentation | playwright.dev |
| Vitest Documentation | vitest.dev |
