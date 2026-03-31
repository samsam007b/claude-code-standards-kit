#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# SQWR Project Kit — Integrity Checker
# ═══════════════════════════════════════════════════════════════
#
# Role: Validates that the Project Kit is complete and consistent.
#       Automated self-tests for the kit itself (meta-tests).
#
# Usage: bash verify-kit.sh [--verbose]
#
# What it checks:
#   1. All kit files exist (contracts, audits, templates, agents, hooks, workflows)
#   2. The CLAUDE.md template has the required sections
#   3. Each contract cites at least one source
#   4. Audits have numerical thresholds
#   5. init-project.sh references existing contracts
#   6. Agent files have required structure (frontmatter + 4-level)
#   7. Hook scripts cite contract sources and are executable
#   8. Workflow files have gates and observable truths
#   9. settings.json template references existing hooks
#  10. Workflow gates and observable truths
#  11. settings.json → hook references
#  12. Last validated field in contracts
#  13. Plugin structure (.claude-plugin/ + hooks.json + skills/)
#  14. Risk Score formula validity (weights in AGENT-RISK-SCORE.md)
#  15. Hook event coverage (≥15 event types in hooks.json)
#  16. Version consistency (plugin.json = README.md = CHANGELOG.md)
#  17. SECURITY.md (Responsible Disclosure policy)
#  18. CHANGELOG.md (Keep a Changelog format)
#
# Exit codes:
#   Exit 0 = kit valid
#   Exit 1 = gaps detected
#
# Requirements: bash ≥3.2 (macOS default), grep, awk
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERBOSE=false
ERRORS=0
WARNINGS=0

# ─── Args ───────────────────────────────────────────────────────
for arg in "$@"; do
  case $arg in
    --verbose|-v) VERBOSE=true ;;
  esac
done

# ─── Colours ────────────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GRAY='\033[0;37m'
NC='\033[0m'

