---
name: token-economy
description: Optimise les coûts et la délégation de modèles Claude Code — RTK compression shell, délégation Haiku/Sonnet/Opus, stratégie de contexte, réduction 3x validée empiriquement.
tags: [tokens, cost, optimization, delegation, haiku, claude-code, rtk]
model: haiku
---

# /token-economy — Optimisation Tokens & Coûts Claude Code

## Quand utiliser

- Analyser les coûts d'une session ou d'un workflow
- Décider quel modèle déléguer pour quelle tâche
- Réduire les tokens d'une commande ou d'un prompt
- Auditer l'usage RTK et les gains de compression

## Hiérarchie de délégation (empirique — réduction 3.2x validée)

| Tâche | Modèle | Pourquoi |
|-------|--------|---------|
| Recherche web, résumés, lire des docs | **Haiku** | 20x moins cher, suffisant pour la synthèse |
| Écriture de code, modifications | **Sonnet** | Rapport qualité/coût optimal |
| Architecture, plans complexes, raisonnement | **Opus** | Quand Sonnet est insuffisant |
| Jamais Haiku pour : écriture de code critique | — | Qualité insuffisante, économie illusoire |

## RTK — Rust Token Killer (83.7% compression shell)

RTK intercepte les sorties de commandes shell et compresse avant injection dans le contexte :
- `git status` → RTK filtre les fichiers non pertinents
- `npm test` → RTK extrait uniquement les échecs
- `git log` → RTK résume les commits

```bash
rtk gain              # analytics de compression
rtk gain --history    # historique des commandes et gains
rtk discover          # analyse l'historique Claude pour opportunités manquées
```

## Stratégie de contexte

### Ce qui consomme le plus
1. Fichiers lus entiers non nécessaires (utiliser `Read` avec `offset/limit`)
2. Résultats de commandes shell verbeux (→ RTK)
3. Recherches larges sans filtrage (→ subagent Haiku d'abord)
4. Conversations longues sans compaction (→ `/compact`)

### Règle 2 phases (obligatoire dans ce setup)
1. **Phase 1** : Subagent Haiku → résumé max 400 tokens
2. **Phase 2** : Opus lit le résumé → deep-dive sélectif sur 1-3 URLs

### Prompt caching
- Le cache Anthropic a un TTL de 5 minutes
- Pour les boucles `/loop` : délai < 300s pour rester dans le cache
- `CLAUDE_CODE_MAX_OUTPUT_TOKENS=128000` dans .zshrc pour les outputs longs

## Audit d'un workflow

Pour analyser le coût réel d'une session :
```bash
ccusage daily          # coût du jour
ccusage session        # coût de la session courante
rtk gain --history     # commandes compressées par RTK
```

## Format de sortie

```
## Token Economy Audit — [workflow/session]

### Coût actuel : $X.XX
### Coût optimisé estimé : $X.XX (-XX%)

### Délégations à revoir
| Tâche | Modèle actuel | Modèle recommandé | Économie |
|-------|-------------|------------------|---------|

### Compressions RTK manquées
[commandes qui auraient dû passer par RTK]

### Actions
1. [action spécifique]
```
