# Framework — Architecture Decision Records (ADR)

> Framework SQWR Project Kit — mémoire institutionnelle des décisions architecturales.
> Sources : Michael Nygard (2011), ADR GitHub (adr.github.io), AWS ADR Best Practices, GOV.UK ADR Framework.
> Principe : documenter POURQUOI, pas seulement QUOI.

---

## Pourquoi les ADRs ?

**Le problème :** Dans 6 mois, pourquoi a-t-on choisi Supabase plutôt que PlanetScale ? Pourquoi Plausible plutôt que Mixpanel ? Pourquoi Vercel plutôt que Railway ? Ces décisions existent dans la mémoire des fondateurs. Quand un collaborateur arrive, ou quand on veut revenir sur une décision, le contexte est perdu.

**La solution :** Un ADR (Architecture Decision Record) capture une décision significative avec son contexte, les alternatives considérées, et les conséquences. Immuable. Versionné avec le code. Retrouvable.

> *"An ADR is not a requirements document. It's a record of a decision that was made."* — Michael Nygard

---

## Convention de stockage

```
[projet]/
└── docs/
    └── adr/
        ├── ADR-001-choix-supabase.md
        ├── ADR-002-analytics-plausible.md
        ├── ADR-003-tailwind-vs-styled-components.md
        └── ...
```

**Règle d'immuabilité :** Un ADR existant ne s'édite jamais. Si une décision change :
1. Créer un nouvel ADR : `ADR-XXX-remplacement-de-ADR-NNN.md`
2. Mettre le statut de l'ancien ADR à `Superseded by ADR-XXX`

---

## Template ADR (format Michael Nygard)

```markdown
# ADR-[NNN]: [Titre court et descriptif]

**Date :** [JJ/MM/AAAA]
**Statut :** [Proposed | Accepted | Deprecated | Superseded by ADR-XXX]
**Décideur(s) :** [Samuel / Samuel + Joakim / Samuel + Alexandre]

---

## Contexte

[Décrivez la situation ou le problème qui nécessite cette décision.
Quel est le contexte technique, métier, ou organisationnel ?
Quelles contraintes existent ?]

## Alternatives considérées

| Option | Avantages | Inconvénients |
|--------|-----------|--------------|
| **[Option A]** | [+] | [-] |
| **[Option B]** | [+] | [-] |
| **[Option C]** | [+] | [-] |

## Décision

[Quelle option a été choisie et pourquoi.]

**Option retenue : [Option X]**

Raisons :
- [raison 1]
- [raison 2]

## Conséquences

**Ce qui devient plus facile :**
- [conséquence positive 1]

**Ce qui devient plus difficile (trade-offs) :**
- [trade-off 1]

**Ce qui doit être fait à la suite de cette décision :**
- [ ] [action concrète]

## Révision possible si

[Conditions dans lesquelles cette décision devrait être réévaluée]
Ex: "Si le volume dépasse X requêtes/jour" ou "Si le coût mensuel dépasse Y€"
```

---

## Cycle de vie des statuts

```
Proposed → Accepted → Deprecated
                  ↘ Superseded by ADR-XXX
```

| Statut | Signification |
|--------|--------------|
| **Proposed** | En discussion, pas encore validée |
| **Accepted** | Décision active, en vigueur |
| **Deprecated** | N'est plus pertinente (technologie abandonnée, contexte changé) |
| **Superseded by ADR-NNN** | Remplacée par un nouvel ADR |

---

## ADRs fondateurs SQWR — à créer pour chaque projet

Ces décisions ont déjà été prises implicitement. Les documenter crée la mémoire institutionnelle.

| Décision | ADR suggéré |
|----------|-------------|
| Choix de Supabase vs alternatives | `ADR-001-database-supabase.md` |
| Choix de Vercel vs Railway/Render | `ADR-002-hosting-vercel.md` |
| Choix de Plausible vs Google Analytics | `ADR-003-analytics-plausible.md` |
| Choix de Claude vs OpenAI pour le dev | `ADR-004-ai-dev-claude-code.md` |
| Choix de Next.js App Router vs Pages Router | `ADR-005-nextjs-app-router.md` |
| Choix de Tailwind vs CSS Modules | `ADR-006-styling-tailwind.md` |

---

## Exemple complet — ADR-001

```markdown
# ADR-001: Supabase comme base de données

**Date :** 15/01/2025
**Statut :** Accepted
**Décideur(s) :** Samuel Baudon

---

## Contexte

izzico nécessite une base de données PostgreSQL avec authentification intégrée,
stockage de fichiers, et des politiques d'accès granulaires par rôle utilisateur
(Seekers, Residents, Owners). Budget initial : bootstrapé, pas de DevOps dédié.

## Alternatives considérées

| Option | Avantages | Inconvénients |
|--------|-----------|--------------|
| **Supabase** | Auth + DB + Storage intégré, RLS natif, SDK JS excellent, tier gratuit généreux | Vendor lock-in, prix scalabilité |
| **PlanetScale** | Scalabilité MySQL excellente, branching | Pas d'auth natif, pas de storage, pas de RLS |
| **Firebase** | Mature, Google ecosystem | NoSQL = migration difficile, prix imprévisible |

## Décision

**Option retenue : Supabase**

Raisons :
- RLS natif = sécurité multi-tenant sans infrastructure supplémentaire
- Auth, Storage, Realtime dans le même service = moins de pièces mobiles
- PostgreSQL = migration possible vers tout hébergeur Postgres si nécessaire
- SDK Next.js + SSR = compatible avec notre stack

## Conséquences

**Ce qui devient plus facile :**
- Gestion des permissions par rôle (RLS)
- Auth sans serveur tiers

**Trade-offs :**
- Vendor lock-in sur les fonctionnalités Supabase-spécifiques (Edge Functions, Realtime)
- Coût scalabilité à surveiller au-delà de 50k MAU

## Révision possible si

Prix Supabase dépasse 500€/mois ou si des limitations techniques bloquantes apparaissent
```

---

## Sources

| Référence | Source |
|-----------|--------|
| Michael Nygard — ADR original | cognitect.com/blog/2011/11/15/documenting-architecture-decisions |
| ADR GitHub | adr.github.io |
| AWS ADR Best Practices | aws.amazon.com/blogs/architecture/master-architecture-decision-records-adrs-best-practices |
| Microsoft Azure Well-Architected | learn.microsoft.com/en-us/azure/well-architected/architect-role/architecture-decision-record |
| GOV.UK ADR Framework | gov.uk/government/publications/architectural-decision-record-framework |
