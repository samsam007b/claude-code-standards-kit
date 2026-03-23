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
#
# Examples:
#   bash init-project.sh --name "my-site" --stack "nextjs-supabase"
#   bash init-project.sh --name "python-api" --stack "python" --path "/Desktop/api"
#
# Common errors:
#   "Unknown argument"      → check flag spelling (--name, --stack, --path)
#   "Unrecognized stack"    → use one of the 4 documented stacks above
#   Permission denied       → run with `bash init-project.sh` (no chmod needed)
#
# Prerequisites: bash ≥3.2 (macOS default), git (optional for repo init)
# ═══════════════════════════════════════════════════════════════

set -e

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --name) PROJECT_NAME="$2"; shift ;;
    --stack) PROJECT_STACK="$2"; shift ;;
    --path) PROJECT_PATH="$2"; shift ;;
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
sed -i '' "s/\[PROJECT NAME\]/$PROJECT_NAME/" "$PROJECT_PATH/.env.example"
echo -e "${GREEN}✓${NC} .env.example copied"

# CLAUDE.md
cp "$KIT_DIR/templates/CLAUDE.md" "$PROJECT_PATH/CLAUDE.md"
# Replace the name placeholder
sed -i '' "s/\[PROJECT NAME\]/$PROJECT_NAME/" "$PROJECT_PATH/CLAUDE.md"
echo -e "${GREEN}✓${NC} CLAUDE.md copied (fill in the [TO FILL IN] sections!)"

# CHANGELOG.md
cp "$KIT_DIR/templates/CHANGELOG.md" "$PROJECT_PATH/CHANGELOG.md"
sed -i '' "s/YYYY-MM-DD/$(date +%Y-%m-%d)/" "$PROJECT_PATH/CHANGELOG.md"
echo -e "${GREEN}✓${NC} CHANGELOG.md created (date initialized: $(date +%Y-%m-%d))"

# CONTRIBUTING.md
cp "$KIT_DIR/templates/CONTRIBUTING.md" "$PROJECT_PATH/CONTRIBUTING.md"
sed -i '' "s/\[PROJECT NAME\]/$PROJECT_NAME/" "$PROJECT_PATH/CONTRIBUTING.md"
echo -e "${GREEN}✓${NC} CONTRIBUTING.md created"

# ─── Contracts by stack ──────────────────────────────────────
CONTRACTS_TO_INCLUDE=""

case $PROJECT_STACK in
  nextjs-supabase)
    CONTRACTS_TO_INCLUDE="CONTRACT-NEXTJS CONTRACT-SUPABASE CONTRACT-VERCEL CONTRACT-TYPESCRIPT CONTRACT-DESIGN CONTRACT-SECURITY CONTRACT-TESTING CONTRACT-PERFORMANCE CONTRACT-ACCESSIBILITY CONTRACT-OBSERVABILITY CONTRACT-RESILIENCE CONTRACT-SEO CONTRACT-CICD"
    ;;
  nextjs)
    CONTRACTS_TO_INCLUDE="CONTRACT-NEXTJS CONTRACT-VERCEL CONTRACT-TYPESCRIPT CONTRACT-DESIGN CONTRACT-SECURITY CONTRACT-TESTING CONTRACT-PERFORMANCE CONTRACT-ACCESSIBILITY CONTRACT-SEO CONTRACT-CICD"
    ;;
  nextjs-supabase-ai)
    CONTRACTS_TO_INCLUDE="CONTRACT-NEXTJS CONTRACT-SUPABASE CONTRACT-VERCEL CONTRACT-TYPESCRIPT CONTRACT-DESIGN CONTRACT-SECURITY CONTRACT-TESTING CONTRACT-PERFORMANCE CONTRACT-ACCESSIBILITY CONTRACT-OBSERVABILITY CONTRACT-RESILIENCE CONTRACT-AI-PROMPTING CONTRACT-ANTI-HALLUCINATION CONTRACT-SEO CONTRACT-CICD"
    ;;
  python)
    CONTRACTS_TO_INCLUDE="CONTRACT-PYTHON CONTRACT-SECURITY CONTRACT-TESTING"
    ;;
  ios)
    CONTRACTS_TO_INCLUDE="CONTRACT-IOS CONTRACT-ACCESSIBILITY CONTRACT-SECURITY CONTRACT-TESTING"
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
echo -e "  3. Update ${YELLOW}$PROJECT_PATH/CHANGELOG.md${NC} with each release"
echo -e "  4. Open with ${YELLOW}cursor $PROJECT_PATH${NC} or ${YELLOW}code $PROJECT_PATH${NC}"
echo ""
