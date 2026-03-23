# Contrat — Design System & UI

> Module de contrat SQWR Project Kit — enrichi avec références scientifiques.
> Sources : Itten, Munsell, Wertheimer/Köhler (Gestalt), Bringhurst, Baymard Institute, WCAG 2.1 W3C, Dr. Pamela Rutledge.

---

## Fondements scientifiques

**62-90% du jugement utilisateur sur une interface est basé sur la couleur seule** (Dr. Pamela Rutledge, Media Psychology Research Center). Les décisions de design ne sont pas esthétiques — elles sont cognitives.

---

## 1. Théorie des couleurs

### Systèmes d'harmonie (Johannes Itten, Albert Munsell)

| Système | Principe | Usage |
|---------|----------|-------|
| **Complémentaire** | Couleurs opposées sur la roue (180°) | Contraste fort, attention, CTAs |
| **Analogique** | Couleurs adjacentes (30-60°) | Harmonie naturelle, cohérence visuelle |
| **Triadique** | 3 couleurs à 120° (triangle équilatéral) | Vivacité équilibrée |
| **Split-complémentaire** | Couleur + 2 voisines de son complément | Contraste doux, polyvalent |

**Règle d'attribution des rôles (hiérarchie couleur) :**
- **Dominante** (60%) : fond, surfaces neutres
- **Secondaire** (30%) : éléments structurants, navigation
- **Accent** (10%) : CTAs, alertes, liens actifs

### Seuils de contraste WCAG 2.1 (W3C — standard légal)

| Niveau | Texte normal | Grand texte (≥18pt ou ≥14pt bold) | Graphiques & UI |
|--------|-------------|----------------------------------|----------------|
| **AA (minimum)** | 4.5:1 | 3:1 | 3:1 |
| **AAA (optimal)** | 7:1 | 4.5:1 | — |

**Outil de vérification :** WebAIM Contrast Checker (webaim.org/resources/contrastchecker)

> Source : W3C WCAG 2.1 SC 1.4.3 — [w3.org/WAI/WCAG21/Understanding/contrast-minimum](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)

### Espaces couleur modernes (W3C 2025)
Les professionnels de niveau avancé préparent pour **Display P3** et **Oklch** (CSS Color Level 4). L'amateur reste en sRGB/hex. Pour les projets SQWR actuels : hex + vérification WCAG suffisent.

---

## 2. Typographie & Lisibilité

> Source principale : Lesia Rello & Martin Pielot (CHI 2016 — étude sur la taille de police optimale), Baymard Institute (étude longueur de ligne), Robert Bringhurst (*The Elements of Typographic Style*)

### Seuils mesurables — obligatoires

| Paramètre | Seuil | Raison scientifique |
|-----------|-------|---------------------|
| **Taille corps minimum** | 16px (idéal 18px) | Sous 14px = augmentation mesurée de la fatigue oculaire (Rello & Pielot) |
| **Longueur de ligne (desktop)** | 50-75 caractères/ligne | Sweet spot = 66 CPL. Au-delà = perte de tracé oculaire (Baymard) |
| **Longueur de ligne (mobile)** | 30-50 caractères/ligne | — |
| **WCAG max characters** | ≤80 (anglais/français), ≤40 (CJK) | WCAG 2.1 SC 1.4.8 |
| **Interligne (line-height)** | 1.5 × taille police | Prévient les "rivières blanches" et la perte de ligne |

**Implementation CSS :**
```css
/* ✅ Largeur de colonne de texte : forcer les seuils mesurables */
.prose {
  max-width: 75ch;      /* 75 caractères max */
  font-size: 1rem;      /* 16px minimum */
  line-height: 1.5;     /* ratio 1.5 obligatoire */
}
```

### Modular Scale (Robert Bringhurst)

Au lieu de tailles arbitraires, utiliser un **ratio mathématique** pour la hiérarchie typographique :

| Ratio | Nom | Application |
|-------|-----|-------------|
| ×1.618 | Golden Ratio | Titres impactants, présence forte |
| ×1.5 | Perfect Fifth | Usage web général, équilibré |
| ×1.333 | Perfect Fourth | Interface dense, hiérarchie subtile |

