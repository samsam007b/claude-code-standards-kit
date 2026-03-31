#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# SQWR Project Kit — New project initialization
# ═══════════════════════════════════════════════════════════════
#
# Role: Automatic bootstrap of a new SQWR project.
#       Copies templates (CLAUDE.md, .env.example, .gitignore),
#       includes contracts based on the chosen stack, and optionally
#       initializes a git repository.
#
# Usage:
#   bash init-project.sh --name <name> --stack <stack> --path <path>
#
# Arguments:
#   --name   Project name (required — interactive prompt if missing)
#   --stack  Tech stack (default: nextjs-supabase)
#   --path   Destination path (default: ./project-name)
#
# Available stacks:
#   nextjs-supabase      → NextJS + Supabase + Vercel + TypeScript + Design + Security + Testing + Performance + Accessibility
#   nextjs               → NextJS + Vercel + TypeScript + Design + Security + Testing + Performance + Accessibility
#   nextjs-supabase-ai   → nextjs-supabase + AI-Prompting + Anti-Hallucination
#   python               → Python + Security + Testing
#   ios                  → iOS + Accessibility + Security + Testing
#   android              → Android + Accessibility + Security + Testing
#   fullstack            → All 29 contracts
#
# Examples:
#   bash init-project.sh --name "my-site" --stack "nextjs-supabase"
#   bash init-project.sh --name "python-api" --stack "python" --path "/Desktop/api"
#
# Common errors:
#   "Unknown argument"      → check flag spelling (--name, --stack, --path)
#   "Unrecognized stack"    → use one of the 7 documented stacks above
#   Permission denied       → run with `bash init-project.sh` (no chmod needed)
#
# Prerequisites: bash ≥3.2 (macOS default), git (optional for repo init)
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Portable in-place sed: macOS BSD sed requires an explicit (even empty) backup
# extension while GNU sed on Linux does not accept the '' argument form.
sed_inplace() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

# ─── Colors ─────────────────────────────────────────────────
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  SQWR Project Kit — Init${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# ─── Arguments ──────────────────────────────────────────────
PROJECT_NAME=""
PROJECT_STACK="nextjs-supabase"
PROJECT_PATH=""
USE_PLUGIN=false

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --name) PROJECT_NAME="$2"; shift ;;
    --stack) PROJECT_STACK="$2"; shift ;;
    --path) PROJECT_PATH="$2"; shift ;;
    --plugin) USE_PLUGIN=true ;;
    *) echo -e "${RED}Unknown argument: $1${NC}"; exit 1 ;;
  esac
  shift
done

# ─── Validation ─────────────────────────────────────────────
if [ -z "$PROJECT_NAME" ]; then
  echo -e "${YELLOW}Project name:${NC} "
  read -r PROJECT_NAME
fi

if [ -z "$PROJECT_PATH" ]; then
  PROJECT_PATH="$(pwd)/$PROJECT_NAME"
fi

echo ""
echo -e "Project   : ${GREEN}$PROJECT_NAME${NC}"
echo -e "Stack     : ${GREEN}$PROJECT_STACK${NC}"
echo -e "Path      : ${GREEN}$PROJECT_PATH${NC}"
echo ""

# ─── Create directory ────────────────────────────────────────
if [ ! -d "$PROJECT_PATH" ]; then
  mkdir -p "$PROJECT_PATH"
  echo -e "${GREEN}✓${NC} Directory created: $PROJECT_PATH"
fi

# ─── Copy base files ─────────────────────────────────────────

# .gitignore
if [ ! -f "$PROJECT_PATH/.gitignore" ]; then
  cp "$KIT_DIR/templates/.gitignore" "$PROJECT_PATH/.gitignore"
  echo -e "${GREEN}✓${NC} .gitignore copied"
fi

# .env.example
cp "$KIT_DIR/templates/.env.example" "$PROJECT_PATH/.env.example"
# Replace the name placeholder
sed_inplace "s/\[PROJECT NAME\]/$PROJECT_NAME/" "$PROJECT_PATH/.env.example"
echo -e "${GREEN}✓${NC} .env.example copied"

