---
name: accessibility-review
description: WCAG 2.1 accessibility audit: contrast, keyboard navigation, ARIA, screen readers, forms. Sources: W3C WCAG 2.1 AA, Nielsen 10 heuristics, ARIA Authoring Practices Guide.
tags: [accessibility, wcag, aria, keyboard, screen-reader, a11y]
model: sonnet
---

# /accessibility-review: WCAG 2.1 Accessibility Audit

## When to use

- Audit of a component or page (WCAG 2.1 AA conformance)
- Review before launching a public feature
- Verification of a critical form or flow
- Fixing axe/Lighthouse accessibility errors

## WCAG 2.1 AA criteria

### Perceivable
- [ ] Text contrast: 4.5:1 minimum (3:1 for large text)
- [ ] Non-text UI contrast (icons, focus borders): 3:1
- [ ] No information conveyed by color alone
- [ ] Alt text on all non-decorative images (`alt=""` if decorative)

> Counting pitfall (a previous run wrongly counted 87 violations): a grep for `<Image` in a Next.js project matches both the `next/image` component (needs `alt`) and the `Image`/`ImageIcon`/`ImagePlus` icon imported from `lucide-react` (does not need one, it is not an `<img>` tag). Always check the import source (`from 'next/image'` vs `from 'lucide-react'`) before counting a hit as a violation. Do not rely on a grep for `<Image` alone.
- [ ] Captions on videos, transcript for audio
- [ ] Content zooms to 200% without loss of information

### Operable (keyboard navigation)
- [ ] All interactive elements reachable by keyboard (Tab, Shift+Tab)
- [ ] Focus visible on all elements (CSS outline not removed)
- [ ] Logical tab order (follows the visual flow)
- [ ] No keyboard trap (modal closes with Escape)
- [ ] Skip links ("Skip to content" as the first element)
- [ ] Keyboard shortcut for repetitive functions

### Understandable
- [ ] `lang` on `<html>` (and on inline language changes)
- [ ] Explicit labels on all inputs (not placeholder only)
- [ ] Error messages associated via `aria-describedby`
- [ ] No timeout without warning (WCAG 2.2.1)
- [ ] Confirmation before irreversible actions

### Robust (ARIA)
- [ ] ARIA only if semantic HTML is insufficient
- [ ] `role`, `aria-label`, `aria-describedby` consistent
- [ ] Live regions (`aria-live="polite"`) for dynamic updates
- [ ] `aria-expanded`, `aria-selected`, `aria-checked` on custom components
- [ ] Unique IDs in the page (never duplicates)

### Custom components (ARIA Authoring Practices)
| Component | Required ARIA pattern |
|-----------|-------------------|
| Modal | `role="dialog"`, `aria-modal="true"`, focus trap, close on Escape |
| Dropdown | `role="listbox"` + `role="option"`, `aria-selected` |
| Tabs | `role="tablist"`, `role="tab"`, `aria-selected`, `role="tabpanel"` |
| Toast | `role="status"` or `role="alert"`, `aria-live` |
| Accordion | `aria-expanded`, controls/labelledby |

## Output format

```
## Accessibility Review: [component/page]

### WCAG 2.1 AA score: [X/100]

### 🔴 Critical non-conformance (legally blocking, EAA 2025)
### 🟡 AA non-conformance to fix
### 🟢 AAA (bonus)

### Code fixes
[Fixed JSX/HTML with ARIA]
```