```
Base: 16px → ×1.5 = 24px → ×1.5 = 36px → ×1.5 = 54px → ×1.5 = 81px
```

**Jamais de tailles arbitraires** (`12px → 20px → 32px → 48px` = signale du travail amateur).

---

## 3. Les 7 Lois de Gestalt (Wertheimer, Koffka, Köhler — 1920s)

> Base scientifique universelle de la perception visuelle humaine. Établies par la psychologie expérimentale, non remises en question depuis 1960.

| Loi | Principe | Application UI concrète |
|-----|----------|------------------------|
| **Proximité** | Éléments proches = perçus comme liés | Grouper les champs d'un formulaire (8-16px), séparer les sections (32px+) |
| **Similarité** | Même apparence = même fonction | Tous les boutons primaires = même couleur ; tous les liens = même style |
| **Continuité** | L'œil suit les lignes et courbes | Alignements, grilles, animations qui guident le regard |
| **Fermeture** | Le cerveau complète les formes incomplètes | Icônes minimalistes encore lisibles ; espaces négatifs intentionnels |
| **Figure-fond** | Séparation premier plan / arrière-plan | Contraste suffisant entre contenu et fond |
| **Symétrie** | Arrangements symétriques = ordre | Layouts équilibrés réduisent la charge cognitive |
| **Destin commun** | Éléments qui bougent ensemble = liés | Animations groupant des éléments relatifs |

**Règle d'application :** toute violation consciente d'une loi Gestalt doit être documentée avec sa justification.

---

## 4. Hiérarchie visuelle

### Eye-tracking & patterns de lecture (Nielsen Norman Group)

- **Pattern F** (contenu texte dense) : balayage horizontal en haut → vertical gauche → horizontal milieu
- **Pattern Z** (interfaces éparses) : coin haut-gauche → coin haut-droit → diagonal → coin bas-droit

**Implication :** placer les CTAs primaires dans les zones de fort engagement (haut-gauche, haut-droit).

### Espacement systématique (base 8px)

| Usage | Valeur |
|-------|--------|
| Espacement interne (padding tight) | 8px |
| Espacement interne (padding normal) | 16px |
| Espacement entre éléments liés | 8-16px |
| Espacement entre sections | 32-48px |
| Espacement entre blocs majeurs | 64-96px |

**Ratio espacement négatif/positif : 30-50% d'espace blanc optimal.**

---

## 5. Identité visuelle — Tokens à définir par projet

> Remplir avec les valeurs de votre charte graphique.
> Voir `frameworks/BRAND-STRATEGY.md` pour définir la stratégie avant de choisir les couleurs.

**Palette principale**

| Token | Valeur | Usage |
|-------|--------|-------|
| `brand-primary` | `[À COMPLÉTER — ex: #0A0A0A]` | Couleur dominante (60%) — fond ou couleur forte |
| `brand-secondary` | `[À COMPLÉTER — ex: #F5F5F0]` | Couleur secondaire (30%) — éléments structurants |
| `brand-accent` | `[À COMPLÉTER — ex: #FF4D00]` | Accent (10%) — CTAs, liens actifs, alertes |

**Exemple minimal Tailwind (`tailwind.config.ts`) :**
```ts
colors: {
  'brand-primary': '[votre couleur]',
  'brand-secondary': '[votre couleur]',
  'brand-accent': '[votre couleur]',
}
```

> Documenter votre design system complet dans `docs/design-system.md` de votre projet.

---

## 6. Règles Tailwind

### Ne jamais faire

- **Styles inline** (`style={{ color: 'red' }}`) — toujours des classes Tailwind
- **Valeurs arbitraires excessives** (`w-[347px]`) — utiliser la grille de spacing Tailwind
- **Tailles de police sous 16px** pour le corps de texte
- **Mélanger Tailwind v3 et v4 syntax** dans le même projet

### Toujours faire

