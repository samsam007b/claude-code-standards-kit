# Contributing to SQWR Project Kit

Merci de contribuer à ce kit. Quelques règles pour garder le niveau de qualité.

---

## Principe fondamental

**Toute règle ajoutée au kit doit avoir une source vérifiable.**

Ce kit vaut parce que ses règles sont ancrées dans des standards réels (OWASP, W3C, NIST, Google SRE Book, etc.) — pas dans des opinions. Avant d'ajouter ou de modifier un contrat, trouver la source Tier 1 ou Tier 2 qui justifie la règle.

Voir `METHODOLOGY.md` pour la hiérarchie des sources (Tier 1 = documentation officielle, Tier 2 = standards académiques/industriels).

---

## Types de contributions bienvenues

| Type | Description |
|------|-------------|
| **Nouveau contrat** | Domaine non couvert (ex : i18n, animations, mobile natif) |
| **Amélioration contrat** | Threshold manquant, source plus récente, règle incomplète |
| **Nouveau framework** | Outil situationnel (ex : templates pour nouveaux cas d'usage) |
| **Correction** | Erreur factuelle, lien brisé, threshold obsolète |
| **Traduction** | Adapter un contrat pour une autre langue (EN, NL, DE...) |

---

## Structure d'un contrat

Chaque contrat doit suivre cette structure :

```markdown
# Contrat — [Domaine]

> Sources : [Auteur/Org (année)], [Auteur/Org (année)]
> Score : /100 | Seuil recommandé : ≥XX

## Section 1 — [Nom] (XX points)

- [ ] Critère mesurable avec threshold chiffré .............. (X)
- [ ] Critère avec source citée ............................. (X)

**Sous-total : /XX**

## Sources

| Référence | Apport |
|-----------|--------|
| Auteur — *Titre* (Éditeur, année) | Ce que ça apporte |
```

---

## Comment contribuer

1. **Fork** le repo
2. **Créer une branche** : `feat/contract-i18n` ou `fix/wcag-threshold`
3. **Ajouter la source** dans la section `## Sources` du fichier modifié
4. **Mettre à jour** `README.md` + `scripts/verify-kit.sh` si vous ajoutez un fichier
5. **Tester** : `bash scripts/verify-kit.sh --verbose` doit retourner exit 0
6. **Pull Request** avec description du changement et lien vers la source

---

## Ce qui ne sera pas mergé

- Règles sans source vérifiable
- Opinions personnelles présentées comme des standards
- Suppression de sources existantes sans remplacement plus récent
- Code de debug, chemins hardcodés privés, données personnelles

---

## Questions

Ouvrir une Issue GitHub avec le label `question`.
