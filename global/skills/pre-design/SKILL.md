---
name: pre-design
description: Design generation protocol. Load before writing any new design file (.html, .css, .tsx, .jsx): a page, printable document, kit or component. Forces a visible design declaration (reference read, tokens, layout primitives, excluded clichés) so generation does not regress to the corpus-default look.
---

# /pre-design: design generation protocol

**Trigger**: before any new design file, for client work and personal products alike. **Do not skip it** even when the prompt looks simple: the default-cluster regression fires without it.

## Interview: declare 5 points, visibly, in the turn

The answers form the **Design Declaration**, stated before the first `<style>`.

**Resuming a project**: if a `DIRECTION.md` already exists in the project folder, read it first. It is authoritative. The 5 points then only check that the new file stays inside that direction.

### Point 0: anti-convergence draw (new project or new territory only)

Skip when iterating on an established direction or when the brief imposes one (an imposed choice always beats the draw).

**Why**: without a draw, the model picks the most probable direction of its corpus. A warm, family or bookish subject comes out as cream background, italic display serif, lamp light.

1. One sentence each: the product's own mechanism, the real scene of its audience, the audience's cultural world. Note the page this category always ships and its predictable opposite. Both are excluded.
2. List **7 directions** drawn from that cultural world: objects, places, rituals, graphic or interface systems the audience knows by heart. One justification line each. If more than 3 share a material family, dig until at least 3 families are covered.
3. Draw 3 numbers at random, visibly:
   ```bash
   python3 -c "import random; print(sorted(random.sample(range(1, 8), 3)))"
   ```
4. Choose among the 3 drawn only. If none can carry the product, say why with a factual reason and redraw once. Taste is never a reason to redraw.

**Calibration signals** (name them if your direction lands there, then justify or change):
- default clusters: cream + serif + terracotta; near-black + neon; editorial rules + italic serif + mono labels;
- corpus-default fonts to justify if chosen: Fraunces, Playfair Display, Cormorant, Lora, Crimson, Newsreader, Syne, Space Grotesk, Space Mono, IBM Plex, Inter as display, DM Sans, DM Serif, Outfit, Plus Jakarta Sans, Instrument Sans;
- light or dark is never a default: anchor it in a physical scene of use, in one sentence.

### Point 1: territory

Pick a named visual territory from your own catalog (keep 4 to 6 in a `TERRITORIES.md`: for example quiet luxury, institutional, premium no-frills, geometric/structured, organic/natural, editorial/culture). Each territory fixes: background family, type pairing, accent logic, motion level, and its veto rules (for example "never a dark body background" for a quiet-luxury territory).

### Point 2: reference read

Which existing file did I read as a structural reference? Read a template or the latest validated file of the same project or a similar territory. Identify its reusable classes and conventions. **Never invent from scratch**: templates hold the validated conventions.

### Point 3: palette

Which color tokens? Named tokens only, defined once on `:root`, with an accessible (AA) variant for each accent used on text.

```css
--ink: ...;       /* main text */
--paper: ...;     /* page background */
--bg-soft: ...;   /* section backgrounds */
--accent: ...;    /* standard accent */
--accent-aa: ...; /* accessible accent for text */
```

**Forbidden**: inventing a new hex ad hoc; gold/yellow-brown for text; over-saturated accents in restrained territories.

### Point 4: layout primitives

Which different primitive for each section? At most 2 of 5 sections may share the same paradigm.

| Primitive | Ideal use |
|---|---|
| Comparison table | diagnosis, before/after |
| 2-column grid | site pages, features |
| Editorial numbering | steps, concepts |
| Highlight pack | featured price or offer |
| 3-scenario grid | pricing scenarios |
| Vertical steps | timeline, process |
| Callout | highlights, warnings |
| Pill row | stack, feature lists |

### Point 5: anti-cliché check

Which 3 clichés did I check and exclude? Minimum checklist:
- [ ] no forbidden background for the chosen territory
- [ ] zero `transition: all` (list properties explicitly)
- [ ] gold/yellow-brown is decoration only, never a text color
- [ ] `print-color-adjust: exact` present on printable HTML
- [ ] each section uses a different primitive (Point 4)
- [ ] no row of 3 identical cards for features
- [ ] fonts load reliably in the target renderer

Score the checklist out of 10. Require 8 or more before writing.

## Expected output: the declaration

```
DESIGN DECLARATION: <document name>
1. Territory: <name>
2. Reference read: <path> (classes reused: ...)
3. Palette: --ink + --paper + --bg-soft + --accent (+ client token)
4. Layout: S2=table, S3=grid-2, S4=numbering, S5=highlight+scenarios, S6=steps
5. Clichés excluded: <3 named>
-> Checklist: 9/10. GO.
```

Only after the declaration: write the code.

## Persist the direction: `DIRECTION.md`

A declaration in chat is lost next session. For a new project or territory, also write about 150 words to `DIRECTION.md` at the project root:

```markdown
# DIRECTION: <project>
Date: YYYY-MM-DD, Territory: <name>, Draw: [3 numbers] -> chosen n

THESIS: the one idea this surface owns, and the default arrangement of its category that it refuses.
OWN-WORLD: palette (named tokens) and component language, recognizable even stripped of content.
STORY: what the visitor understands, believes, then does.
FIRST VIEWPORT: exact composition of the first screen: what, where, at what scale, where the primary action sits.
FORM: the chosen form, its rank among the 7, why it beats the 2 other draws.
FINISH: exit condition (audit passed, specificity verdict OK). Not re-read and not documented = not finished.
```

Rules: a block that reads as a mood ("warm", "premium") means the direction is not decided yet; re-read the file at the start of each later session; never copy its content into shipped code; a change of direction means rewriting and dating the file, not stacking.

## Optional enforcement hooks

A `PostToolUse` hook on design files can block `transition: all` and a missing `print-color-adjust`, and warn on gold text or identical 1fr/1fr grids. A `PreToolUse` hook can inject your design digest before any `.html` write.
