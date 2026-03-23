# Contrat — Sécurité

> Module de contrat SQWR Project Kit.
> Sources : OWASP Top 10, NIST SP 800-63B, CWE Top 25, Cloudflare.

---

## Fondements scientifiques

**Broken Access Control** est la vulnérabilité #1 de l'OWASP Top 10 (données 2021, mise à jour 2024). 94% des applications testées présentent une forme de contrôle d'accès défaillant. La sécurité ne s'ajoute pas après coup — elle se conçoit dès l'architecture.

> Source : [OWASP Top 10 — owasp.org/www-project-top-ten](https://owasp.org/www-project-top-ten/)

---

## 1. OWASP Top 10 — Mitigations pour Next.js + Supabase

| # | Vulnérabilité | Mitigation SQWR |
|---|--------------|----------------|
| **A01** | Broken Access Control | RLS Supabase activé + middleware auth sur toutes routes protégées |
| **A02** | Cryptographic Failures | Pas de données sensibles en clair, HTTPS obligatoire, cookies HttpOnly |
| **A03** | Injection | Zod validation sur toutes entrées + Supabase parameterized queries |
| **A04** | Insecure Design | Threat modeling avant implémentation features auth |
| **A05** | Security Misconfiguration | Headers sécurité, RLS enabled, env vars jamais exposées |
| **A06** | Vulnerable Components | `npm audit` en CI, SLA <48h pour critical |
| **A07** | Auth Failures | Sessions courtes, refresh token rotation, pas de localStorage |
| **A09** | Logging Failures | Erreurs loggées (sans données sensibles), alertes sur events suspects |

---

## 2. Cross-Site Scripting (XSS)

### Ne jamais faire

```tsx
// ❌ Injection directe de HTML utilisateur — vulnérabilité critique
<div dangerouslySetInnerHTML={{ __html: userInput }} />

// ❌ Interpolation non échappée dans href
<a href={userProvidedUrl}>Link</a>  // Possible javascript: protocol injection
```

### Toujours faire

```tsx
// ✅ React échappe automatiquement — pas de dangerouslySetInnerHTML
<div>{userInput}</div>

// ✅ Valider les URLs utilisateur
function sanitizeUrl(url: string): string {
  try {
    const parsed = new URL(url)
    if (!['http:', 'https:'].includes(parsed.protocol)) return '#'
    return url
  } catch { return '#' }
}
<a href={sanitizeUrl(userProvidedUrl)}>Link</a>

// ✅ Content Security Policy (next.config.js)
const ContentSecurityPolicy = `
  default-src 'self';
  script-src 'self' 'unsafe-eval' 'unsafe-inline';
  style-src 'self' 'unsafe-inline';
  img-src 'self' blob: data:;
  font-src 'self';
`
```

---

## 3. Cross-Site Request Forgery (CSRF)

Next.js App Router + Supabase avec cookies `SameSite=Lax` protège contre la majorité des CSRF.

```typescript
// Vérification supplémentaire pour Server Actions sensibles
export async function sensitiveAction(formData: FormData) {
  const origin = headers().get('origin')
  if (origin !== process.env.NEXT_PUBLIC_APP_URL) {
    throw new Error('CSRF check failed')
  }
  // Logique...
}
```

---

## 4. Injection (SQL, LDAP, OS)

**Supabase utilise automatiquement des prepared statements via PostgREST.** Risque principal = construire du SQL manuellement.

```typescript
// ❌ JAMAIS de SQL construit avec des inputs utilisateur
const { data } = await supabase.rpc(`SELECT * FROM projects WHERE name = '${name}'`)

// ✅ API Supabase native = parameterized par défaut
const { data } = await supabase.from('projects').select('*').eq('name', name)

// ✅ Validation Zod avant toute opération DB
const validated = ProjectSchema.parse(input)  // throw si invalide
```

---

## 5. Security Headers (next.config.js)

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          { key: 'X-Content-Type-Options', value: 'nosniff' },
          { key: 'X-Frame-Options', value: 'DENY' },
          { key: 'X-XSS-Protection', value: '1; mode=block' },
          { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
          { key: 'Permissions-Policy', value: 'camera=(), microphone=(), geolocation=()' },
          {
            key: 'Strict-Transport-Security',
            value: 'max-age=63072000; includeSubDomains; preload',
          },
        ],
      },
    ]
  },
}
```

---

## 6. Dependency Scanning

```bash
# En CI/CD (GitHub Actions) — bloquer sur vulnerabilities critiques
npm audit --audit-level=critical

# Localement — rapport complet
npm audit

