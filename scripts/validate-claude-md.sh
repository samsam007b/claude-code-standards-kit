#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# SQWR Project Kit — CLAUDE.md Validator
# ═══════════════════════════════════════════════════════════════
#
# Role: Verifies that a project CLAUDE.md is complete.
#       Blocks if any [TO FILL IN] placeholders remain or if
#       required sections are missing.
#
# Usage: bash validate-claude-md.sh [path/to/CLAUDE.md]
#        Default: ./CLAUDE.md (from the project root)
#
# Examples:
#   bash ~/.../Project-Kit/scripts/validate-claude-md.sh
#   bash ~/.../Project-Kit/scripts/validate-claude-md.sh /path/to/project/CLAUDE.md
#
# Exit codes:
#   Exit 0 = CLAUDE.md is valid
#   Exit 1 = CLAUDE.md is incomplete
#
# Prerequisites: bash ≥3.2, grep
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

# ─── Colors ─────────────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

pass() { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; ((ERRORS++)); }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; ((WARNINGS++)); }

# ─── Locate the file ─────────────────────────────────────────────
CLAUDE_FILE="${1:-$(pwd)/CLAUDE.md}"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  SQWR — CLAUDE.md Validation${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  File: $CLAUDE_FILE"
echo ""

if [ ! -f "$CLAUDE_FILE" ]; then
  echo -e "${RED}❌ CLAUDE.md not found: $CLAUDE_FILE${NC}"
  echo -e "   Create a CLAUDE.md from the template:"
  echo -e "   cp ~/.../Project-Kit/templates/CLAUDE.md ./CLAUDE.md"
  exit 1
fi

# ═══════════════════════════════════════════════════════════════
# TEST 1 — Required sections present
# ═══════════════════════════════════════════════════════════════
echo -e "${BLUE}▸ Required sections${NC}"

REQUIRED_SECTIONS=(
  "Who you are"
  "This project"
  "Architecture"
  "Active contracts"
  "Absolute rules"
  "Error history"
)

for section in "${REQUIRED_SECTIONS[@]}"; do
  if grep -q "$section" "$CLAUDE_FILE"; then
    pass "Section present: $section"
  else
    fail "MISSING section: $section"
  fi
done

# ═══════════════════════════════════════════════════════════════
# TEST 2 — No remaining [TO FILL IN] placeholders
# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${BLUE}▸ Unfilled placeholders${NC}"

PLACEHOLDER_COUNT=$(grep -c "\[TO FILL IN\]" "$CLAUDE_FILE" 2>/dev/null || echo "0")
if [ "$PLACEHOLDER_COUNT" -eq 0 ]; then
  pass "No remaining [TO FILL IN] placeholders"
else
  fail "$PLACEHOLDER_COUNT [TO FILL IN] placeholder(s) not filled in:"
  grep -n "\[TO FILL IN\]" "$CLAUDE_FILE" | while read -r line; do
    echo -e "     Line $line"
  done
fi

# ═══════════════════════════════════════════════════════════════
# TEST 3 — User identity present
# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${BLUE}▸ User identity${NC}"

# Check that the CLAUDE.md has been personalized (no generic placeholder)
if grep -q "\[YOUR NAME\]" "$CLAUDE_FILE"; then
  warn "Identity section not filled in — replace [YOUR NAME] with your name"
else
  pass "Identity personalized (no [YOUR NAME] placeholder)"
fi

if grep -qE "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" "$CLAUDE_FILE"; then
  pass "Email present in CLAUDE.md"
else
  warn "No email found — add your contact details from IDENTITY-TEMPLATE.md"
fi

# ═══════════════════════════════════════════════════════════════
# TEST 4 — At least one "Never do" rule
# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${BLUE}▸ Absolute rules${NC}"

if grep -qiE "(never do|never|NEVER)" "$CLAUDE_FILE"; then
  pass "'Never do' rules present"
else
  fail "No 'Never do' rules — Absolute rules section is empty"
fi

if grep -qiE "(always do|always|ALWAYS)" "$CLAUDE_FILE"; then
  pass "'Always do' rules present"
else
  warn "No 'Always do' rules (optional but recommended)"
fi

# ═══════════════════════════════════════════════════════════════
# TEST 5 — Error history table present
# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${BLUE}▸ Error history${NC}"

if grep -qE "\|.*Date.*\|" "$CLAUDE_FILE"; then
  pass "Error history table present"
else
  fail "Error history table MISSING"
fi

# ═══════════════════════════════════════════════════════════════
# TEST 6 — Stack documented
# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${BLUE}▸ Tech stack${NC}"

if grep -qiE "(next\.js|python|react|supabase|vercel|swift)" "$CLAUDE_FILE"; then
  pass "Tech stack documented"
else
  warn "Tech stack not detected — 'This project' section may be incomplete"
fi

# ═══════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
  echo -e "${GREEN}✅ CLAUDE.md valid — ready for AI work${NC}"
  exit 0
elif [ "$ERRORS" -eq 0 ]; then
  echo -e "${YELLOW}⚠️  CLAUDE.md acceptable — $WARNINGS warning(s) to address${NC}"
  exit 0
else
  echo -e "${RED}❌ CLAUDE.md incomplete — $ERRORS blocking error(s)${NC}"
  echo -e "   Complete the file before starting an AI session."
  exit 1
fi
