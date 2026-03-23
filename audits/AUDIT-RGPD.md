# Audit — Conformité RGPD

> Module d'audit SQWR Project Kit.
> Sources : Règlement UE 2016/679 (RGPD), CNIL (cnil.fr), European Data Protection Board (edpb.europa.eu), ICO (ico.org.uk).

---

## Fondements légaux

**Le RGPD (Règlement Général sur la Protection des Données) est obligatoire pour tout traitement de données personnelles de résidents EU** depuis le 25 mai 2018. Amendes : jusqu'à 4% du CA mondial ou 20M€. Sur 10 points critiques, un score ≥8/10 est requis avant mise en production grand public.

> Source : Règlement (UE) 2016/679 du Parlement européen — [eur-lex.europa.eu](https://eur-lex.europa.eu/legal-content/FR/TXT/?uri=CELEX%3A32016R0679)

---

## Instructions d'utilisation

Pour chaque dimension ci-dessous :
1. Vérifier l'implémentation actuelle
2. Scorer 0-10 selon le barème
3. Identifier les gaps
4. Prioriser selon le niveau de risque (🔴 critique / 🟡 important / 🟢 souhaitable)

---

## Dimensions d'audit

### D1 — Droits Utilisateurs Core (20 points)

**Poids : 20% du score total**

| Article | Droit | Implémenté | Points |
|---------|-------|------------|--------|
| Art. 15 | Droit d'accès — export des données personnelles (format JSON lisible) | ☐ | 0-5 |
| Art. 17 | Droit à l'oubli — suppression + anonymisation des PII | ☐ | 0-5 |
| Art. 20 | Droit à la portabilité — export format standard, machine-readable | ☐ | 0-5 |
| Art. 21 | Droit d'opposition — opt-out marketing/profiling | ☐ | 0-5 |

**Score D1 : ___/20**

#### Ce que ça implique techniquement

```typescript
// Art. 15 + 20 — Export données
// Route : GET /api/user/export
// Rate limit : 2/heure par IP
// Contenu : profile, messages, transactions, preferences
// Format : JSON horodaté avec export_version

// Art. 17 — Suppression compte
// Stratégie recommandée :
// - Anonymiser : nom, email, téléphone, bio → null
// - Anonymiser : messages → "[Message supprimé]"
// - Conserver : données financières (obligation légale 6 ans)
// - Supprimer : storage (avatars, documents)
// - Supprimer : compte auth
```

---

### D2 — Consentement & Collecte (15 points)

**Poids : 15% du score total**

| Article | Obligation | Implémenté | Points |
|---------|------------|------------|--------|
| Art. 6 | Base légale documentée pour chaque traitement (consentement / contrat / intérêt légitime) | ☐ | 0-5 |
| Art. 7 | Consentement granulaire, librement donné, retirable — cookie banner opt-in (pas opt-out) | ☐ | 0-5 |
| Art. 8 | Vérification d'âge minimum 16 ans (recommandé : 18 ans) à l'inscription | ☐ | 0-5 |

**Score D2 : ___/15**

#### Threshold article 8

```typescript
// ✅ Implémentation minimale conforme Article 8
const age = differenceInYears(new Date(), new Date(birthDate))
if (age < 18) {
  return { error: 'RGPD Art. 8 — Âge minimum 18 ans requis.' }
}
```

**Cookie consent — critères de conformité :**
- ✅ Opt-in (pas opt-out par défaut)
- ✅ Consentement granulaire par catégorie (essentiel / analytics / marketing)
- ✅ Timestamp du consentement stocké en DB
- ✅ Révocation possible à tout moment
- ❌ Pré-cochage des cases = NON conforme

---

### D3 — Transparence & Documentation (15 points)

**Poids : 15% du score total**

| Article | Obligation | Implémenté | Points |
|---------|------------|------------|--------|
| Art. 13 | Privacy Policy complète : identité du responsable, finalités, sous-traitants, durées de conservation | ☐ | 0-5 |
| Art. 13 | Sous-traitants nommés + mécanisme légal pour transferts hors EU (SCC si USA) | ☐ | 0-5 |
| Art. 5(1)(e) | Data retention policies documentées par type de donnée | ☐ | 0-5 |

**Score D3 : ___/15**

#### Template sous-traitants (Privacy Policy)

```markdown
| Sous-traitant | Pays | Rôle | Mécanisme légal |
|---------------|------|------|-----------------|
| Supabase Inc. | USA | Base de données, auth, stockage | DPA + SCC (Décision 2021/914) |
| Stripe Inc. | USA | Paiements | SCC + Privacy Shield successor |
| Sentry (Functional Software) | USA | Monitoring erreurs | SCC (Décision 2021/914) |
| Vercel Inc. | USA | Hébergement | DPA disponible sur vercel.com/legal/dpa |
```

#### Data retention policies minimales

| Type | Durée | Justification légale |
|------|-------|---------------------|
| Données financières | 6 ans | Code civil belge / français |
| Logs sécurité | 12 mois | Bonne pratique CNIL |
| Données marketing | 3 ans sans contact | Recommandation CNIL |
| Analytics | 13 mois | Standard GA4 |
| Sessions expirées | 24h | Nettoyage technique |

---

### D4 — Sécurité des Données (20 points)

**Poids : 20% du score total**

| Article | Obligation | Implémenté | Points |
|---------|------------|------------|--------|
| Art. 25 | Privacy by Design — données minimales collectées (pas de champs superflus) | ☐ | 0-5 |
| Art. 32 | Mesures techniques : chiffrement, RLS, rate limiting, HTTPS | ☐ | 0-5 |
| Art. 32 | Protection contre l'énumération d'emails (réponses génériques auth) | ☐ | 0-5 |
| Art. 32 | Aucun `console.log(email/password/token)` en production | ☐ | 0-5 |

**Score D4 : ___/20**

#### Checklist technique Art. 32

```bash
# Détecter les logs avec PII
grep -r "console.log" src/ | grep -i "email\|password\|token\|secret"

# Détecter les données sensibles non protégées
grep -r "SELECT \*" src/ --include="*.ts"  # Éviter SELECT * sur tables sensibles
```

---

### D5 — Notification d'Incidents (15 points)

**Poids : 15% du score total**

| Article | Obligation | Implémenté | Points |
|---------|------------|------------|--------|
| Art. 33 | Table `security_breaches` pour traçabilité interne des incidents | ☐ | 0-5 |
| Art. 33 | Process documenté pour notification autorité < 72h après détection | ☐ | 0-5 |
| Art. 34 | Process documenté pour notification utilisateurs si risque élevé | ☐ | 0-5 |

**Score D5 : ___/15**

#### Structure minimale table `security_breaches`

```sql
CREATE TABLE security_breaches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  detected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  severity TEXT CHECK (severity IN ('low', 'medium', 'high', 'critical')),
  affected_records INTEGER,
  data_types TEXT[],
  description TEXT,
  containment_actions TEXT,
  notified_authority BOOLEAN DEFAULT false,
  notified_at TIMESTAMPTZ,
  resolved_at TIMESTAMPTZ
);
```

**Contacts autorités de contrôle EU :**
| Pays | Autorité | Délai |
|------|----------|-------|
| Belgique | APD — apd-gba.be | <72h |
| France | CNIL — cnil.fr | <72h |
| UE (trans-frontalier) | EDPB — edpb.europa.eu | <72h |

---

### D6 — Pages Légales (15 points)

**Poids : 15% du score total**

| Obligation | Implémenté | Points |
|------------|------------|--------|
| Privacy Policy complète et accessible (lien en footer) | ☐ | 0-3 |
| Terms of Service / CGU | ☐ | 0-3 |
| Mentions légales (identité entreprise, numéro d'entreprise) | ☐ | 0-3 |
| Cookie Policy avec liste des cookies | ☐ | 0-3 |
| Données de contact pour exercer les droits | ☐ | 0-3 |

**Score D6 : ___/15**

---

## Calcul du Score Global

```
Score RGPD = (D1/20 × 20) + (D2/15 × 15) + (D3/15 × 15) + (D4/20 × 20) + (D5/15 × 15) + (D6/15 × 15)
           = Score sur 100
```

| Score | Niveau | Action |
|-------|--------|--------|
| ≥90/100 | ✅ Conforme | Audit de maintenance annuel |
| 75-89/100 | 🟡 Majoritairement conforme | Traiter les gaps dans les 30 jours |
| 60-74/100 | 🟠 Partiellement conforme | Ne pas lancer en production grand public |
| <60/100 | 🔴 Non conforme | **BLOQUER** le lancement — risque légal |

**Score cible avant production grand public : ≥80/100**

---

## Checklist pré-lancement

### 🔴 Bloquants (score <80 = ne pas lancer)

- [ ] Droits utilisateurs core implémentés (export + suppression — Art. 15, 17, 20)
- [ ] Privacy Policy complète avec sous-traitants et SCC pour transferts USA
- [ ] Cookie banner opt-in (pas opt-out)
- [ ] Vérification d'âge à l'inscription (Art. 8)
- [ ] Données financières conservées 6 ans, PII anonymisées après suppression compte
- [ ] Aucun `console.log(email/password)` en production

### 🟡 Importants (dans 30 jours post-lancement)

- [ ] Table `security_breaches` créée + process notification 72h documenté (Art. 34)
- [ ] Consentement stocké avec timestamp en DB (Art. 7)
- [ ] Protection énumération emails — réponses auth génériques
- [ ] Opt-out marketing emails (Art. 21)

### 🟢 Souhaitables (dans 90 jours)

- [ ] DPIA (Data Protection Impact Assessment) pour traitements à risque élevé (Art. 35)
- [ ] DPO désigné si traitement à grande échelle
- [ ] Dashboard admin pour auditer les sous-traitants

---

## Template Rapport d'Audit

```
RAPPORT AUDIT RGPD
Projet : [nom]
Date : [date]
Auditeur : [nom]

D1 — Droits utilisateurs    : ___/20
D2 — Consentement           : ___/15
D3 — Transparence           : ___/15
D4 — Sécurité               : ___/20
D5 — Notification incidents : ___/15
D6 — Pages légales          : ___/15
                              ------
SCORE GLOBAL                : ___/100

Gaps critiques (🔴) :
- [gap 1]
- [gap 2]

Plan d'action :
- [action 1] — Responsable : [nom] — Délai : [date]
- [action 2] — Responsable : [nom] — Délai : [date]
```

---

## Sources

| Référence | Lien |
|-----------|------|
| RGPD — Règlement UE 2016/679 | eur-lex.europa.eu/legal-content/FR/TXT/?uri=CELEX%3A32016R0679 |
| CNIL — Guide sécurité développeurs | cnil.fr/fr/la-securite-des-donnees-personnelles |
| EDPB — Guidelines | edpb.europa.eu/our-work-tools/our-documents/guidelines |
| ICO — GDPR Guide for developers | ico.org.uk/for-organisations/guide-to-data-protection |
| SCC — Décision Commission 2021/914 | eur-lex.europa.eu/eli/dec_impl/2021/914/oj |
| APD Belgique | apd-gba.be |
| CNIL France | cnil.fr |
