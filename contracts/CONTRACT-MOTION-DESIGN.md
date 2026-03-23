# Contrat — Motion Design & Animation

> Module de contrat SQWR Project Kit.
> Sources : Material Design 3 Motion (m3.material.io/styles/motion), Apple HIG — Motion (developer.apple.com/design/human-interface-guidelines/motion), W3C WCAG 2.3 — Seizure and Physical Reactions (w3.org/TR/WCAG23), CSS Easing Functions Level 2 (w3.org/TR/css-easing-2), Remotion docs (remotion.dev/docs), Nielsen Norman Group — Animation for Attention and Comprehension (nngroup.com).

---

## Fondements

**Principe fondamental : Animation = Communication.** Tout mouvement a un but. Une animation sans raison est du bruit visuel.

> « L'animation sert à guider l'attention, à maintenir la continuité entre les états, et à fournir un feedback sur les interactions — pas à décorer. »
> — Nielsen Norman Group, "Animation for Attention and Comprehension"

Ce contrat couvre : animations UI web/app, motion design social (Reels, TikTok), video production avec Remotion, et accessibilité des animations.

---

## 1. Règle des 200ms — Feedback utilisateur

> Source : Material Design 3 — Motion speed (m3.material.io/styles/motion/applying-motion/motion-parameters)
> **Threshold : ≤200ms pour toute animation déclenchée par une interaction utilisateur**

```css
/* ✅ Micro-interactions — réponse immédiate */
.button {
  transition: transform 150ms cubic-bezier(0.2, 0, 0, 1),
              box-shadow 150ms cubic-bezier(0.2, 0, 0, 1);
}

.button:hover  { transform: translateY(-2px); }
.button:active { transform: scale(0.97); }
```

Au-delà de 200ms, l'utilisateur perçoit un **lag** — la réponse ne semble plus instantanée (Miller's Law : seuil de "immédiat" = 100-200ms).

---

## 2. Durées standard

> Source : Material Design 3 — Duration tokens (m3.material.io/styles/motion/easing-and-duration/tokens-specs)
> Source : Apple HIG — Animation duration (developer.apple.com/design/human-interface-guidelines/motion)

| Catégorie | Durée | Usage |
|-----------|-------|-------|
| **Instant** | 50–100ms | Hover state, focus ring |
| **Micro** | 150–200ms | Boutons, icônes, toggles |
| **Petite** | 200–300ms | Tooltips, chips, badges |
| **Moyenne** | 300–500ms | Cards, modals, drawers |
| **Grande** | 500–800ms | Page transitions, sidebars |
| **Héro** | 800–1500ms | Animations d'entrée landing page |

**Règle absolue : jamais d'animation UI > 1500ms.** Au-delà, l'utilisateur perd patience (NN/G research, 2019).

---

## 3. Courbes d'easing

> Source : CSS Easing Functions Level 2 — W3C Working Draft (w3.org/TR/css-easing-2)
> Source : Material Design 3 — Easing (m3.material.io/styles/motion/easing-and-duration/applying-easing)

```css
:root {
  /* Entrer dans l'écran — décélère à l'arrivée */
  --ease-enter:   cubic-bezier(0.0, 0.0, 0.2, 1);   /* Material: Emphasized decelerate */

  /* Quitter l'écran — accélère au départ */
  --ease-exit:    cubic-bezier(0.4, 0.0, 1, 1);      /* Material: Emphasized accelerate */

  /* Dans l'écran — transitions d'état */
  --ease-smooth:  cubic-bezier(0.4, 0.0, 0.2, 1);   /* Material: Standard */

  /* Réponse rapide — snappy */
  --ease-snappy:  cubic-bezier(0.2, 0.0, 0.0, 1);

  /* Éléments ludiques — bounce contrôlé */
  --ease-spring:  cubic-bezier(0.34, 1.56, 0.64, 1);
}
```

```typescript
// Remotion / Framer Motion — équivalents
const easings = {
  enter:   [0.0, 0.0, 0.2, 1],
  exit:    [0.4, 0.0, 1.0, 1],
  smooth:  [0.4, 0.0, 0.2, 1],
  snappy:  [0.2, 0.0, 0.0, 1],
  spring:  { type: "spring", stiffness: 300, damping: 20 },
} as const
```

---

## 4. Patterns de composants — Standards

> Source : Material Design 3 — Component motion (m3.material.io/styles/motion/transitions/transition-patterns)

### 4.1 Boutons

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

### 4.4 Listes et grilles — Stagger

```typescript
// Framer Motion — entrée en stagger (0.08s entre chaque item)
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

## 5. Remotion — Production video

> Source : Remotion documentation (remotion.dev/docs)

```typescript
// Composition standard — Social Media Reel (9:16)
import { Composition } from 'remotion'

