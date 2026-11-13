#!/bin/bash

# Clean up Git worktrees with merged PRs or deleted branches
# Usage: Run from any git repository

set -e

echo "🧹 Cleaning up Git worktrees..."

# Fetch latest remote information
echo "📡 Fetching remote information..."
git fetch --all --prune

# Get all worktrees except main
worktrees=$(git worktree list --porcelain | grep -B1 "^branch " | grep "^worktree " | grep -v "$(pwd)$" | cut -d' ' -f2-)

if [ -z "$worktrees" ]; then
    echo "✅ No worktrees to clean up"
    exit 0
fi

# Process each worktree
removed_count=0
for worktree in $worktrees; do
    # Get branch name for this worktree
    branch=$(git worktree list --porcelain | grep -A1 "^worktree $worktree$" | grep "^branch " | sed 's/^branch refs\/heads\///')

    if [ -z "$branch" ]; then
        continue
    fi

    echo "🔍 Checking: $branch"

    # Check if branch exists on remote
    if ! git ls-remote --heads origin "$branch" | grep -q .; then
        echo "  → Branch deleted from remote, removing worktree"
        git worktree remove "$worktree" --force 2>/dev/null || rm -rf "$worktree"
        removed_count=$((removed_count + 1))
        continue
    fi

    # Check if PR is merged (requires gh CLI)
    if command -v gh &> /dev/null; then
        merged_pr=$(gh pr list --state merged --head "$branch" --json number --jq '.[0].number' 2>/dev/null || echo "")
        if [ -n "$merged_pr" ]; then
            echo "  → PR #$merged_pr merged, removing worktree"
            git worktree remove "$worktree" --force 2>/dev/null || rm -rf "$worktree"
            removed_count=$((removed_count + 1))
            continue
        fi
    fi

    echo "  → Keeping (branch still active)"
done

# Clean up any stale references
git worktree prune

echo ""
echo "✅ Done! Removed $removed_count worktree(s)"
echo ""
echo "📋 Remaining worktrees:"
git worktree list
