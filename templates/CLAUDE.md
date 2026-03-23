# [NOM DU PROJET] — Contrat IA

> Template universel — [Claude Code Standards Kit](https://github.com/samsam007b/claude-code-standards-kit) par [SQWR Studio](https://sqwr.be).
> Instructions : remplacer tous les `[À COMPLÉTER]` et supprimer les sections non pertinentes.

---

## Qui travaille avec toi

**[VOTRE NOM]** — [votre rôle, ex : fondateur / développeur / étudiant]

| Contact | Valeur |
|---------|--------|
| Email | [votre@email.com] |
| Email pro | [pro@votrestudio.com] |

**Ce projet appartient à :** [Votre studio / votre entreprise / personnel]

Contexte complet :
- Identité : `[CHEMIN_KIT]/IDENTITY-TEMPLATE.md` (à remplir avec vos informations)

---

## Ce projet

**Nom :** [À COMPLÉTER]
**Description :** [À COMPLÉTER — 1-2 phrases max]
**URL prod :** [À COMPLÉTER ou N/A]
**Statut :** [En développement / En production / Archivé]

**Stack :**
- [À COMPLÉTER — ex: Next.js 16 + TypeScript + Tailwind CSS + Supabase]

**Déploiement :**
- [À COMPLÉTER — ex: Vercel (auto depuis main)]

---

## Architecture

```
[À COMPLÉTER — arborescence des dossiers clés]
src/
├── app/          → Routes Next.js App Router
├── components/   → Composants réutilisables
├── lib/          → Utilitaires, config, helpers
└── types/        → Types TypeScript partagés
```

**Fichiers critiques :**

| Fichier | Rôle |
|---------|------|
| [À COMPLÉTER] | [rôle] |
| [À COMPLÉTER] | [rôle] |

---

## Contrats actifs

> Inclure ici les contrats pertinents pour ce projet.
> Fichiers source : `[CHEMIN_KIT]/contracts/`

- [ ] `CONTRACT-NEXTJS.md` — App Router, SSR, Server Components
- [ ] `CONTRACT-SUPABASE.md` — RLS, auth, migrations
- [ ] `CONTRACT-VERCEL.md` — Déploiement, env vars
- [ ] `CONTRACT-DESIGN.md` — Tailwind, design system, tokens
- [ ] `CONTRACT-TYPESCRIPT.md` — Typage strict
- [ ] `CONTRACT-ANTI-HALLUCINATION.md` — Données réelles uniquement

> Copier le contenu des contrats sélectionnés directement ici OU les lire via Read avant toute intervention sur ce projet.
> Chemin kit : `[CHEMIN_KIT]/contracts/`

---

## Règles absolues

> Ce que l'IA ne doit JAMAIS faire sur ce projet, spécifique à ce contexte.

### Ne jamais faire

- [À COMPLÉTER — ex: Modifier le schéma Supabase sans vérifier les RLS]
- [À COMPLÉTER — ex: Passer une page en `'use client'` sans justification]
- [À COMPLÉTER]

### Toujours faire

- [À COMPLÉTER — ex: Lancer `npm run build` avant tout commit]
- [À COMPLÉTER — ex: Vérifier le rendu SSR sur les pages SEO-critiques]
- [À COMPLÉTER]

---

## Historique des erreurs

> Tracker ici les erreurs détectées pour éviter leur répétition.
> Format : date | erreur | statut

| Date | Erreur | Statut |
|------|--------|--------|
| [JJ/MM/AAAA] | [description] | Corrigé / À corriger |

---

## ADR actifs

> Architecture Decision Records — les décisions techniques structurantes de ce projet.
> Template complet : `[CHEMIN_KIT]/frameworks/ADR-TEMPLATE.md`
> Fichiers ADR : `./docs/adr/`

| ADR | Décision | Statut |
|-----|----------|--------|
| ADR-001 | [À COMPLÉTER — ex: Choix Supabase] | Accepted |
| ADR-002 | [À COMPLÉTER — ex: Choix Vercel vs Railway] | Accepted |

*Créer un ADR dans `./docs/adr/` pour toute nouvelle décision architecturale significative.*

---

## SLO (Service Level Objectives)

> Définition de fiabilité cible. Template : `[CHEMIN_KIT]/frameworks/SLO-TEMPLATE.md`

| SLI | SLO cible | Mesure | Outil |
|-----|-----------|--------|-------|
| Uptime | [À COMPLÉTER — ex: 99.5%] | [actuel] | UptimeRobot |
| LCP p75 | ≤2.5s | [actuel] | Vercel Speed Insights |
| Error rate | ≤0.5% | [actuel] | Sentry |

*Error budget : [% SLO] × 30j = [X]h de downtime autorisé par mois*

---

## Tech Debt Tracker

> Dettes techniques connues, à traiter selon priorité.

| Dette | Impact | Priorité | Date détectée |
|-------|--------|---------|--------------|
| [À COMPLÉTER] | [ex: Performance] | P1/P2/P3 | [JJ/MM] |

---

## Notes de contexte

[À COMPLÉTER — informations importantes sur le projet que l'IA doit toujours avoir en tête]
