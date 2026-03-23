# Contrat — Production Vidéo & Studio IA

> Module de contrat SQWR Project Kit.
> Sources : Instagram Creator Guidelines (creators.instagram.com), TikTok Creator Portal (creator.tiktok.com), YouTube Technical Specs (support.google.com/youtube), Remotion docs (remotion.dev), 11ElevenLabs docs (elevenlabs.io/docs), Nielsen NN/G — Video Usability (nngroup.com), Meta Business — Video Best Practices (business.meta.com).

---

## Fondements

**Le studio de production vidéo moderne est virtuel** — piloté par des outils IA et des workflows Claude Code structurés. Il remplace une équipe de 5-10 personnes par une stack d'outils pilotée par 1-2 personnes avec la méthode correcte.

**Stack de référence :**
| Outil | Rôle | Coût mensuel |
|-------|------|-------------|
| **Remotion** | Composition vidéo programmatique (React) | Gratuit + ~$0.05/render |
| **Veo / Gemini** | B-roll IA, footage lifestyle | Pay-per-use |
| **ElevenLabs** | Voiceover IA | $0–22/mois |
| **Canva** | Stories, templates rapides | Inclus plan existant |
| **Higgsfield** | Motion graphics premium | $75/mois (Phase 4) |

**Budget par phase :**
- Phase 1 (fondations) : ~$5–10/mois
- Phase 2 (social régulier) : ~$30–50/mois
- Phase 3 (démos produit) : ~$75–100/mois
- Phase 4 (campagnes) : ~$150–200/mois

---

## 1. Arbre de décision — Quel outil pour quel contenu ?

> Source : Remotion docs — Use cases (remotion.dev/docs/use-cases)

```
Contenu à produire
│
├── Demo UI / app en mouvement ?
│   └── → Remotion (réutilise les composants React du projet)
│
├── Footage lifestyle / scènes humaines / b-roll ?
│   └── → Veo / Gemini (génération IA)
│
├── Data visualization / motion graphics complexes ?
│   ├── Budget Phase 4 → Higgsfield
│   └── Sinon → Remotion custom composition
│
├── Story ou animation simple rapide ?
│   └── → Canva (itération rapide)
│
└── Default → Remotion
```

---

## 2. Pipeline de production — 5 phases

> Source : Meta Business — Creative Production Process (business.meta.com/creative-guidance)

### Phase 1 : Brief

Template obligatoire pour toute production :

```markdown
## Brief vidéo

**Objectif :** [Notoriété / Conversion / Rétention / Éducation]
**Audience cible :** [Persona + âge + contexte]
**Durée :** [Xs]
**Format :** [Reel 9:16 / YouTube 16:9 / Story 9:16 / Hero web]
**Plateforme(s) :** [Instagram / TikTok / YouTube / Web]
**Voiceover :** [Oui (ElevenLabs) / Non / Humain]
**Musique :** [Style + émotion cible]
**CTA :** [Action souhaitée à la fin]
**Assets disponibles :** [Logo, photos produit, screenshots app...]
**Deadline :** [Date]
```

### Phase 2 : Création

Suivre l'arbre de décision (section 1). Ouvrir le brief dans Claude Code avant toute génération.

### Phase 3 : Review — Checklist qualité

```
BRANDING
  [ ] Couleurs conformes au design system
  [ ] Logo visible et correctement placé
  [ ] Typographie de la marque utilisée
  [ ] Ton conforme à la brand voice

TECHNIQUE
  [ ] Résolution correcte pour la plateforme (section 4)
  [ ] Audio clair, pas de saturation (-14 LUFS target)
  [ ] Durée dans les limites plateforme
  [ ] Pas d'éléments coupés aux bords

UX & ENGAGEMENT
  [ ] Message lisible en 3 secondes (hook visuel)
  [ ] Sous-titres présents (85% regardent sans son — Meta, 2023)
  [ ] CTA visible et lisible
  [ ] Première frame accrochante (scroll-stop)
```

### Phase 4 : Export

Voir section 4 — Spécifications par plateforme.

### Phase 5 : Publication

