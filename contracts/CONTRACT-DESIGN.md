# Contract — Design System & UI

> SQWR Project Kit contract module — enriched with scientific references.
> Sources: Itten, Munsell, Wertheimer/Köhler (Gestalt), Bringhurst, Baymard Institute, WCAG 2.1 W3C, Dr. Pamela Rutledge.

---

## Scientific Foundations

**62-90% of user judgment about an interface is based on color alone** (Dr. Pamela Rutledge, Media Psychology Research Center). Design decisions are not aesthetic — they are cognitive.

---

## 1. Color Theory

### Harmony Systems (Johannes Itten, Albert Munsell)

| System | Principle | Usage |
|--------|-----------|-------|
| **Complementary** | Opposite colors on the wheel (180°) | Strong contrast, attention, CTAs |
| **Analogous** | Adjacent colors (30-60°) | Natural harmony, visual consistency |
| **Triadic** | 3 colors at 120° (equilateral triangle) | Balanced vibrancy |
| **Split-complementary** | Color + 2 neighbors of its complement | Soft contrast, versatile |

**Role assignment rule (color hierarchy):**
- **Dominant** (60%): backgrounds, neutral surfaces
- **Secondary** (30%): structural elements, navigation
- **Accent** (10%): CTAs, alerts, active links

### WCAG 2.1 Contrast Thresholds (W3C — legal standard)

| Level | Normal text | Large text (≥18pt or ≥14pt bold) | Graphics & UI |
|-------|-------------|----------------------------------|---------------|
| **AA (minimum)** | 4.5:1 | 3:1 | 3:1 |
| **AAA (optimal)** | 7:1 | 4.5:1 | — |

**Verification tool:** WebAIM Contrast Checker (webaim.org/resources/contrastchecker)

> Source: W3C WCAG 2.1 SC 1.4.3 — [w3.org/WAI/WCAG21/Understanding/contrast-minimum](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)

### Modern Color Spaces (W3C 2025)
Advanced-level professionals prepare for **Display P3** and **Oklch** (CSS Color Level 4). Amateurs stay in sRGB/hex. For current SQWR projects: hex + WCAG verification is sufficient.

---

## 2. Typography & Readability

> Primary source: Lesia Rello & Martin Pielot (CHI 2016 — study on optimal font size), Baymard Institute (line length study), Robert Bringhurst (*The Elements of Typographic Style*)

### Measurable Thresholds — Mandatory

| Parameter | Threshold | Scientific rationale |
|-----------|-----------|----------------------|
| **Minimum body font size** | 16px (ideal 18px) | Below 14px = measured increase in eye strain (Rello & Pielot) |
| **Line length (desktop)** | 50-75 characters/line | Sweet spot = 66 CPL. Beyond = loss of eye tracking (Baymard) |
| **Line length (mobile)** | 30-50 characters/line | — |
| **WCAG max characters** | ≤80 (English/French), ≤40 (CJK) | WCAG 2.1 SC 1.4.8 |
| **Line height** | 1.5 × font size | Prevents "rivers" and loss of line tracking |

**CSS Implementation:**
```css
/* ✅ Text column width: enforce measurable thresholds */
.prose {
  max-width: 75ch;      /* 75 characters max */
  font-size: 1rem;      /* 16px minimum */
  line-height: 1.5;     /* 1.5 ratio mandatory */
}
```

### Modular Scale (Robert Bringhurst)

Instead of arbitrary sizes, use a **mathematical ratio** for typographic hierarchy:

| Ratio | Name | Application |
|-------|------|-------------|
| ×1.618 | Golden Ratio | Impactful headings, strong presence |
| ×1.5 | Perfect Fifth | General web use, balanced |
| ×1.333 | Perfect Fourth | Dense interface, subtle hierarchy |

```
Base: 16px → ×1.5 = 24px → ×1.5 = 36px → ×1.5 = 54px → ×1.5 = 81px
```

**Never use arbitrary sizes** (`12px → 20px → 32px → 48px` = signals amateur work).

---

## 3. The 7 Laws of Gestalt (Wertheimer, Koffka, Köhler — 1920s)

> Universal scientific basis of human visual perception. Established by experimental psychology, unchallenged since 1960.