export const RemotionRoot: React.FC = () => (
  <>
    <Composition
      id="SocialReel"
      component={SocialReelComposition}
      durationInFrames={450}   // 15s à 30fps
      fps={30}
      width={1080}
      height={1920}
    />
    <Composition
      id="HeroAnimation"
      component={HeroComposition}
      durationInFrames={180}   // 6s à 30fps
      fps={30}
      width={1920}
      height={1080}
    />
  </>
)
```

```typescript
// Animation d'entrée avec spring — Remotion
import { spring, useCurrentFrame, useVideoConfig } from 'remotion'

export const AnimatedCard: React.FC = () => {
  const frame = useCurrentFrame()
  const { fps } = useVideoConfig()

  const opacity = spring({ frame, fps, config: { damping: 20 }, from: 0, to: 1 })
  const translateY = spring({ frame, fps, config: { stiffness: 300, damping: 20 }, from: 24, to: 0 })

  return (
    <div style={{ opacity, transform: `translateY(${translateY}px)` }}>
      {/* contenu */}
    </div>
  )
}
```

**Thresholds Remotion :**
- `fps` : **30fps minimum** pour le social, 24fps acceptable pour cinématique
- Résolution : **1080×1920** pour Reels/TikTok, **1920×1080** pour YouTube/web
- Durée Reel : **15–30s** (15s = optimal engagement, TikTok Creator research 2024)

---

## 6. Spécifications d'export par plateforme

> Source : Instagram Creator Guidelines (creators.instagram.com), TikTok Creator Portal (creator.tiktok.com), YouTube Help — upload specs (support.google.com/youtube), Vimeo Compression guidelines (vimeo.com/help/compression)

| Plateforme | Format | Résolution | Codec | Framerate | Bitrate |
|------------|--------|------------|-------|-----------|---------|
| Instagram Reel | MP4 | 1080×1920 | H.264 | 30fps | 8–12 Mbps |
| TikTok | MP4 | 1080×1920 | H.264 | 30fps | 8–12 Mbps |
| YouTube Short | MP4 | 1080×1920 | H.264 | 30fps | 8–12 Mbps |
| YouTube (paysage) | MP4 | 1920×1080 | H.264 | 24/30fps | 10–15 Mbps |
| Web (hero) | WebM | Variable | VP9 | 24/30fps | 4–8 Mbps |
| Web (fallback) | MP4 | Variable | H.264 | 24/30fps | 4–8 Mbps |

**Audio :** AAC 44.1kHz, 320kbps pour musique, 128kbps pour voix seule.

---

## 7. Accessibilité — prefers-reduced-motion

> Source : W3C WCAG 2.3 SC 2.3.3 — Animation from Interactions (AAA) (w3.org/TR/WCAG23)
> Source : MDN — prefers-reduced-motion (developer.mozilla.org/fr/docs/Web/CSS/@media/prefers-reduced-motion)
> **Threshold : respecter `prefers-reduced-motion` est obligatoire (WCAG 2.3 SC 2.3.3)**

```css
/* ✅ Pattern global — réduire ou supprimer toutes les animations */
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
// React — hook utilitaire
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

**Règles absolues accessibilité :**
- Jamais de flash > 3 fois/seconde → risque épileptique (WCAG 2.1 SC 2.3.1, seuil légal)
- Animations infinites : toujours pauseables (bouton ou `prefers-reduced-motion`)
- Parallax excessif → interdit sans fallback (mal des transports, vestibulaire)

---

## 8. Motion Branding — Identité visuelle animée

> Source : Nielsen Norman Group — "Brand Expression Through Animation" (nngroup.com, 2021)

**La signature animée d'une marque se définit par 3 paramètres :**
1. **Easing signature** — la courbe caractéristique (ex: spring légèrement overshot = jeune/dynamique)
2. **Durée signature** — rapide ou lente (ex: transitions 300ms = moderne, professionnel)
3. **Comportement signature** — stagger, reveal, glide, bounce

```typescript
// Exemple — design system tokens d'animation
export const motionTokens = {
  // Signature de marque
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

## 9. Checklist avant livraison

### Bloquants

- [ ] `prefers-reduced-motion` respecté sur toutes les animations
- [ ] Aucun flash > 3 fois/seconde sur l'ensemble du contenu animé
- [ ] Durées UI : toutes ≤ 1500ms
- [ ] Réponse interactions : ≤ 200ms

### Importants

- [ ] Exports vidéo : résolution et bitrate conformes par plateforme (section 6)
- [ ] Animations infinites : pauseables
- [ ] Stagger : ≤ 0.1s entre items (au-delà = lent perçu)
- [ ] Remotion : fps et dimensions corrects avant render

### Souhaitables

- [ ] Motion tokens centralisés (section 8) — cohérence cross-composants
- [ ] Tests sur appareil réel avec `prefers-reduced-motion: reduce` activé
- [ ] Fichiers WebM générés pour le web (fallback MP4)

---

## Sources

| Référence | Lien |
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
