# Changelog

All notable changes to the SQWR Project-Kit are documented in this file.

This project adheres to [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

## [4.1.0] - 2026-10-06

### Fixed
- `global/hooks/validate-command.js`: the database guard now reads the working directory from the hook payload (`cwd`), so it follows `cd` inside a session instead of the process directory. Before this, `CLAUDE_DB_PROTECT_DIRS` could silently never match.
- `global/hooks/validate-command.js`: the untracked-file cleanup rule now catches combined flags (`-fd`, `-xdf`, `-n -d -f`) and no longer matches unrelated text later in the command.
- `global/hooks/validate-command.js`: the force branch delete rule was case-insensitive, so the safe `git branch -d` (refuses unmerged branches) was blocked like `-D`. The rule is now case-sensitive and also catches `--delete --force`.
- `global/hooks/lib/external-send-classify.py`: a payload without a string `tool_name` is now refused (exit 3) instead of being classified as harmless.
- `global/hooks/lib/external-send-classify.py`: `CLAUDE_SEND_GUARD_ALLOW_REGEX` now only exempts the command segments it matches (split on newlines and `;`). Before this, one allowed segment exempted a whole chained command, including a real send after it.
- `global/install-global.sh`: every `_comment*` key from `settings.example.json` is stripped at install time (nested ones too), so the installed `settings.json` only holds keys Claude Code knows.
- `global/settings.example.json`: `CLAUDE_DB_SAFE_TOOL` points at the installed path (`~/.claude/scripts/`), and the example no longer sets `CLAUDE_DB_PROTECT=1`, which would have blocked database commands in every directory instead of only the ones listed in `CLAUDE_DB_PROTECT_DIRS`.
- `README.md`: every count it advertises (audit agents, hook scripts for both the project and the user-level layer, skills, audits) was drifted from what is actually on disk (for example "11/12" audit agents depending on the section, "21/22/19/18" hooks). Recounted every figure from the filesystem and corrected the mismatches.
- Removed the unverifiable "self-audit 91/100" badge and claim; the CI badge for the `verify-kit.yml` GitHub Actions workflow is now the only quality badge.
- Replaced the comparison table against "dev-skills" and "hotl-plugin" (two kits that could not be found/verified) with a factual "Positionnement" paragraph against three real, checkable projects (`claude-code-templates`, `SuperClaude_Framework`, `get-shit-done`).
- `global/install-global.sh` and `README.md`: `jq` and `node` are required, not optional (`node` runs `validate-command.js`, the main destructive-command guard). The installer now warns clearly if `node` is missing instead of listing it as optional.

### Added
- `scripts/verify-kit.sh`: Test 19 recomputes every count README.md advertises (audit agents, hooks, scripts, skills, commands, agents, both project-level and user-level) straight from the filesystem and fails if any of them drift. bash 3.2 and bash 5 compatible.
- `global/settings.example.json`: a `permissions.deny` block for obviously destructive commands and sensitive file reads, and an opt-in `sandbox` block (filesystem/network/credentials), following the official Claude Code settings and sandboxing documentation.
- `global/hooks/README.md`: a "Layered defense" section explaining the native-deny > sandbox > hooks strategy, with the documentation sources cited.
- `docs/managed-settings.example.json` and `docs/TEAM-MANAGED-SETTINGS.md`: organization-level managed settings for teams, with the exact file path per OS from the official documentation.
- `global/scripts/safe-db-operation.js` and `global/scripts/safe-db-operation.config.example.json`: a generic, config-driven version of the project-specific "safe DB operation" script (no hardcoded schema). Dry-run by default, explicit confirmation code required for `--execute`, every call logged. Documented in `global/scripts/README.md` and `global/settings.example.json` (`CLAUDE_DB_PROTECT_DIRS`, `CLAUDE_DB_PROTECT`, `CLAUDE_DB_SAFE_TOOL`). Tested in `global/scripts/tests/test-safe-db-operation.sh`.
- README.md: a documented alternative to `curl | bash` (clone a tagged release, read `scripts/install.sh` before running it).

## [4.0.0] - 2026-10-06

### Added

- **User-level layer (`global/`)**: everything needed to run the same Claude Code setup in `~/.claude`, installable with `global/install-global.sh` (dry-run, timestamped backup, idempotent settings merge).
- **Global `CLAUDE.md`**: self-verification before the final answer, output and context discipline, design generation protocol, anti-proliferation gate, 2-phase research, CLI over MCP, model delegation (`opusplan` default), usage-measured routing, communication style, memory conventions.
- **19 hooks** with `settings-hooks.json`: `validate-command.js`, `external-send-guard.sh` (in-turn confirmation flag), `no-haiku-for-code.sh`, `check-force-push.sh`, `check-compiled-files.sh`, `api-key-isolation-guard.sh`, marketplace vetting (`plugin-script-exec-guard.sh`, `marketplace-add-guard.sh`, `mcp-tool-trust-gate.sh`, `guard-file-tamper-guard.sh`), `memory-novelty-gate.py`, `local-search-before-uncertainty.py`, `detect-frustration-pattern.sh`, `rtk-rewrite.sh`, session lifecycle hooks. Tests: smoke test (43 cases) and marketplace vetting suite (24 cases).
- **16 ops scripts**: `env-vault.sh`, `scan-secrets.sh`, `api-key-guard.sh`, worktree helpers, heartbeat watchdog with alert-channel canary (+ cron evaluator, 40 test cases), cost status line and dashboard, `usage-scan.py`, `skills-index-refresh.py`, rotation and dashboard utilities.
- **Skills**: `engineering-philosophy`, `just-content`, `anti-ai-writing`, `marketplace-vetting`, `pre-design`. **Commands**: `/grill`, `/clean-commit`, `/opusplan`, `/fableplan`, `/audit-drift`. **Agents**: `researcher`, `doc-reader`, `code-reviewer`, `debug-assistant`, `test-writer`, `pr-describer`, `memory-sync`.
- **Docs**: `docs/MEMORY-SYSTEM.md`, `docs/SKILLS-GOVERNANCE.md`.

### Changed

- `verify-kit.sh`: utility subagents (`AGENT-RESEARCHER`, `AGENT-DOC-READER`) are no longer checked as audit agents. The kit passes its own check again (0 errors, 0 warnings).
- `AGENT-RESEARCHER.md`, `AGENT-DOC-READER.md`: English descriptions, `effort` and `permissionMode` frontmatter.
- Examples in contracts and frameworks use neutral placeholder names.

### Removed

- `IMPROVEMENT-PLAN.md` (internal planning document, superseded).

## [3.3.0] - 2026-04-22

### Added

- **CONTRACT-TOKEN-ECONOMY.md**: Complete token economy optimization contract — 7 domains: model delegation (TE-1.x), two-phase research pattern 3.2x cheaper (TE-2.x), context reduction .claudeignore + CLAUDE.md migration (TE-3.x), output controls (TE-4.x), RTK shell compression 70-99% (TE-5.x), MCP server hygiene 50-100K tokens/session (TE-6.x), monitoring (TE-7.x). Sources: Anthropic pricing 2025, empirical testing, RTK Issue #690, arXiv 2601.08815
- **AGENT-RESEARCHER.md**: Haiku subagent for web research — mandatory 400 token summary + ranked "dig deeper" table
- **AGENT-DOC-READER.md**: Haiku subagent for documentation reading — mandatory 400 token digest + "sections to read" table
- **hook-subagent-output.sh**: PostToolUse hook (Agent matcher) — alerts when subagent output exceeds 800 words (CONTRACT-TOKEN-ECONOMY TE-7.1)
- **templates/.claudeignore**: Universal .claudeignore template with stack-specific sections (Next.js, iOS, Android, Python, Monorepo)
- **templates/settings.json**: Full token economy config — `model: opusplan` (Haiku research → Opus plan → Sonnet execute, 68% savings), env vars, bypass permissions, RTK telemetry disabled, subagent monitoring hook
- **templates/rtk-filters.toml**: RTK user-global filters — bypass compression for all test commands (npm test, pytest, cargo test, xcodebuild, gradle) to prevent Issue #690 debug loops. Documents which commands RTK should compress vs pass raw.

### Insights (validated, no action required)

- **Prompt caching**: Claude Code caches automatically. Manual breakpoints are API-only, not configurable in Claude Code. Optimal caching is achieved by keeping CLAUDE.md short + stable + minimal MCP servers — all already covered by TE-3.x and TE-6.x.

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
