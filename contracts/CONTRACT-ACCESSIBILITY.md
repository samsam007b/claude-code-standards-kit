# Contrat — Accessibilité

> Module de contrat SQWR Project Kit.
> Sources : W3C WCAG 2.1, Nielsen Norman Group (10 Heuristics), ARIA Authoring Practices Guide.

---

## Fondements scientifiques

**15% de la population mondiale vit avec un handicap** (OMS, 2023). L'accessibilité n'est pas une contrainte — c'est une audience. WCAG 2.1 AA est le standard légal dans l'UE (Directive 2016/2102) et dans la majorité des marchés professionnels.

**Nielsen's 10 Usability Heuristics** (Jakob Nielsen, 1994) : inchangées depuis leur publication car elles décrivent des invariants cognitifs humains, pas des tendances technologiques.

---

## 1. WCAG 2.1 — Les 4 principes POUR

| Principe | Signification | Exemples |
|----------|--------------|---------|
| **P**erceivable | Contenu accessible à tous les sens | Alt text, sous-titres, contraste suffisant |
| **O**perable | Interface navigable sans souris | Keyboard nav, skip links, timeouts suffisants |
| **U**nderstandable | Contenu clair et prévisible | Langage simple, erreurs explicites, comportement cohérent |
| **R**obust | Compatible avec technologies d'assistance | ARIA correct, HTML sémantique, pas de ARIA custom cassé |

**Niveau minimum :** WCAG 2.1 **AA** (obligatoire)
**Cible :** WCAG 2.1 **AAA** pour les éléments critiques (texte principal, navigation)

---

## 2. Nielsen's 10 Usability Heuristics