```markdown
## Métadonnées publication

- **Titre :** [60 caractères max pour YouTube]
- **Caption :** [Hook + contenu + CTA + hashtags]
- **Hashtags :** [3–5 core + 5–10 niche — éviter les hashtags génériques]
- **Thumbnail :** [Personnalisée — jamais la frame auto]
- **UTM link :** [Traçabilité analytics]
- **Publication :** [Horaire optimal — voir section 5]
```

---

## 3. Règles de contenu vidéo

> Source : Nielsen NN/G — "Video Usability" (nngroup.com, 2023)
> Source : Meta Business — "Video Best Practices" (business.meta.com)

### Hook — les 3 premières secondes

**Threshold : le message principal doit être compris en ≤3 secondes** (NN/G, 2023 — 73% des décisions de scroll se font dans les 3 premières secondes).

```
❌ Mauvais hook : Intro avec logo + musique (2s perdues)
✅ Bon hook   : Texte + image impactante dès la frame 1
✅ Bon hook   : Question provocatrice en overlay
✅ Bon hook   : Stat choc en texte large
```

### Sous-titres — obligatoires

> Source : Meta for Business — "85% of video is watched without sound" (business.meta.com, 2016, confirmé 2023)
> **Threshold : sous-titres sur 100% des vidéos sociales**

```typescript
// Remotion — sous-titres auto via Whisper + @remotion/captions
import { Transcript } from '@remotion/captions'

// Générer avec Whisper (openai) ou AssemblyAI, puis intégrer dans la composition
```

### Durées optimales par plateforme

> Source : TikTok Creator Portal — Optimal video length (creator.tiktok.com)
> Source : Instagram Creator — Reels best practices (creators.instagram.com)
> Source : YouTube Creator Academy — Optimal video length (creatoracademy.youtube.com)

| Plateforme | Optimal | Maximum |
|------------|---------|---------|
| Instagram Reel | **15–30s** | 90s |
| TikTok | **15–60s** | 10min |
| YouTube Short | **30–60s** | 60s |
| YouTube standard | **7–15 min** | illimité |
| Web hero loop | **6–15s** | 30s |
| Story | **7–15s** | 60s |

---

## 4. Spécifications d'export par plateforme

> Source : Instagram Technical Specs (creators.instagram.com/tools-and-resources/formats-and-specs)
> Source : TikTok Video Specs (creator.tiktok.com/creator-portal/en-us/getting-started/video-specs)
> Source : YouTube Upload Specs (support.google.com/youtube/answer/1722171)

| Plateforme | Format | Résolution | Codec | FPS | Bitrate vidéo | Audio |
|------------|--------|------------|-------|-----|---------------|-------|
| Instagram Reel | MP4 | **1080×1920** | H.264 | 30 | 8–12 Mbps | AAC 128kbps |
| TikTok | MP4 | **1080×1920** | H.264 | 30 | 8–12 Mbps | AAC 128kbps |
| YouTube Short | MP4 | **1080×1920** | H.264 | 30 | 8–12 Mbps | AAC 128kbps |
| YouTube paysage | MP4 | **1920×1080** | H.264 | 24/30 | 10–15 Mbps | AAC 320kbps |
| Web hero | WebM | Variable | VP9 | 24/30 | 4–8 Mbps | N/A (muet) |
| Web fallback | MP4 | Variable | H.264 | 24/30 | 4–8 Mbps | N/A (muet) |

**Remotion export — commande standard :**
```bash
# Reel Instagram / TikTok
npx remotion render src/index.ts SocialReel out/reel.mp4 \
  --codec=h264 --crf=18 --scale=1

# Hero web (WebM + fallback MP4)
npx remotion render src/index.ts HeroLoop out/hero.webm --codec=vp8
npx remotion render src/index.ts HeroLoop out/hero.mp4 --codec=h264
```

---

## 5. Horaires de publication optimaux

> Source : Sprout Social — "Best Times to Post on Social Media" (sproutsocial.com/insights/best-times-to-post-on-social-media, 2024)
> Source : Later — "Best Time to Post on Instagram" (later.com/blog/best-time-to-post-on-instagram, 2024)

