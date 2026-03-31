#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# SQWR Project Kit — Project Validator
# ═══════════════════════════════════════════════════════════════
#
# Role: Validates that a project using the SQWR Kit is
#       correctly configured and ready for development.
#
# Usage: bash verify-project.sh [--path <project-path>] [--verbose]
#
# What it checks:
#   1. CLAUDE.md exists and passes validate-claude-md.sh
#   2. Active contracts in CLAUDE.md exist in docs/contracts/
#   3. .claude/settings.json exists with hooks configured
#   4. .claude/agents/ contains audit agents
#   5. docs/audits/ contains relevant audit files
#   6. .env.local exists (not committed)
#   7. Project health score /100
#
# Exit codes:
#   Exit 0 = project valid (score >= 70)
#   Exit 1 = gaps detected (score < 70)
#
# Requirements: bash ≥3.2 (macOS default)
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

PROJECT_DIR="$(pwd)"
VERBOSE=false
ERRORS=0
WARNINGS=0
SCORE=0

# ─── Args ───────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    --path)
      PROJECT_DIR="$2"
      shift 2
      ;;
    --verbose|-v)
      VERBOSE=true
      shift
      ;;
    *)
      shift
      ;;
  esac
done

# Resolve to absolute path
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

# ─── Colours ────────────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GRAY='\033[0;37m'
NC='\033[0m'

# ─── Helpers ────────────────────────────────────────────────────
pass()    { echo -e "  ${GREEN}✓${NC} $1"; }
fail()    { echo -e "  ${RED}✗${NC} $1"; ((ERRORS++)); }
warn()    { echo -e "  ${YELLOW}⚠${NC} $1"; ((WARNINGS++)); }
info()    { $VERBOSE && echo -e "  ${GRAY}→${NC} $1" || true; }
section() { echo -e "\n${BLUE}▸ $1${NC}"; }

