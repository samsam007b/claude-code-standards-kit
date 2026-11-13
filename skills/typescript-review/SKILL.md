---
name: typescript-review
description: Audit TypeScript & qualité de code — strict mode, types explicites, no-any, patterns SOLID, nommage Clean Code. Sources : Martin Fowler, Google Engineering Practices, Microsoft TypeScript Handbook.
tags: [typescript, code-quality, solid, clean-code, types]
model: sonnet
---

# /typescript-review — Audit TypeScript & Code Quality

## Quand utiliser

- Review d'un fichier ou module TypeScript
- Avant merge d'une PR backend ou frontend
- Refactoring d'un fichier legacy (any partout, types manquants)
- Validation d'un nouveau service ou helper

## Règles (Robert C. Martin + TypeScript strict)

### Types stricts
- [ ] `strict: true` dans tsconfig (inclut noImplicitAny, strictNullChecks, etc.)
- [ ] Zéro `any` — utiliser `unknown` puis narrowing ou `as Type` justifié
- [ ] Zéro `// @ts-ignore` — résoudre le problème typé
- [ ] Types explicites sur les paramètres de fonctions publiques
- [ ] Return type explicite sur les fonctions complexes ou publiques

### Patterns de types avancés
- **Discriminated unions** pour les états multiples (pas de `boolean` + `data` séparés)
- **Branded types** pour les IDs (`UserId`, `PropertyId` — pas de `string` nu)
- **`const` assertions** pour les littéraux (`as const`)
- **Generics** pour la réutilisabilité (pas de copie-coller de types)
- **`satisfies`** operator pour la validation sans widening

### Clean Code (Martin)
- Fonctions : max 20 lignes, 1 responsabilité, max 3 paramètres
- Nommage : verbe + nom pour les fonctions (`getUserProfile`, `validateEmail`)
- Variables : noms explicites — jamais `d`, `tmp`, `data`, `res`
- Commentaires : uniquement sur le "pourquoi" (jamais le "quoi" si le code est clair)
- Fichier : max 300 lignes — au-delà, découper en sous-modules

### SOLID
- **S** Single Responsibility : 1 classe/fichier = 1 raison de changer
- **O** Open/Closed : extension via interfaces, pas de modification du core
- **L** Liskov : sous-types remplaçables sans casser le comportement
- **I** Interface Segregation : interfaces petites et spécifiques
- **D** Dependency Inversion : dépendre d'abstractions, pas de concrets

### Patterns interdits
- `switch` sur un type union → utiliser des discriminated unions + map d'objets
- `Object.keys()` sans cast → `(Object.keys(obj) as (keyof typeof obj)[])`
- `JSON.parse()` sans validation Zod → valider toujours les inputs externes
- Mutations d'objets partagés → toujours retourner un nouveau objet

## Format de sortie

```
## TypeScript Review — [fichier/module]

### Score qualité : [0-100]

### 🔴 Violations critiques (any, ts-ignore, unsafe)
### 🟡 Problèmes de design (SOLID, Clean Code)
### 🟢 Suggestions (optimisations de types)

### Refactoring proposé
[code corrigé avec explication]
```
