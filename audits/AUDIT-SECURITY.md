# Audit Sécurité

> Basé sur OWASP Top 10, NIST SP 800-63B, CWE Top 25.
> Score : /100 | Seuil de blocage : <70

---

## Section 1 — Contrôle d'accès (30 points)

- [ ] RLS activé sur toutes les tables avec données utilisateurs .............. (10)
- [ ] Middleware auth vérifie l'authentification sur toutes les routes protégées . (8)
- [ ] Aucune route protégée accessible sans authentification valide ............ (7)
- [ ] Politique RLS séparée par opération (SELECT/INSERT/UPDATE/DELETE) ....... (5)

**Sous-total : /30**

---

## Section 2 — Gestion des secrets (20 points)

- [ ] Aucune clé secrète dans le code source ou l'historique git ............. (8)
- [ ] `SUPABASE_SERVICE_ROLE_KEY` jamais préfixée `NEXT_PUBLIC_` .............. (7)
- [ ] `.env.local` dans `.gitignore` et non commité .......................... (5)

**Sous-total : /20**

---

## Section 3 — Protection XSS/Injection (20 points)

- [ ] `dangerouslySetInnerHTML` absent (ou justifié + sanitisé) ............... (8)
- [ ] Toutes les entrées utilisateur validées avec Zod avant DB ............... (7)
- [ ] URLs fournies par l'utilisateur validées (pas de `javascript:`) ......... (5)

**Sous-total : /20**

---

## Section 4 — Dépendances et supply chain (15 points)

- [ ] `npm audit --audit-level=critical` passe sans vulnérabilité critique .... (8)
- [ ] `npm audit --audit-level=high` passe ou vulnérabilités documentées ...... (7)

**Sous-total : /15**

---

## Section 5 — Headers de sécurité (15 points)

- [ ] `X-Content-Type-Options: nosniff` configuré .............................. (3)
- [ ] `X-Frame-Options: DENY` configuré ........................................ (3)
- [ ] `Strict-Transport-Security` configuré (HTTPS forcé) ..................... (3)
- [ ] `Referrer-Policy` configuré .............................................. (3)
- [ ] `Permissions-Policy` configuré ........................................... (3)

**Sous-total : /15**

---

## Score total : /100

| Section | Score | /Total |
|---------|-------|--------|
| Contrôle d'accès | | /30 |
| Secrets | | /20 |
| XSS/Injection | | /20 |
| Dépendances | | /15 |
| Headers | | /15 |
| **TOTAL** | | **/100** |

**Seuil : <70 = déploiement bloqué**

---

## Outil de vérification rapide

```bash
npm audit --audit-level=critical   # Dépendances
git log -S "service_role" --all    # Secrets dans git
grep -r "dangerouslySetInnerHTML" src/  # XSS risk
```
