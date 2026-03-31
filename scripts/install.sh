#!/usr/bin/env bash
set -euo pipefail
# SQWR Standards Kit — One-command installer
# Usage: curl -sL https://raw.githubusercontent.com/samsam007b/claude-code-standards-kit/main/scripts/install.sh | bash
# Or:    bash scripts/install.sh [--dest /path/to/dir]

REPO_URL="https://github.com/samsam007b/claude-code-standards-kit.git"
DEFAULT_DEST="$HOME/sqwr-standards-kit"
DEST="${SQWR_INSTALL_DIR:-$DEFAULT_DEST}"

# Parse --dest argument
while [[ $# -gt 0 ]]; do
  case $1 in
    --dest) DEST="$2"; shift 2 ;;
    *) shift ;;
  esac
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  SQWR Standards Kit — Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check git
if ! command -v git &>/dev/null; then
  echo "  ERROR: git is required. Install git first."
  exit 1
fi

# Clone or update
if [ -d "$DEST/.git" ]; then
  echo "  Updating existing installation at $DEST ..."
  git -C "$DEST" pull --ff-only
else
  echo "  Installing to $DEST ..."
  git clone --depth 1 "$REPO_URL" "$DEST"
fi

echo ""
echo "  Kit installed at: $DEST"
echo ""

# Verify integrity
if [ -f "$DEST/scripts/verify-kit.sh" ]; then
  echo "  Running verify-kit.sh ..."
  echo ""
  bash "$DEST/scripts/verify-kit.sh" 2>&1 | tail -5
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Next steps:"
echo ""
echo "  1. Bootstrap a project (plugin mode — recommended):"
echo "     bash $DEST/scripts/init-project.sh \\"
echo "       --name my-project \\"
echo "       --stack nextjs-supabase \\"
echo "       --path ~/my-project \\"
echo "       --plugin"
echo ""
echo "  2. Or install as Claude Code plugin directly:"
echo "     /plugin install samsam007b/claude-code-standards-kit"
echo ""
echo "  Available stacks: nextjs-supabase · nextjs · nextjs-supabase-ai"
echo "                    python · ios · android · fullstack"
echo ""
echo "  Docs: $DEST/DISCOVERY-GUIDE.md"
echo ""
