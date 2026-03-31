# Contract — Accessibility

> SQWR Project Kit contract module.
> Sources: W3C WCAG 2.1, Nielsen Norman Group (10 Heuristics), ARIA Authoring Practices Guide.

---

## Scientific Foundations

**15% of the world's population lives with a disability** (WHO, 2023). Accessibility is not a constraint — it is an audience. WCAG 2.1 AA is the legal standard in the EU (Directive 2016/2102) and in the majority of professional markets.

**Nielsen's 10 Usability Heuristics** (Jakob Nielsen, 1994): unchanged since their publication because they describe invariant human cognitive patterns, not technological trends.

---

## 0. Inclusive Design

**Inclusive Design** : concevoir pour les limitations permanentes (handicap), temporaires (bras cassé), et situationnelles (soleil sur l'écran). Source : Microsoft Inclusive Design Toolkit (microsoft.com/design/inclusive). Un design accessible à une personne avec handicap bénéficie à tous.

---

## 1. WCAG 2.1 — The 4 POUR Principles

| Principle | Meaning | Examples |
|----------|--------------|---------|
| **P**erceivable | Content accessible to all senses | Alt text, captions, sufficient contrast |
| **O**perable | Interface navigable without a mouse | Keyboard nav, skip links, sufficient timeouts |
| **U**nderstandable | Clear and predictable content | Plain language, explicit errors, consistent behavior |
| **R**obust | Compatible with assistive technologies | Correct ARIA, semantic HTML, no broken custom ARIA |

**Minimum level:** WCAG 2.1 **AA** (mandatory)
**Target:** WCAG 2.1 **AAA** for critical elements (main text, navigation)

> **Legal deadline**: The European Accessibility Act (EAA) is enforceable from **June 28, 2025**. Products failing WCAG 2.1 AA compliance risk fines up to 1% of annual turnover in EU member states. Score ≥ 80/100 is the minimum legal threshold for EU deployment.

---

## 2. Nielsen's 10 Usability Heuristics

> Source: Nielsen Norman Group — [nngroup.com/articles/ten-usability-heuristics](https://www.nngroup.com/articles/ten-usability-heuristics/)
> Optimal heuristic evaluation: **3-5 evaluators** (beyond that = diminishing returns).

| # | Heuristic | Concrete web application |
|---|------------|-------------------------|
| 1 | **Visibility of system status** | Loading states, progress bars, action confirmations |
| 2 | **Match between system and real world** | User vocabulary (no technical jargon) |
| 3 | **User control and freedom** | Undo/redo, "Cancel", clear exits from states |
| 4 | **Consistency and standards** | Same button = same action everywhere |
| 5 | **Error prevention** | Confirmation before deletion, inline validation |
| 6 | **Recognition rather than recall** | Icons with labels, suggestion lists |
| 7 | **Flexibility and efficiency of use** | Keyboard shortcuts, favorites, history |
| 8 | **Aesthetic and minimalist design** | Every element must justify its presence |
| 9 | **Help users recognize, diagnose, and recover from errors** | Precise error messages + suggested solution |
| 10 | **Help and documentation** | Searchable, task-oriented, concrete steps |

---

## 2b. Daltonisme et APCA

**Daltonisme** : 8% des hommes ont une déficience de la vision des couleurs (Birch J., 'Worldwide prevalence of red-green color deficiency', Journal of the Optical Society of America A, 2012). Tester avec : Sim Daltonism (macOS), Color Oracle (multi-platform), ou Chrome DevTools → Rendering → Emulate vision deficiencies. Couvrir : deutéranopie (vert), protanopie (rouge), tritanopie (bleu).

**APCA (Advanced Perceptual Contrast Algorithm)** : amélioration de l'algorithme de contraste WCAG 2.x, intégré dans WCAG 3.0 (W3C WCAG 3.0 Working Draft). APCA offre une meilleure uniformité perceptuelle, particulièrement pour les textes de taille intermédiaire. Outils : Colour Contrast Checker (APCA), apcacontrast.com.

---

## 3. Contrast — WCAG Thresholds

| Context | Level AA (minimum) | Level AAA (optimal) |
|----------|---------------------|---------------------|
| Normal text (<18pt) | **4.5:1** | 7:1 |
| Large text (≥18pt or ≥14pt bold) | **3:1** | 4.5:1 |
| UI elements / graphics | **3:1** | — |

**Tool:** WebAIM Contrast Checker — [webaim.org/resources/contrastchecker](https://webaim.org/resources/contrastchecker)

---

## 4. Semantic HTML — Mandatory

```tsx
// ✅ Correct semantic structure
<header>
  <nav aria-label="Main navigation">
    <ul>
      <li><a href="/">Home</a></li>
    </ul>
  </nav>
</header>

<main id="main-content">  {/* skip link target */}
  <h1>Main page title</h1>  {/* Only one h1 per page */}
  <article>...</article>
</main>

<footer>...</footer>

// ❌ Div soup — no semantics
<div class="header">
  <div class="nav">
    <div class="nav-item">...</div>
  </div>
</div>
```

---

## 5. Skip Links (Quick Navigation)

```tsx
// layout.tsx — mandatory for screen readers
export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <>
      {/* Skip link — invisible except on focus */}
      <a
        href="#main-content"
        className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 focus:z-50 bg-sqwr-black text-sqwr-white px-4 py-2 rounded"
      >
        Skip to main content
      </a>
      <Header />
      <main id="main-content">{children}</main>
      <Footer />
    </>
  )
}
```

---

## 6. Images and Media

```tsx
// ✅ Informative image — descriptive alt
<Image src="/hero.jpg" alt="[First name] and [First name], co-founders of [Brand], in [City]" />

// ✅ Decorative image — empty alt (not absent alt)
<Image src="/decorative-pattern.svg" alt="" role="presentation" />

// ❌ Generic alt — useless for screen reader
<Image src="/hero.jpg" alt="image" />
<Image src="/hero.jpg" alt="photo" />

// ✅ Icon with label
<button aria-label="Close menu">
  <XIcon aria-hidden="true" />  {/* aria-hidden hides the icon from SR */}
</button>
```

---

## 7. Accessible Forms

```tsx
// ✅ Explicit labels + error messages
<div>
  <label htmlFor="email" className="block text-sm font-medium">
    Email address *
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
      {error}  {/* Precise with solution: "Invalid format. Example: name@example.com" */}
    </p>
  )}
</div>
```

---

## 8. Keyboard Navigation

```tsx
// All interactive elements must be reachable by keyboard
// and must have a visible focus indicator

// ✅ Visible focus mandatory
.focus-visible:outline-2
.focus-visible:outline-offset-2
.focus-visible:outline-sqwr-black

// ❌ Never remove the focus outline without an alternative
// outline: none; → FORBIDDEN unless replaced by a custom focus style

// ✅ Logical tab order (follows visual order)
// Use tabIndex={-1} only for programmatically focused elements
// Never use tabIndex > 0 (breaks the natural order)
```

---

## 9. ARIA — Correct Usage

```tsx
// ✅ ARIA Landmarks
<nav aria-label="Main navigation">
<nav aria-label="Footer navigation">
<main>
<aside aria-label="Additional information">

// ✅ Live regions for dynamic updates
<div role="status" aria-live="polite">
  {statusMessage}  {/* Announced by SR when content changes */}
</div>

<div role="alert" aria-live="assertive">
  {errorMessage}  {/* Announced immediately */}
</div>

// ⚠️ Golden rule: do not recreate native components with ARIA
// A semantic <button> > a <div role="button">
```

---

## 10. Touch Targets — Mobile Accessibility

> Source: Apple Human Interface Guidelines — Buttons (developer.apple.com/design/human-interface-guidelines/buttons)
> Source: W3C WCAG 2.5.5 — Target Size (w3.org/WAI/WCAG22/Understanding/target-size-enhanced.html)
> Source: W3C WCAG 2.5.8 — Target Size Minimum WCAG 2.2 (w3.org/WAI/WCAG22/Understanding/target-size-minimum.html)

**Threshold: 44×44 px minimum for any interactive element on mobile.** This is the Apple HIG threshold (44pt) and the W3C WCAG 2.5.5 recommendation (44×44 CSS pixels).

### Web — Touch targets

```tsx
// ✅ Icon button — enlarge the tap zone without enlarging the icon
<button
  aria-label="Close"
  className="p-3"  // padding 12px × 2 = zone 40px+ (+ icon 16px = ~44px)
>
  <XIcon className="w-4 h-4" aria-hidden="true" />
</button>

// ✅ Text link — sufficient spacing between adjacent links
<nav className="flex gap-4">  {/* gap-4 = 16px minimum between zones */}
  <a href="/about" className="py-3 px-2">About</a>
  <a href="/contact" className="py-3 px-2">Contact</a>
</nav>

// ❌ Icon without padding — touch target < 44px
<button>
  <XIcon className="w-4 h-4" />  {/* Tap zone = 16px × 16px */}
</button>
```

### Mobile (Capacitor/React Native) — Touch targets

```tsx
// ✅ Minimum 44px interactive zone (even if the visual element is smaller)
<TouchableOpacity
  style={{ minWidth: 44, minHeight: 44, justifyContent: 'center', alignItems: 'center' }}
  onPress={handlePress}
>
  <Icon name="close" size={20} />
</TouchableOpacity>
```

### Spacing Between Interactive Elements

**Rule: ≥ 8px of space between two adjacent interactive elements** (W3C WCAG 2.5.8).

```css
/* ✅ Button list — minimum spacing */
.action-list {
  display: flex;
  gap: 8px;  /* Minimum 8px between interactive zones */
}
```

---

## 11. ARIA Patterns — Interactive Components

> Source: W3C WAI-ARIA Authoring Practices Guide 1.2 — [w3.org/WAI/ARIA/apg/patterns](https://www.w3.org/WAI/ARIA/apg/patterns/)

**Golden rule: Always prefer native HTML elements over ARIA reconstructions.**
A native `<button>` automatically handles: role, focus, keydown (Enter/Space), disabled. A `<div role="button">` requires all of that to be coded manually.

### Accordion

```tsx
// ✅ Accessible accordion
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
// ✅ Accessible modal — focus trap mandatory
<dialog
  ref={dialogRef}
  aria-labelledby="dialog-title"
  aria-describedby="dialog-description"
  onClose={() => setOpen(false)}
>
  <h2 id="dialog-title">Modal title</h2>
  <p id="dialog-description">Description...</p>
  <button onClick={() => dialogRef.current?.close()}>
    Close
  </button>
</dialog>

// Open the native dialog (handles focus trap automatically)
dialogRef.current?.showModal()
```

### Tabs

```tsx
// ✅ Tabs with keyboard navigation (arrow keys ← →)
<div role="tablist" aria-label="Profile sections">
  <button
    role="tab"
    id="tab-infos"
    aria-selected={activeTab === 'infos'}
    aria-controls="panel-infos"
    tabIndex={activeTab === 'infos' ? 0 : -1}
  >
    Information
  </button>
  <button
    role="tab"
    id="tab-securite"
    aria-selected={activeTab === 'securite'}
    aria-controls="panel-securite"
    tabIndex={activeTab === 'securite' ? 0 : -1}
  >
    Security
  </button>
</div>

<div
  role="tabpanel"
  id="panel-infos"
  aria-labelledby="tab-infos"
  hidden={activeTab !== 'infos'}
>
  Content...
</div>
```

### Combobox / Autocomplete

```tsx
// ✅ Accessible autocomplete
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

## 12. Accessibility Testing

```typescript
// Automated tools (detect ~30% of issues)
// axe-core (integrated in Playwright and Testing Library)
import { axe } from 'jest-axe'

test('page is accessible', async () => {
  const { container } = render(<HomePage />)
  const results = await axe(container)
  expect(results).toHaveNoViolations()
})

// Mandatory manual tools
// VoiceOver (macOS): Cmd+F5 to activate
// NVDA (Windows): free, standard screen reader
// Lighthouse Accessibility (DevTools): quick score
// Xcode Accessibility Inspector: for iOS
```

**Heuristic evaluation:** apply the 10 Nielsen heuristics with 3-5 distinct evaluators. Each heuristic scored from 0 (no problem) to 4 (catastrophic).

---

## 13. Sources

| European Accessibility Act | Directive (EU) 2019/882, enforceable June 28, 2025, eur-lex.europa.eu | Tier 1 |

| Reference | Link |
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
| Microsoft Inclusive Design Toolkit | microsoft.com/design/inclusive |
| Birch J. — Color deficiency prevalence (JOSA A, 2012) | doi.org/10.1364/JOSAA.29.000313 |
| APCA — Advanced Perceptual Contrast Algorithm | apcacontrast.com |
| W3C WCAG 3.0 Working Draft | w3.org/TR/wcag-3.0 |

> **Last validated:** 2026-03-30 — WCAG 2.1 AA, EAA juin 2025, EN 301 549, W3C ARIA 1.2, Microsoft Inclusive Design Toolkit, WCAG 3.0 (draft)
