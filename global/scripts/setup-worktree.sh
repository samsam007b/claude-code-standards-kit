#!/usr/bin/env bash
# setup-worktree.sh: create an isolated git worktree for a GitHub issue.
#
# Usage (from the repo root): setup-worktree.sh <github-issue-url>
# Example: setup-worktree.sh https://github.com/owner/repo/issues/123
#
# What it does: derives a branch name (issue-<n>-<slug>), creates a worktree,
# copies .env* files, installs JS dependencies, runs `prisma generate` if present.
#
# Environment:
#   WORKTREE_ROOT        base directory (default: $HOME/Developer/worktrees)
#   WORKTREE_USE_CLAUDE  1 = ask `claude -p` for a nicer branch name (default: 0, uses gh title)
#   WORKTREE_NO_INSTALL  1 = skip dependency install
#
# Dependencies: git, gh (optional, for the title), jq + claude (only if WORKTREE_USE_CLAUDE=1)

set -euo pipefail

if [ $# -eq 0 ]; then
  echo "Usage: $0 <github-issue-url>" >&2
  echo "Example: $0 https://github.com/owner/repo/issues/123" >&2
  exit 1
fi

ISSUE_URL=$1
if [[ ! "$ISSUE_URL" =~ ^https://github\.com/[^/]+/[^/]+/issues/[0-9]+$ ]]; then
  echo "Error: invalid GitHub issue URL. Expected https://github.com/owner/repo/issues/123" >&2
  exit 1
fi

ISSUE_NUMBER="${ISSUE_URL##*/}"
BRANCH_NAME=""

if [ "${WORKTREE_USE_CLAUDE:-0}" = "1" ] && command -v claude >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  echo "Generating branch name with claude..."
  OUT=$(claude -p "Using the gh CLI, read this GitHub issue: $ISSUE_URL. Return ONLY a git branch name of the form issue-$ISSUE_NUMBER-short-descriptive-slug (lowercase letters, digits and hyphens only)." --output-format json 2>/dev/null || echo "")
  BRANCH_NAME=$(echo "$OUT" | jq -r '.result // empty' 2>/dev/null || echo "")
  # Reject anything that is not a safe branch name.
  [[ "$BRANCH_NAME" =~ ^issue-[0-9]+-[a-z0-9-]+$ ]] || BRANCH_NAME=""
fi

if [ -z "$BRANCH_NAME" ]; then
  TITLE=""
  if command -v gh >/dev/null 2>&1; then
    TITLE=$(gh issue view "$ISSUE_URL" --json title --jq '.title' 2>/dev/null || echo "")
  fi
  if [ -n "$TITLE" ]; then
    SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g; s/--*/-/g; s/^-//; s/-$//' | cut -c1-50)
    BRANCH_NAME="issue-$ISSUE_NUMBER-$SLUG"
  else
    BRANCH_NAME="issue-$ISSUE_NUMBER"
  fi
fi

echo "Branch: $BRANCH_NAME"

PROJECT_NAME=$(basename "$(pwd)")
ROOT="${WORKTREE_ROOT:-$HOME/Developer/worktrees}/${PROJECT_NAME}-worktrees"
WORKTREE_PATH="$ROOT/$BRANCH_NAME"
REPO_DIR=$(pwd)

mkdir -p "$ROOT"

if [ -d "$WORKTREE_PATH" ]; then
  echo "Removing existing worktree at $WORKTREE_PATH"
  git worktree remove "$WORKTREE_PATH" 2>/dev/null || {
    echo "Worktree has local changes, remove it manually: git worktree remove --force '$WORKTREE_PATH'" >&2
    exit 1
  }
fi

git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH"

echo "Copying environment files..."
while IFS= read -r env_file; do
  relative_path="${env_file#./}"
  target_dir="$WORKTREE_PATH/$(dirname "$relative_path")"
  mkdir -p "$target_dir"
  cp -p "$env_file" "$target_dir/"
  echo "  copied: $relative_path"
done < <(find . -name ".env*" -type f -not -path "*/node_modules/*" -not -path "./.git/*")

cd "$WORKTREE_PATH"

if [ "${WORKTREE_NO_INSTALL:-0}" != "1" ] && [ -f package.json ]; then
  echo "Installing dependencies..."
  if [ -f pnpm-lock.yaml ]; then pnpm install
  elif [ -f yarn.lock ]; then yarn install
  elif [ -f bun.lockb ] || [ -f bun.lock ]; then bun install
  else npm install; fi
fi

while IFS= read -r prisma_dir; do
  project_root=$(dirname "$prisma_dir")
  echo "prisma generate in: $project_root"
  (
    cd "$WORKTREE_PATH/$project_root" || exit 0
    [ -f package.json ] || exit 0
    if [ -f pnpm-lock.yaml ]; then pnpm prisma generate
    elif [ -f yarn.lock ]; then yarn prisma generate
    else npx prisma generate; fi
  ) 2>/dev/null || true
done < <(find . -type d -name prisma -not -path "*/node_modules/*")

echo
echo "Worktree ready at: $WORKTREE_PATH (from $REPO_DIR)"
echo "Next: cd '$WORKTREE_PATH' && claude"