# Fix automatique (attention aux breaking changes)
npm audit fix
```

**SLA de correction :**
| Sévérité | SLA |
|----------|-----|
| **Critical** | <48h |
| **High** | <1 semaine |
| **Medium** | Sprint suivant |
| **Low** | Backlog |

---

## 7. Gestion des secrets

```bash
# ✅ Rotation des clés Supabase si compromises
# Aller dans Supabase Dashboard → Settings → API → Rotate keys

# ✅ Vérifier qu'aucun secret n'est dans git
git log -S "SUPABASE_SERVICE" --all  # Recherche dans l'historique git
```

**Règle NIST SP 800-63B :** ne pas faire de rotation sur calendrier fixe. Rotation uniquement si compromission suspectée.

---

## 8. Incident Response (3 étapes)

**En cas de compromission détectée :**

1. **Contenir** (0-1h)
   - Invalider toutes les sessions actives (Supabase Auth → Invalidate all tokens)
   - Rotationner les clés API exposées
   - Révoquer les accès suspects

2. **Analyser** (1-24h)
   - Identifier le vecteur d'attaque
   - Évaluer les données compromises
   - Documenter la timeline

3. **Communiquer** (selon RGPD)
   - Notification CNIL si données personnelles compromises (< 72h)
   - Communication aux utilisateurs affectés si nécessaire

---

## 9. Conformité RGPD — Obligations techniques

> Sources : Règlement UE 2016/679 (RGPD), CNIL (cnil.fr), European Data Protection Board (edpb.europa.eu)

**Applicable à tout projet traitant des données personnelles de résidents EU.**

### 9.1 Article 8 — Vérification d'âge

**Seuil légal : 16 ans minimum sans consentement parental (implémentation recommandée : 18 ans).**

```typescript
// ✅ Vérification âge à l'inscription (Article 8 RGPD)
const birthDate = new Date(input.birthDate)
const age = differenceInYears(new Date(), birthDate)
if (age < 18) {
  return NextResponse.json(
    { error: 'Vous devez avoir 18 ans ou plus pour vous inscrire.' },
    { status: 400 }
  )
}
```

**Règles :**
- Champ `birthDate` obligatoire au signup
- Vérification `age >= 18` côté serveur (pas uniquement client)
- Documenter dans CGU : condition d'âge minimum

### 9.2 Article 34 — Notification de violation de données

**Seuil : 72 heures maximum pour notifier l'autorité de contrôle (CNIL/APD).**

```sql
-- Table obligatoire pour traçabilité des incidents
CREATE TABLE security_breaches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  detected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  severity TEXT CHECK (severity IN ('low', 'medium', 'high', 'critical')),
  affected_records INTEGER,
  data_types TEXT[],      -- ex: ['email', 'phone', 'bank_info']
  description TEXT,
  containment_actions TEXT,
  notified_authority BOOLEAN DEFAULT false,
  notified_at TIMESTAMPTZ,
  notified_users BOOLEAN DEFAULT false,
  resolved_at TIMESTAMPTZ
);
```

**Process :**
1. Incident détecté → log dans `security_breaches` immédiatement
2. Évaluer si données personnelles affectées
3. Si OUI → notifier autorité nationale (CNIL/APD) **< 72h** après détection
4. Si risque élevé pour individus → notifier les utilisateurs affectés sans délai

### 9.3 Articles 44-49 — Transferts internationaux (Schrems II)

**Applicable lorsque des sous-traitants US traitent des données EU.**

| Sous-traitant | Pays | Mécanisme légal requis |
|---------------|------|----------------------|
| Stripe Inc. | USA | Standard Contractual Clauses (SCC) |
| Sentry (Functional Software) | USA | Standard Contractual Clauses (SCC) |
| Vercel Inc. | USA | SCC ou DPA EU |
| Supabase Inc. | USA | DPA disponible sur supabase.com/dpa |

**Obligations dans la Privacy Policy :**
```markdown
Nos sous-traitants situés aux États-Unis traitent vos données
sur la base des Clauses Contractuelles Types (CCT/SCC)
approuvées par la Commission européenne (Décision 2021/914).
```

**Ne jamais :** nommer des sous-traitants US sans mentionner le mécanisme légal de transfert.

### 9.4 Circuit Breaker pour Rate Limiter

**Problème :** Un rate limiter "fail-open" (laisse passer si Redis tombe) expose à des attaques DoS en cas de panne Redis.

```typescript
// ✅ Pattern circuit breaker avec fallback mémoire
import { Ratelimit } from '@upstash/ratelimit'
import { Redis } from '@upstash/redis'