- Utiliser les tokens définis dans `tailwind.config.ts`
- Grouper les classes dans l'ordre : layout → spacing → typography → colors → effects
- Extraire les classes répétées dans des composants

```tsx
// ✅ Ordre cohérent, lisible
<div className="flex items-center gap-4 px-6 py-3 text-base font-medium text-sqwr-black bg-sqwr-white rounded-lg shadow-sm hover:shadow-md transition-shadow">
```

---

## 7. Composants — Règles générales

### Atomic Design (Brad Frost)

| Niveau | Description | Exemples |
|--------|------------|---------|
| **Atoms** | Éléments indivisibles | Button, Input, Label, Icon |
| **Molecules** | Combinaisons simples | SearchForm (Input + Button) |
| **Organisms** | Sections fonctionnelles | ProductCard, NavigationBar |
| **Templates** | Structure de page (sans contenu réel) | PageLayout |
| **Pages** | Contenu réel dans templates | HomePage, AboutPage |

```tsx
// Structure d'un composant
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

- Préférer Framer Motion (déclaratif, React-natif) pour composants
- GSAP pour animations timeline/canvas complexes
- **Toujours respecter `prefers-reduced-motion`** — obligation WCAG

```tsx
// ✅ Obligatoire sur toute animation
const shouldReduceMotion = useReducedMotion()
const animation = shouldReduceMotion ? {} : { opacity: [0, 1], y: [20, 0] }
```

---

## 9. Psychologie du Design — Ancrage Académique

> Ces principes complètent les règles de design du kit avec des fondements issus de la recherche cognitive et comportementale. Ils s'appliquent à tout projet avec une composante UI, quelle que soit la stack.

### 9.1 Processing Fluency

**Principe :** Plus un stimulus visuel est fluent à traiter cognitivement, plus il est perçu comme beau et fiable — ce jugement est pré-cognitif et se produit en moins de 3 secondes.

| Variable | Effet sur la fluence |
|----------|---------------------|
| Figural goodness (formes simples et régulières) | Augmente |
| Contraste élevé | Augmente |
| Symétrie | Augmente |
| Répétition de motifs | Augmente |

**Threshold :** Jugement de beauté = < 3 secondes (avant toute lecture).

**Implication :** Un design system cohérent (grille, échelle typographique, palette limitée) génère de la confiance avant même que l'utilisateur lise le contenu. Toute incohérence visuelle dégrade la fluence et donc la crédibilité perçue.

**(Reber, Schwarz & Winkielman, 2004 — Personality and Social Psychology Review, 8(4), 364–382)**

---

### 9.2 Peak-End Rule

**Principe :** Les humains jugent une expérience par son moment PEAK (le point d'intensité maximale) et sa FIN — pas par sa durée totale ni par la moyenne des moments.

**Threshold :** Investir ≥ 60% du budget d'animation et de soin visuel sur le moment signature (hero section) et le exit de page.

**Implication :** 1 moment signature fort + un footer soigné surpasse 47 micro-animations médiocres réparties sur la page. Identifier et suroptimiser le point émotionnel maximal de chaque page avant de traiter les détails intermédiaires.

**(Kahneman & Frederickson, 1993 — Psychological Science, 4(6), 409–415)**

---

### 9.3 Isolation Effect (Von Restorff)

**Principe :** Un élément distinctif parmi des éléments homogènes est mieux mémorisé que les éléments uniformes environnants.

**Threshold :** 95% de surface sobre et cohérente + 5% de rupture intentionnelle radicale = mémorabilité maximale.

**Anti-patterns :**
- 100% "propre et sobre" = aucun point focal = rien de mémorable
- 100% animé ou contrasté = saturation = aucun élément ne se détache

**Implication :** Choisir délibérément 1 seul élément par page comme point de rupture (couleur, typographie, taille, mouvement). Tout le reste doit être cohérent pour que la rupture fonctionne.

**(Von Restorff, 1933 — Psychologische Forschung, 18, 299–342)**

---

### 9.4 Optimal Complexity (Berlyne)

**Principe :** Le plaisir esthétique suit une courbe en U inversé selon la complexité visuelle — la complexité intermédiaire produit le plaisir maximal.

| Niveau de complexité | Réponse |
|---------------------|---------|
| Trop faible | Ennui, désengagement |
| Intermédiaire | Plaisir esthétique maximal |
| Trop élevé | Confusion, rejet |

**Implication :** Un design system cohérent (réduction de la complexité) + 1 convention intentionnellement brisée (injection de complexité ciblée) = point optimal. Ne pas viser ni le maximalisme ni le minimalisme absolu.

**(Berlyne, 1971 — Aesthetics and Psychobiology, Appleton-Century-Crofts)**

---

### 9.5 Aesthetic-Usability Effect

**Principe :** Un design beau est perçu comme plus utilisable — même lorsque l'usabilité fonctionnelle réelle est identique à celle d'un design moins esthétique.

**Threshold :** Corrélation r = 0.73 entre beauté perçue et usabilité perçue (Tractinsky, 2000).

**Implication ROI :** L'investissement esthétique produit une meilleure satisfaction, une meilleure tolérance aux frictions et une perception de qualité supérieure. Le design "fonctionnel mais laid" n'est pas neutre — il dégrade activement la satisfaction.

**(Kurosu & Kashimura, 1995 — CHI Conference Companion, 292–293)**
**(Tractinsky, Katz & Ikar, 2000 — Interacting with Computers, 13(2), 127–145)**

---

### 9.6 Anti-Laws of Luxury Design (Kapferer)

**Principe :** Le design de marques premium suit des règles inverses au marketing de masse. 6 anti-lois applicables au digital :

| Anti-loi | Application design |
|----------|-------------------|
| Ne jamais se comparer | Zéro référence à la concurrence dans le copy ou les visuels |
| Maintenir la rareté | Pas de "disponible maintenant" — la friction est un signal de valeur |
| Rendre l'accès difficile | Contact = candidature, pas checkout instantané |
| Communiquer au-delà des acheteurs | Le rêve dépasse la cible — l'aspirationnel est une fonctionnalité |
| Just enough imperfection | Légère irrégularité intentionnelle = signature artisanale |
| Jamais afficher les tarifs sans contexte | Le prix est un signal de valeur, pas un point d'entrée |

**Implication technique :** Grille légèrement visible (opacity 0.02–0.04), courbes d'easing custom (pas les défauts navigateur), asymétries géométriques intentionnelles documentées.

**(Kapferer & Bastien, 2009, 2e éd. 2012 — The Luxury Strategy, Kogan Page)**

---

### 9.7 Color Psychology — Rouge et dominance

**Principe :** Le rouge est un signal de dominance, de statut et de capture d'attention maximale.

**Threshold :** Utiliser le rouge < 10% de la surface totale (rôle d'accent exclusivement).

**Contre-indication :** Le rouge inhibe la performance cognitive par association au signal de danger — à éviter sur les CTAs informatifs, les formulaires et les zones de lecture. Le réserver aux alertes et aux accents de marque.

**(Elliot & Maier, 2007 — Current Directions in Psychological Science, 16(5), 250–254)**

---

### 9.8 Typeface Personality

**Principe :** La typographie est perçue selon 3 dimensions : Potency (force/autorité), Evaluative (élégance/qualité), Activity (énergie/dynamisme).

| Contexte | Choix typographique | Effet |
|----------|--------------------|----|
| Projets premium, titres | Sérif | Signal d'autorité et de fiabilité supérieure au sans-sérif |
| Corps de texte, UI | Sans-sérif | Lisibilité optimale à taille réduite |
| Display/hero (72–120px+) | Sérif display ou sans-sérif condensé | Impact émotionnel maximal |

**Threshold ratio :** Minimum 1.5:1 entre niveaux de hiérarchie typographique (Golden Ratio 1.618 recommandé — cf. Section 2).

**(Li & Suen, 2010 — Proceedings of DAS 2010)**
**(MIT AgeLab & Monotype, 2019 — Emotional Response to Type)**

---

### 9.9 Standards d'Animation — Thresholds de timing

> Sources : Apple HIG (developer.apple.com/design/human-interface-guidelines), Google Material Design 3 (m3.material.io), WCAG 2.1 SC 2.3.3

| Type d'interaction | Durée cible | Règle |
|-------------------|-------------|-------|
| Small interactions (boutons, toggles, focus) | 200–350ms | En dessous = imperceptible. Au-dessus = lent. |
| Large transitions (pages, modals, drawers) | 400–600ms | Laisser l'utilisateur percevoir le changement de contexte |
| Stagger entre éléments d'une liste | 50–100ms | Délai entre chaque enfant pour guider le regard |

**Règles absolues :**
- **Custom easing obligatoire** — jamais `ease-in-out` navigateur par défaut. Définir des courbes de Bézier spécifiques au projet.
- **`prefers-reduced-motion` toujours respecté** — obligation WCAG 2.1 SC 2.3.3.

```tsx
// ✅ Easing custom — exemple
const easing = [0.16, 1, 0.3, 1] // ease-out-expo

// ✅ prefers-reduced-motion obligatoire
const shouldReduceMotion = useReducedMotion()
const transition = shouldReduceMotion
  ? { duration: 0 }
  : { duration: 0.4, ease: easing }
```

**Display typography — thresholds hero :**
- Titres héros : 72–120px+ pour impact émotionnel maximal
- Whitespace ≥ 40% de la surface pour signal premium **(Baymard Institute)**

---

## 10. Color Scale — Cohérence Perceptuelle

> Source : Fairchild, M.D. — *Color Appearance Models*, 3e éd. (Wiley, 2013) — CIECAM02/CIELAB
> Source : Izzico Design System (terrain — couleurs de rôle, validé avec WCAG AA)

### ΔE — Seuil de distinction perceptuelle

**Threshold : ΔE > 7 entre deux couleurs censées être distinctes** — seuil humain de discrimination (CIELAB). En dessous, les utilisateurs risquent de confondre deux couleurs.

| ΔE | Perception |
|----|-----------|
| 0–1 | Imperceptible |
| 1–3 | Subtile (visible en comparaison directe) |
| 3–7 | Modérée (visible à l'œil nu) |
| >7 | **Clairement distincte** ← threshold SQWR |

**Outil de calcul ΔE :** Colorpedia (colorpedia.io) ou Adobe Color.

### L* Progression pour les scales de couleur

Pour créer des scales de 50 à 900 (style Tailwind) :

```
L* doit décroître monotoniquement de 50 (clair) → 900 (foncé)
Exemple correct :    50 → L*=95, 100 → L*=88, 500 → L*=50, 900 → L*=15
Exemple incorrect :  50 → L*=95, 100 → L*=93, 200 → L*=94 ← inversion = erreur
```

**Implication :** Pour les systèmes multi-rôle (ex: Owner/Resident/Seeker), vérifier que les couleurs à même niveau (ex: tous les -500) ont des ΔE > 7 entre elles.

---

## 11. Voice & Tone — Matrice par Segment

> Source : Nielsen Norman Group — 4 Dimensions of Tone of Voice
> [nngroup.com/articles/tone-of-voice-dimensions](https://www.nngroup.com/articles/tone-of-voice-dimensions)

**Le design ne s'arrête pas au visuel.** Le copywriting est une composante du design — chaque surface UI contient du texte, et ce texte communique une personnalité de marque. La cohérence tone/visuel est ce qui fait qu'une interface paraît "professionnelle" ou "générique".

### Les 4 dimensions Nielsen NN/G

| Dimension | Pôle bas | Pôle haut |
|-----------|---------|----------|
| Formalité | Casual (1) | Formel (5) |
| Humour | Sérieux (1) | Humoristique (5) |
| Irrévérence | Respectueux (1) | Irrévérencieux (5) |
| Énergie | Neutre (1) | Enthousiaste (5) |

**Usage :** définir la matrice dans `CLAUDE.md` du projet. Claude Code l'applique ensuite sur tous les textes UI générés.

### Template de matrice à documenter par projet

```markdown
## Tone of Voice — [Nom du projet]

### Segment : [ex: Utilisateurs B2C]
| Dimension | Score | Exemple |
|-----------|-------|---------|
| Formalité | 4/5 (casual) | "Hello [Prénom] !" |
| Humour | 3/5 (léger) | "Tu dois X€ à Lucas 💸" |
| Irrévérence | 3/5 | "Tes colocs aussi ont du mal à finir le mois..." |
| Énergie | 4/5 | Verbes d'action, phrases courtes |

### Segment : [ex: Utilisateurs B2B / propriétaires]
| Dimension | Score | Exemple |
|-----------|-------|---------|
| Formalité | 2/5 (neutre) | "Bonjour [Prénom]" |
| Humour | 2/5 (sobre) | Pas d'humour sur sujets financiers |
| Irrévérence | 1/5 (respectueux) | Vouvoiement |
| Énergie | 3/5 | Professionnel, factuel |

### Mots interdits
- [corporate speak] : "leverage", "synergy", "seamless"
- [jargon secteur à éviter] : ...

### Mots propriétaires
- [terme de marque 1] : utilisé à la place de [terme générique]
- [terme de marque 2] : ...
```

**Règle multi-segments :** si la plateforme s'adresse à des types d'utilisateurs différents (B2C + B2B, juniors + seniors), définir une matrice distincte par segment. Confondre les tonalités crée une expérience incohérente.

---

## 12. Sources scientifiques

| Référence | Usage |
|-----------|-------|
| Johannes Itten — *Kunst der Farbe* (1961) | Systèmes d'harmonie couleur |
| Albert Munsell — Munsell Color System (1905) | Mesure scientifique des couleurs |
| Dr. Pamela Rutledge — Media Psychology Research (2024) | Cognition et couleur |
| Wertheimer, Koffka, Köhler (1920-1960) | 7 lois Gestalt |
| Robert Bringhurst — *The Elements of Typographic Style* (1992) | Modular scale, typographie |
| Lesia Rello & Martin Pielot — CHI 2016 | Taille de police optimale |
| Baymard Institute — Line Length Study | CPL 50-75, whitespace premium |
| Nielsen Norman Group — Eye-tracking studies | F/Z patterns, hiérarchie |
| W3C WCAG 2.1 — SC 1.4.3, 1.4.8, 2.3.3 | Contrastes, longueur de ligne, motion |
| Brad Frost — *Atomic Design* (2016) | Hiérarchie de composants |
| W3C Design Tokens Community Group (2025.10) | Standard tokens cross-platform |
| Reber, Schwarz & Winkielman (2004) — *Personality and Social Psychology Review* | Processing Fluency |
| Kahneman & Frederickson (1993) — *Psychological Science* | Peak-End Rule |
| Von Restorff (1933) — *Psychologische Forschung* | Isolation Effect, mémorabilité |
| Berlyne (1971) — *Aesthetics and Psychobiology* | Optimal Complexity |
| Kurosu & Kashimura (1995) — CHI | Aesthetic-Usability Effect |
| Tractinsky, Katz & Ikar (2000) — *Interacting with Computers* | Aesthetic-Usability Effect (r=0.73) |
| Kapferer & Bastien (2009, 2e éd. 2012) — *The Luxury Strategy* | Anti-Laws of Luxury Design |
| Elliot & Maier (2007) — *Current Directions in Psychological Science* | Color Psychology, rouge |
| Li & Suen (2010) — *Proceedings of DAS 2010* | Typeface Personality |
| MIT AgeLab & Monotype (2019) — *Emotional Response to Type* | Typeface Personality |
| Apple Human Interface Guidelines (developer.apple.com) | Animation timing standards |
| Google Material Design 3 (m3.material.io) | Animation timing standards |
| Nielsen Norman Group — 4 Dimensions of Tone of Voice (nngroup.com) | Voice & Tone matrix |
| Fairchild, M.D. — *Color Appearance Models* 3e éd. (Wiley, 2013) | CIECAM02/CIELAB ΔE |
