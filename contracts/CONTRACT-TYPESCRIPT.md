# Contrat — TypeScript & Qualité Code

> Module de contrat SQWR Project Kit — enrichi avec références scientifiques.
> Sources : Robert C. Martin (Clean Code), Google Engineering Practices, Microsoft TypeScript Handbook, SOLID principles.

---

## Fondements scientifiques

**Le code est lu 10× plus souvent qu'il est écrit** (Robert C. Martin, *Clean Code*, 2008). La lisibilité est la première vertu d'un code professionnel — pas la performance ni l'élégance.

---

## 1. Seuils mesurables — non négociables

| Métrique | Seuil | Standard |
|----------|-------|---------|
| **Line coverage** | >80% | Industrie (client-facing code) |
| **Type coverage** | >95% | Professionnel (outils : `type-coverage`) |
| **Cyclomatic complexity** | Max 10 par fonction (idéal <5) | ISO/IEC 25010 |
| **ESLint errors en CI** | 0 | Google, Microsoft |
| **Build time (incremental)** | <5s | Performance moderne |

---

## 2. Mode strict — configuration obligatoire

`tsconfig.json` doit avoir :
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

## 3. Les 5 principes SOLID (Robert C. Martin)

> Piliers du code maintenable, établis dans les années 1990, universellement adoptés par Google, Microsoft, Amazon.

### S — Single Responsibility Principle
**Une classe/fonction = une seule raison de changer.**

```typescript
// ❌ Trop de responsabilités
class UserService {
  getUser(id: string) { /* DB query */ }
  sendWelcomeEmail(user: User) { /* Email logic */ }
  formatUserForDisplay(user: User) { /* UI logic */ }
}

// ✅ Séparation claire
class UserRepository { getUser(id: string) { /* DB only */ } }
class EmailService { sendWelcome(user: User) { /* Email only */ } }
class UserPresenter { format(user: User) { /* Display only */ } }
```

### O — Open/Closed Principle
**Ouvert à l'extension, fermé à la modification.**

```typescript
// ✅ Ajouter un type de notification sans modifier le code existant
interface Notifier { send(message: string): void }
class EmailNotifier implements Notifier { send(msg: string) { /* email */ } }
class SlackNotifier implements Notifier { send(msg: string) { /* slack */ } }
```

### L — Liskov Substitution Principle
**Les sous-types doivent être substituables aux types de base sans casser le comportement.**

### I — Interface Segregation Principle
**Plusieurs interfaces spécifiques valent mieux qu'une interface générale.**

```typescript
// ❌ Interface trop large
interface Worker { work(): void; eat(): void; sleep(): void }

// ✅ Interfaces segregated
interface Workable { work(): void }
interface Eatable { eat(): void }
```

### D — Dependency Inversion Principle
**Le code haut niveau dépend d'abstractions, pas d'implémentations.**

```typescript
// ✅ Inversion via interface
interface Logger { log(message: string): void }
class UserService {
  constructor(private logger: Logger) {}  // Injection, pas hardcoded
}
```

---

## 4. Clean Code — principes fondateurs

> Robert C. Martin, *Clean Code* (2008) — livre de référence universel en génie logiciel.

| Principe | Règle |
|----------|-------|
| **Meaningful Naming** | Les noms expliquent l'intention (`getUserById` > `getUser`) |
| **Single Responsibility** | Une fonction fait une chose |
| **DRY** (Don't Repeat Yourself) | Zéro duplication — extraire en fonction/util |
| **KISS** (Keep It Simple) | La solution la plus simple qui fonctionne |
| **Boy Scout Rule** | Laisser le code plus propre qu'on ne l'a trouvé |
| **Error Handling** | Pas d'erreur silencieuse — toujours gérer ou rethrow |

---

## 5. Règles TypeScript — interdictions

### Ne jamais faire

```typescript
// ❌ any — utiliser unknown + narrowing
function process(data: any) {}  // INTERDIT

// ❌ as casting sans vérification
const user = data as User  // Dangereux

// ❌ ! non-null assertion sans justification
const element = document.getElementById('id')!  // Risqué

// ❌ @ts-ignore — utiliser @ts-expect-error + commentaire si absolument nécessaire
// @ts-ignore
```

### Toujours faire

```typescript
// ✅ unknown + type narrowing
function process(data: unknown) {
  if (typeof data === 'string') { /* narrowed */ }
}

// ✅ Union types explicites pour les états
type RequestState<T> =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: string }

// ✅ Discriminated unions pour logique complexe
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

## 6. Validation avec Zod (données externes)

```typescript
import { z } from 'zod'

const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string().min(1).max(100),
})

type User = z.infer<typeof UserSchema>

// Toujours valider les données externes (API, formulaires, Supabase)
const user = UserSchema.parse(rawData)           // throws si invalide
const result = UserSchema.safeParse(rawData)      // { success, data/error }
```

---

## 7. Google Code Review Standard (6 critères)

> Source : [google.github.io/eng-practices/review](https://google.github.io/eng-practices/review)

Tout PR doit passer ces 6 critères avant merge :

| Critère | Question à se poser |
|---------|---------------------|
| **Design** | Le code est-il bien conçu et approprié pour le système ? |
| **Functionality** | Fait-il ce qu'il est censé faire ? Est-ce bon pour les utilisateurs ? |
| **Complexity** | Pourrait-il être plus simple ? Un autre dev le comprendra-t-il facilement ? |
| **Tests** | Les tests sont-ils corrects, exhaustifs et bien conçus ? |
| **Naming** | Les noms (variables, classes, méthodes) sont-ils clairs ? |
| **Documentation** | La documentation est-elle mise à jour et claire ? |

**Principe Google :** approuver si le code améliore la santé globale du codebase, même s'il n'est pas parfait.

---

## 8. Server Actions typées

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

  // Logique métier...
  return { success: true, data: result }
}
```

---

## 9. Types Supabase

Toujours générer les types depuis le schéma :

```bash
supabase gen types typescript --project-id [project-id] > src/types/database.types.ts
```

```typescript
import type { Database } from '@/types/database.types'
const supabase = createClient<Database>(url, key)

// Types automatiquement inférés des tables
type Project = Database['public']['Tables']['projects']['Row']
```

---

## 10. Organisation des imports

```typescript
// 1. Bibliothèques externes (node_modules)
import { z } from 'zod'
import { createClient } from '@supabase/ssr'

// 2. Imports internes absolus (alias @/)
import { Button } from '@/components/ui/Button'
import { createProject } from '@/lib/actions'

// 3. Imports relatifs locaux (même dossier/parent proche)
import { formatDate } from './utils'
```

---

## 11. Sources

| Référence | Lien |
|-----------|------|
| Robert C. Martin — *Clean Code* (2008) | amazon.com/Clean-Code-Handbook-Software-Craftsmanship |
| Google Engineering Practices | google.github.io/eng-practices/review |
| TypeScript Handbook — Do's & Don'ts | typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts |
| SOLID Principles in TypeScript | blog.logrocket.com/applying-solid-principles-typescript |
| ISO/IEC 25010 — Software Quality | iso.org/standard/35733.html |
