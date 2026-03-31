---
description: "SQWR Documentation Rules — Markdown standards, link validation, README requirements"
paths:
  - "*.md"
  - "docs/**"
  - "README.md"
  - "CONTRIBUTING.md"
---

# Documentation Rules (SQWR)

Source: Google Developer Documentation Style Guide, CommonMark Specification, Diátaxis Framework

## README Requirements

Every project README must contain:
1. **What it does** — 1-2 sentence description (not marketing copy)
2. **Prerequisites** — required tools and versions
3. **Installation** — step-by-step instructions that work on a fresh machine
4. **Usage** — at least one working example
5. **Contributing** — how to submit issues and PRs

## Markdown Standards

- Use ATX-style headings (`#`, `##`, `###`) — not Setext-style (`===`, `---`)
- One blank line before and after headings, code blocks, and lists
- Code blocks must specify language for syntax highlighting (` ```typescript `, ` ```bash `)
- Use relative links for internal documents — not absolute URLs
- Tables must have header rows with alignment separators

## Link Validation

- All external links must resolve (no 404s)
- Avoid deep-linking to headings that might change
- Use meaningful link text — not "click here" or "this link"

## Code Examples

- All code examples must be tested and working
- Include expected output where applicable
- Specify the version of tools/libraries used in examples
- Use `// ...` for omitted code sections, not `...` alone

## Technical Writing

- Write for the reader's task, not your system's structure (Diátaxis: tutorials, how-tos, reference, explanation)
- Use present tense and active voice
- Define acronyms on first use
- Keep sentences under 25 words — split complex sentences
