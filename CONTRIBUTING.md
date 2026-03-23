# Contributing to SQWR Project Kit

Thank you for contributing to this kit. A few rules to maintain the quality level.

---

## Core principle

**Every rule added to the kit must have a verifiable source.**

This kit has value because its rules are grounded in real standards (OWASP, W3C, NIST, Google SRE Book, etc.) — not in opinions. Before adding or modifying a contract, find the Tier 1 or Tier 2 source that justifies the rule.

See `METHODOLOGY.md` for the source hierarchy (Tier 1 = official documentation, Tier 2 = academic/industrial standards).

---

## Welcome types of contribution

| Type | Description |
|------|-------------|
| **New contract** | Uncovered domain (e.g. i18n, animations, native mobile) |
| **Contract improvement** | Missing threshold, more recent source, incomplete rule |
| **New framework** | Situational tool (e.g. templates for new use cases) |
| **Correction** | Factual error, broken link, outdated threshold |
| **Translation** | Adapt a contract for another language (EN, NL, DE…) |

---

## Contract structure

Every contract must follow this structure:

```markdown
# Contract — [Domain]

> Sources: [Author/Org (year)], [Author/Org (year)]
> Score: /100 | Recommended threshold: ≥XX

## Section 1 — [Name] (XX points)

- [ ] Measurable criterion with numerical threshold .............. (X)
- [ ] Criterion with cited source ............................. (X)

**Subtotal: /XX**

## Sources

| Reference | Contribution |
|-----------|--------|
| Author — *Title* (Publisher, year) | What it contributes |
```

---

## How to contribute

1. **Fork** the repo
2. **Create a branch**: `feat/contract-i18n` or `fix/wcag-threshold`
3. **Add the source** in the `## Sources` section of the modified file
4. **Update** `README.md` + `scripts/verify-kit.sh` if you add a file
5. **Test**: `bash scripts/verify-kit.sh --verbose` must return exit 0
6. **Pull Request** with a description of the change and a link to the source

---

## What will not be merged

- Rules without a verifiable source
- Personal opinions presented as standards
- Removal of existing sources without a more recent replacement
- Debug code, private hardcoded paths, personal data

---

## Questions

Open a GitHub Issue with the `question` label.
