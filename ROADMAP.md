# ROADMAP

Public roadmap for the SQWR Project-Kit. Dates are targets, not commitments.

---

## Current: v3.1.0 (2026-Q1)

✅ **Perfection release** — Targeting Anthropic Verified Plugins Program (Platinum ≥90/100)

- 38 contracts covering all major development domains
- 13 audits with weighted composite Risk Score
- 11 agents with worktree isolation
- 9 skills including EU compliance and risk score
- 21 hook scripts across 18 event types
- 6 modular contextual rules
- Full governance: SECURITY.md, CHANGELOG.md, .github/ templates, CI

---

## v3.2 — Agent Teams (2026-Q2)

**Theme**: Multi-agent coordination support

- TeamCreate workflow for parallel audits across large codebases
- Agent mailbox system for inter-agent communication
- Shared task list pattern for distributed code review
- `hook-teammate-idle.sh` activation — auto-assign tasks to idle agents
- `WORKFLOW-AGENT-TEAM.md` — team coordination playbook

---

## v4.0 — AI-Native Contracts (2026-Q3)

**Theme**: Machine-readable contract format

- JSON Schema for all contracts (machine-parseable alongside human-readable)
- Contract validation API — projects can programmatically check compliance
- LLM-optimized contract summaries for reduced token usage
- Contract dependency graph — show which contracts depend on others
- Automated contract update detection (notify when source standards change)

**Scientific basis**: Building on arXiv 2601.08815 (90% token reduction with structured contracts)

---

## v4.1 — IDE Integration (2026-Q3)

**Theme**: Inline contract hints in editors

- VS Code extension: show relevant contract rules as you type
- JetBrains plugin: contract compliance linting
- Pre-commit hook improvements: faster, more accurate secret detection
- ESLint/Prettier rule generation from contracts

---

## v5.0 — Self-Evolving Kit (2026-Q4)

**Theme**: Kit that stays current automatically

- Source monitoring: detect when OWASP/WCAG/Google standards update
- AI-assisted contract update proposals (PRs auto-created when sources change)
- Community contribution system: submit contract improvements through structured PRs
- Multi-language support: Python, Rust, Go, Swift contract variants
- Marketplace integration: installable via `claude plugin install sqwr/standards-kit`

---

## Completed

| Version | Release Date | Highlight |
|---------|-------------|-----------|
| v3.1.0 | 2026-03-31 | Perfection + Marketplace submission |
| v3.0.0 | 2026-03-31 | 35 contracts, 7 skills, 9 hooks, tech watch implementation |
| v2.0.0 | 2026-03-30 | Plugin architecture, native Claude Code integration |
| v1.0.0 | 2026-03-29 | Initial release — 29 contracts, 12 audits, 8 agents |

---

## Contributing to the Roadmap

Have a feature idea? Open an issue using the **Feature Request** template and tag it `roadmap`.

Prioritization criteria:
1. Does it improve quality for solo developers with Claude Code?
2. Is it grounded in a verifiable Tier 1/2 standard?
3. Does it maintain backward compatibility?

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.