# CLAUDE.md
cp "$KIT_DIR/templates/CLAUDE.md" "$PROJECT_PATH/CLAUDE.md"
# Replace the name placeholder
sed_inplace "s/\[PROJECT NAME\]/$PROJECT_NAME/" "$PROJECT_PATH/CLAUDE.md"
# Resolve [KIT_PATH] to the actual kit directory
sed_inplace "s|\[KIT_PATH\]|$KIT_DIR|g" "$PROJECT_PATH/CLAUDE.md"
echo -e "${GREEN}✓${NC} CLAUDE.md copied (fill in the [TO FILL IN] sections!)"

# CHANGELOG.md
cp "$KIT_DIR/templates/CHANGELOG.md" "$PROJECT_PATH/CHANGELOG.md"
sed_inplace "s/YYYY-MM-DD/$(date +%Y-%m-%d)/" "$PROJECT_PATH/CHANGELOG.md"
echo -e "${GREEN}✓${NC} CHANGELOG.md created (date initialized: $(date +%Y-%m-%d))"

# CONTRIBUTING.md
cp "$KIT_DIR/templates/CONTRIBUTING.md" "$PROJECT_PATH/CONTRIBUTING.md"
sed_inplace "s/\[PROJECT NAME\]/$PROJECT_NAME/" "$PROJECT_PATH/CONTRIBUTING.md"
echo -e "${GREEN}✓${NC} CONTRIBUTING.md created"

# ─── Contracts by stack ──────────────────────────────────────
CONTRACTS_TO_INCLUDE=""

case $PROJECT_STACK in
  nextjs-supabase)
    CONTRACTS_TO_INCLUDE="CONTRACT-NEXTJS CONTRACT-SUPABASE CONTRACT-VERCEL CONTRACT-TYPESCRIPT CONTRACT-DESIGN CONTRACT-SECURITY CONTRACT-TESTING CONTRACT-PERFORMANCE CONTRACT-ACCESSIBILITY CONTRACT-OBSERVABILITY CONTRACT-RESILIENCE CONTRACT-SEO CONTRACT-CICD CONTRACT-API-DESIGN CONTRACT-DATABASE-MIGRATIONS CONTRACT-ERROR-HANDLING"
    ;;
  nextjs)
    CONTRACTS_TO_INCLUDE="CONTRACT-NEXTJS CONTRACT-VERCEL CONTRACT-TYPESCRIPT CONTRACT-DESIGN CONTRACT-SECURITY CONTRACT-TESTING CONTRACT-PERFORMANCE CONTRACT-ACCESSIBILITY CONTRACT-SEO CONTRACT-CICD CONTRACT-API-DESIGN CONTRACT-ERROR-HANDLING"
    ;;
  nextjs-supabase-ai)
    CONTRACTS_TO_INCLUDE="CONTRACT-NEXTJS CONTRACT-SUPABASE CONTRACT-VERCEL CONTRACT-TYPESCRIPT CONTRACT-DESIGN CONTRACT-SECURITY CONTRACT-TESTING CONTRACT-PERFORMANCE CONTRACT-ACCESSIBILITY CONTRACT-OBSERVABILITY CONTRACT-RESILIENCE CONTRACT-AI-PROMPTING CONTRACT-ANTI-HALLUCINATION CONTRACT-SEO CONTRACT-CICD CONTRACT-API-DESIGN CONTRACT-DATABASE-MIGRATIONS CONTRACT-ERROR-HANDLING"
    ;;
  python)
    CONTRACTS_TO_INCLUDE="CONTRACT-PYTHON CONTRACT-SECURITY CONTRACT-TESTING CONTRACT-API-DESIGN CONTRACT-ERROR-HANDLING"
    ;;
  ios)
    CONTRACTS_TO_INCLUDE="CONTRACT-IOS CONTRACT-ACCESSIBILITY CONTRACT-SECURITY CONTRACT-TESTING CONTRACT-ERROR-HANDLING"
    ;;
  android)
    CONTRACTS_TO_INCLUDE="CONTRACT-ANDROID CONTRACT-ACCESSIBILITY CONTRACT-SECURITY CONTRACT-TESTING CONTRACT-ERROR-HANDLING"
    ;;
  fullstack)
    CONTRACTS_TO_INCLUDE="CONTRACT-NEXTJS CONTRACT-SUPABASE CONTRACT-VERCEL CONTRACT-TYPESCRIPT CONTRACT-DESIGN CONTRACT-SECURITY CONTRACT-TESTING CONTRACT-PERFORMANCE CONTRACT-ACCESSIBILITY CONTRACT-OBSERVABILITY CONTRACT-RESILIENCE CONTRACT-SEO CONTRACT-CICD CONTRACT-AI-PROMPTING CONTRACT-ANTI-HALLUCINATION CONTRACT-EMAIL CONTRACT-PDF-GENERATION CONTRACT-I18N CONTRACT-ANALYTICS CONTRACT-PRICING CONTRACT-GREEN-SOFTWARE CONTRACT-MOTION-DESIGN CONTRACT-VIDEO-PRODUCTION CONTRACT-PYTHON CONTRACT-IOS CONTRACT-ANDROID CONTRACT-API-DESIGN CONTRACT-DATABASE-MIGRATIONS CONTRACT-ERROR-HANDLING"
    ;;
  *)
    echo -e "${YELLOW}ℹ${NC}  Stack '$PROJECT_STACK' not recognized. Contracts must be added manually."
    ;;
