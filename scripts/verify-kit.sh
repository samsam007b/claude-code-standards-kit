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
#   1. All kit files exist (contracts, audits, templates)
#   2. The CLAUDE.md template has the required sections
#   3. Each contract cites at least one source
#   4. Audits have numerical thresholds
#   5. init-project.sh references existing contracts
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
fail() { echo -e "  ${RED}✗${NC} $1"; ((ERRORS++)); }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; ((WARNINGS++)); }
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
  "frameworks/BRAND-STRATEGY.md"
  "METHODOLOGY.md"
  "DISCOVERY-GUIDE.md"
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
  REFERENCED=$(grep -oE "CONTRACT-[A-Z-]+" "$INIT_SCRIPT" | sort -u)
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
