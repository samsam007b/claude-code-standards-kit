# Contract — Video Production & AI Studio

> SQWR Project Kit contract module.
> Sources: Instagram Creator Guidelines (creators.instagram.com), TikTok Creator Portal (creator.tiktok.com), YouTube Technical Specs (support.google.com/youtube), Remotion docs (remotion.dev), ElevenLabs docs (elevenlabs.io/docs), Nielsen NN/G — Video Usability (nngroup.com), Meta Business — Video Best Practices (business.meta.com).

---

## Foundations

**The modern video production studio is virtual** — driven by AI tools and structured Claude Code workflows. It replaces a team of 5–10 people with a tool stack operated by 1–2 people using the right method.

**Reference stack:**
| Tool | Role | Monthly cost |
|-------|------|-------------|
| **Remotion** | Programmatic video composition (React) | Free + ~$0.05/render |
| **Veo / Gemini** | AI b-roll, lifestyle footage | Pay-per-use |
| **ElevenLabs** | AI voiceover | $0–22/month |
| **Canva** | Stories, quick templates | Included in existing plan |
| **Higgsfield** | Premium motion graphics | $75/month (Phase 4) |

**Budget per phase:**
- Phase 1 (foundations): ~$5–10/month
- Phase 2 (regular social): ~$30–50/month
- Phase 3 (product demos): ~$75–100/month
- Phase 4 (campaigns): ~$150–200/month

---

## 1. Decision Tree — Which Tool for Which Content?

> Source: Remotion docs — Use cases (remotion.dev/docs/use-cases)

```
Content to produce
│
├── UI / app demo in motion?
│   └── → Remotion (reuses the project's React components)
│
├── Lifestyle footage / human scenes / b-roll?
│   └── → Veo / Gemini (AI generation)
│
├── Data visualization / complex motion graphics?
│   ├── Phase 4 budget → Higgsfield
│   └── Otherwise → Remotion custom composition
│
├── Quick story or simple animation?
│   └── → Canva (fast iteration)
│
└── Default → Remotion
```

---

## 2. Production Pipeline — 5 Phases

> Source: Meta Business — Creative Production Process (business.meta.com/creative-guidance)

### Phase 1: Brief

Mandatory template for every production:

```markdown
## Video Brief

**Objective:** [Awareness / Conversion / Retention / Education]
**Target audience:** [Persona + age + context]
**Duration:** [Xs]
**Format:** [Reel 9:16 / YouTube 16:9 / Story 9:16 / Web hero]
**Platform(s):** [Instagram / TikTok / YouTube / Web]
**Voiceover:** [Yes (ElevenLabs) / No / Human]
**Music:** [Style + target emotion]
**CTA:** [Desired action at the end]
**Available assets:** [Logo, product photos, app screenshots...]
**Deadline:** [Date]
```

### Phase 2: Creation

Follow the decision tree (section 1). Open the brief in Claude Code before any generation.

### Phase 3: Review — Quality Checklist

```
BRANDING
  [ ] Colors conform to the design system
  [ ] Logo visible and correctly placed
  [ ] Brand typography used
  [ ] Tone consistent with brand voice

TECHNICAL
  [ ] Correct resolution for the platform (section 4)
  [ ] Clear audio, no saturation (-14 LUFS target)
  [ ] Duration within platform limits
  [ ] No elements cut off at the edges

UX & ENGAGEMENT
  [ ] Message readable in 3 seconds (visual hook)
  [ ] Subtitles present (85% watch without sound — Meta, 2023)
  [ ] CTA visible and readable
  [ ] Attention-grabbing first frame (scroll-stop)
```

### Phase 4: Export

See section 4 — Platform specifications.

### Phase 5: Publication

```markdown
## Publication Metadata

- **Title:** [60 characters max for YouTube]
- **Caption:** [Hook + content + CTA + hashtags]
- **Hashtags:** [3–5 core + 5–10 niche — avoid generic hashtags]
- **Thumbnail:** [Custom — never the auto frame]
- **UTM link:** [Analytics tracking]
- **Publication:** [Optimal time — see section 5]
```

---

## 3. Video Content Rules

> Source: Nielsen NN/G — "Video Usability" (nngroup.com, 2023)
> Source: Meta Business — "Video Best Practices" (business.meta.com)

### Hook — The First 3 Seconds

**Threshold: the main message must be understood in ≤3 seconds** (NN/G, 2023 — 73% of scroll decisions happen in the first 3 seconds).

```
❌ Bad hook: Intro with logo + music (2s wasted)
✅ Good hook: Impactful text + image from frame 1
✅ Good hook: Provocative question in overlay
✅ Good hook: Shocking stat in large text
```

### Subtitles — Mandatory

> Source: Meta for Business — "85% of video is watched without sound" (business.meta.com, 2016, confirmed 2023)
> **Threshold: subtitles on 100% of social videos**

```typescript
// Remotion — automatic subtitles via Whisper + @remotion/captions
import { Transcript } from '@remotion/captions'

// Generate with Whisper (openai) or AssemblyAI, then integrate into the composition
```

### Optimal Durations by Platform

> Source: TikTok Creator Portal — Optimal video length (creator.tiktok.com)
> Source: Instagram Creator — Reels best practices (creators.instagram.com)
> Source: YouTube Creator Academy — Optimal video length (creatoracademy.youtube.com)

| Platform | Optimal | Maximum |
|------------|---------|---------|
| Instagram Reel | **15–30s** | 90s |
| TikTok | **15–60s** | 10min |
| YouTube Short | **30–60s** | 60s |
| YouTube standard | **7–15 min** | unlimited |
| Web hero loop | **6–15s** | 30s |
| Story | **7–15s** | 60s |