| Law | Principle | Concrete UI application |
|-----|-----------|------------------------|
| **Proximity** | Close elements = perceived as related | Group form fields (8-16px), separate sections (32px+) |
| **Similarity** | Same appearance = same function | All primary buttons = same color; all links = same style |
| **Continuity** | The eye follows lines and curves | Alignments, grids, animations that guide the gaze |
| **Closure** | The brain completes incomplete shapes | Minimalist icons still legible; intentional negative space |
| **Figure-ground** | Separation of foreground / background | Sufficient contrast between content and background |
| **Symmetry** | Symmetric arrangements = order | Balanced layouts reduce cognitive load |
| **Common fate** | Elements that move together = related | Animations grouping related elements |

**Application rule:** any conscious violation of a Gestalt law must be documented with its justification.

---

## 4. Visual Hierarchy

### Eye-tracking & Reading Patterns (Nielsen Norman Group)

- **F Pattern** (dense text content): horizontal scan at top → vertical left → horizontal middle
- **Z Pattern** (sparse interfaces): top-left corner → top-right corner → diagonal → bottom-right corner

**Implication:** place primary CTAs in high-engagement zones (top-left, top-right).

### Systematic Spacing (8px base)

| Usage | Value |
|-------|-------|
| Internal spacing (tight padding) | 8px |
| Internal spacing (normal padding) | 16px |
| Spacing between related elements | 8-16px |
| Spacing between sections | 32-48px |
| Spacing between major blocks | 64-96px |

**Negative/positive spacing ratio: 30-50% white space is optimal.**

---

## 5. Visual Identity — Tokens to Define per Project

> Fill in with your brand guidelines values.
> See `frameworks/BRAND-STRATEGY.md` to define the strategy before choosing colors.

**Primary Palette**

| Token | Value | Usage |
|-------|-------|-------|
| `brand-primary` | `[TO FILL — e.g.: #0A0A0A]` | Dominant color (60%) — background or strong color |
| `brand-secondary` | `[TO FILL — e.g.: #F5F5F0]` | Secondary color (30%) — structural elements |
| `brand-accent` | `[TO FILL — e.g.: #FF4D00]` | Accent (10%) — CTAs, active links, alerts |

**Minimal Tailwind example (`tailwind.config.ts`):**
```ts
colors: {
  'brand-primary': '[your color]',
  'brand-secondary': '[your color]',
  'brand-accent': '[your color]',
}
```

> Document your complete design system in `docs/design-system.md` of your project.

---

## 6. Tailwind Rules

### Never do

- **Inline styles** (`style={{ color: 'red' }}`) — always use Tailwind classes
- **Excessive arbitrary values** (`w-[347px]`) — use Tailwind's spacing grid
- **Font sizes below 16px** for body text
- **Mixing Tailwind v3 and v4 syntax** in the same project

### Always do

- Use tokens defined in `tailwind.config.ts`
- Group classes in order: layout → spacing → typography → colors → effects
- Extract repeated classes into components

```tsx
// ✅ Consistent, readable order
<div className="flex items-center gap-4 px-6 py-3 text-base font-medium text-sqwr-black bg-sqwr-white rounded-lg shadow-sm hover:shadow-md transition-shadow">
```

---

## 7. Components — General Rules

### Atomic Design (Brad Frost)

| Level | Description | Examples |
|-------|-------------|---------|
| **Atoms** | Indivisible elements | Button, Input, Label, Icon |
| **Molecules** | Simple combinations | SearchForm (Input + Button) |
| **Organisms** | Functional sections | ProductCard, NavigationBar |
| **Templates** | Page structure (without real content) | PageLayout |
| **Pages** | Real content in templates | HomePage, AboutPage |

```tsx
// Component structure
interface ComponentProps {
  title: string
  variant?: 'primary' | 'secondary'
}

export default function Component({ title, variant = 'primary' }: ComponentProps) {
  return (...)
}
```

---

## 8. Animations

- Prefer Framer Motion (declarative, React-native) for components
- GSAP for complex timeline/canvas animations
- **Always respect `prefers-reduced-motion`** — WCAG obligation

```tsx
// ✅ Mandatory on every animation
const shouldReduceMotion = useReducedMotion()
const animation = shouldReduceMotion ? {} : { opacity: [0, 1], y: [20, 0] }
```

---

## 9. Design Psychology — Academic Foundations

> These principles complement the kit's design rules with foundations from cognitive and behavioral research. They apply to any project with a UI component, regardless of the stack.

