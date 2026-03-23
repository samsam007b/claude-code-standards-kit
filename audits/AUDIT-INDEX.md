# Audit Index — SQWR Project Kit

> Système d'audit inspiré du Starter Kit SQWR (Writing-Skills/INDEX.md).
> Principe : chaque règle est vérifiable, chaque score est mesurable.
> Format : checklist pondérée → score /100 par domaine → score global.

---

## Quand utiliser quel audit

| Situation | Audits à lancer |
|-----------|----------------|
| **Avant premier déploiement** | DEPLOYMENT + SECURITY + PERFORMANCE + ACCESSIBILITY + OBSERVABILITY |
| **Avant merge d'une feature** | CODE-QUALITY + SECURITY (si auth/DB) + DEPLOYMENT |
| **Revue mensuelle maintenance** | tous les audits |
| **Urgence sécurité** | SECURITY seul, en priorité absolue |
| **Incident production** | OBSERVABILITY + RESILIENCE (post-incident) |
| **Refonte design** | DESIGN + ACCESSIBILITY + PERFORMANCE |
| **Ajout d'un agent IA** | AI-GOVERNANCE + ANTI-HALLUCINATION (contrat) |
| **Nouveau projet lancé** | AI-GOVERNANCE + CODE-QUALITY + DESIGN |
| **Livraison client (UE)** | ACCESSIBILITY (EAA obligatoire) + SECURITY + DEPLOYMENT + RGPD |
| **Avant livraison client** | CLIENT-HANDOFF (→ frameworks/) + DEPLOYMENT + ACCESSIBILITY + SECURITY + RGPD |
| **Fin de sprint / release** | DEPLOYMENT (CHANGELOG mis à jour ?) + CODE-QUALITY |
| **Avant lancement produit/marque** | BRAND-STRATEGY + COMPETITIVE-AUDIT (→ frameworks/) |
| **Repositionnement ou rebranding** | BRAND-STRATEGY seul |
| **Grand public EU (données perso)** | RGPD ≥80/100 obligatoire avant mise en production |

---

## Seuils de blocage

| Score | Signification | Action |
|-------|--------------|--------|
| <50 | Critique | ❌ Bloquer le déploiement |
| 50-69 | Insuffisant | ⚠️ Corriger avant merge |
| 70-84 | Acceptable | Déploiement possible, plan d'amélioration requis |
| 85-94 | Bon | Déployer |
| 95-100 | Excellent | Déployer + documenter comme référence |

**Score SECURITY <70 = blocage absolu — aucune exception.**

---

## Scores par domaine (pondération globale — v2)

| Audit | Poids | Fichier | Seuil blocage |
|-------|-------|---------|--------------|
| **SECURITY** | 22% | `AUDIT-SECURITY.md` | <70 = BLOQUANT |
| **PERFORMANCE** | 18% | `AUDIT-PERFORMANCE.md` | <70 recommandé |
| **CODE-QUALITY** | 18% | `AUDIT-CODE-QUALITY.md` | <75 recommandé |
| **OBSERVABILITY** | 12% | `AUDIT-OBSERVABILITY.md` | <60 recommandé |
| **ACCESSIBILITY** | 12% | `AUDIT-ACCESSIBILITY.md` | <80 (légal EU) |
| **DESIGN** | 8% | `AUDIT-DESIGN.md` | <70 recommandé |
| **AI-GOVERNANCE** | 5% | `AUDIT-AI-GOVERNANCE.md` | <80 recommandé |
| **DEPLOYMENT** | 5% | `AUDIT-DEPLOYMENT.md` | Gate pré-prod |
| **RGPD** | — | `AUDIT-RGPD.md` | ≥80/100 avant prod grand public |
| **BRAND-STRATEGY** | — | `AUDIT-BRAND-STRATEGY.md` | Avant lancement / repositionnement |

**Score global = somme pondérée des 8 domaines pondérés.**
**RGPD et BRAND-STRATEGY sont des audits hors-pondération — obligatoires selon le contexte.**

**ACCESSIBILITY <80 = non-conforme European Accessibility Act (juin 2025) — obligation légale.**
**RGPD <80 = risque CNIL / ICO si traitement de données personnelles de résidents EU.**

---

## Format de score par audit

Chaque audit utilise ce format :

```
[ ] Item à vérifier ........................... (points)
[x] Item validé ................................ ✅ (points)
[-] Non applicable ............................. N/A
```

Score = (points obtenus / points applicables) × 100

---

## Séquençage recommandé

```
Audit SECURITY          → priorité absolue
       ↓
Audit OBSERVABILITY     → monitoring en place avant d'aller plus loin
       ↓
Audit PERFORMANCE       → Core Web Vitals
       ↓
Audit CODE-QUALITY      → TypeScript, tests, coverage
       ↓
Audit ACCESSIBILITY     → WCAG + EAA légal
       ↓
Audit DESIGN            → couleurs, typo, Gestalt
       ↓
Audit AI-GOVERNANCE     → CLAUDE.md, contrats, hallucinations
       ↓
Audit DEPLOYMENT        → gate finale avant prod
```

---

## Audit du Project Kit lui-même

Pour auditer la qualité du kit SQWR :

1. `bash scripts/verify-kit.sh --verbose` — intégrité automatique (0 erreur = pré-requis)
2. `AUDIT-AI-GOVERNANCE.md` — CLAUDE.md templates complets ?
3. `AUDIT-CODE-QUALITY.md` — Contrats TypeScript/Testing corrects ?
4. `AUDIT-DESIGN.md` — Contrat design scientifiquement ancré ?
5. Vérifier que chaque contrat cite ses sources

**Score cible du Project Kit (référentiel 2026) : ≥92/100**

---

## Frameworks disponibles (hors audit — outils complémentaires)

| Framework | Fichier | Usage |
|-----------|---------|-------|
| **Incident Response** | `frameworks/INCIDENT-RESPONSE.md` | Quand un service casse en prod |
| **ADR Template** | `frameworks/ADR-TEMPLATE.md` | Documenter les décisions architecturales |
| **SLO Template** | `frameworks/SLO-TEMPLATE.md` | Définir les objectifs de fiabilité |
| **Compliance EU** | `frameworks/COMPLIANCE-EU.md` | EU AI Act, EAA, RGPD, NIS2 |
| **Project Scoping** | `frameworks/PROJECT-SCOPING.md` | Avant toute nouvelle feature ou projet (Shape Up + Pre-mortem) |
| **Client Handoff** | `frameworks/CLIENT-HANDOFF.md` | Livraison finale à un client (5 catégories + SLA) |
| **Estimation** | `frameworks/ESTIMATION.md` | Avant engagement de délai (PERT + RCF + règle ×1.5) |
| **Dependency Management** | `frameworks/DEPENDENCY-MANAGEMENT.md` | Setup projet + revue mensuelle sécurité dépendances |
| **Brand Strategy** | `frameworks/BRAND-STRATEGY.md` | Positionnement, Golden Circle, archétypes — avant tout design |
| **Competitive Audit** | `frameworks/COMPETITIVE-AUDIT.md` | Analyse concurrentielle Blue Ocean + Nielsen avant lancement |
| **Campaign Strategy** | `frameworks/CAMPAIGN-STRATEGY.md` | SEE-THINK-DO-CARE, funnel, KPIs — pour tout lancement |
