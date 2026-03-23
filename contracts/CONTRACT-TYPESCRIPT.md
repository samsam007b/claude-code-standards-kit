# Contract — TypeScript & Code Quality

> SQWR Project Kit contract module — enriched with scientific references.
> Sources: Robert C. Martin (Clean Code), Google Engineering Practices, Microsoft TypeScript Handbook, SOLID principles.

---

## Scientific Foundations

**Code is read 10× more often than it is written** (Robert C. Martin, *Clean Code*, 2008). Readability is the primary virtue of professional code — not performance or elegance.

---

## 1. Measurable Thresholds — Non-Negotiable

| Metric | Threshold | Standard |
|----------|-------|---------|
| **Line coverage** | >80% | Industry (client-facing code) |
| **Type coverage** | >95% | Professional (tools: `type-coverage`) |
| **Cyclomatic complexity** | Max 10 per function (ideal <5) | ISO/IEC 25010 |
| **ESLint errors in CI** | 0 | Google, Microsoft |
| **Build time (incremental)** | <5s | Modern performance |

---

## 2. Strict Mode — Mandatory Configuration

`tsconfig.json` must include:
```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

---

## 3. The 5 SOLID Principles (Robert C. Martin)

> Pillars of maintainable code, established in the 1990s, universally adopted by Google, Microsoft, Amazon.

### S — Single Responsibility Principle
**One class/function = one single reason to change.**

```typescript
// ❌ Too many responsibilities
class UserService {
  getUser(id: string) { /* DB query */ }
  sendWelcomeEmail(user: User) { /* Email logic */ }
  formatUserForDisplay(user: User) { /* UI logic */ }
}

// ✅ Clear separation
class UserRepository { getUser(id: string) { /* DB only */ } }
class EmailService { sendWelcome(user: User) { /* Email only */ } }
class UserPresenter { format(user: User) { /* Display only */ } }
```

### O — Open/Closed Principle
**Open for extension, closed for modification.**

```typescript
// ✅ Add a notification type without modifying existing code
interface Notifier { send(message: string): void }
class EmailNotifier implements Notifier { send(msg: string) { /* email */ } }
class SlackNotifier implements Notifier { send(msg: string) { /* slack */ } }
```

### L — Liskov Substitution Principle
**Subtypes must be substitutable for their base types without breaking behavior.**

### I — Interface Segregation Principle
**Multiple specific interfaces are better than one general interface.**

```typescript
// ❌ Interface too broad
interface Worker { work(): void; eat(): void; sleep(): void }

// ✅ Segregated interfaces
interface Workable { work(): void }
interface Eatable { eat(): void }
```

### D — Dependency Inversion Principle
**High-level code depends on abstractions, not implementations.**

```typescript
// ✅ Inversion via interface
interface Logger { log(message: string): void }
class UserService {
  constructor(private logger: Logger) {}  // Injected, not hardcoded
}
```

---

## 4. Clean Code — Core Principles

> Robert C. Martin, *Clean Code* (2008) — universal reference in software engineering.

| Principle | Rule |
|----------|-------|
| **Meaningful Naming** | Names explain intent (`getUserById` > `getUser`) |
| **Single Responsibility** | A function does one thing |
| **DRY** (Don't Repeat Yourself) | Zero duplication — extract into a function/util |
| **KISS** (Keep It Simple) | The simplest solution that works |
| **Boy Scout Rule** | Leave the code cleaner than you found it |
| **Error Handling** | No silent errors — always handle or rethrow |

---

## 5. TypeScript Rules — Prohibitions

### Never do

```typescript
// ❌ any — use unknown + narrowing
function process(data: any) {}  // FORBIDDEN

// ❌ as casting without verification
const user = data as User  // Dangerous

// ❌ ! non-null assertion without justification
const element = document.getElementById('id')!  // Risky

// ❌ @ts-ignore — use @ts-expect-error + comment if absolutely necessary
// @ts-ignore
```

### Always do

```typescript
// ✅ unknown + type narrowing
function process(data: unknown) {
  if (typeof data === 'string') { /* narrowed */ }
}

// ✅ Explicit union types for states
type RequestState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: string }

// ✅ Discriminated unions for complex logic
type Shape =
  | { kind: 'circle'; radius: number }
  | { kind: 'rectangle'; width: number; height: number }

function area(shape: Shape): number {
  switch (shape.kind) {
    case 'circle': return Math.PI * shape.radius ** 2
    case 'rectangle': return shape.width * shape.height
  }
}
```

---

## 6. Validation with Zod (External Data)

```typescript
import { z } from 'zod'

const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string().min(1).max(100),
})

type User = z.infer<typeof UserSchema>

// Always validate external data (API, forms, Supabase)
const user = UserSchema.parse(rawData)           // throws if invalid
const result = UserSchema.safeParse(rawData)      // { success, data/error }
```

---

## 7. Google Code Review Standard (6 Criteria)

> Source: [google.github.io/eng-practices/review](https://google.github.io/eng-practices/review)

Every PR must pass these 6 criteria before merge:

| Criterion | Question to ask |
|---------|---------------------|
| **Design** | Is the code well-designed and appropriate for the system? |
| **Functionality** | Does it do what it's supposed to do? Is it good for users? |
| **Complexity** | Could it be simpler? Will another developer understand it easily? |
| **Tests** | Are the tests correct, thorough, and well-designed? |
| **Naming** | Are the names (variables, classes, methods) clear? |
| **Documentation** | Is the documentation updated and clear? |

**Google principle:** approve if the code improves the overall health of the codebase, even if it is not perfect.

---

## 8. Typed Server Actions

```typescript
'use server'

export async function createProject(
  formData: FormData
): Promise<{ success: boolean; error?: string; data?: Project }> {
  const validated = ProjectSchema.safeParse({
    name: formData.get('name'),
    description: formData.get('description'),
  })

  if (!validated.success) {
    return { success: false, error: validated.error.message }
  }

  // Business logic...
  return { success: true, data: result }
}
```

---

## 9. Supabase Types

Always generate types from the schema:

```bash
supabase gen types typescript --project-id [project-id] > src/types/database.types.ts
```

```typescript
import type { Database } from '@/types/database.types'
const supabase = createClient<Database>(url, key)

// Types automatically inferred from tables
type Project = Database['public']['Tables']['projects']['Row']
```

---

## 10. Import Organization

```typescript
// 1. External libraries (node_modules)
import { z } from 'zod'
import { createClient } from '@supabase/ssr'

// 2. Absolute internal imports (@ alias)
import { Button } from '@/components/ui/Button'
import { createProject } from '@/lib/actions'

// 3. Relative local imports (same or nearby folder)
import { formatDate } from './utils'
```

---

## 11. Sources

| Reference | Link |
|-----------|------|
| Robert C. Martin — *Clean Code* (2008) | amazon.com/Clean-Code-Handbook-Software-Craftsmanship |
| Google Engineering Practices | google.github.io/eng-practices/review |
| TypeScript Handbook — Do's & Don'ts | typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts |
| SOLID Principles in TypeScript | blog.logrocket.com/applying-solid-principles-typescript |
| ISO/IEC 25010 — Software Quality | iso.org/standard/35733.html |