### 9.1 Processing Fluency

**Principle:** The more cognitively fluent a visual stimulus is to process, the more it is perceived as beautiful and trustworthy — this judgment is pre-cognitive and occurs in under 3 seconds.

| Variable | Effect on fluency |
|----------|------------------|
| Figural goodness (simple, regular shapes) | Increases |
| High contrast | Increases |
| Symmetry | Increases |
| Pattern repetition | Increases |

**Threshold:** Beauty judgment = < 3 seconds (before any reading).

**Implication:** A consistent design system (grid, typographic scale, limited palette) generates trust before the user even reads the content. Any visual inconsistency degrades fluency and therefore perceived credibility.

**(Reber, Schwarz & Winkielman, 2004 — Personality and Social Psychology Review, 8(4), 364–382)**

---

### 9.2 Peak-End Rule

**Principle:** Humans judge an experience by its PEAK moment (the point of maximum intensity) and its END — not by total duration or average of moments.

**Threshold:** Invest ≥ 60% of the animation budget and visual care on the signature moment (hero section) and the page exit.

**Implication:** 1 strong signature moment + a polished footer outperforms 47 mediocre micro-animations spread across the page. Identify and over-optimize the maximum emotional point of each page before handling intermediate details.

**(Kahneman & Frederickson, 1993 — Psychological Science, 4(6), 409–415)**

---

### 9.3 Isolation Effect (Von Restorff)

**Principle:** A distinctive element among homogeneous elements is better remembered than the surrounding uniform elements.

**Threshold:** 95% sober and consistent surface + 5% radical intentional rupture = maximum memorability.

**Anti-patterns:**
- 100% "clean and sober" = no focal point = nothing memorable
- 100% animated or contrasted = saturation = no element stands out

**Implication:** Deliberately choose 1 single element per page as the break point (color, typography, size, movement). Everything else must be consistent for the rupture to work.

**(Von Restorff, 1933 — Psychologische Forschung, 18, 299–342)**

---

### 9.4 Optimal Complexity (Berlyne)

**Principle:** Aesthetic pleasure follows an inverted U-curve according to visual complexity — intermediate complexity produces maximum pleasure.

| Complexity level | Response |
|-----------------|---------|
| Too low | Boredom, disengagement |
| Intermediate | Maximum aesthetic pleasure |
| Too high | Confusion, rejection |

**Implication:** A consistent design system (complexity reduction) + 1 intentionally broken convention (targeted complexity injection) = optimal point. Aim for neither maximalism nor absolute minimalism.

**(Berlyne, 1971 — Aesthetics and Psychobiology, Appleton-Century-Crofts)**

---

### 9.5 Aesthetic-Usability Effect

**Principle:** A beautiful design is perceived as more usable — even when actual functional usability is identical to that of a less aesthetic design.

**Threshold:** Correlation r = 0.73 between perceived beauty and perceived usability (Tractinsky, 2000).

**ROI Implication:** Aesthetic investment produces better satisfaction, greater tolerance for friction, and a perception of superior quality. "Functional but ugly" design is not neutral — it actively degrades satisfaction.

**(Kurosu & Kashimura, 1995 — CHI Conference Companion, 292–293)**
**(Tractinsky, Katz & Ikar, 2000 — Interacting with Computers, 13(2), 127–145)**

---

### 9.6 Anti-Laws of Luxury Design (Kapferer)

**Principle:** Premium brand design follows rules that are the inverse of mass marketing. 6 anti-laws applicable to digital:

| Anti-law | Design application |
|----------|-------------------|
| Never compare yourself | Zero reference to competition in copy or visuals |
| Maintain scarcity | No "available now" — friction is a value signal |
| Make access difficult | Contact = application, not instant checkout |
| Communicate beyond buyers | The dream exceeds the target — aspiration is a feature |
| Just enough imperfection | Slight intentional irregularity = artisanal signature |
| Never display prices without context | Price is a value signal, not an entry point |

**Technical implication:** Slightly visible grid (opacity 0.02–0.04), custom easing curves (not browser defaults), intentionally documented geometric asymmetries.

**(Kapferer & Bastien, 2009, 2nd ed. 2012 — The Luxury Strategy, Kogan Page)**

---

### 9.7 Color Psychology — Red and Dominance