> Source : Nielsen Norman Group — [nngroup.com/articles/ten-usability-heuristics](https://www.nngroup.com/articles/ten-usability-heuristics/)
> Évaluation heuristique optimale : **3-5 évaluateurs** (au-delà = rendements décroissants).

| # | Heuristique | Application web concrète |
|---|------------|-------------------------|
| 1 | **Visibilité du statut système** | Loading states, progress bars, confirmations d'action |
| 2 | **Correspondance système-monde réel** | Vocabulaire utilisateur (pas jargon technique) |
| 3 | **Contrôle et liberté utilisateur** | Undo/redo, "Annuler", sorties claires des états |
| 4 | **Cohérence et standards** | Même bouton = même action partout |
| 5 | **Prévention des erreurs** | Confirmation avant suppression, validation inline |
| 6 | **Reconnaissance plutôt que rappel** | Icônes avec labels, listes de suggestions |
| 7 | **Flexibilité et efficacité** | Raccourcis clavier, favoris, historique |
| 8 | **Design esthétique et minimaliste** | Chaque élément doit justifier sa présence |
| 9 | **Aider à reconnaître et corriger les erreurs** | Messages d'erreur précis + solution suggérée |
| 10 | **Aide et documentation** | Recherchable, orientée tâche, étapes concrètes |

---

## 3. Contraste — seuils WCAG

| Contexte | Niveau AA (minimum) | Niveau AAA (optimal) |
|----------|---------------------|---------------------|
| Texte normal (<18pt) | **4.5:1** | 7:1 |
| Grand texte (≥18pt ou ≥14pt bold) | **3:1** | 4.5:1 |
| Éléments UI / graphiques | **3:1** | — |

**Outil :** WebAIM Contrast Checker — [webaim.org/resources/contrastchecker](https://webaim.org/resources/contrastchecker)

---

## 4. HTML sémantique — obligation

```tsx
// ✅ Structure sémantique correcte
<header>
  <nav aria-label="Navigation principale">
    <ul>
      <li><a href="/">Accueil</a></li>
    </ul>
  </nav>
</header>

<main id="main-content">  {/* cible du skip link */}
  <h1>Titre principal de la page</h1>  {/* Un seul h1 par page */}
  <article>...</article>
</main>

<footer>...</footer>

// ❌ Div soup — aucune sémantique
<div class="header">
  <div class="nav">
    <div class="nav-item">...</div>
  </div>
</div>
```

---

## 5. Skip Links (navigation rapide)

```tsx
// layout.tsx — obligatoire pour screen readers
export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <>
      {/* Skip link — invisible sauf au focus */}
      <a
        href="#main-content"
        className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 focus:z-50 bg-sqwr-black text-sqwr-white px-4 py-2 rounded"
      >
        Aller au contenu principal
      </a>
      <Header />
      <main id="main-content">{children}</main>
      <Footer />
    </>
  )
}
```

---

## 6. Images et médias

```tsx
// ✅ Image informative — alt descriptif
<Image src="/hero.jpg" alt="[Prénom] et [Prénom], co-fondateurs de [Marque], à [Ville]" />

// ✅ Image décorative — alt vide (pas d'alt absent)
<Image src="/decorative-pattern.svg" alt="" role="presentation" />

// ❌ Alt générique — inutile pour screen reader
<Image src="/hero.jpg" alt="image" />
<Image src="/hero.jpg" alt="photo" />

// ✅ Icône avec label
<button aria-label="Fermer le menu">
  <XIcon aria-hidden="true" />  {/* aria-hidden masque l'icône au SR */}
</button>
```

---

## 7. Formulaires accessibles

```tsx
// ✅ Labels explicites + error messages
<div>
  <label htmlFor="email" className="block text-sm font-medium">
    Adresse email *
  </label>
  <input
    id="email"
    type="email"
    name="email"
    required
    aria-required="true"
    aria-describedby={error ? "email-error" : undefined}
    aria-invalid={error ? "true" : undefined}
    className="..."
  />
  {error && (
    <p id="email-error" role="alert" className="text-red-600 text-sm mt-1">
      {error}  {/* Précis et avec solution : "Format invalide. Exemple : nom@exemple.com" */}
    </p>
  )}
</div>
```

---

## 8. Navigation clavier

```tsx
// Tous les éléments interactifs doivent être atteignables au clavier
// et avoir un focus visible

// ✅ Focus visible obligatoire
.focus-visible:outline-2
.focus-visible:outline-offset-2
.focus-visible:outline-sqwr-black

// ❌ Ne jamais supprimer le focus outline sans alternative
// outline: none; → INTERDIT sauf si remplacé par un focus style custom

// ✅ Ordre de tabulation logique (suit l'ordre visuel)
// Utiliser tabIndex={-1} uniquement pour les éléments focus programmatiques
// Ne jamais utiliser tabIndex > 0 (casse l'ordre naturel)
```

---

## 9. ARIA — utilisation correcte

```tsx
// ✅ Landmarks ARIA
<nav aria-label="Navigation principale">
<nav aria-label="Navigation pied de page">
<main>
<aside aria-label="Informations complémentaires">

// ✅ Live regions pour les mises à jour dynamiques
<div role="status" aria-live="polite">
  {statusMessage}  {/* Annoncé par SR quand le contenu change */}
</div>

<div role="alert" aria-live="assertive">
  {errorMessage}  {/* Annoncé immédiatement */}
</div>

// ⚠️ Règle d'or : ne pas recréer des composants natifs avec ARIA
// Un <button> sémantique > un <div role="button">
```

---

## 10. Touch Targets — Accessibilité Mobile

> Source : Apple Human Interface Guidelines — Buttons (developer.apple.com/design/human-interface-guidelines/buttons)
> Source : W3C WCAG 2.5.5 — Target Size (w3.org/WAI/WCAG22/Understanding/target-size-enhanced.html)
> Source : W3C WCAG 2.5.8 — Target Size Minimum WCAG 2.2 (w3.org/WAI/WCAG22/Understanding/target-size-minimum.html)

**Threshold : 44×44 px minimum pour tout élément interactif sur mobile.** C'est le seuil Apple HIG (44pt) et la recommandation W3C WCAG 2.5.5 (44×44 CSS pixels).

### Web — Touch targets

```tsx
// ✅ Bouton icône — agrandir la zone de tap sans agrandir l'icône
<button
  aria-label="Fermer"
  className="p-3"  // padding 12px × 2 = zone 40px+ (+ icône 16px = ~44px)
>
  <XIcon className="w-4 h-4" aria-hidden="true" />
</button>

// ✅ Lien texte — espacement suffisant entre liens adjacents
<nav className="flex gap-4">  {/* gap-4 = 16px minimum entre les zones */}
  <a href="/about" className="py-3 px-2">À propos</a>
  <a href="/contact" className="py-3 px-2">Contact</a>
</nav>

// ❌ Icône sans padding — touch target < 44px
<button>
  <XIcon className="w-4 h-4" />  {/* Zone de tap = 16px × 16px */}
</button>
```

### Mobile (Capacitor/React Native) — Touch targets

```tsx
// ✅ Minimum 44px de zone interactive (même si l'élément visuel est plus petit)
<TouchableOpacity
  style={{ minWidth: 44, minHeight: 44, justifyContent: 'center', alignItems: 'center' }}
  onPress={handlePress}
>
  <Icon name="close" size={20} />
</TouchableOpacity>
```

### Espacements entre éléments interactifs

**Règle : ≥ 8px d'espace entre deux éléments interactifs adjacents** (W3C WCAG 2.5.8).

```css
/* ✅ Liste de boutons — espacement minimum */
.action-list {
  display: flex;
  gap: 8px;  /* Minimum 8px entre les zones interactives */
}
```

---

## 11. ARIA Patterns — Composants Interactifs

> Source : W3C WAI-ARIA Authoring Practices Guide 1.2 — [w3.org/WAI/ARIA/apg/patterns](https://www.w3.org/WAI/ARIA/apg/patterns/)

**Règle d'or : Toujours préférer les éléments HTML natifs à des reconstructions ARIA.**
Un `<button>` natif gère automatiquement : role, focus, keydown (Enter/Space), disabled. Une `<div role="button">` nécessite tout recoder manuellement.

### Accordion

```tsx
// ✅ Accordion accessible
<div>
  <h3>
    <button
      id="accordion-header-1"
      aria-expanded={isOpen}
      aria-controls="accordion-panel-1"
      onClick={() => setIsOpen(!isOpen)}
    >
      Section title
    </button>
  </h3>
  <div
    id="accordion-panel-1"
    role="region"
    aria-labelledby="accordion-header-1"
    hidden={!isOpen}
  >
    <p>Contenu...</p>
  </div>
</div>
```

### Dialog / Modal

```tsx
// ✅ Modal accessible — focus trap obligatoire
<dialog
  ref={dialogRef}
  aria-labelledby="dialog-title"
  aria-describedby="dialog-description"
  onClose={() => setOpen(false)}
>
  <h2 id="dialog-title">Titre de la modal</h2>
  <p id="dialog-description">Description...</p>
  <button onClick={() => dialogRef.current?.close()}>
    Fermer
  </button>
</dialog>

// Ouvrir la dialog native (gère focus trap automatiquement)
dialogRef.current?.showModal()
```

### Tabs

```tsx
// ✅ Tabs avec navigation clavier (flèches ← →)
<div role="tablist" aria-label="Sections du profil">
  <button
    role="tab"
    id="tab-infos"
    aria-selected={activeTab === 'infos'}
    aria-controls="panel-infos"
    tabIndex={activeTab === 'infos' ? 0 : -1}
  >
    Informations
  </button>
  <button
    role="tab"
    id="tab-securite"
    aria-selected={activeTab === 'securite'}
    aria-controls="panel-securite"
    tabIndex={activeTab === 'securite' ? 0 : -1}
  >
    Sécurité
  </button>
</div>

<div
  role="tabpanel"
  id="panel-infos"
  aria-labelledby="tab-infos"
  hidden={activeTab !== 'infos'}
>
  Contenu...
</div>
```

### Combobox / Autocomplete

```tsx
// ✅ Autocomplete accessible
<div role="combobox" aria-expanded={isOpen} aria-haspopup="listbox">
  <input
    type="text"
    aria-autocomplete="list"
    aria-controls="suggestions-list"
    aria-activedescendant={activeOption ? `option-${activeOption}` : undefined}
  />
  {isOpen && (
    <ul role="listbox" id="suggestions-list">
      {suggestions.map((s, i) => (
        <li
          key={s.id}
          role="option"
          id={`option-${s.id}`}
          aria-selected={activeOption === s.id}
        >
          {s.label}
        </li>
      ))}
    </ul>
  )}
</div>
```

---

## 12. Testing accessibilité

```typescript
// Outils automatisés (détectent ~30% des problèmes)
// axe-core (intégré dans Playwright et Testing Library)
import { axe } from 'jest-axe'

test('page is accessible', async () => {
  const { container } = render(<HomePage />)
  const results = await axe(container)
  expect(results).toHaveNoViolations()
})

// Outils manuels obligatoires
// VoiceOver (macOS) : Cmd+F5 pour activer
// NVDA (Windows) : gratuit, screen reader standard
// Lighthouse Accessibility (DevTools) : score rapide
// Xcode Accessibility Inspector : pour iOS
```

**Évaluation heuristique :** appliquer les 10 Nielsen heuristics avec 3-5 évaluateurs distincts. Chaque heuristique scorée de 0 (pas de problème) à 4 (catastrophe).

---

## 13. Sources

| Référence | Lien |
|-----------|------|
| W3C WCAG 2.1 | w3.org/TR/WCAG21 |
| Nielsen's 10 Heuristics | nngroup.com/articles/ten-usability-heuristics |
| ARIA Authoring Practices Guide | w3.org/WAI/ARIA/apg |
| WebAIM Contrast Checker | webaim.org/resources/contrastchecker |
| axe-core | github.com/dequelabs/axe-core |
| Heuristic Evaluation — NN/G | nngroup.com/articles/how-to-conduct-a-heuristic-evaluation |
| W3C WCAG 2.5.5 — Target Size | w3.org/WAI/WCAG22/Understanding/target-size-enhanced |
| W3C WCAG 2.5.8 — Target Size Minimum | w3.org/WAI/WCAG22/Understanding/target-size-minimum |
| Apple HIG — Touch Targets | developer.apple.com/design/human-interface-guidelines/buttons |
| WAI-ARIA Authoring Practices 1.2 | w3.org/WAI/ARIA/apg/patterns |
