# Changelog

All notable changes to the SQWR Project-Kit are documented in this file.

This project adheres to [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added

- **CONTRACT-TOKEN-ECONOMY.md**: Complete token economy optimization contract — model delegation (TE-1.x), two-phase research pattern validated at 3.2x cost reduction (TE-2.x), context reduction with .claudeignore and CLAUDE.md migration (TE-3.x), output controls (TE-4.x), monitoring hooks (TE-5.x). Sources: Anthropic pricing 2025, empirical testing, arXiv 2601.08815
- **AGENT-RESEARCHER.md**: Haiku subagent for web research — mandatory 400 token summary + ranked "dig deeper" table format
- **AGENT-DOC-READER.md**: Haiku subagent for documentation reading — mandatory 400 token digest + "sections to read" table format
- **hook-subagent-output.sh**: PostToolUse hook (Agent matcher) — alerts when subagent output exceeds 800 words (CONTRACT-TOKEN-ECONOMY TE-5.1)
- **templates/.claudeignore**: Universal .claudeignore template with stack-specific sections (Next.js, iOS, Android, Python, Monorepo)
- **templates/settings.json**: Updated with token economy settings (effort level, thinking tokens, output tokens, subagent model, compact window, bypass permissions, subagent monitoring hook)

---

## [3.2.0] — 2026-03-31

### Added

- **CONTRACT-ANTI-PATTERNS.md**: 10 AI coding anti-patterns codified with Tier 1 sources (Fowler, Martin, OWASP Agentic, DORA 2024, arXiv 2602.22302) — premature abstraction, anti-rationalization, over-engineering, hallucinated requirements, god objects, context drift, silent failures, premature optimization, cargo-cult, speculative generalization
- **`/brainstorm` skill** (`skills/brainstorm/SKILL.md`): Pre-implementation guard — evaluates scope, reversibility, approach plurality, and motivation clarity before any implementation starts
- **AGENT-BRAINSTORM.md**: 4-level brainstorm agent (Quick Scope Check → Full Brainstorm → Conflict Resolution → Post-Implementation Validation)
- **AUDIT-ANTI-PATTERNS.md**: 5-section anti-patterns audit scoring /100 with automated detection scripts
- **`scripts/install.sh`**: One-command installer (`curl -sL .../install.sh | bash`)
- **hook-user-prompt.sh** enhanced: detects large-scope tasks, anti-rationalization requests, and database migration risk — suggests `/brainstorm` proactively

### Changed

- plugin.json version: 3.1.0 → 3.2.0 (39 contracts, 14 audits, 12 agents, 10 skills, 5 scripts)
- verify-kit.sh REQUIRED_FILES: +5 new files (CONTRACT-ANTI-PATTERNS, AUDIT-ANTI-PATTERNS, AGENT-BRAINSTORM, skills/brainstorm/SKILL.md, scripts/install.sh)
- README.md: updated counts, added `/brainstorm` to skills table, added one-liner install, added competitive positioning section

---

## [3.1.0] — 2026-03-31

### Added

- **3 new contracts**: CONTRACT-EU-AI-ACT, CONTRACT-AI-SAFETY, CONTRACT-DORA-METRICS (38 total)
- **2 new skills**: `/compliance-check` (EU regulatory compliance), `/risk-score` (composite risk score)
- **1 new agent**: AGENT-RISK-SCORE with weighted composite formula (Security×0.22 + Performance×0.18 + …)
- **1 new audit**: AUDIT-RISK-SCORE with scoring grid and computation procedure
- **12 new hook scripts**: PostCompact, SubagentStart/Stop, UserPromptSubmit, TaskCreated/Completed, PermissionRequest, FileChanged, InstructionsLoaded, WorktreeCreate/Remove, TeammateIdle
- **hooks.json expanded**: 6 → 18 event types
- **6 modular rules** in `rules/` with contextual path scoping: security, accessibility, performance, API, testing, documentation
- **SECURITY.md**: Responsible disclosure policy, security features documentation
- **CHANGELOG.md**: Full version history (this file)
- **ROADMAP.md**: Project vision v3.1 through v5.0
- **.github/ templates**: 3 issue templates (bug, feature, contract update) + PR template + CI workflow
- **`isolation: worktree`** added to all 10 audit agents
- **plugin.json v3.1.0**: Added `rules` field, 3 new userConfig keys (enable_agent_hooks, eu_compliance, risk_score_threshold)
- **`fullstack` stack** added to init-project.sh (activates all contracts)
- **verify-kit.sh**: 5 new tests (14-18) covering Risk Score formula, hook coverage, version consistency, SECURITY.md, CHANGELOG.md

### Changed

- All agents: added `isolation: worktree` to frontmatter for audit safety
- CONTRACT-SECURITY.md: Added OWASP Agentic AI Top 10 (2025) and NIST AI 600-1 references
- CONTRACT-AI-AGENTS.md: Added Least Agency Principle section (OWASP Agentic AI #1)
- CONTRACT-ACCESSIBILITY.md: Added European Accessibility Act reference (enforceable June 28, 2025)
- AUDIT-INDEX.md: Updated to 13 audits with AUDIT-RISK-SCORE

---

## [3.0.0] — 2026-03-31

### Added

- **6 new contracts**: CONTRACT-AI-AGENTS, CONTRACT-GRAPHQL, CONTRACT-MULTI-TENANT, CONTRACT-FEATURE-FLAGS, CONTRACT-MONOREPO, CONTRACT-DOCUMENTATION (35 total)
- **`auto-fix` skill**: Automatic fixes for console.log, alt text, TODO format
- **hook-post-response.sh** (Stop event, async): Checks code quality after each response
- **hook-session-end.sh** (SessionEnd event, async): Persists session state to .sqwr-last-state.sh
- **Agent memory sections**: All 10 agents have ## Memory section with domain-specific instructions
- **`context: fork`** + **`agent: "general-purpose"`**: Correct documented skill syntax (replacing `agent: true`)
- **`disable-model-invocation: true`**: Added to side-effect skills and commands
- **`memory: project`**: Cross-session knowledge for all audit agents
- **`tools: ["Agent"]`**: Replaced deprecated `tools: ["Task"]` (renamed v2.1.63)
- **hooks.json**: Stop and SessionEnd events with `"async": true`
- **plugin.json**: Added `keywords` and `userConfig` (audit_threshold, org_name)

### Fixed

- `effort: max` → `effort: high` (only low/medium/high are valid values)
- `hook-pre-compact.sh`: Rewrote to use `.sqwr-last-state.sh` (CLAUDE_ENV_FILE not supported in PreCompact)

---

## [2.0.0] — 2026-03-30

### Added

- **Plugin architecture**: `.claude-plugin/plugin.json` with auto-discovery
- **6 skills** in `skills/`: new-feature, pre-deployment, monthly-review, contract-lookup, audit-runner, project-setup
- **4 commands** in `commands/`: full-audit, init-project, verify-kit, verify-project
- **hooks.json** declarative format with `${CLAUDE_PLUGIN_ROOT}` for portable paths
- **`hooks/scripts/`** directory: moved all hook scripts here
- **hook-session-context.sh** (SessionStart): detects project stack, writes CLAUDE_ENV_FILE
- **hook-pre-compact.sh** (PreCompact): persists context before conversation compression
- **GitHub Actions CI template**: `templates/github-actions/verify-kit.yml`
- **`--plugin` flag** for init-project.sh: plugin-mode initialization

### Changed

- All hook paths updated to use `${CLAUDE_PLUGIN_ROOT}` (no more hardcoded KIT_PATH)
- templates/settings.json: Added legacy comment
- verify-kit.sh: Test 13 validates plugin structure + JSON validity

---

## [1.0.0] — 2026-03-29

### Added

- Initial release of SQWR Project-Kit
- **29 contracts** across all major development domains
- **12 audits** with scoring grids and blocking thresholds
- **8 agents** with enriched frontmatter (model, effort, color, permissionMode, maxTurns)
- **13 frameworks** for recurring decisions
- **3 workflows**: new-feature, pre-deployment, monthly-review
- **5 templates**: CLAUDE.md, settings.json, IDENTITY-TEMPLATE.md, and more
- **4 scripts**: init-project.sh, verify-kit.sh, verify-project.sh, validate-claude-md.sh
- **5 hooks**: no-secrets, no-dangerous-html, build-before-commit, contract-compliance, audit-before-push
- Scientific grounding: all contracts trace to Tier 1/2 sources (OWASP, WCAG, Google SRE, etc.)
- verify-kit.sh: 12 automated tests for kit structure validation