// Fallback en mémoire si Redis indisponible
const MEMORY_STORE = new Map<string, { count: number; reset: number }>()

async function checkRateLimit(ip: string, limit: number, windowMs: number): Promise<boolean> {
  try {
    // Tentative Redis
    const ratelimit = new Ratelimit({
      redis: Redis.fromEnv(),
      limiter: Ratelimit.slidingWindow(limit, `${windowMs}ms`),
    })
    const { success } = await ratelimit.limit(ip)
    return success
  } catch {
    // Fallback mémoire si Redis indisponible (fail-closed)
    const now = Date.now()
    const entry = MEMORY_STORE.get(ip)
    if (!entry || entry.reset < now) {
      MEMORY_STORE.set(ip, { count: 1, reset: now + windowMs })
      return true
    }
    if (entry.count >= limit) return false  // Bloquer (fail-closed)
    entry.count++
    return true
  }
}
```

### 9.5 Data Retention Policies

**RGPD Article 5(1)(e) — Limitation de la conservation.**

| Type de donnée | Durée de rétention | Justification |
|----------------|-------------------|---------------|
| Données financières (paiements) | 6 ans | Obligation légale comptable |
| Logs d'audit sécurité | 12 mois | Détection incidents |
| Messages utilisateurs | Durée du compte + 30 jours | Continuité service |
| Analytics (GA) | 13 mois | Standard Google Analytics |
| Tokens de session expirés | 24 heures | Nettoyage automatique |
| Données compte supprimé | Anonymisation immédiate | Art. 17 droit à l'oubli |

```sql
-- Cleanup automatique recommandé (cron Supabase)
DELETE FROM audit_logs WHERE created_at < NOW() - INTERVAL '12 months';
DELETE FROM analytics_events WHERE created_at < NOW() - INTERVAL '13 months';
```

### 9.6 Protection contre l'énumération d'emails

**Principe :** ne jamais révéler si un email existe ou non — prévient les attaques de reconnaissance.

```typescript
// ✅ Réponse générique indépendante du résultat
export async function POST(req: Request) {
  const { email } = await req.json()

  // Toujours le même délai (prévient timing attacks)
  await new Promise(resolve => setTimeout(resolve, 300))

  try {
    await createUser(email) // peut échouer silencieusement
  } catch {
    // Ne jamais exposer "cet email est déjà utilisé"
  }

  // Même réponse, succès ou échec
  return NextResponse.json({
    message: 'Si cet email est valide, vous recevrez un lien de confirmation.'
  })
}
```

---

## 10. Checklist sécurité pré-déploiement

- [ ] `npm audit --audit-level=critical` passe
- [ ] RLS activé sur toutes les tables avec données utilisateurs
- [ ] Aucune clé secrète dans le code ou `.env.example`
- [ ] Security headers configurés dans `next.config.js`
- [ ] `dangerouslySetInnerHTML` absent (ou justifié)
- [ ] Validation Zod sur tous les inputs externes
- [ ] Auth middleware sur toutes les routes protégées
- [ ] HTTPS configuré (Vercel par défaut)
- [ ] Vérification d'âge implémentée si données personnelles mineurs possibles (RGPD Art. 8)
- [ ] Table `security_breaches` créée pour traçabilité incidents (RGPD Art. 34)
- [ ] Sous-traitants US documentés avec mécanisme SCC dans Privacy Policy (RGPD Art. 44-49)
- [ ] Rate limiter avec circuit breaker (pas de fail-open)
- [ ] Data retention policies documentées par type de donnée (RGPD Art. 5)
- [ ] Réponses auth génériques (pas d'email enumeration)

---

## 12. Risques IA & Supply Chain (2025-2026)

> Sources : OWASP LLM Top 10 2025, The Register (avril 2025), Trend Micro, Anthropic Research, Veracode 2025.

### Slopsquatting — menace active sur les projets IA-assistés

**Les LLMs hallucinent des packages NPM/PyPI inexistants dans 19.7% des cas** (testé sur 576,000 échantillons, 16 modèles — The Register, avril 2025). Des attaquants enregistrent ces noms avec du code malveillant. Un `npm install` sur une suggestion IA sans vérification peut installer un malware.

**Seth Larson (Python Software Foundation security lead) a nommé ce vecteur "slopsquatting".**

**Protocole de vérification obligatoire (tout package suggéré par IA) :**

```bash
# Avant tout npm install suggéré par Claude/ChatGPT/Copilot :

# 1. Vérifier que le package existe sur npmjs.com
npm info <package-name>

