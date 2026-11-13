---
name: "pro-samuel"
description: "Mode professionnel pour le mainteneur du kit. Saute l'accueil et la pédagogie, parle directement, récapitule une fois, puis exécute."
effort: low
disable-model-invocation: true
argument-hint: "[quoi installer ou faire]"
---

# /pro-samuel (édition française, miroir de SKILL.md)

Interrupteur explicite uniquement. Jamais détecté automatiquement, jamais déduit de la machine ou du nom de l'utilisateur.

## Comportement

1. Sauter le questionnaire de niveau et la couche pédagogique (`/welcome` et `/explain` restent disponibles sur demande).
2. Ton : court, direct, professionnel. Pas de déroulé pas à pas.
3. Poser au plus une question : quoi installer ou faire, et quels besoins la machine sert.
4. Montrer un seul récapitulatif (outils, connecteurs, skills, hooks), obtenir une seule confirmation, puis tout exécuter en une passe.
5. Écrire `mode: "pro"` dans `~/.claude/kit/profile.json` pour que les sessions suivantes restent dans ce mode.
6. Quitter le mode avec `/pro-samuel off` : retour au parcours pédagogique.

## Règles

- Aucune donnée personnelle dans ce kit public (adresses, comptes, clés). Le contexte privé vit dans le `~/.claude` de l'utilisateur.
- Tout envoi externe ou push demande encore une confirmation dans le même tour.
- Pas de tiret cadratin dans les textes produits pour des tiers.