esac

# Create docs/contracts directory if contracts need to be included
if [ -n "$CONTRACTS_TO_INCLUDE" ]; then
  mkdir -p "$PROJECT_PATH/docs/contracts"
  for contract in $CONTRACTS_TO_INCLUDE; do
    if [ -f "$KIT_DIR/contracts/$contract.md" ]; then
      cp "$KIT_DIR/contracts/$contract.md" "$PROJECT_PATH/docs/contracts/"
      echo -e "${GREEN}✓${NC} $contract.md included"
    fi
  done
fi

# ─── Audits by stack ─────────────────────────────────────────
AUDITS_TO_INCLUDE=""

case $PROJECT_STACK in
  nextjs-supabase|nextjs|nextjs-supabase-ai|fullstack)
    AUDITS_TO_INCLUDE="AUDIT-INDEX AUDIT-SECURITY AUDIT-PERFORMANCE AUDIT-CODE-QUALITY AUDIT-ACCESSIBILITY AUDIT-DEPLOYMENT AUDIT-OBSERVABILITY AUDIT-DESIGN AUDIT-AI-GOVERNANCE AUDIT-RGPD AUDIT-BRAND-STRATEGY AUDIT-RESILIENCE AUDIT-RISK-SCORE"
    ;;
  python)
    AUDITS_TO_INCLUDE="AUDIT-INDEX AUDIT-SECURITY AUDIT-CODE-QUALITY AUDIT-DEPLOYMENT AUDIT-RESILIENCE"
    ;;
  ios|android)
    AUDITS_TO_INCLUDE="AUDIT-INDEX AUDIT-SECURITY AUDIT-ACCESSIBILITY AUDIT-CODE-QUALITY AUDIT-DEPLOYMENT"
    ;;
esac

if [ -n "$AUDITS_TO_INCLUDE" ]; then
  mkdir -p "$PROJECT_PATH/docs/audits"
  for audit in $AUDITS_TO_INCLUDE; do
    if [ -f "$KIT_DIR/audits/$audit.md" ]; then
      cp "$KIT_DIR/audits/$audit.md" "$PROJECT_PATH/docs/audits/"
      echo -e "${GREEN}✓${NC} $audit.md included"
    fi
  done
fi

# ─── Claude Code setup (.claude/) ────────────────────────────
mkdir -p "$PROJECT_PATH/.claude/agents"

if [ "$USE_PLUGIN" = true ]; then
  # ── Plugin mode: use hooks.json + copy skills and commands ──
  if [ -f "$KIT_DIR/hooks/hooks.json" ]; then
    cp "$KIT_DIR/hooks/hooks.json" "$PROJECT_PATH/.claude/hooks.json"
    # Replace ${CLAUDE_PLUGIN_ROOT} with the actual kit path
    sed_inplace "s|\${CLAUDE_PLUGIN_ROOT}|$KIT_DIR|g" "$PROJECT_PATH/.claude/hooks.json"
    echo -e "${GREEN}✓${NC} .claude/hooks.json created (plugin-style hooks with resolved KIT_PATH)"
  fi
  # Copy skills
  if [ -d "$KIT_DIR/skills" ]; then
    mkdir -p "$PROJECT_PATH/.claude/skills"
    cp -r "$KIT_DIR/skills/"* "$PROJECT_PATH/.claude/skills/" 2>/dev/null || true
    echo -e "${GREEN}✓${NC} skills/ copied to .claude/skills/"
  fi
  # Copy commands
  if [ -d "$KIT_DIR/commands" ]; then
    mkdir -p "$PROJECT_PATH/.claude/commands"
    cp "$KIT_DIR/commands/"*.md "$PROJECT_PATH/.claude/commands/" 2>/dev/null || true
    # Replace ${CLAUDE_PLUGIN_ROOT} in commands
    for cmd in "$PROJECT_PATH/.claude/commands/"*.md; do
      [ -f "$cmd" ] && sed_inplace "s|\${CLAUDE_PLUGIN_ROOT}|$KIT_DIR|g" "$cmd"
    done
    echo -e "${GREEN}✓${NC} commands/ copied to .claude/commands/ (slash commands available)"
  fi
