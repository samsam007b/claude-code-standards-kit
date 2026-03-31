---
description: "SQWR Accessibility Rules — WCAG 2.1 AA compliance, keyboard navigation, screen readers"
paths:
  - "src/components/**"
  - "src/pages/**"
  - "src/app/**"
  - "pages/**"
  - "components/**"
  - "*.html"
---

# Accessibility Rules (SQWR)

Source: WCAG 2.1 AA, European Accessibility Act (enforceable June 28, 2025), ARIA Practices Guide

## Images & Media

- ALL `<img>` elements must have descriptive `alt` text (empty `alt=""` only for decorative images)
- Videos must have captions; audio must have transcripts
- Avoid using images of text (use real text with CSS styling instead)

## Color & Contrast

- Normal text: contrast ratio ≥ 4.5:1 (WCAG AA)
- Large text (≥ 18pt or ≥ 14pt bold): contrast ratio ≥ 3:1
- UI components and graphical objects: contrast ratio ≥ 3:1
- NEVER use color as the sole means of conveying information

## Keyboard Navigation

- ALL interactive elements must be reachable via Tab key
- Focus indicator must be visible (never use `outline: none` without a replacement)
- Logical tab order — follows visual reading order
- No keyboard traps — users can always navigate away from any component

## ARIA & Semantics

- Use semantic HTML elements first (`<button>`, `<nav>`, `<main>`, `<header>`) before adding ARIA
- `role` must match the element's actual behavior
- `aria-label` is required on icon-only buttons
- `aria-live` regions for dynamic content updates

## Forms

- Every form input must have an associated `<label>`
- Required fields must be indicated (not by color alone)
- Error messages must be descriptive and associated with the input via `aria-describedby`
