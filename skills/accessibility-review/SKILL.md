---
name: accessibility-review
description: Audit accessibilité WCAG 2.1 — contrastes, navigation clavier, ARIA, lecteurs d'écran, formulaires. Sources : W3C WCAG 2.1 AA, Nielsen 10 heuristics, ARIA Authoring Practices Guide.
tags: [accessibility, wcag, aria, keyboard, screen-reader, a11y]
model: sonnet
---

# /accessibility-review — Audit Accessibilité WCAG 2.1

## Quand utiliser

- Audit d'un composant ou page (conformité WCAG 2.1 AA)
- Review avant lancement d'une feature publique
- Vérification d'un formulaire ou flow critique
- Correction d'erreurs axe/Lighthouse accessibility

## Critères WCAG 2.1 AA

### Perceptibilité
- [ ] Contraste texte : 4.5:1 minimum (3:1 pour texte large)
- [ ] Contraste UI non-texte (icônes, bordures focus) : 3:1
- [ ] Pas d'information transmise uniquement par la couleur
- [ ] Alt text sur toutes les images non-décoratives (`alt=""` si décorative)

> Piège de comptage (un run précédent avait compté 87 violations à tort) : un grep `<Image` sur un projet Next.js matche aussi bien le composant `next/image` (a besoin d'`alt`) que l'icône `Image`/`ImageIcon`/`ImagePlus` importée de `lucide-react` (n'en a pas besoin, ce n'est pas une balise `<img>`). Toujours vérifier la source de l'import (`from 'next/image'` vs `from 'lucide-react'`) avant de compter un hit comme violation — ne pas se fier à un grep sur `<Image` seul.
- [ ] Captions sur les vidéos, transcription pour l'audio
- [ ] Contenu zoom 200% sans perte d'information

### Opérabilité (navigation clavier)
- [ ] Tous les éléments interactifs accessibles au clavier (Tab, Shift+Tab)
- [ ] Focus visible sur tous les éléments (outline CSS non supprimé)
- [ ] Ordre de tabulation logique (suit le flux visuel)
- [ ] Pas de piège clavier (modal ferme avec Escape)
- [ ] Skip links ("Aller au contenu" en premier élément)
- [ ] Shortcut clavier pour les fonctions répétitives

### Compréhensibilité
- [ ] `lang` sur `<html>` (et sur les changements de langue inline)
- [ ] Labels explicites sur tous les inputs (pas uniquement placeholder)
- [ ] Messages d'erreur associés via `aria-describedby`
- [ ] Pas de timeout sans avertissement (WCAG 2.2.1)
- [ ] Confirmation avant actions irréversibles

### Robustesse (ARIA)
- [ ] ARIA uniquement si HTML sémantique insuffisant
- [ ] `role`, `aria-label`, `aria-describedby` cohérents
- [ ] Live regions (`aria-live="polite"`) pour les mises à jour dynamiques
- [ ] `aria-expanded`, `aria-selected`, `aria-checked` sur les composants custom
- [ ] IDs uniques dans la page (jamais de duplicats)

### Composants custom (ARIA Authoring Practices)
| Composant | Pattern ARIA requis |
|-----------|-------------------|
| Modal | `role="dialog"`, `aria-modal="true"`, focus trap, close on Escape |
| Dropdown | `role="listbox"` + `role="option"`, `aria-selected` |
| Tabs | `role="tablist"`, `role="tab"`, `aria-selected`, `role="tabpanel"` |
| Toast | `role="status"` ou `role="alert"`, `aria-live` |
| Accordion | `aria-expanded`, controls/labelledby |

## Format de sortie

```
## Accessibility Review — [composant/page]

### Score WCAG 2.1 AA : [X/100]

### 🔴 Non-conformité critique (bloquant légalement EAA 2025)
### 🟡 Non-conformité AA à corriger
### 🟢 AAA (bonus)

### Corrections code
[JSX/HTML corrigé avec ARIA]
```