**Principle:** Red is a signal of dominance, status, and maximum attention capture.

**Threshold:** Use red < 10% of the total surface area (accent role exclusively).

**Contraindication:** Red inhibits cognitive performance through association with the danger signal — avoid it on informational CTAs, forms, and reading areas. Reserve it for alerts and brand accents.

**(Elliot & Maier, 2007 — Current Directions in Psychological Science, 16(5), 250–254)**

---

### 9.8 Typeface Personality

**Principle:** Typography is perceived along 3 dimensions: Potency (strength/authority), Evaluative (elegance/quality), Activity (energy/dynamism).

| Context | Typographic choice | Effect |
|---------|-------------------|----|
| Premium projects, headings | Serif | Signals authority and reliability superior to sans-serif |
| Body text, UI | Sans-serif | Optimal readability at small sizes |
| Display/hero (72–120px+) | Display serif or condensed sans-serif | Maximum emotional impact |

**Threshold ratio:** Minimum 1.5:1 between typographic hierarchy levels (Golden Ratio 1.618 recommended — cf. Section 2).

**(Li & Suen, 2010 — Proceedings of DAS 2010)**
**(MIT AgeLab & Monotype, 2019 — Emotional Response to Type)**

---

### 9.9 Animation Standards — Timing Thresholds

> Sources: Apple HIG (developer.apple.com/design/human-interface-guidelines), Google Material Design 3 (m3.material.io), WCAG 2.1 SC 2.3.3

| Interaction type | Target duration | Rule |
|-----------------|-----------------|-------|
| Small interactions (buttons, toggles, focus) | 200–350ms | Below = imperceptible. Above = slow. |
| Large transitions (pages, modals, drawers) | 400–600ms | Let the user perceive the context change |
| Stagger between list elements | 50–100ms | Delay between each child to guide the gaze |

**Absolute Rules:**
- **Custom easing mandatory** — never use the browser default `ease-in-out`. Define project-specific Bézier curves.
- **`prefers-reduced-motion` always respected** — WCAG 2.1 SC 2.3.3 obligation.

```tsx
// ✅ Custom easing — example
const easing = [0.16, 1, 0.3, 1] // ease-out-expo

// ✅ prefers-reduced-motion mandatory
const shouldReduceMotion = useReducedMotion()
const transition = shouldReduceMotion
  ? { duration: 0 }
  : { duration: 0.4, ease: easing }
```

**Display typography — hero thresholds:**
- Hero titles: 72–120px+ for maximum emotional impact
- Whitespace ≥ 40% of the surface for premium signal **(Baymard Institute)**

---

## 10. Color Scale — Perceptual Consistency

> Source: Fairchild, M.D. — *Color Appearance Models*, 3rd ed. (Wiley, 2013) — CIECAM02/CIELAB
> Source: Izzico Design System (field — role colors, validated with WCAG AA)

### ΔE — Perceptual Distinction Threshold

**Threshold: ΔE > 7 between two colors intended to be distinct** — human discrimination threshold (CIELAB). Below this, users risk confusing two colors.

| ΔE | Perception |
|----|-----------|
| 0–1 | Imperceptible |
| 1–3 | Subtle (visible in direct comparison) |
| 3–7 | Moderate (visible to the naked eye) |
| >7 | **Clearly distinct** ← SQWR threshold |

**ΔE calculation tool:** Colorpedia (colorpedia.io) or Adobe Color.

### L* Progression for Color Scales

To create scales from 50 to 900 (Tailwind style):

```
L* must decrease monotonically from 50 (light) → 900 (dark)
Correct example:    50 → L*=95, 100 → L*=88, 500 → L*=50, 900 → L*=15
Incorrect example:  50 → L*=95, 100 → L*=93, 200 → L*=94 ← inversion = error
```

**Implication:** For multi-role systems (e.g.: Owner/Resident/Seeker), verify that colors at the same level (e.g.: all -500) have ΔE > 7 between them.

---

## 11. Voice & Tone — Matrix by Segment

> Source: Nielsen Norman Group — 4 Dimensions of Tone of Voice
> [nngroup.com/articles/tone-of-voice-dimensions](https://www.nngroup.com/articles/tone-of-voice-dimensions)

**Design does not stop at the visual.** Copywriting is a design component — every UI surface contains text, and that text communicates a brand personality. Tone/visual consistency is what makes an interface feel "professional" or "generic".

### The 4 Nielsen NN/G Dimensions

| Dimension | Low pole | High pole |
|-----------|---------|----------|
| Formality | Casual (1) | Formal (5) |
| Humor | Serious (1) | Humorous (5) |
| Irreverence | Respectful (1) | Irreverent (5) |
| Energy | Neutral (1) | Enthusiastic (5) |

**Usage:** define the matrix in the project's `CLAUDE.md`. Claude Code then applies it to all generated UI text.

### Matrix Template to Document per Project

```markdown
## Tone of Voice — [Project Name]

### Segment: [e.g.: B2C Users]
| Dimension | Score | Example |
|-----------|-------|---------|
| Formality | 4/5 (casual) | "Hello [First Name]!" |
| Humor | 3/5 (light) | "You owe €X to Lucas 💸" |
| Irreverence | 3/5 | "Your roommates also struggle to make it to the end of the month..." |
| Energy | 4/5 | Action verbs, short sentences |

### Segment: [e.g.: B2B Users / owners]
| Dimension | Score | Example |
|-----------|-------|---------|
| Formality | 2/5 (neutral) | "Hello [First Name]" |
| Humor | 2/5 (sober) | No humor on financial topics |
| Irreverence | 1/5 (respectful) | Formal address |
| Energy | 3/5 | Professional, factual |

### Banned Words
- [corporate speak]: "leverage", "synergy", "seamless"
- [industry jargon to avoid]: ...

### Brand-owned Words
- [brand term 1]: used in place of [generic term]
- [brand term 2]: ...
```

**Multi-segment rule:** if the platform addresses different user types (B2C + B2B, juniors + seniors), define a distinct matrix per segment. Mixing tones creates an inconsistent experience.

---

## 12. Scientific Sources

| Reference | Usage |
|-----------|-------|
| Johannes Itten — *Kunst der Farbe* (1961) | Color harmony systems |
| Albert Munsell — Munsell Color System (1905) | Scientific color measurement |
| Dr. Pamela Rutledge — Media Psychology Research (2024) | Cognition and color |
| Wertheimer, Koffka, Köhler (1920-1960) | 7 Gestalt laws |
| Robert Bringhurst — *The Elements of Typographic Style* (1992) | Modular scale, typography |
| Lesia Rello & Martin Pielot — CHI 2016 | Optimal font size |
| Baymard Institute — Line Length Study | CPL 50-75, premium whitespace |
| Nielsen Norman Group — Eye-tracking studies | F/Z patterns, hierarchy |
| W3C WCAG 2.1 — SC 1.4.3, 1.4.8, 2.3.3 | Contrast, line length, motion |
| Brad Frost — *Atomic Design* (2016) | Component hierarchy |
| W3C Design Tokens Community Group (2025.10) | Cross-platform tokens standard |
| Reber, Schwarz & Winkielman (2004) — *Personality and Social Psychology Review* | Processing Fluency |
| Kahneman & Frederickson (1993) — *Psychological Science* | Peak-End Rule |
| Von Restorff (1933) — *Psychologische Forschung* | Isolation Effect, memorability |
| Berlyne (1971) — *Aesthetics and Psychobiology* | Optimal Complexity |
| Kurosu & Kashimura (1995) — CHI | Aesthetic-Usability Effect |
| Tractinsky, Katz & Ikar (2000) — *Interacting with Computers* | Aesthetic-Usability Effect (r=0.73) |
| Kapferer & Bastien (2009, 2nd ed. 2012) — *The Luxury Strategy* | Anti-Laws of Luxury Design |
| Elliot & Maier (2007) — *Current Directions in Psychological Science* | Color Psychology, red |
| Li & Suen (2010) — *Proceedings of DAS 2010* | Typeface Personality |
| MIT AgeLab & Monotype (2019) — *Emotional Response to Type* | Typeface Personality |
| Apple Human Interface Guidelines (developer.apple.com) | Animation timing standards |
| Google Material Design 3 (m3.material.io) | Animation timing standards |
| Nielsen Norman Group — 4 Dimensions of Tone of Voice (nngroup.com) | Voice & Tone matrix |
| Fairchild, M.D. — *Color Appearance Models* 3rd ed. (Wiley, 2013) | CIECAM02/CIELAB ΔE |