# 2. Vérifier le nombre de téléchargements (packages légitimes = millions/semaine)
npm info <package-name> downloads-per-week 2>/dev/null || echo "Vérifier sur npmjs.com"

# 3. Vérifier la date de création (package créé récemment = suspect)
npm info <package-name> time.created

# 4. Vérifier le repo GitHub lié
npm info <package-name> repository

# 5. Scanner après installation
npm audit
```

**Règles :**
- Tout package NPM/PyPI suggéré par une IA doit être vérifié manuellement avant installation
- Packages avec <1000 téléchargements/semaine → vérification renforcée du code source
- Ne jamais copier-coller un `npm install` depuis un output IA sans vérifier l'existence du package

### AI-Generated Code Review Checklist

**Veracode 2025 GenAI Code Security Report : 45% du code généré par IA contient des failles de sécurité.** Les 5 patterns les plus fréquents à vérifier systématiquement :

| Pattern | Vérification |
|---------|-------------|
| **Broken Authentication** | Tokens exposés ? Pas de auth sur routes protégées ? |
| **Injection** | Inputs validés avec Zod ? Pas de SQL construit manuellement ? |
| **Exposition de données sensibles** | Variables d'env pas dans le code ? Pas de NEXT_PUBLIC_ sur secrets ? |
| **Missing Access Control** | RLS actif ? Auth middleware sur toutes les routes ? |
| **Insecure Direct Object References** | URLs avec IDs → vérification propriété en DB ? |

**Process de review du code IA :**
1. Lire le code généré ligne par ligne (ne pas juste "tester si ça marche")
2. Appliquer la checklist ci-dessus avant tout commit
3. Faire tourner `npm audit` après installation de nouveaux packages
4. Utiliser `grep -r "dangerouslySetInnerHTML\|eval(\|innerHTML" src/` pour détecter les injections HTML

### RAG Poisoning — menace pour les KBs CozyGrowth/izzico

**Anthropic Research (2025) : 5 documents soigneusement craftés suffisent à manipuler les réponses IA 90% du temps** dans un système RAG. Source : CSA 2025 "AI Security Threats".

**Mitigations :**

```typescript
// Validation des documents avant injection en KB
function validateKBDocument(doc: string): boolean {
  // Détecter les tentatives d'injection de prompts dans les documents
  const injectionPatterns = [
    /ignore (all |previous |above )?instructions/i,
    /you are now/i,
    /system prompt/i,
    /\[INST\]/i,
    /<\|im_start\|>/i,
  ]

  return !injectionPatterns.some(pattern => pattern.test(doc))
}

// Pour CozyGrowth : valider chaque document KB avant insertion
function addToKnowledgeBase(doc: string, metadata: KBMetadata) {
  if (!validateKBDocument(doc)) {
    throw new Error('Document KB rejeté : tentative d\'injection détectée')
  }
  // Insertion normale...
}
```

**Sources :**

| Référence | Source |
|-----------|--------|
| OWASP LLM Top 10 2025 | genai.owasp.org/llmrisk |
| Slopsquatting — The Register | theregister.com/2025/04/12/ai_code_suggestions_sabotage_supply_chain |
| Slopsquatting — Trend Micro | trendmicro.com/vinfo/us/security/news/slopsquatting |
| AI Code Security — Veracode | veracode.com/blog/research/state-of-software-security-genai |
| RAG Poisoning — Anthropic | anthropic.com/research |
| OWASP LLM03:2025 Supply Chain | genai.owasp.org/llmrisk/llm032025-supply-chain |

---

## 13. Sources

| Référence | Lien |
|-----------|------|
| OWASP Top 10 | owasp.org/www-project-top-ten |
| OWASP Top 10:2025 | owasptopten.org |
| NIST SP 800-63B | pages.nist.gov/800-63-4/sp800-63b.html |
| CWE Top 25 | cwe.mitre.org/top25 |
| OWASP Cheat Sheets | cheatsheetseries.owasp.org |
| Cloudflare — OWASP Top 10 | cloudflare.com/learning/security/threats/owasp-top-10 |
| RGPD — Règlement UE 2016/679 | eur-lex.europa.eu/legal-content/FR/TXT/?uri=CELEX%3A32016R0679 |
| CNIL — Guide RGPD développeur | cnil.fr/fr/la-securite-des-donnees-personnelles |
| EDPB — Guidelines transferts internationaux | edpb.europa.eu/our-work-tools/our-documents/guidelines |
| SCC — Décision Commission 2021/914 | eur-lex.europa.eu/eli/dec_impl/2021/914/oj |