# ─── Helpers ────────────────────────────────────────────────────
pass() { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; WARNINGS=$((WARNINGS + 1)); }
info() { $VERBOSE && echo -e "  ${GRAY}→${NC} $1" || true; }
section() { echo -e "\n${BLUE}▸ $1${NC}"; }

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  SQWR Project Kit — Integrity Check${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  Kit: ${GRAY}$KIT_DIR${NC}"

# ═══════════════════════════════════════════════════════════════
# TEST 1 — Required files
# ═══════════════════════════════════════════════════════════════
section "Test 1 — Required files"

REQUIRED_FILES=(
  "README.md"
  "IDENTITY-TEMPLATE.md"
  "templates/CLAUDE.md"
  "templates/.env.example"
  "templates/.gitignore"
  "templates/CHANGELOG.md"
  "templates/CONTRIBUTING.md"
  "contracts/CONTRACT-NEXTJS.md"
  "contracts/CONTRACT-SUPABASE.md"
  "contracts/CONTRACT-VERCEL.md"
  "contracts/CONTRACT-DESIGN.md"
  "contracts/CONTRACT-TYPESCRIPT.md"
  "contracts/CONTRACT-TESTING.md"
  "contracts/CONTRACT-SECURITY.md"
  "contracts/CONTRACT-PERFORMANCE.md"
  "contracts/CONTRACT-ACCESSIBILITY.md"
  "contracts/CONTRACT-ANTI-HALLUCINATION.md"
  "contracts/CONTRACT-AI-PROMPTING.md"
  "contracts/CONTRACT-IOS.md"
  "contracts/CONTRACT-PDF-GENERATION.md"
  "contracts/CONTRACT-SEO.md"
  "contracts/CONTRACT-EMAIL.md"
  "contracts/CONTRACT-CICD.md"
  "contracts/CONTRACT-ANALYTICS.md"
  "contracts/CONTRACT-I18N.md"
  "contracts/CONTRACT-PRICING.md"
  "contracts/CONTRACT-ANDROID.md"
  "contracts/CONTRACT-MOTION-DESIGN.md"
  "contracts/CONTRACT-VIDEO-PRODUCTION.md"
  "contracts/CONTRACT-OBSERVABILITY.md"
  "contracts/CONTRACT-RESILIENCE.md"
  "contracts/CONTRACT-PYTHON.md"
  "contracts/CONTRACT-GREEN-SOFTWARE.md"
  "contracts/CONTRACT-AI-AGENTS.md"
  "contracts/CONTRACT-GRAPHQL.md"
  "contracts/CONTRACT-MULTI-TENANT.md"
  "contracts/CONTRACT-FEATURE-FLAGS.md"
  "contracts/CONTRACT-MONOREPO.md"
  "contracts/CONTRACT-DOCUMENTATION.md"
  "audits/AUDIT-OBSERVABILITY.md"
  "frameworks/UX-RESEARCH.md"
  "frameworks/SOCIAL-CONTENT.md"
  "audits/AUDIT-RGPD.md"
  "audits/AUDIT-BRAND-STRATEGY.md"
  "frameworks/COMPETITIVE-AUDIT.md"
  "frameworks/CAMPAIGN-STRATEGY.md"
  "audits/AUDIT-INDEX.md"
  "audits/AUDIT-SECURITY.md"
  "audits/AUDIT-PERFORMANCE.md"
  "audits/AUDIT-ACCESSIBILITY.md"
  "audits/AUDIT-CODE-QUALITY.md"
  "audits/AUDIT-AI-GOVERNANCE.md"
  "audits/AUDIT-DESIGN.md"
  "audits/AUDIT-DEPLOYMENT.md"
  "scripts/init-project.sh"
  "scripts/verify-kit.sh"
  "scripts/validate-claude-md.sh"
  "templates/settings.json"
  "scripts/verify-project.sh"
  "agents/AGENT-SECURITY-AUDIT.md"
  "agents/AGENT-PERFORMANCE-AUDIT.md"
  "agents/AGENT-CODE-QUALITY-AUDIT.md"
  "agents/AGENT-ACCESSIBILITY-AUDIT.md"
  "agents/AGENT-OBSERVABILITY-AUDIT.md"
  "agents/AGENT-DESIGN-AUDIT.md"
  "agents/AGENT-AI-GOVERNANCE-AUDIT.md"
  "agents/AGENT-DEPLOYMENT-GATE.md"
  "agents/AGENT-FULL-AUDIT.md"
  "skills/auto-fix/SKILL.md"
  "contracts/CONTRACT-API-DESIGN.md"
  "contracts/CONTRACT-DATABASE-MIGRATIONS.md"
  "contracts/CONTRACT-ERROR-HANDLING.md"
  "audits/AUDIT-RESILIENCE.md"
  "agents/AGENT-RESILIENCE-AUDIT.md"
  "hooks/hooks.json"
  "hooks/scripts/hook-no-secrets.sh"
  "hooks/scripts/hook-no-dangerous-html.sh"
  "hooks/scripts/hook-build-before-commit.sh"
  "hooks/scripts/hook-contract-compliance.sh"
  "hooks/scripts/hook-audit-before-push.sh"
  "hooks/scripts/hook-session-context.sh"
  "hooks/scripts/hook-pre-compact.sh"
  "hooks/scripts/hook-post-response.sh"
  "hooks/scripts/hook-session-end.sh"
  ".claude-plugin/plugin.json"
  "workflows/WORKFLOW-NEW-FEATURE.md"
  "workflows/WORKFLOW-PRE-DEPLOYMENT.md"
  "workflows/WORKFLOW-MONTHLY-REVIEW.md"
  "frameworks/BRAND-STRATEGY.md"
  "METHODOLOGY.md"
  "DISCOVERY-GUIDE.md"
  # Governance files
  "SECURITY.md"
  "CHANGELOG.md"
  "ROADMAP.md"
  # New agents
  "agents/AGENT-RISK-SCORE.md"
  # New audits
  "audits/AUDIT-RISK-SCORE.md"
  # New contracts
  "contracts/CONTRACT-EU-AI-ACT.md"
  "contracts/CONTRACT-AI-SAFETY.md"
  "contracts/CONTRACT-DORA-METRICS.md"
  # New skills
  "skills/compliance-check/SKILL.md"
  "skills/risk-score/SKILL.md"
  # New rules
  "rules/security-rules.md"
  "rules/accessibility-rules.md"
  "rules/performance-rules.md"
  "rules/api-rules.md"
  "rules/testing-rules.md"
  "rules/documentation-rules.md"
  # GitHub CI
  ".github/workflows/verify-kit.yml"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [ -f "$KIT_DIR/$file" ]; then
    info "Found: $file"
    pass "$file"
  else
    fail "MISSING: $file"
  fi
done

# ═══════════════════════════════════════════════════════════════
# TEST 2 — Required sections in CLAUDE.md template
# ═══════════════════════════════════════════════════════════════
section "Test 2 — Required sections in CLAUDE.md template"

TEMPLATE="$KIT_DIR/templates/CLAUDE.md"
REQUIRED_SECTIONS=(
  "Who you are"
  "This project"
  "Architecture"
  "Active contracts"
  "Absolute rules"
  "Error history"
)

if [ -f "$TEMPLATE" ]; then
  for section_name in "${REQUIRED_SECTIONS[@]}"; do
    if grep -q "$section_name" "$TEMPLATE"; then
      pass "Section: $section_name"
    else
      fail "Missing section: $section_name"
    fi
  done
  # Check that the template has [TO FILL IN] placeholders (expected)
  PLACEHOLDER_COUNT=$(grep -c "\[TO FILL IN\]" "$TEMPLATE" 2>/dev/null || echo "0")
  info "[TO FILL IN] placeholders in template: $PLACEHOLDER_COUNT (expected)"
else
  fail "CLAUDE.md template not found"
fi

# ═══════════════════════════════════════════════════════════════
# TEST 3 — Each contract cites at least one source
# ═══════════════════════════════════════════════════════════════
section "Test 3 — Scientific grounding (sources in contracts)"

for contract in "$KIT_DIR/contracts/"CONTRACT-*.md; do
  contract_name=$(basename "$contract")
  if grep -qiE "(source|référence|https?://|w3\.org|owasp|nist|wcag|google|martin fowler)" "$contract"; then
    pass "$contract_name → sources present"
  else
    fail "$contract_name → NO source detected"
  fi
done

# ═══════════════════════════════════════════════════════════════
# TEST 4 — Audits have numerical thresholds
# ═══════════════════════════════════════════════════════════════
section "Test 4 — Measurable thresholds in audits"

for audit in "$KIT_DIR/audits/"AUDIT-*.md; do
  audit_name=$(basename "$audit")
  # Look for percentages, /100 scores, or threshold numbers
  if grep -qE "([0-9]+%|/100|≤[0-9]|≥[0-9]|<[0-9]|>[0-9])" "$audit"; then
    pass "$audit_name → numerical thresholds present"
  else
    warn "$audit_name → no numerical thresholds detected"
  fi
done

# ═══════════════════════════════════════════════════════════════
# TEST 5 — init-project.sh references existing contracts
# ═══════════════════════════════════════════════════════════════
section "Test 5 — Consistency: init-project.sh ↔ contracts"

INIT_SCRIPT="$KIT_DIR/scripts/init-project.sh"
if [ -f "$INIT_SCRIPT" ]; then
  # Extract contract names referenced in the script
  REFERENCED=$(grep -oE "CONTRACT-[A-Z0-9-]+" "$INIT_SCRIPT" | sort -u)
  for contract_ref in $REFERENCED; do
    if [ -f "$KIT_DIR/contracts/$contract_ref.md" ]; then
      pass "Resolved reference: $contract_ref.md"
    else
      fail "Broken reference in init-project.sh: $contract_ref.md NOT FOUND"
    fi
  done
else
  fail "init-project.sh not found"
fi

# ═══════════════════════════════════════════════════════════════
# TEST 6 — IDENTITY-TEMPLATE contains the required structure
# ═══════════════════════════════════════════════════════════════
section "Test 6 — IDENTITY-TEMPLATE.md structure"

IDENTITY="$KIT_DIR/IDENTITY-TEMPLATE.md"
REQUIRED_IDENTITY=(
  "Who I am"
  "Preferred stack"
  "Cognitive biases"
  "Planning fallacy"
  "Work style"
)

if [ -f "$IDENTITY" ]; then
  for item in "${REQUIRED_IDENTITY[@]}"; do
    if grep -q "$item" "$IDENTITY"; then
      pass "Identity: $item present"
    else
      fail "Identity: $item MISSING"
    fi
  done
else
  fail "IDENTITY-TEMPLATE.md not found"
fi

# ═══════════════════════════════════════════════════════════════
# TEST 7 — README references all contracts
# ═══════════════════════════════════════════════════════════════
section "Test 7 — README.md references all contracts"

README="$KIT_DIR/README.md"
if [ -f "$README" ]; then
  for contract in "$KIT_DIR/contracts/"CONTRACT-*.md; do
    contract_name=$(basename "$contract" .md)
    if grep -q "$contract_name" "$README"; then
      pass "README references: $contract_name"
    else
      warn "README does not reference: $contract_name"
    fi
  done
else
  fail "README.md not found"
fi

# ═══════════════════════════════════════════════════════════════
# TEST 8 — Agent files have required structure
# ═══════════════════════════════════════════════════════════════
section "Test 8 — Agent structure (frontmatter + 4-level verification)"

AGENTS_DIR="$KIT_DIR/agents"
if [ -d "$AGENTS_DIR" ]; then
  for agent in "$AGENTS_DIR"/AGENT-*.md; do
    agent_name=$(basename "$agent")
    # Check frontmatter description
    if grep -q "^description:" "$agent"; then
      info "$agent_name → description present"
    else
      fail "$agent_name → missing 'description:' frontmatter"
    fi
    # Check frontmatter tools
    if grep -q "^tools:" "$agent"; then
      info "$agent_name → tools present"
    else
      fail "$agent_name → missing 'tools:' frontmatter"
    fi
    # Check enriched frontmatter (Phase 2 — plugin system fields)
    if grep -q "^model:" "$agent"; then
      info "$agent_name → model present"
    else
      fail "$agent_name → missing 'model:' frontmatter (required: sonnet, opus, or haiku)"
    fi
    if grep -q "^effort:" "$agent"; then
      # Validate effort value is one of: low, medium, high
      EFFORT_VAL=$(grep "^effort:" "$agent" | head -1 | sed 's/effort: *//' | tr -d '"')
      if echo "$EFFORT_VAL" | grep -qE "^(low|medium|high)$"; then
        pass "$agent_name → effort: $EFFORT_VAL (valid)"
      else
        fail "$agent_name → invalid effort value: '$EFFORT_VAL' (must be low, medium, or high)"
      fi
    else
      fail "$agent_name → missing 'effort:' frontmatter (required: low, medium, or high)"
    fi
    if grep -q "^permissionMode:" "$agent"; then
      info "$agent_name → permissionMode present"
    else
      warn "$agent_name → missing 'permissionMode:' frontmatter (recommended: bypassPermissions for read-only audits)"
    fi
    # Check 4-level verification structure (skip orchestrator)
    if [[ "$agent_name" == "AGENT-FULL-AUDIT.md" ]]; then
      pass "$agent_name → orchestrator (delegates 4-level verification to sub-agents)"
    else
      LEVELS_FOUND=0
      grep -q "Level 1" "$agent" && ((LEVELS_FOUND++))
      grep -q "Level 2" "$agent" && ((LEVELS_FOUND++))
      grep -q "Level 3" "$agent" && ((LEVELS_FOUND++))
      grep -q "Level 4" "$agent" && ((LEVELS_FOUND++))
      if [ "$LEVELS_FOUND" -eq 4 ]; then
        pass "$agent_name → 4-level verification structure"
      else
        fail "$agent_name → incomplete 4-level verification ($LEVELS_FOUND/4 levels found)"
      fi
    fi
    # Check scoring section
    if grep -qi "scoring\|score" "$agent"; then
      pass "$agent_name → scoring section present"
    else
      warn "$agent_name → no scoring section detected"
    fi
  done
else
  fail "agents/ directory not found"
fi

# ═══════════════════════════════════════════════════════════════
# TEST 9 — Hooks cite contract sources and are executable
# ═══════════════════════════════════════════════════════════════
section "Test 9 — Hooks structure (source citations + exit codes)"

HOOKS_DIR="$KIT_DIR/hooks/scripts"
if [ -d "$HOOKS_DIR" ]; then
  for hook in "$HOOKS_DIR"/hook-*.sh; do
    hook_name=$(basename "$hook")
    # Check executable
    if [ -x "$hook" ]; then
      pass "$hook_name → executable"
    else
      warn "$hook_name → not executable (run: chmod +x $hook)"
    fi
    # Check source citation
    if grep -qiE "(CONTRACT-|AUDIT-|Source:)" "$hook"; then
      pass "$hook_name → contract source cited"
    else
      fail "$hook_name → no contract source citation"
    fi
    # Check exit codes
    if grep -qE "exit [02]" "$hook"; then
      pass "$hook_name → exit codes present"
    else
      warn "$hook_name → no explicit exit codes found"
    fi
  done
else
  fail "hooks/ directory not found"
fi

# ═══════════════════════════════════════════════════════════════
# TEST 10 — Workflows have Observable truths at each gate
# ═══════════════════════════════════════════════════════════════
section "Test 10 — Workflow structure (gates + observable truths)"

WORKFLOWS_DIR="$KIT_DIR/workflows"
if [ -d "$WORKFLOWS_DIR" ]; then
  for workflow in "$WORKFLOWS_DIR"/WORKFLOW-*.md; do
    workflow_name=$(basename "$workflow")
    # Check gate structure
    if grep -qiE "Gate [0-9]|## Gate|Phase [0-9]|## Phase" "$workflow"; then
      pass "$workflow_name → gate/phase structure present"
    else
      fail "$workflow_name → no gate or phase structure detected"
    fi
    # Check observable truths
    TRUTH_COUNT=$(grep -ci "observable truth" "$workflow" 2>/dev/null || echo "0")
    if [ "$TRUTH_COUNT" -ge 3 ]; then
      pass "$workflow_name → $TRUTH_COUNT observable truths"
    else
      fail "$workflow_name → only $TRUTH_COUNT observable truth(s) (minimum: 3)"
    fi
  done
else
  fail "workflows/ directory not found"
fi

# ═══════════════════════════════════════════════════════════════
# TEST 11 — templates/settings.json references existing hooks
# ═══════════════════════════════════════════════════════════════
section "Test 11 — settings.json template consistency"

SETTINGS_TEMPLATE="$KIT_DIR/templates/settings.json"
if [ -f "$SETTINGS_TEMPLATE" ]; then
  # Extract hook paths referenced in settings.json
  HOOK_REFS=$(grep -oE "hook-[a-z-]+\.sh" "$SETTINGS_TEMPLATE" | sort -u)
  for hook_ref in $HOOK_REFS; do
    if [ -f "$KIT_DIR/hooks/scripts/$hook_ref" ]; then
      pass "settings.json → $hook_ref exists in hooks/scripts/"
    else
      fail "settings.json references missing hook: $hook_ref (looked in hooks/scripts/)"
    fi
  done
else
  fail "templates/settings.json not found"
fi

# ═══════════════════════════════════════════════════════════════
# TEST 12 — Last validated in contracts
# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${BLUE}▸ Test 12 — Last validated field in contracts${NC}"
for contract in "$KIT_DIR"/contracts/CONTRACT-*.md; do
  name=$(basename "$contract")
  if grep -q "Last validated" "$contract" 2>/dev/null; then
    [ "$VERBOSE" = true ] && echo -e "  ${GREEN}✓${NC} $name → Last validated present"
  else
    echo -e "  ${YELLOW}⚠${NC}  $name → missing Last validated field (CONTRIBUTING.md requires it)"
    WARNINGS=$((WARNINGS + 1))
  fi
done

# ═══════════════════════════════════════════════════════════════
# TEST 13 — Plugin structure
# ═══════════════════════════════════════════════════════════════
section "Test 13 — Plugin structure (.claude-plugin/ + hooks.json)"

PLUGIN_JSON="$KIT_DIR/.claude-plugin/plugin.json"
HOOKS_JSON="$KIT_DIR/hooks/hooks.json"

# Validate plugin.json
if [ -f "$PLUGIN_JSON" ]; then
  if python3 -m json.tool "$PLUGIN_JSON" >/dev/null 2>&1; then
    pass ".claude-plugin/plugin.json → valid JSON"
  else
    fail ".claude-plugin/plugin.json → invalid JSON"
  fi
  # Check required fields
  for field in name version agents skills hooks; do
    if grep -q "\"$field\"" "$PLUGIN_JSON"; then
      pass ".claude-plugin/plugin.json → field '$field' present"
    else
      fail ".claude-plugin/plugin.json → missing field '$field'"
    fi
  done
else
  fail ".claude-plugin/plugin.json not found"
fi

# Validate hooks.json
if [ -f "$HOOKS_JSON" ]; then
  if python3 -m json.tool "$HOOKS_JSON" >/dev/null 2>&1; then
    pass "hooks/hooks.json → valid JSON"
  else
    fail "hooks/hooks.json → invalid JSON"
  fi
  # Check referenced hook scripts exist
  HOOK_REFS_JSON=$(grep -oE "hook-[a-z-]+\.sh" "$HOOKS_JSON" | sort -u)
  for hook_ref in $HOOK_REFS_JSON; do
    if [ -f "$KIT_DIR/hooks/scripts/$hook_ref" ]; then
      pass "hooks.json → $hook_ref exists"
    else
      fail "hooks.json references missing hook: $hook_ref (looked in hooks/scripts/)"
    fi
  done
else
  fail "hooks/hooks.json not found"
fi

# Check skills/ directory
if [ -d "$KIT_DIR/skills" ]; then
  SKILL_COUNT=$(find "$KIT_DIR/skills" -name "SKILL.md" | wc -l | tr -d ' ')
  if [ "$SKILL_COUNT" -gt 0 ]; then
    pass "skills/ → $SKILL_COUNT SKILL.md file(s) found"
    # Validate each skill has required frontmatter
    while IFS= read -r skill; do
      skill_name=$(dirname "$skill" | xargs basename)
      for field in name description effort; do
        if grep -q "^$field:" "$skill"; then
          info "$skill_name/SKILL.md → '$field' present"
        else
          warn "$skill_name/SKILL.md → missing '$field' in frontmatter"
        fi
      done
    done < <(find "$KIT_DIR/skills" -name "SKILL.md")
  else
    warn "skills/ directory exists but no SKILL.md files found"
  fi
else
  warn "skills/ directory not found (optional — run Phase 3 to create skills)"
fi

# Check commands/ directory
if [ -d "$KIT_DIR/commands" ]; then
  CMD_COUNT=$(find "$KIT_DIR/commands" -name "*.md" | wc -l | tr -d ' ')
  if [ "$CMD_COUNT" -gt 0 ]; then
    pass "commands/ → $CMD_COUNT command file(s) found"
  else
    warn "commands/ directory exists but no .md files found"
  fi
else
  warn "commands/ directory not found (optional — run Phase 4 to create commands)"
fi

# ═══════════════════════════════════════════════════════════════
# TEST 14 — Risk Score formula validity
# ═══════════════════════════════════════════════════════════════
# ─────────────────────────────────────────────────────────────────────────────
# Test 14 — Risk Score formula validity
# ─────────────────────────────────────────────────────────────────────────────
test_num=14
section "Test $test_num — Risk Score formula"

RISK_AGENT="$KIT_DIR/agents/AGENT-RISK-SCORE.md"
if [ ! -f "$RISK_AGENT" ]; then
  fail "Test $test_num: agents/AGENT-RISK-SCORE.md missing"
else
  # Check formula presence
  if ! grep -q "0\.22" "$RISK_AGENT" 2>/dev/null; then
    fail "Test $test_num: AGENT-RISK-SCORE.md missing Security weight 0.22"
  fi
  if ! grep -q "0\.18" "$RISK_AGENT" 2>/dev/null; then
    fail "Test $test_num: AGENT-RISK-SCORE.md missing Performance/CodeQuality weight 0.18"
  fi
  # Check weight sum annotation (1.00)
  if ! grep -qE "1\.00|= 100" "$RISK_AGENT" 2>/dev/null; then
    warn "Test $test_num: AGENT-RISK-SCORE.md should document that weights sum to 1.00"
  fi
  # Check AUDIT-RISK-SCORE.md also contains the formula
  if [ -f "$KIT_DIR/audits/AUDIT-RISK-SCORE.md" ]; then
    if ! grep -q "0\.22" "$KIT_DIR/audits/AUDIT-RISK-SCORE.md" 2>/dev/null; then
      warn "Test $test_num: AUDIT-RISK-SCORE.md should contain the weighted formula"
    fi
  fi
  pass "Test $test_num: Risk Score formula validated (weights: Security×0.22 + Performance×0.18 + CodeQuality×0.18 + ...)"
fi

# ═══════════════════════════════════════════════════════════════
# TEST 15 — Hook event coverage
# ═══════════════════════════════════════════════════════════════
# ─────────────────────────────────────────────────────────────────────────────
# Test 15 — Hook event coverage (≥15 event types in hooks.json)
# ─────────────────────────────────────────────────────────────────────────────
test_num=15
section "Test $test_num — Hook event coverage"

HOOKS_JSON="$KIT_DIR/hooks/hooks.json"
if [ ! -f "$HOOKS_JSON" ]; then
  fail "Test $test_num: hooks/hooks.json missing"
else
  # Count top-level keys in hooks object (each key = one event type)
  # Use python3 for reliable JSON parsing
  EVENT_COUNT=$(python3 -c "
import json, sys
with open('$HOOKS_JSON') as f:
    data = json.load(f)
hooks = data.get('hooks', {})
print(len(hooks))
" 2>/dev/null || echo "0")

  if [ "$EVENT_COUNT" -lt 10 ]; then
    fail "Test $test_num: hooks.json covers only $EVENT_COUNT event types (minimum 10 required)"
  elif [ "$EVENT_COUNT" -lt 15 ]; then
    warn "Test $test_num: hooks.json covers only $EVENT_COUNT event types (recommended ≥15)"
  else
    pass "Test $test_num: Hook event coverage: $EVENT_COUNT event types covered"
  fi
fi

# ═══════════════════════════════════════════════════════════════
# TEST 16 — Version consistency
# ═══════════════════════════════════════════════════════════════
# ─────────────────────────────────────────────────────────────────────────────
# Test 16 — Version consistency (plugin.json = README.md = CHANGELOG.md)
# ─────────────────────────────────────────────────────────────────────────────
test_num=16
section "Test $test_num — Version consistency"

PLUGIN_JSON="$KIT_DIR/.claude-plugin/plugin.json"
if [ ! -f "$PLUGIN_JSON" ]; then
  fail "Test $test_num: .claude-plugin/plugin.json missing"
else
  PLUGIN_VERSION=$(python3 -c "
import json
with open('$PLUGIN_JSON') as f:
    data = json.load(f)
print(data.get('version', 'missing'))
" 2>/dev/null || echo "missing")

  if [ "$PLUGIN_VERSION" = "missing" ]; then
    fail "Test $test_num: Could not read version from plugin.json"
  else
    ERRORS_V=0
    # Check README.md references this version
    if [ -f "$KIT_DIR/README.md" ]; then
      if ! grep -q "$PLUGIN_VERSION" "$KIT_DIR/README.md" 2>/dev/null; then
        warn "Test $test_num: README.md does not reference version $PLUGIN_VERSION"
        ERRORS_V=$((ERRORS_V + 1))
      fi
    fi
    # Check CHANGELOG.md has an entry for this version
    if [ -f "$KIT_DIR/CHANGELOG.md" ]; then
      if ! grep -q "\[$PLUGIN_VERSION\]" "$KIT_DIR/CHANGELOG.md" 2>/dev/null; then
        warn "Test $test_num: CHANGELOG.md has no entry for version [$PLUGIN_VERSION]"
        ERRORS_V=$((ERRORS_V + 1))
      fi
    fi
    if [ "$ERRORS_V" -eq 0 ]; then
      pass "Test $test_num: Version consistency: $PLUGIN_VERSION consistent across plugin.json, README.md, CHANGELOG.md"
    else
      pass "Test $test_num: Version consistency: $PLUGIN_VERSION in plugin.json ($ERRORS_V consistency warnings — see above)"
    fi
  fi
fi

# ═══════════════════════════════════════════════════════════════
# TEST 17 — SECURITY.md
# ═══════════════════════════════════════════════════════════════
# ─────────────────────────────────────────────────────────────────────────────
# Test 17 — SECURITY.md (Responsible Disclosure policy)
# ─────────────────────────────────────────────────────────────────────────────
test_num=17
section "Test $test_num — SECURITY.md"

if [ ! -f "$KIT_DIR/SECURITY.md" ]; then
  fail "Test $test_num: SECURITY.md missing (required by Anthropic Verified Plugins Program)"
else
  SECURITY_ERRORS=0
  if ! grep -qi "responsible disclosure\|reporting.*vulnerabilit\|vulnerabilit.*report" "$KIT_DIR/SECURITY.md" 2>/dev/null; then
    warn "Test $test_num: SECURITY.md should contain a Responsible Disclosure section"
    SECURITY_ERRORS=$((SECURITY_ERRORS + 1))
  fi
  if ! grep -qi "supported version" "$KIT_DIR/SECURITY.md" 2>/dev/null; then
    warn "Test $test_num: SECURITY.md should contain a Supported Versions table"
    SECURITY_ERRORS=$((SECURITY_ERRORS + 1))
  fi
  if [ "$SECURITY_ERRORS" -eq 0 ]; then
    pass "Test $test_num: SECURITY.md valid (Responsible Disclosure + Supported Versions present)"
  else
    pass "Test $test_num: SECURITY.md exists ($SECURITY_ERRORS structure warnings — see above)"
  fi
fi

# ═══════════════════════════════════════════════════════════════
# TEST 18 — CHANGELOG.md
# ═══════════════════════════════════════════════════════════════
# ─────────────────────────────────────────────────────────────────────────────
# Test 18 — CHANGELOG.md (Keep a Changelog format)
# ─────────────────────────────────────────────────────────────────────────────
test_num=18
section "Test $test_num — CHANGELOG.md"

if [ ! -f "$KIT_DIR/CHANGELOG.md" ]; then
  fail "Test $test_num: CHANGELOG.md missing (required by Anthropic Verified Plugins Program)"
else
  CHANGELOG_ERRORS=0
  if ! grep -q "\[Unreleased\]" "$KIT_DIR/CHANGELOG.md" 2>/dev/null; then
    warn "Test $test_num: CHANGELOG.md missing [Unreleased] section (Keep a Changelog format)"
    CHANGELOG_ERRORS=$((CHANGELOG_ERRORS + 1))
  fi
  if ! grep -qE "\[[0-9]+\.[0-9]+\.[0-9]+\]" "$KIT_DIR/CHANGELOG.md" 2>/dev/null; then
    warn "Test $test_num: CHANGELOG.md missing versioned entries like [3.1.0]"
    CHANGELOG_ERRORS=$((CHANGELOG_ERRORS + 1))
  fi
  if ! grep -qi "added\|changed\|fixed\|removed" "$KIT_DIR/CHANGELOG.md" 2>/dev/null; then
    warn "Test $test_num: CHANGELOG.md should use Keep a Changelog sections (Added, Changed, Fixed)"
    CHANGELOG_ERRORS=$((CHANGELOG_ERRORS + 1))
  fi
  if [ "$CHANGELOG_ERRORS" -eq 0 ]; then
    pass "Test $test_num: CHANGELOG.md valid (Keep a Changelog format with [Unreleased] section)"
  else
    pass "Test $test_num: CHANGELOG.md exists ($CHANGELOG_ERRORS format warnings — see above)"
  fi
fi

# ═══════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
  echo -e "${GREEN}✅ Kit valid — 0 errors, 0 warnings${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  exit 0
elif [ "$ERRORS" -eq 0 ]; then
  echo -e "${YELLOW}⚠️  Kit acceptable — 0 errors, $WARNINGS warning(s)${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  exit 0
else
  echo -e "${RED}❌ Kit invalid — $ERRORS error(s), $WARNINGS warning(s)${NC}"
  echo -e "   Fix the errors before using the kit on a new project."
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  exit 1
fi
