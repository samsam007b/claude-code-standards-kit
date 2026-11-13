---
name: api-design
description: Design et audit d'API REST — conventions REST, codes HTTP corrects, error format RFC 7807, rate limiting, versioning, sécurité OWASP API Top 10. Standards : RFC 7231, RFC 7807, OpenAPI 3.1.
tags: [api, rest, http, security, openapi, rate-limiting, design]
model: sonnet
---

# /api-design — Design & Audit API REST

## Quand utiliser

- Créer une nouvelle route API
- Auditer des routes existantes
- Vérifier la conformité REST et sécurité
- Générer la documentation OpenAPI

## Standards (RFC 7231 + Google API Design Guide)

### Conventions REST
| Action | Méthode | URL | Status success |
|--------|---------|-----|---------------|
| Lister | GET | `/resources` | 200 |
| Créer | POST | `/resources` | 201 |
| Lire | GET | `/resources/:id` | 200 |
| Remplacer | PUT | `/resources/:id` | 200 |
| Modifier | PATCH | `/resources/:id` | 200 |
| Supprimer | DELETE | `/resources/:id` | 204 |

### Codes HTTP corrects
- `400` — Validation échouée (body malformé, champ manquant)
- `401` — Non authentifié (token manquant ou expiré)
- `403` — Authentifié mais non autorisé
- `404` — Resource inexistante
- `409` — Conflit (duplicate, état invalide)
- `422` — Entité non processable (logique métier échouée)
- `429` — Rate limit atteint
- `500` — Erreur serveur (à logger, pas exposer)

### Format d'erreur (RFC 7807 Problem Details)
```json
{
  "type": "https://api.example.com/errors/validation-failed",
  "title": "Validation Failed",
  "status": 400,
  "detail": "Le champ 'email' est requis",
  "instance": "/api/users/register"
}
```

### Sécurité (OWASP API Security Top 10 2023)
- [ ] Auth vérifiée sur toutes les routes non-publiques
- [ ] Rate limiting : `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `Retry-After`
- [ ] Validation Zod sur TOUS les inputs (body, query params, path params)
- [ ] Pas d'IDs séquentiels exposés (IDOR) — utiliser UUID ou CUID
- [ ] Champs sensibles filtrés des réponses (password_hash, internal_ids)
- [ ] Pagination obligatoire sur les listes (max 100 items, défaut 20)
- [ ] `Sunset` header sur les routes dépréciées (RFC 8594)

### Rate Limiting (Upstash pattern)
```typescript
const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '10 s'),
  analytics: true,
})
```

## Format de sortie

```
## API Review — [route/module]

### Conformité REST : [X/10]
### Sécurité OWASP : [X/10]

### 🔴 Bloquant
### 🟡 Important
### 🟢 Suggestions

### Schema OpenAPI 3.1
[yaml snippet pour la route]
```
