# Contrat — Supabase

> Module de contrat SQWR Project Kit — enrichi avec références scientifiques.
> Sources : Supabase RLS docs, NIST SP 800-63B, JWT Best Practices (Curity), OWASP.

---

## 1. Règles de sécurité absolues

### Ne jamais faire

- **Exposer la `service_role` key côté client** — uniquement Server Actions ou API Routes
- **Désactiver RLS** sur une table contenant des données utilisateurs
- **Requêter sans vérifier les RLS** — tester toujours avec un utilisateur non-admin
- **Écrire des données sans validation Zod** — valider en amont systématiquement
- **Commit de fichiers `.env.local`** — credentials Supabase jamais dans le repo
- **Stocker des données sensibles dans les JWT** — les tokens traversent le réseau

---

## 2. Standards JWT (NIST SP 800-63B — Curity Research)

> Source : [NIST Special Publication 800-63B](https://pages.nist.gov/800-63-4/sp800-63b.html), [JWT Best Practices — Curity](https://curity.io/resources/learn/jwt-best-practices/)

### Durée de vie des tokens

| Token | Durée recommandée | Raison |
|-------|------------------|--------|
| **Access token** | **5-15 minutes** | Exposure window minimal en cas de vol |
| **Refresh token** | 7-30 jours (avec rotation) | Confort utilisateur avec sécurité |
| **Session cookie** | ≤24h (configurable) | Équilibre UX/sécurité |

### Algorithme de signature

| Algo | Usage | Note |
|------|-------|------|
| **RS256** (RSA + SHA-256) | Recommandé en production | Clé publique/privée — vérifiable sans secret |
| **HS256** | Simple, petits projets | Clé symétrique — tous les services partagent le secret |

**Recommandation :** RS256 dès qu'il y a plusieurs services ou une API publique.

### Stockage des tokens

```
✅ Cookies HttpOnly + SameSite=Strict   → CSRF protégé, inaccessible JS
✅ Cookies HttpOnly + SameSite=Lax     → Compatible OAuth redirects
❌ localStorage                         → Vulnérable XSS
❌ sessionStorage                       → Vulnérable XSS
```

### Rotation des secrets (NIST SP 800-63B)

**NIST recommande de NE PAS faire de rotation sur calendrier fixe.** Rotation uniquement si :
- Compromission confirmée ou suspectée
- Départ d'un employé ayant accès
- Audit de sécurité le requiert

---

## 3. Pattern Client correct

```typescript
// lib/supabase/server.ts — côté serveur uniquement
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'
import type { Database } from '@/types/database.types'

export async function createClient() {
  const cookieStore = await cookies()
  return createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll: () => cookieStore.getAll(),
        setAll: (cs) => cs.forEach(({ name, value, options }) =>
          cookieStore.set(name, value, options)
        ),
      },
    }
  )
}

// lib/supabase/client.ts — côté client uniquement
import { createBrowserClient } from '@supabase/ssr'
import type { Database } from '@/types/database.types'

export function createClient() {
  return createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

---

## 4. Row Level Security (RLS)

**Toutes les tables avec données utilisateurs = RLS obligatoire.**

### Règle d'indexation critique

> Source : Supabase RLS Documentation — Performance

**Chaque colonne utilisée dans une politique RLS doit avoir un index.** Sans index, chaque requête scanne toute la table.

```sql
-- ✅ Activer RLS
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

-- ✅ Index obligatoire sur les colonnes de politique
CREATE INDEX ON projects(user_id);    -- filtré dans la politique
CREATE INDEX ON projects(tenant_id);  -- filtré dans la politique

-- ✅ Politique spécifique par opération (éviter FOR ALL avec USING(true))
CREATE POLICY "select_own" ON projects FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "insert_own" ON projects FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "update_own" ON projects FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "delete_own" ON projects FOR DELETE USING (auth.uid() = user_id);
```

### Patterns RLS avancés

```sql
-- Lecture publique, écriture authentifiée
CREATE POLICY "public_read" ON posts FOR SELECT USING (true);
CREATE POLICY "auth_write" ON posts FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Multi-tenant (organisations)
CREATE POLICY "tenant_isolation" ON resources
  FOR ALL USING (tenant_id = (auth.jwt() ->> 'tenant_id')::uuid);
```

---

## 5. Gestion des sessions expirées

```typescript
// middleware.ts — rafraîchir la session automatiquement
import { createServerClient } from '@supabase/ssr'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  let response = NextResponse.next({ request })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { cookies: { /* ... */ } }
  )

  // Rafraîchit automatiquement le token si expiré
  const { data: { user } } = await supabase.auth.getUser()

  if (!user && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  return response
}
```

---

## 6. Rate Limiting

```typescript
// app/api/contact/route.ts — rate limiting applicatif
import { NextResponse } from 'next/server'

const rateLimitMap = new Map<string, { count: number; timestamp: number }>()

function rateLimit(ip: string, limit = 5, windowMs = 60_000): boolean {
  const now = Date.now()
  const entry = rateLimitMap.get(ip)

  if (!entry || now - entry.timestamp > windowMs) {
    rateLimitMap.set(ip, { count: 1, timestamp: now })
    return true
  }

  if (entry.count >= limit) return false
  entry.count++
  return true
}

export async function POST(request: Request) {
  const ip = request.headers.get('x-forwarded-for') ?? 'unknown'
  if (!rateLimit(ip)) {
    return NextResponse.json({ error: 'Too many requests' }, { status: 429 })
  }
  // Logique normale...
}
```

---

## 7. Gestion des migrations

```
Convention de nommage : YYYYMMDDHHMMSS_description.sql
Exemple : 20260317143000_create_projects_table.sql
```

- Utiliser `supabase/migrations/` pour toutes les modifications de schéma
- Tester les migrations en local avant de pusher sur prod
- Ne jamais modifier le schéma directement en prod via l'interface Supabase
- Versionner les migrations dans git (committed, jamais dans .gitignore)

---

## 8. Variables d'environnement requises

```bash
NEXT_PUBLIC_SUPABASE_URL=         # URL du projet (https://xxx.supabase.co)
NEXT_PUBLIC_SUPABASE_ANON_KEY=    # Clé anon — publique, ok côté client
SUPABASE_SERVICE_ROLE_KEY=        # Clé service — JAMAIS NEXT_PUBLIC_
```

---

## 9. Storage

- Activer RLS sur les buckets en production
- Pas d'upload direct depuis client sans vérification MIME et taille
- URLs signées pour fichiers privés (expiration ≤ 1h pour données sensibles)
- Buckets publics uniquement pour assets statiques (images produit, logos)

---

## 10. Sources

| Référence | Lien |
|-----------|------|
| Supabase RLS Documentation | supabase.com/docs/guides/database/postgres/row-level-security |
| JWT Best Practices — Curity | curity.io/resources/learn/jwt-best-practices |
| JWT Security — LogRocket | blog.logrocket.com/jwt-authentication-best-practices |
| NIST SP 800-63B | pages.nist.gov/800-63-4/sp800-63b.html |
| OWASP Secrets Management | cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet |
