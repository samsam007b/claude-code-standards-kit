# Contract — Motion Design & Animation

> SQWR Project Kit contract module.
> Sources: Material Design 3 Motion (m3.material.io/styles/motion), Apple HIG — Motion (developer.apple.com/design/human-interface-guidelines/motion), W3C WCAG 2.3 — Seizure and Physical Reactions (w3.org/TR/WCAG23), CSS Easing Functions Level 2 (w3.org/TR/css-easing-2), Remotion docs (remotion.dev/docs), Nielsen Norman Group — Animation for Attention and Comprehension (nngroup.com).

---

## Foundations

**Fundamental principle: Animation = Communication.** Every movement has a purpose. An animation without reason is visual noise.

> "Animation serves to guide attention, maintain continuity between states, and provide feedback on interactions — not to decorate."
> — Nielsen Norman Group, "Animation for Attention and Comprehension"

This contract covers: web/app UI animations, social motion design (Reels, TikTok), video production with Remotion, and animation accessibility.

---

## 1. The 200ms Rule — User Feedback

> Source: Material Design 3 — Motion speed (m3.material.io/styles/motion/applying-motion/motion-parameters)
> **Threshold: ≤200ms for any animation triggered by a user interaction**

```css
/* ✅ Micro-interactions — immediate response */
.button {
  transition: transform 150ms cubic-bezier(0.2, 0, 0, 1),
              box-shadow 150ms cubic-bezier(0.2, 0, 0, 1);
}

.button:hover  { transform: translateY(-2px); }
.button:active { transform: scale(0.97); }
```

Beyond 200ms, the user perceives **lag** — the response no longer feels instantaneous (Miller's Law: threshold of "immediate" = 100-200ms).

---

## 2. Standard Durations

> Source: Material Design 3 — Duration tokens (m3.material.io/styles/motion/easing-and-duration/tokens-specs)
> Source: Apple HIG — Animation duration (developer.apple.com/design/human-interface-guidelines/motion)

| Category | Duration | Usage |
|----------|----------|-------|
| **Instant** | 50–100ms | Hover state, focus ring |
| **Micro** | 150–200ms | Buttons, icons, toggles |
| **Small** | 200–300ms | Tooltips, chips, badges |
| **Medium** | 300–500ms | Cards, modals, drawers |
| **Large** | 500–800ms | Page transitions, sidebars |
| **Hero** | 800–1500ms | Landing page entry animations |

**Absolute rule: never any UI animation > 1500ms.** Beyond this, the user loses patience (NN/G research, 2019).

---

## 3. Easing Curves

> Source: CSS Easing Functions Level 2 — W3C Working Draft (w3.org/TR/css-easing-2)
> Source: Material Design 3 — Easing (m3.material.io/styles/motion/easing-and-duration/applying-easing)

```css
:root {
  /* Enter the screen — decelerates on arrival */
  --ease-enter:   cubic-bezier(0.0, 0.0, 0.2, 1);   /* Material: Emphasized decelerate */

  /* Exit the screen — accelerates on departure */
  --ease-exit:    cubic-bezier(0.4, 0.0, 1, 1);      /* Material: Emphasized accelerate */

  /* On screen — state transitions */
  --ease-smooth:  cubic-bezier(0.4, 0.0, 0.2, 1);   /* Material: Standard */

  /* Quick response — snappy */
  --ease-snappy:  cubic-bezier(0.2, 0.0, 0.0, 1);

  /* Playful elements — controlled bounce */
  --ease-spring:  cubic-bezier(0.34, 1.56, 0.64, 1);
}
```

```typescript
// Remotion / Framer Motion — equivalents
const easings = {
  enter:   [0.0, 0.0, 0.2, 1],
  exit:    [0.4, 0.0, 1.0, 1],
  smooth:  [0.4, 0.0, 0.2, 1],
  snappy:  [0.2, 0.0, 0.0, 1],
  spring:  { type: "spring", stiffness: 300, damping: 20 },
} as const
```

---

## 4. Component Patterns — Standards

> Source: Material Design 3 — Component motion (m3.material.io/styles/motion/transitions/transition-patterns)

### 4.1 Buttons

```css
.btn {
  transition:
    transform     150ms var(--ease-snappy),
    box-shadow    150ms var(--ease-smooth),
    background    200ms var(--ease-smooth);
}
.btn:hover  { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
.btn:active { transform: scale(0.97); }
```

### 4.2 Cards

```css
.card {
  transition: transform 300ms var(--ease-smooth), box-shadow 300ms var(--ease-smooth);
}
.card:hover { transform: translateY(-4px); box-shadow: 0 8px 24px rgba(0,0,0,0.12); }
```

### 4.3 Modals & Drawers

```css
/* Modal — fade + scale */
.modal-enter { opacity: 0; transform: scale(0.95); }
.modal-enter-active {
  opacity: 1; transform: scale(1);
  transition: opacity 300ms var(--ease-enter), transform 300ms var(--ease-enter);
}
.modal-exit-active {
  opacity: 0; transform: scale(0.95);
  transition: opacity 200ms var(--ease-exit), transform 200ms var(--ease-exit);
}
```

### 4.4 Lists and Grids — Stagger

```typescript
// Framer Motion — stagger entry (0.08s between each item)
const container = {
  hidden: { opacity: 0 },
  show: {
    opacity: 1,
    transition: { staggerChildren: 0.08 }
  }
}
const item = {
  hidden: { opacity: 0, y: 16 },
  show:   { opacity: 1, y: 0, transition: { duration: 0.4, ease: [0.0, 0.0, 0.2, 1] } }
}
```

---

## 5. Remotion — Video Production

> Source: Remotion documentation (remotion.dev/docs)

```typescript
// Standard composition — Social Media Reel (9:16)
import { Composition } from 'remotion'

export const RemotionRoot: React.FC = () => (
  <>
    <Composition
      id="SocialReel"
      component={SocialReelComposition}
      durationInFrames={450}   // 15s at 30fps
      fps={30}
      width={1080}
      height={1920}
    />
    <Composition
      id="HeroAnimation"
      component={HeroComposition}
      durationInFrames={180}   // 6s at 30fps
      fps={30}
      width={1920}
      height={1080}
    />
  </>
)
```

```typescript
// Entry animation with spring — Remotion
import { spring, useCurrentFrame, useVideoConfig } from 'remotion'

export const AnimatedCard: React.FC = () => {
  const frame = useCurrentFrame()
  const { fps } = useVideoConfig()

  const opacity = spring({ frame, fps, config: { damping: 20 }, from: 0, to: 1 })
  const translateY = spring({ frame, fps, config: { stiffness: 300, damping: 20 }, from: 24, to: 0 })

  return (
    <div style={{ opacity, transform: `translateY(${translateY}px)` }}>
      {/* content */}
    </div>
  )
}
```

**Remotion Thresholds:**
- `fps`: **30fps minimum** for social, 24fps acceptable for cinematic
- Resolution: **1080×1920** for Reels/TikTok, **1920×1080** for YouTube/web
- Reel duration: **15–30s** (15s = optimal engagement, TikTok Creator research 2024)

---

## 6. Export Specifications by Platform

> Source: Instagram Creator Guidelines (creators.instagram.com), TikTok Creator Portal (creator.tiktok.com), YouTube Help — upload specs (support.google.com/youtube), Vimeo Compression guidelines (vimeo.com/help/compression)

| Platform | Format | Resolution | Codec | Framerate | Bitrate |
|----------|--------|------------|-------|-----------|---------|
| Instagram Reel | MP4 | 1080×1920 | H.264 | 30fps | 8–12 Mbps |
| TikTok | MP4 | 1080×1920 | H.264 | 30fps | 8–12 Mbps |
| YouTube Short | MP4 | 1080×1920 | H.264 | 30fps | 8–12 Mbps |
| YouTube (landscape) | MP4 | 1920×1080 | H.264 | 24/30fps | 10–15 Mbps |
| Web (hero) | WebM | Variable | VP9 | 24/30fps | 4–8 Mbps |
| Web (fallback) | MP4 | Variable | H.264 | 24/30fps | 4–8 Mbps |

**Audio:** AAC 44.1kHz, 320kbps for music, 128kbps for voice only.

---

## 7. Accessibility — prefers-reduced-motion

> Source: W3C WCAG 2.3 SC 2.3.3 — Animation from Interactions (AAA) (w3.org/TR/WCAG23)
> Source: MDN — prefers-reduced-motion (developer.mozilla.org/fr/docs/Web/CSS/@media/prefers-reduced-motion)
> **Threshold: respecting `prefers-reduced-motion` is mandatory (WCAG 2.3 SC 2.3.3)**

```css
/* ✅ Global pattern — reduce or remove all animations */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration:   0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration:  0.01ms !important;
    scroll-behavior:      auto !important;
  }
}
```

```typescript
// React — utility hook
import { useReducedMotion } from 'framer-motion'

export function AnimatedEntry({ children }: { children: React.ReactNode }) {
  const prefersReduced = useReducedMotion()

  return (
    <motion.div
      initial={{ opacity: 0, y: prefersReduced ? 0 : 16 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: prefersReduced ? 0 : 0.4 }}
    >
      {children}
    </motion.div>
  )
}
```

**Absolute accessibility rules:**
- Never flash > 3 times/second → epileptic risk (WCAG 2.1 SC 2.3.1, legal threshold)
- Infinite animations: always pauseable (button or `prefers-reduced-motion`)
- Excessive parallax → forbidden without fallback (motion sickness, vestibular)

---

## 8. Motion Branding — Animated Visual Identity

> Source: Nielsen Norman Group — "Brand Expression Through Animation" (nngroup.com, 2021)

**A brand's animated signature is defined by 3 parameters:**
1. **Signature easing** — the characteristic curve (e.g.: slightly overshot spring = young/dynamic)
2. **Signature duration** — fast or slow (e.g.: 300ms transitions = modern, professional)
3. **Signature behavior** — stagger, reveal, glide, bounce

```typescript
// Example — animation design system tokens
export const motionTokens = {
  // Brand signature
  brand: {
    enter:    { duration: 400, ease: [0.0, 0.0, 0.2, 1] as const },
    exit:     { duration: 250, ease: [0.4, 0.0, 1.0, 1] as const },
    emphasis: { type: "spring" as const, stiffness: 280, damping: 18 },
  },
  // Micro-interactions
  micro: {
    hover:  { duration: 150, ease: [0.2, 0.0, 0.0, 1] as const },
    active: { duration: 100, ease: [0.4, 0.0, 0.2, 1] as const },
  },
} as const
```

---

## 9. Pre-delivery Checklist

### Blockers

- [ ] `prefers-reduced-motion` respected on all animations
- [ ] No flash > 3 times/second across all animated content
- [ ] UI durations: all ≤ 1500ms
- [ ] Interaction response: ≤ 200ms

### Important

- [ ] Video exports: resolution and bitrate compliant per platform (section 6)
- [ ] Infinite animations: pauseable
- [ ] Stagger: ≤ 0.1s between items (beyond = perceived as slow)
- [ ] Remotion: fps and dimensions correct before render

### Desirable

- [ ] Motion tokens centralized (section 8) — cross-component consistency
- [ ] Tests on real device with `prefers-reduced-motion: reduce` enabled
- [ ] WebM files generated for the web (MP4 fallback)

---

## Sources

| Reference | Link |
|-----------|------|
| Material Design 3 — Motion | m3.material.io/styles/motion |
| Apple HIG — Motion | developer.apple.com/design/human-interface-guidelines/motion |
| W3C WCAG 2.3 SC 2.3.1 | w3.org/TR/WCAG23/#seizures-and-physical-reactions |
| CSS Easing Functions L2 | w3.org/TR/css-easing-2 |
| Nielsen NN/G — Animation | nngroup.com/articles/animation-usability |
| Remotion docs | remotion.dev/docs |
| Instagram Creator specs | creators.instagram.com/tools-and-resources/formats-and-specs |
| TikTok Creator Portal | creator.tiktok.com/creator-portal |
| YouTube upload specs | support.google.com/youtube/answer/1722171 |
| MDN — prefers-reduced-motion | developer.mozilla.org/fr/docs/Web/CSS/@media/prefers-reduced-motion |
