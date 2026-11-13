#!/bin/bash

# Simple Git Worktree Setup for Mac
# Usage: ./setup-worktree.sh <github-issue-url>
# Example: ./setup-worktree.sh https://github.com/owner/repo/issues/123

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <github-issue-url>"
    echo "Example: $0 https://github.com/owner/repo/issues/123"
    exit 1
fi

ISSUE_URL=$1

# Validate GitHub issue URL format
if [[ ! "$ISSUE_URL" =~ ^https://github\.com/[^/]+/[^/]+/issues/[0-9]+$ ]]; then
    echo "❌ Error: Invalid GitHub issue URL format"
    echo "Expected format: https://github.com/owner/repo/issues/123"
    exit 1
fi

# Extract issue number from URL
ISSUE_NUMBER=$(echo "$ISSUE_URL" | grep -o '[0-9]*$')

# Generate branch name using Claude CLI (if available)
echo "🤖 Generating branch name from issue..."

if command -v claude &> /dev/null; then
    CLAUDE_OUTPUT=$(claude -p "Get information about this GitHub issue using 'gh' CLI: $ISSUE_URL. Based on the issue title and description, generate a perfect git branch name. The branch name MUST follow this format: 'issue-XX-some-understanding-name' where XX is the issue number and 'some-understanding-name' is a descriptive name based on the issue content. Use lowercase letters and hyphens only, no slashes or special characters. It should be suitable as a folder name. Return ONLY the branch name, nothing else." --output-format json --dangerously-skip-permissions 2>/dev/null || echo "")
    BRANCH_NAME=$(echo "$CLAUDE_OUTPUT" | jq -r '.result' 2>/dev/null || echo "")
fi

# Check if branch name generation was successful
if [ -z "$BRANCH_NAME" ] || [ "$BRANCH_NAME" = "null" ]; then
    echo "⚠️  Using fallback branch name..."
    # Try to get issue title from gh CLI
    if command -v gh &> /dev/null; then
        ISSUE_TITLE=$(gh issue view "$ISSUE_NUMBER" --json title --jq '.title' 2>/dev/null || echo "")
        if [ -n "$ISSUE_TITLE" ]; then
            # Convert title to branch-friendly format
            BRANCH_NAME="issue-$ISSUE_NUMBER-$(echo "$ISSUE_TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | cut -c1-50)"
        else
            BRANCH_NAME="issue-$ISSUE_NUMBER"
        fi
    else
        BRANCH_NAME="issue-$ISSUE_NUMBER"
    fi
fi

echo "📌 Generated branch name: $BRANCH_NAME"

FEATURE_NAME=$BRANCH_NAME
PROJECT_NAME=$(basename "$(pwd)")
WORKTREE_PATH="$HOME/Developer/worktrees/${PROJECT_NAME}-worktrees/$FEATURE_NAME"

echo "🚀 Setting up worktree: $FEATURE_NAME"
echo "📁 Project: $PROJECT_NAME"

# Create worktree directory
mkdir -p "$HOME/Developer/worktrees/${PROJECT_NAME}-worktrees"

# Remove existing worktree if it exists
if [ -d "$WORKTREE_PATH" ]; then
    echo "⚠️  Removing existing worktree..."
    git worktree remove "$WORKTREE_PATH" 2>/dev/null || rm -rf "$WORKTREE_PATH"
fi

# Create the worktree
echo "📦 Creating worktree..."
git worktree add -b "$FEATURE_NAME" "$WORKTREE_PATH"

# Copy env files (including nested ones)
echo "📋 Copying environment files..."
find . -name ".env*" -type f | while read -r env_file; do
    relative_path="${env_file#./}"
    target_dir="$WORKTREE_PATH/$(dirname "$relative_path")"
    mkdir -p "$target_dir"
    cp "$env_file" "$target_dir/"
    echo "  📄 Copied: $relative_path"
done

# Setup worktree
cd "$WORKTREE_PATH"

# Install dependencies
if [ -f "package.json" ]; then
    echo "📥 Installing dependencies..."
    if [ -f "pnpm-lock.yaml" ]; then
        pnpm install
    elif [ -f "yarn.lock" ]; then
        yarn install
    else
        npm install
    fi
fi

# Run prisma generate for all nested prisma folders
find . -type d -name "prisma" -not -path "*/node_modules/*" | while read -r prisma_dir; do
    project_root=$(dirname "$prisma_dir")
    echo "🗄️  Running prisma generate in: $project_root"
    cd "$project_root" || continue

    if [ -f "package.json" ]; then
        if [ -f "pnpm-lock.yaml" ]; then
            pnpm prisma generate 2>/dev/null || true
        elif [ -f "yarn.lock" ]; then
            yarn prisma generate 2>/dev/null || true
        else
            npx prisma generate 2>/dev/null || true
        fi
    fi

    cd "$WORKTREE_PATH" || exit
done

echo ""
echo "✅ Worktree ready at: $WORKTREE_PATH"
echo ""
echo "📝 Next steps:"
echo "   cd $WORKTREE_PATH"
echo "   claude --dangerously-skip-permissions --permission-mode plan '/run-tasks $ISSUE_URL'"

# Try to open terminal with Claude (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Check for common terminal apps
    if [ -d "/Applications/Ghostty.app" ]; then
        echo ""
        echo "🖥️  Opening Ghostty with Claude..."
        osascript -e "
            tell application \"Ghostty\"
                activate
                delay 0.5
                tell application \"System Events\"
                    tell process \"Ghostty\"
                        keystroke \"t\" using {command down}
                        delay 0.2
                        keystroke \"cd '$WORKTREE_PATH' && echo '🎯 Feature: $FEATURE_NAME' && echo '📂 Branch: \$(git branch --show-current)' && echo '🔗 Issue: $ISSUE_URL' && echo '' && claude --dangerously-skip-permissions --permission-mode plan '/run-tasks $ISSUE_URL'\"
                        keystroke return
                    end tell
                end tell
            end tell
        " 2>/dev/null || true
    elif [ -d "/Applications/iTerm.app" ]; then
        echo ""
        echo "🖥️  Opening iTerm..."
        osascript -e "
            tell application \"iTerm\"
                activate
                tell current window
                    create tab with default profile
                    tell current session
                        write text \"cd '$WORKTREE_PATH' && echo '🎯 Feature: $FEATURE_NAME' && echo '📂 Branch: \$(git branch --show-current)' && echo '🔗 Issue: $ISSUE_URL'\"
                    end tell
                end tell
            end tell
        " 2>/dev/null || true
    fi
fi

echo ""
echo "🎉 Done! Worktree created for issue: $ISSUE_URL"