else
  # ── Legacy mode: settings.json with absolute KIT_PATH ──
  if [ -f "$KIT_DIR/templates/settings.json" ]; then
    cp "$KIT_DIR/templates/settings.json" "$PROJECT_PATH/.claude/settings.json"
    sed_inplace "s|KIT_PATH|$KIT_DIR|g" "$PROJECT_PATH/.claude/settings.json"
    echo -e "${GREEN}✓${NC} .claude/settings.json created (hooks configured — review to activate)"
  fi
fi

# Copy audit agents to .claude/agents/
if [ -d "$KIT_DIR/agents" ]; then
  cp "$KIT_DIR/agents/"AGENT-*.md "$PROJECT_PATH/.claude/agents/" 2>/dev/null || true
  AGENT_COUNT=$(ls "$PROJECT_PATH/.claude/agents/"AGENT-*.md 2>/dev/null | wc -l | tr -d ' ')
  echo -e "${GREEN}✓${NC} $AGENT_COUNT audit agents copied to .claude/agents/"
fi

# ─── Empty .env.local ────────────────────────────────────────
if [ ! -f "$PROJECT_PATH/.env.local" ]; then
  echo "# Copied from .env.example — fill in the values" > "$PROJECT_PATH/.env.local"
  cat "$PROJECT_PATH/.env.example" >> "$PROJECT_PATH/.env.local"
  echo -e "${GREEN}✓${NC} .env.local created (fill in the values)"
fi

# ─── Git init ────────────────────────────────────────────────
if [ ! -d "$PROJECT_PATH/.git" ]; then
  echo ""
  echo -e "${YELLOW}Initialize git in this project? (y/N)${NC} "
  read -r INIT_GIT
  if [[ "$INIT_GIT" =~ ^[Yy]$ ]]; then
    git -C "$PROJECT_PATH" init
    git -C "$PROJECT_PATH" add .gitignore .env.example CLAUDE.md CHANGELOG.md CONTRIBUTING.md
    if [ -d "$PROJECT_PATH/docs" ]; then
      git -C "$PROJECT_PATH" add docs/
    fi
    if [ -d "$PROJECT_PATH/.claude" ]; then
      git -C "$PROJECT_PATH" add .claude/
    fi
    git -C "$PROJECT_PATH" commit -m "chore: init project $PROJECT_NAME from SQWR Project Kit"
    echo -e "${GREEN}✓${NC} Git initialized + initial commit"
  fi
fi

# ─── Summary ─────────────────────────────────────────────────
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Project successfully initialized!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Next steps:"
echo -e "  1. Fill in ${YELLOW}$PROJECT_PATH/CLAUDE.md${NC} ([TO FILL IN] sections)"
echo -e "  2. Fill in ${YELLOW}$PROJECT_PATH/.env.local${NC} with real values"
if [ "$USE_PLUGIN" = true ]; then
  echo -e "  3. Hooks active via ${YELLOW}.claude/hooks.json${NC} — slash commands ready in .claude/commands/"
else
  echo -e "  3. Review ${YELLOW}$PROJECT_PATH/.claude/settings.json${NC} and activate hooks (replace KIT_PATH if needed)"
fi
echo -e "  4. Update ${YELLOW}$PROJECT_PATH/CHANGELOG.md${NC} with each release"
echo -e "  5. Before shipping: ask Claude to run ${YELLOW}.claude/agents/AGENT-FULL-AUDIT.md${NC}"
echo -e "  6. Open with ${YELLOW}cursor $PROJECT_PATH${NC} or ${YELLOW}code $PROJECT_PATH${NC}"
echo ""
