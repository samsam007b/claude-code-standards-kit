#!/bin/bash
# SQWR Hook — No Secrets in Git
# Source: CONTRACT-SECURITY.md §2 — OWASP A02 (Cryptographic Failures), NIST SP 800-63B
# Trigger: PreToolUse on Bash (git commit, git add)
# Action: BLOCK if staged files contain secret patterns

set -euo pipefail

# Validate stdin is available
if [ -t 0 ]; then
  # Running interactively (no stdin) — skip hook
  exit 0
fi

# Check python3 availability
if ! command -v python3 >/dev/null 2>&1; then
  echo "SQWR HOOK WARN: python3 not found — hook-no-secrets.sh disabled" >&2
  exit 0
fi

INPUT=$(cat)

COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

# Only act on git commit or git add commands
if ! echo "$COMMAND" | grep -qE "^git (commit|add)"; then
  exit 0
fi

VIOLATIONS=()

# Check for .env files being staged
STAGED_ENV=$(git diff --cached --name-only 2>/dev/null | grep -E "^\.env(\.local)?$" || true)
if [ -n "$STAGED_ENV" ]; then
  VIOLATIONS+=("Sensitive env file staged: $STAGED_ENV — CONTRACT-SECURITY §5 (OWASP A05: Security Misconfiguration)")
fi

# Get staged file list for content scanning
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || true)

if [ -n "$STAGED_FILES" ]; then
  while IFS= read -r file; do
    # Skip binary and non-existent files
    [ -f "$file" ] || continue

    # Skip test/fixture files — they legitimately contain test credentials
    case "$file" in
      *.test.ts|*.test.tsx|*.test.js|*.spec.ts|*.spec.tsx|*.spec.js) continue ;;
      */__tests__/*|*/test/*|*/tests/*|*/fixtures/*|*/mocks/*) continue ;;
    esac

    file "$file" | grep -q "text" || continue

    CONTENT=$(git show ":$file" 2>/dev/null || true)
    [ -z "$CONTENT" ] && continue

    # SUPABASE_SERVICE_ROLE_KEY
    if echo "$CONTENT" | grep -qE "SUPABASE_SERVICE_ROLE_KEY[[:space:]]*=[[:space:]]*['\"].{10,}"; then
      VIOLATIONS+=("$file: SUPABASE_SERVICE_ROLE_KEY value detected — CONTRACT-SECURITY §2 (OWASP A02)")
    fi

    # OpenAI / generic sk- API keys
    if echo "$CONTENT" | grep -qE "sk-[a-zA-Z0-9]{40,}"; then
      VIOLATIONS+=("$file: API key pattern sk-*** detected — CONTRACT-SECURITY §2 (OWASP A02)")
    fi

    # Private key headers (PEM)
    if echo "$CONTENT" | grep -q "\-\-\-\-\-BEGIN"; then
      VIOLATIONS+=("$file: PEM private key block detected — CONTRACT-SECURITY §2 (NIST SP 800-63B)")
    fi

    # Stripe API keys (live and test)
    if echo "$CONTENT" | grep -qE "sk_live_[a-zA-Z0-9_]{20,}|sk_test_[a-zA-Z0-9_]{20,}|rk_live_[a-zA-Z0-9_]{20,}"; then
      VIOLATIONS+=("$file: Stripe API key pattern detected — CONTRACT-SECURITY §2 (OWASP A02)")
    fi

    # AWS Access Key ID
    if echo "$CONTENT" | grep -qE "AKIA[0-9A-Z]{16}"; then
      VIOLATIONS+=("$file: AWS Access Key ID detected — CONTRACT-SECURITY §2 (OWASP A02)")
    fi

    # GitHub Personal Access Token
    if echo "$CONTENT" | grep -qE "ghp_[a-zA-Z0-9]{36}|github_pat_[a-zA-Z0-9_]{80,}|ghs_[a-zA-Z0-9]{36}"; then
      VIOLATIONS+=("$file: GitHub Personal Access Token detected — CONTRACT-SECURITY §2 (OWASP A02)")
    fi

    # Anthropic API key
    if echo "$CONTENT" | grep -qE "sk-ant-[a-zA-Z0-9-]{40,}"; then
      VIOLATIONS+=("$file: Anthropic API key detected — CONTRACT-SECURITY §2 (OWASP A02)")
    fi

    # npm auth token
    if echo "$CONTENT" | grep -qE "npm_[a-zA-Z0-9]{36,}"; then
      VIOLATIONS+=("$file: npm auth token detected — CONTRACT-SECURITY §2 (OWASP A02)")
    fi

    # Hardcoded passwords
    if echo "$CONTENT" | grep -qiE "password[[:space:]]*=[[:space:]]*[\"'][^\"']{8,}[\"']"; then
      VIOLATIONS+=("$file: Hardcoded password pattern detected — CONTRACT-SECURITY §2 (OWASP A02)")
    fi

  done <<< "$STAGED_FILES"
fi

if [ ${#VIOLATIONS[@]} -gt 0 ]; then
  echo ""
  echo "SQWR HOOK BLOCKED — Secrets detected in staged files"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  for v in "${VIOLATIONS[@]}"; do
    echo "  • $v"
  done
  echo ""
  echo "Fix: remove secrets, use environment variables, and ensure .env files are in .gitignore."
  echo "Ref: CONTRACT-SECURITY.md §2 — OWASP A02 (Cryptographic Failures)"
  echo ""
  exit 2
fi

exit 0
