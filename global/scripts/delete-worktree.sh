#!/usr/bin/env bash
# delete-worktree.sh: remove git worktrees whose branch is gone from the remote
# or whose PR is merged. Run from any git repository.
#
# Usage: delete-worktree.sh [--force]
#   --force   also remove worktrees that have uncommitted changes
#             (default: such worktrees are kept and reported)
#
# Dependencies: git, gh (optional, to detect merged PRs)

set -euo pipefail

FORCE=0
[ "${1:-}" = "--force" ] && FORCE=1

echo "Cleaning up git worktrees..."
git fetch --all --prune

MAIN_WT=$(git rev-parse --show-toplevel)
removed=0

remove_wt() {
  local wt="$1"
  if [ "$FORCE" = 1 ]; then
    git worktree remove --force "$wt"
  else
    git worktree remove "$wt" 2>/dev/null || { echo "  -> has local changes, kept (use --force)"; return 1; }
  fi
}

wt=""
while IFS= read -r line; do
  case "$line" in
    "worktree "*) wt="${line#worktree }" ;;
    "branch refs/heads/"*)
      branch="${line#branch refs/heads/}"
      [ "$wt" = "$MAIN_WT" ] && continue
      echo "Checking: $branch"
      if ! git ls-remote --heads origin "$branch" | grep -q .; then
        # A branch that was never pushed also has no remote ref: only act if it once tracked one.
        if git config --get "branch.$branch.remote" >/dev/null 2>&1; then
          echo "  -> branch deleted from remote, removing worktree"
          remove_wt "$wt" && removed=$((removed + 1))
        else
          echo "  -> never pushed, keeping"
        fi
        continue
      fi
      if command -v gh >/dev/null 2>&1; then
        merged_pr=$(gh pr list --state merged --head "$branch" --json number --jq '.[0].number' 2>/dev/null || echo "")
        if [ -n "$merged_pr" ]; then
          echo "  -> PR #$merged_pr merged, removing worktree"
          remove_wt "$wt" && removed=$((removed + 1))
          continue
        fi
      fi
      echo "  -> keeping (branch still active)"
      ;;
  esac
done < <(git worktree list --porcelain)

git worktree prune
echo
echo "Done. Removed $removed worktree(s)."
echo "Remaining worktrees:"
git worktree list