---

## 4. Export Specifications by Platform

> Source: Instagram Technical Specs (creators.instagram.com/tools-and-resources/formats-and-specs)
> Source: TikTok Video Specs (creator.tiktok.com/creator-portal/en-us/getting-started/video-specs)
> Source: YouTube Upload Specs (support.google.com/youtube/answer/1722171)

| Platform | Format | Resolution | Codec | FPS | Video bitrate | Audio |
|------------|--------|------------|-------|-----|---------------|-------|
| Instagram Reel | MP4 | **1080×1920** | H.264 | 30 | 8–12 Mbps | AAC 128kbps |
| TikTok | MP4 | **1080×1920** | H.264 | 30 | 8–12 Mbps | AAC 128kbps |
| YouTube Short | MP4 | **1080×1920** | H.264 | 30 | 8–12 Mbps | AAC 128kbps |
| YouTube landscape | MP4 | **1920×1080** | H.264 | 24/30 | 10–15 Mbps | AAC 320kbps |
| Web hero | WebM | Variable | VP9 | 24/30 | 4–8 Mbps | N/A (muted) |
| Web fallback | MP4 | Variable | H.264 | 24/30 | 4–8 Mbps | N/A (muted) |

**Remotion export — standard command:**
```bash
# Instagram Reel / TikTok
npx remotion render src/index.ts SocialReel out/reel.mp4 \
  --codec=h264 --crf=18 --scale=1

# Web hero (WebM + fallback MP4)
npx remotion render src/index.ts HeroLoop out/hero.webm --codec=vp8
npx remotion render src/index.ts HeroLoop out/hero.mp4 --codec=h264
```

---

## 5. Optimal Publishing Times

> Source: Sprout Social — "Best Times to Post on Social Media" (sproutsocial.com/insights/best-times-to-post-on-social-media, 2024)
> Source: Later — "Best Time to Post on Instagram" (later.com/blog/best-time-to-post-on-instagram, 2024)

| Platform | Optimal days | Optimal times |
|------------|---------------|-----------------|
| Instagram | Monday, Tuesday, Friday | **11am–1pm** and **5pm–7pm** |
| TikTok | Tuesday, Thursday, Friday | **6am–10am** and **7pm–11pm** |
| YouTube | Thursday, Friday | **3pm–5pm** |
| LinkedIn | Tuesday, Wednesday | **8am–10am** and **5pm–6pm** |

**Rule: always publish in the local time of the primary audience.** For an EU audience: Brussels time (CET/CEST).

---

## 6. AI Voiceover — ElevenLabs

> Source: ElevenLabs documentation (elevenlabs.io/docs)
> **Threshold: target LUFS quality = -14 LUFS** (streaming standard, compliant with Spotify/YouTube Loudness Normalization)

```typescript
// ElevenLabs voiceover generation via API
const response = await fetch('https://api.elevenlabs.io/v1/text-to-speech/{voice_id}', {
  method: 'POST',
  headers: {
    'xi-api-key': process.env.ELEVENLABS_API_KEY!,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    text: script,
    model_id: 'eleven_multilingual_v2',   // Best FR/EN model
    voice_settings: {
      stability: 0.75,                    // 0.75 = natural without too much variation
      similarity_boost: 0.85,
      style: 0.2,
      use_speaker_boost: true,
    },
  }),
})

const audioBuffer = await response.arrayBuffer()
// Write as MP3 then integrate into Remotion via staticFile()
```

**Voiceover checklist:**
- [ ] Multilingual v2 model (superior FR/EN quality)
- [ ] Audio normalization to -14 LUFS after generation
- [ ] Frame-by-frame sync with animations in Remotion
- [ ] Listen to the full output before final export

---

## 7. Claude Code Agents — Virtual Studio

This pattern allows a single developer to manage a multi-disciplinary production with Claude Code:

```
.claude/
├── agents/
│   ├── creative-strategist.md   → Brief, concept, storytelling
│   ├── motion-designer.md       → Animation, timing, Remotion
│   ├── sound-designer.md        → Music, SFX, voiceover
│   ├── assembly.md              → Final edit, audio/video sync
│   └── quality-control.md      → Review checklist, export
├── commands/
│   ├── creative-brief.md        → /creative-brief [format] [objective]
│   ├── generate-content.md      → /generate-content [type]
│   └── sound-design.md          → /sound-design [emotion] [duration]
└── skills/
    ├── motion-design-mastery.md
    ├── cinema-editing-masterclass.md
    └── neuromarketing-visual-persuasion.md
```

**Principle:** each agent has a unique specialty and can be invoked in parallel on the same production.

---

## 8. Absolute Rules — Production

```
❌ NEVER publish social videos without subtitles
❌ NEVER export at the wrong resolution (check section 4)
❌ NEVER publish without reviewing the first 3 seconds (hook)
❌ NEVER exceed the maximum bitrate — the codec degrades quality

✅ ALWAYS normalize audio to -14 LUFS before final export
✅ ALWAYS have an MP4 fallback for the web (WebM not supported everywhere)
✅ ALWAYS create a custom thumbnail (YouTube/LinkedIn)
✅ ALWAYS follow the brief before generating (avoids unnecessary iterations)
```

---

## Sources

| Reference | Link |
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

> **Last validated:** 2026-03-30 — platform specs (YouTube/TikTok/Meta), H.264/HEVC standards, ElevenLabs API docs, Nielsen NN/G Video Usability, YouTube Loudness Normalization