---
name: typescript-review
description: TypeScript & code quality audit: strict mode, explicit types, no-any, SOLID patterns, Clean Code naming. Sources: Martin Fowler, Google Engineering Practices, Microsoft TypeScript Handbook.
tags: [typescript, code-quality, solid, clean-code, types]
model: sonnet
---

# /typescript-review: TypeScript & Code Quality Audit

## When to use

- Review of a TypeScript file or module
- Before merging a backend or frontend PR
- Refactoring a legacy file (any everywhere, missing types)
- Validation of a new service or helper

## Rules (Robert C. Martin + TypeScript strict)

### Strict types
- [ ] `strict: true` in tsconfig (includes noImplicitAny, strictNullChecks, etc.)
- [ ] Zero `any`: use `unknown` then narrowing or a justified `as Type`
- [ ] Zero `// @ts-ignore`: solve the typing problem
- [ ] Explicit types on public function parameters
- [ ] Explicit return type on complex or public functions

### Advanced type patterns
- **Discriminated unions** for multiple states (no separate `boolean` + `data`)
- **Branded types** for IDs (`UserId`, `PropertyId`, not a bare `string`)
- **`const` assertions** for literals (`as const`)
- **Generics** for reusability (no copy-pasting types)
- **`satisfies`** operator for validation without widening

### Clean Code (Martin)
- Functions: max 20 lines, 1 responsibility, max 3 parameters
- Naming: verb + noun for functions (`getUserProfile`, `validateEmail`)
- Variables: explicit names, never `d`, `tmp`, `data`, `res`
- Comments: only on the "why" (never the "what" if the code is clear)
- File: max 300 lines, beyond that split into sub-modules

### SOLID
- **S** Single Responsibility: 1 class/file = 1 reason to change
- **O** Open/Closed: extension via interfaces, no modification of the core
- **L** Liskov: subtypes replaceable without breaking behavior
- **I** Interface Segregation: small, specific interfaces
- **D** Dependency Inversion: depend on abstractions, not concretions

### Forbidden patterns
- `switch` on a union type → use discriminated unions + object map
- `Object.keys()` without a cast → `(Object.keys(obj) as (keyof typeof obj)[])`
- `JSON.parse()` without Zod validation → always validate external inputs
- Mutations of shared objects → always return a new object

## Output format

```
## TypeScript Review: [file/module]

### Quality score: [0-100]

### 🔴 Critical violations (any, ts-ignore, unsafe)
### 🟡 Design issues (SOLID, Clean Code)
### 🟢 Suggestions (type optimizations)

### Proposed refactoring
[corrected code with explanation]
```
