---
name: "explain"
description: "Couche académique. Explique tout terme ou outil de Claude Code (skill, hook, workflow, script, MCP...) au niveau de la personne, avec une analogie, un exemple et la suite."
effort: low
argument-hint: "<terme> | list"
---

# /explain (édition française, miroir de SKILL.md)

Disponible à tout moment, pour tout niveau. À utiliser aussi de façon proactive : quand vous employez un terme que la personne n'a pas encore rencontré (voir `terms_seen` dans `~/.claude/kit/profile.json`), l'expliquer en une ligne, puis l'enregistrer.

## Procédure

1. Lire `~/.claude/kit/glossary/<langue>/README.md` (`en` ou `fr`, selon le profil ; `docs/glossary/` dans le dépôt du kit) et trouver la section du terme (`list` affiche tous les titres).
   Si absent, répondre de mémoire et dire que le glossaire n'a pas encore de fiche.
2. Lire `level` dans le profil. Adapter :
   - Découverte : analogie d'abord, sans jargon, un exemple concret, 6 lignes maximum.
   - Pratique : définition, exemple, quand l'utiliser.
   - Autonome : définition, compromis, où vivent les fichiers.
3. Terminer par « Voulez-vous le voir sur votre machine ? » et proposer une démo sûre, en lecture seule.
4. Ajouter le terme à `terms_seen`.

## Format de fiche (une section `##` par terme)

`Terme` / `En une phrase` / `Analogie` / `Exemple` / `Où ça vit` / `Voir aussi`.

## Règles

- Mots simples d'abord, mots précis ensuite.
- Ne jamais affirmer une fonction non vérifiée dans ce kit.
- Jamais de tiret cadratin.
