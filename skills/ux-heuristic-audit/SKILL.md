---
name: ux-heuristic-audit
description: Auditer une interface selon les heuristiques Nielsen et Laws of UX. Rapport priorisé avec problèmes et recommandations.
tags: [ux, audit, frontend, heuristics, nielsen]
model: sonnet
---

# UX Heuristic Audit Skill

## Description
Audite une interface ou composant selon les principes scientifiques UX (Nielsen Heuristics + Laws of UX). Génère un rapport avec problèmes identifiés et recommandations priorisées.

## Usage
```
/ux-heuristic-audit [file_path_or_component_name]
```

## Workflow

1. **Lecture du Composant/Page**
   - Lit le code source
   - Analyse structure, props, states
   - Identifie éléments UI (buttons, inputs, cards, etc.)

2. **Audit Selon Nielsen's 10 Heuristics**
   - #1 Visibility of System Status
   - #2 Match Between System & Real World
   - #3 User Control & Freedom
   - #4 Consistency & Standards
   - #5 Error Prevention
   - #6 Recognition Rather Than Recall
   - #7 Flexibility & Efficiency
   - #8 Aesthetic & Minimalist Design
   - #9 Help Users Recognize, Diagnose & Recover from Errors
   - #10 Help & Documentation

3. **Audit Selon Laws of UX**
   - Miller's Law (7±2 éléments visibles)
   - Hick's Law (nombre de choix)
   - Fitts's Law (taille cibles interactives)
   - Tesler's Law (distribution complexité)
   - Information Scent (labels descriptifs)

4. **Génération du Rapport**
   - Liste problèmes par sévérité (Critical, High, Medium, Low)
   - Recommandations spécifiques
   - Exemples de code avant/après
   - Score UX global (0-100)

## Output Format

```markdown
# UX Audit Report - [Component Name]

**Date**: [Date]
**Auditor**: Claude (Scientific UX Framework)
**Score UX Global**: [X]/100

---

## Executive Summary

[Résumé des findings principaux]

---

## Critical Issues (Severity 5/5)

### Issue #1: [Titre]
- **Heuristic Violated**: Nielsen #X or Law of UX
- **Current State**: [Description du problème]
- **User Impact**: [Impact sur l'utilisateur]
- **Recommendation**: [Solution proposée]
- **Code Example**:
  ```tsx
  // Before (problematic)
  [code actuel]

  // After (fixed)
  [code corrigé]
  ```

---

## High Priority Issues (Severity 4/5)

[...]

---

## Medium Priority Issues (Severity 3/5)

[...]

---

## Low Priority Issues (Severity 2/5)

[...]

---

## Strengths (What works well)

- [Points forts identifiés]

---

## Recommendations Summary

| Priority | Issue | Estimated Effort | Impact |
|----------|-------|------------------|--------|
| P0 | [Issue] | [Effort] | [Impact] |

---

## Next Steps

1. [Action prioritaire]
2. [Action suivante]
```

## Exemples

### Exemple 1: Audit d'une sidebar de filtres

```bash
/ux-heuristic-audit components/explore/FilterSidebar.tsx
```

**Findings**:
- ❌ Miller's Law violated: 25+ checkboxes visibles (> 7±2)
- ❌ Information Scent weak: Label "Options" trop vague
- ✅ Consistency good: Icons uniformes

### Exemple 2: Audit d'une page complète

```bash
/ux-heuristic-audit app/seeker/explore/page.tsx
```

**Findings**:
- ❌ Visibility: Pas de feedback sur nombre de résultats
- ❌ Hick's Law: Trop de choix simultanés (paralysie)
- ✅ Aesthetic & Minimalist: Design épuré

## Configuration

Le skill utilise les références dans `docs/ux-guidelines/`:
- `ux-checklist-before-feature.md`
- `ux-scientific-research-complex-interfaces.md`

## Output Location

Les rapports sont sauvegardés dans :
```
docs/ux-audits/[component-name]-audit-[date].md
```