| Plateforme | Jours optimaux | Heures optimales |
|------------|---------------|-----------------|
| Instagram | Lundi, mardi, vendredi | **11h–13h** et **17h–19h** |
| TikTok | Mardi, jeudi, vendredi | **6h–10h** et **19h–23h** |
| YouTube | Jeudi, vendredi | **15h–17h** |
| LinkedIn | Mardi, mercredi | **8h–10h** et **17h–18h** |

**Règle : toujours publier en horaires locaux de l'audience principale.** Pour une audience EU : heure de Bruxelles (CET/CEST).

---

## 6. Voiceover IA — ElevenLabs

> Source : ElevenLabs documentation (elevenlabs.io/docs)
> **Threshold : qualité LUFS cible = -14 LUFS** (standard streaming, conforme Spotify/YouTube Loudness Normalization)

```typescript
// Génération voiceover ElevenLabs via API
const response = await fetch('https://api.elevenlabs.io/v1/text-to-speech/{voice_id}', {
  method: 'POST',
  headers: {
    'xi-api-key': process.env.ELEVENLABS_API_KEY!,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    text: script,
    model_id: 'eleven_multilingual_v2',   // Meilleur modèle FR/EN
    voice_settings: {
      stability: 0.75,                    // 0.75 = naturel sans trop de variation
      similarity_boost: 0.85,
      style: 0.2,
      use_speaker_boost: true,
    },
  }),
})

const audioBuffer = await response.arrayBuffer()
// Écrire en MP3 puis intégrer dans Remotion via staticFile()
```

**Checklist voiceover :**
- [ ] Modèle multilingual v2 (qualité supérieure FR/EN)
- [ ] Normalisation audio à -14 LUFS après génération
- [ ] Sync frame-par-frame avec les animations dans Remotion
- [ ] Écouter l'ensemble avant export final

---

## 7. Agents Claude Code — Studio virtuel

Ce pattern permet à un seul développeur de piloter une production multi-disciplinaire avec Claude Code :

```
.claude/
├── agents/
│   ├── creative-strategist.md   → Brief, concept, storytelling
│   ├── motion-designer.md       → Animation, timing, Remotion
│   ├── sound-designer.md        → Musique, SFX, voiceover
│   ├── assembly.md              → Montage final, sync audio/vidéo
│   └── quality-control.md      → Review checklist, export
├── commands/
│   ├── creative-brief.md        → /creative-brief [format] [objectif]
│   ├── generate-content.md      → /generate-content [type]
│   └── sound-design.md          → /sound-design [émotion] [durée]
└── skills/
    ├── motion-design-mastery.md
    ├── cinema-editing-masterclass.md
    └── neuromarketing-visual-persuasion.md
```

**Principe :** chaque agent a une spécialité unique et peut être invoqué en parallèle sur une même production.

---

## 8. Règles absolues production

```
❌ JAMAIS publier sans sous-titres sur les vidéos sociales
❌ JAMAIS exporter en mauvaise résolution (vérifier section 4)
❌ JAMAIS publier sans avoir vérifié les 3 premières secondes (hook)
❌ JAMAIS dépasser le bitrate max — le codec écrase la qualité

✅ TOUJOURS normaliser l'audio à -14 LUFS avant export final
✅ TOUJOURS avoir un fallback MP4 pour le web (WebM non supporté partout)
✅ TOUJOURS créer une thumbnail personnalisée (YouTube/LinkedIn)
✅ TOUJOURS suivre le brief avant de générer (évite les itérations inutiles)
```

---

## Sources

| Référence | Lien |
|-----------|------|
| Instagram Creator — Specs | creators.instagram.com/tools-and-resources/formats-and-specs |
| TikTok Creator Portal — Specs | creator.tiktok.com/creator-portal/en-us/getting-started/video-specs |
| YouTube — Upload specs | support.google.com/youtube/answer/1722171 |
| Remotion docs | remotion.dev/docs |
| ElevenLabs API docs | elevenlabs.io/docs |
| Nielsen NN/G — Video Usability | nngroup.com/articles/video-usability |
| Meta Business — Video best practices | business.meta.com/creative-guidance/video |
| Sprout Social — Best times to post | sproutsocial.com/insights/best-times-to-post-on-social-media |
| YouTube Loudness Normalization | support.google.com/youtube/answer/6297273 |