# ─── Per-check score tracking ───────────────────────────────────
CHECK1_SCORE=0
CHECK2_SCORE=0
CHECK3_SCORE=0
CHECK4_SCORE=0
CHECK5_SCORE=0
CHECK6_SCORE=0

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  SQWR Project Kit — Project Health Check${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  Project: ${GRAY}$PROJECT_DIR${NC}"

# ═══════════════════════════════════════════════════════════════
# CHECK 1 — CLAUDE.md exists and is filled (20 pts)
# ═══════════════════════════════════════════════════════════════
section "Check 1 — CLAUDE.md exists and is filled (20 pts)"

CLAUDE_MD="$PROJECT_DIR/CLAUDE.md"
if [ -f "$CLAUDE_MD" ]; then
  pass "CLAUDE.md exists"
  CHECK1_SCORE=$((CHECK1_SCORE + 5))

  # No remaining [TO FILL IN] placeholders
  PLACEHOLDER_COUNT=$(grep -c "\[TO FILL IN\]" "$CLAUDE_MD" 2>/dev/null || echo "0")
  if [ "$PLACEHOLDER_COUNT" -eq 0 ]; then
    pass "No [TO FILL IN] placeholders remaining"
    CHECK1_SCORE=$((CHECK1_SCORE + 5))
  else
    fail "$PLACEHOLDER_COUNT [TO FILL IN] placeholder(s) still present"
  fi

  # No [YOUR NAME] placeholder
  if ! grep -q "\[YOUR NAME\]" "$CLAUDE_MD"; then
    pass "User identity filled (no [YOUR NAME])"
    CHECK1_SCORE=$((CHECK1_SCORE + 5))
  else
    fail "[YOUR NAME] placeholder still present — fill in your identity"
  fi

  # At least one "Never do" rule
  if grep -qiE "never do|never:|never " "$CLAUDE_MD"; then
    pass "At least one 'Never do' rule present"
    CHECK1_SCORE=$((CHECK1_SCORE + 5))
  else
    fail "No 'Never do' rule detected in CLAUDE.md"
  fi
else
  fail "CLAUDE.md not found at project root"
fi
info "Check 1 score: $CHECK1_SCORE/20"

# ═══════════════════════════════════════════════════════════════
# CHECK 2 — Contracts are in place (20 pts)
# ═══════════════════════════════════════════════════════════════
section "Check 2 — Contracts are in place (20 pts)"

CONTRACTS_DIR="$PROJECT_DIR/docs/contracts"
if [ -d "$CONTRACTS_DIR" ]; then
  pass "docs/contracts/ directory exists"
  CHECK2_SCORE=$((CHECK2_SCORE + 7))

  CONTRACT_COUNT=$(find "$CONTRACTS_DIR" -name "CONTRACT-*.md" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$CONTRACT_COUNT" -ge 2 ]; then
    pass "$CONTRACT_COUNT contract(s) present in docs/contracts/"
    CHECK2_SCORE=$((CHECK2_SCORE + 7))
  else
    fail "Only $CONTRACT_COUNT contract(s) found (minimum: 2)"
  fi

  # Check CLAUDE.md lists contracts that exist on disk
  if [ -f "$CLAUDE_MD" ]; then
    LISTED_CONTRACTS=$(grep -oE "CONTRACT-[A-Z0-9-]+" "$CLAUDE_MD" | sort -u)
    MISMATCH=0
    for listed in $LISTED_CONTRACTS; do
      if [ -f "$CONTRACTS_DIR/$listed.md" ]; then
        info "$listed.md → found on disk"
      else
        warn "CLAUDE.md lists $listed but $CONTRACTS_DIR/$listed.md not found"
        MISMATCH=$((MISMATCH + 1))
      fi
    done
    if [ "$MISMATCH" -eq 0 ]; then
      pass "All contracts listed in CLAUDE.md exist on disk"
      CHECK2_SCORE=$((CHECK2_SCORE + 6))
    fi
  else
    info "CLAUDE.md not found — skipping contract cross-reference check"
  fi
else
  fail "docs/contracts/ directory not found"
fi
info "Check 2 score: $CHECK2_SCORE/20"

# ═══════════════════════════════════════════════════════════════
# CHECK 3 — Claude Code configuration (20 pts)
# ═══════════════════════════════════════════════════════════════
section "Check 3 — Claude Code configuration (20 pts)"

CLAUDE_SETTINGS="$PROJECT_DIR/.claude/settings.json"
if [ -f "$CLAUDE_SETTINGS" ]; then
  pass ".claude/settings.json exists"
  CHECK3_SCORE=$((CHECK3_SCORE + 7))

  # At least 1 hook configured (grep for "command")
  HOOK_COUNT=$(grep -c "\"command\"" "$CLAUDE_SETTINGS" 2>/dev/null || echo "0")
  if [ "$HOOK_COUNT" -ge 1 ]; then
    pass "$HOOK_COUNT hook command(s) configured in settings.json"
    CHECK3_SCORE=$((CHECK3_SCORE + 7))
  else
    fail "No hook commands found in settings.json"
  fi
else
  fail ".claude/settings.json not found"
fi

AGENTS_DIR="$PROJECT_DIR/.claude/agents"
if [ -d "$AGENTS_DIR" ]; then
  AGENT_COUNT=$(find "$AGENTS_DIR" -name "AGENT-*.md" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$AGENT_COUNT" -ge 1 ]; then
    pass ".claude/agents/ exists with $AGENT_COUNT AGENT-*.md file(s)"
    CHECK3_SCORE=$((CHECK3_SCORE + 6))
  else
    fail ".claude/agents/ exists but contains no AGENT-*.md files"
  fi
else
  fail ".claude/agents/ directory not found"
fi
info "Check 3 score: $CHECK3_SCORE/20"

# ═══════════════════════════════════════════════════════════════
# CHECK 4 — Development environment (15 pts)
# ═══════════════════════════════════════════════════════════════
section "Check 4 — Development environment (15 pts)"

ENV_LOCAL="$PROJECT_DIR/.env.local"
if [ -f "$ENV_LOCAL" ]; then
  pass ".env.local exists"
  CHECK4_SCORE=$((CHECK4_SCORE + 5))
else
  warn ".env.local not found (create it for local environment variables)"
fi

GITIGNORE="$PROJECT_DIR/.gitignore"
if [ -f "$GITIGNORE" ] && grep -q "\.env\.local" "$GITIGNORE"; then
  pass ".env.local is in .gitignore"
  CHECK4_SCORE=$((CHECK4_SCORE + 5))
else
  if [ ! -f "$GITIGNORE" ]; then
    fail ".gitignore not found"
  else
    fail ".env.local is NOT in .gitignore — risk of secret exposure"
  fi
fi

AUDITS_DIR="$PROJECT_DIR/docs/audits"
if [ -d "$AUDITS_DIR" ]; then
  AUDIT_COUNT=$(find "$AUDITS_DIR" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$AUDIT_COUNT" -ge 1 ]; then
    pass "docs/audits/ exists with $AUDIT_COUNT audit file(s)"
    CHECK4_SCORE=$((CHECK4_SCORE + 5))
  else
    warn "docs/audits/ exists but contains no audit files"
  fi
else
  warn "docs/audits/ directory not found (run an audit to create it)"
fi
info "Check 4 score: $CHECK4_SCORE/15"

# ═══════════════════════════════════════════════════════════════
# CHECK 5 — Git hygiene (15 pts)
# ═══════════════════════════════════════════════════════════════
section "Check 5 — Git hygiene (15 pts)"

if [ -d "$PROJECT_DIR/.git" ]; then
  pass "Git repository initialized"
  CHECK5_SCORE=$((CHECK5_SCORE + 5))
else
  fail ".git directory not found — project is not a git repository"
fi

if [ -f "$GITIGNORE" ]; then
  COMMON_PATTERNS=(".env" "node_modules" ".DS_Store")
  PATTERNS_FOUND=0
  for pattern in "${COMMON_PATTERNS[@]}"; do
    if grep -q "$pattern" "$GITIGNORE"; then
      info ".gitignore contains: $pattern"
      PATTERNS_FOUND=$((PATTERNS_FOUND + 1))
    else
      warn ".gitignore missing common pattern: $pattern"
    fi
  done
  if [ "$PATTERNS_FOUND" -ge 2 ]; then
    pass ".gitignore has common patterns ($PATTERNS_FOUND/${#COMMON_PATTERNS[@]})"
    CHECK5_SCORE=$((CHECK5_SCORE + 5))
  fi
else
  fail ".gitignore not found"
fi

# Warn only: check for SUPABASE_SERVICE_ROLE_KEY in git history
if [ -d "$PROJECT_DIR/.git" ]; then
  if git -C "$PROJECT_DIR" log --all -p 2>/dev/null | grep -q "SUPABASE_SERVICE_ROLE_KEY"; then
    warn "SUPABASE_SERVICE_ROLE_KEY detected in git history — consider using git-filter-repo"
  else
    pass "No SUPABASE_SERVICE_ROLE_KEY found in git history"
    CHECK5_SCORE=$((CHECK5_SCORE + 5))
  fi
fi
info "Check 5 score: $CHECK5_SCORE/15"

# ═══════════════════════════════════════════════════════════════
# CHECK 6 — Audit readiness (10 pts)
# ═══════════════════════════════════════════════════════════════
section "Check 6 — Audit readiness (10 pts)"

CLAUDE_AGENTS_DIR="$PROJECT_DIR/.claude/agents"
AGENT_AUDIT_COUNT=0
if [ -d "$CLAUDE_AGENTS_DIR" ]; then
  AGENT_AUDIT_COUNT=$(find "$CLAUDE_AGENTS_DIR" -name "AGENT-*.md" 2>/dev/null | wc -l | tr -d ' ')
fi

if [ "$AGENT_AUDIT_COUNT" -ge 1 ]; then
  pass "$AGENT_AUDIT_COUNT audit agent(s) in .claude/agents/"
  CHECK6_SCORE=$((CHECK6_SCORE + 4))
else
  fail "No audit agents found in .claude/agents/"
fi

# Check for AUDIT-INDEX.md in docs/audits/ or .claude/agents/
if [ -f "$PROJECT_DIR/docs/audits/AUDIT-INDEX.md" ] || [ -f "$PROJECT_DIR/.claude/agents/AUDIT-INDEX.md" ]; then
  pass "AUDIT-INDEX.md found"
  CHECK6_SCORE=$((CHECK6_SCORE + 3))
else
  warn "No AUDIT-INDEX.md found (create one to track audit history)"
fi

# .sqwr-last-audit: first use (no file) is fine, existing file means audited
LAST_AUDIT="$PROJECT_DIR/.sqwr-last-audit"
if [ -f "$LAST_AUDIT" ]; then
  LAST_AUDIT_DATE=$(cat "$LAST_AUDIT" 2>/dev/null | head -1)
  pass "Last audit recorded: $LAST_AUDIT_DATE"
  CHECK6_SCORE=$((CHECK6_SCORE + 3))
else
  info ".sqwr-last-audit not found — this is fine for first-time setup"
  pass "First-time setup (no audit yet required)"
  CHECK6_SCORE=$((CHECK6_SCORE + 3))
fi
info "Check 6 score: $CHECK6_SCORE/10"

# ═══════════════════════════════════════════════════════════════
# FINAL SCORE
# ═══════════════════════════════════════════════════════════════
SCORE=$((CHECK1_SCORE + CHECK2_SCORE + CHECK3_SCORE + CHECK4_SCORE + CHECK5_SCORE + CHECK6_SCORE))

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}SQWR Project Health Score${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ "$SCORE" -ge 90 ]; then
  STATUS="${GREEN}✅ READY${NC}"
elif [ "$SCORE" -ge 70 ]; then
  STATUS="${YELLOW}⚠️  ACCEPTABLE${NC}"
else
  STATUS="${RED}❌ NOT READY${NC}"
fi

echo -e "Score   : ${BLUE}$SCORE/100${NC}"
echo -e "Status  : $STATUS"
echo -e "Errors  : ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
echo ""
echo -e "  Check 1 — CLAUDE.md content        : $CHECK1_SCORE/20"
echo -e "  Check 2 — Contracts in place        : $CHECK2_SCORE/20"
echo -e "  Check 3 — Claude Code configuration : $CHECK3_SCORE/20"
echo -e "  Check 4 — Dev environment           : $CHECK4_SCORE/15"
echo -e "  Check 5 — Git hygiene               : $CHECK5_SCORE/15"
echo -e "  Check 6 — Audit readiness           : $CHECK6_SCORE/10"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ "$SCORE" -ge 70 ]; then
  exit 0
else
  exit 1
fi
