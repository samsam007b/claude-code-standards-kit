#!/bin/bash
# =============================================================================
# SECRET SCANNER HOOK FOR CLAUDE CODE
# =============================================================================
# Scans git staged changes and commits for sensitive information before
# allowing git commit or git push operations.
#
# Exit codes:
#   0 = No secrets found (allow operation)
#   2 = Secrets detected (block operation)
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# =============================================================================
# PATTERNS TO DETECT (regex)
# =============================================================================
# Each pattern is on a new line for easy maintenance
PATTERNS=(
    # Passwords in code
    "password\s*[:=]\s*['\"][^'\"]{4,}['\"]"
    "pwd\s*[:=]\s*['\"][^'\"]{4,}['\"]"
    "passwd\s*[:=]\s*['\"][^'\"]{4,}['\"]"

    # API Keys (generic)
    "api[_-]?key\s*[:=]\s*['\"][^'\"]{10,}['\"]"
    "apikey\s*[:=]\s*['\"][^'\"]{10,}['\"]"

    # AWS
    "AKIA[0-9A-Z]{16}"
    "aws[_-]?secret[_-]?access[_-]?key\s*[:=]\s*['\"][^'\"]+['\"]"

    # Stripe
    "sk_live_[0-9a-zA-Z]{24,}"
    "sk_test_[0-9a-zA-Z]{24,}"
    "rk_live_[0-9a-zA-Z]{24,}"
    "whsec_[0-9a-zA-Z]{24,}"

    # Supabase
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9\.[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+"
    "service_role\s*[:=]\s*['\"]eyJ[^'\"]+['\"]"

    # Google
    "AIza[0-9A-Za-z_-]{35}"

    # GitHub
    "ghp_[0-9a-zA-Z]{36}"
    "gho_[0-9a-zA-Z]{36}"
    "github[_-]?token\s*[:=]\s*['\"][^'\"]+['\"]"

    # Private Keys
    "-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----"
    "-----BEGIN PGP PRIVATE KEY BLOCK-----"

    # Generic secrets
    "secret[_-]?key\s*[:=]\s*['\"][^'\"]{8,}['\"]"
    "auth[_-]?token\s*[:=]\s*['\"][^'\"]{8,}['\"]"
    "access[_-]?token\s*[:=]\s*['\"][^'\"]{8,}['\"]"
    "bearer\s+[a-zA-Z0-9_-]{20,}"

    # Database connection strings
    "mongodb(\+srv)?://[^'\"\s]+"
    "postgres(ql)?://[^:]+:[^@]+@"
    "mysql://[^:]+:[^@]+@"
    "redis://[^:]+:[^@]+@"

    # Slack
    "xox[baprs]-[0-9a-zA-Z-]+"

    # Twilio
    "SK[0-9a-fA-F]{32}"

    # SendGrid
    "SG\.[a-zA-Z0-9_-]{22}\.[a-zA-Z0-9_-]{43}"

    # Mailgun
    "key-[0-9a-zA-Z]{32}"

    # Heroku
    "[hH]eroku[_-]?[aA][pP][iI][_-]?[kK][eE][yY]\s*[:=]\s*['\"][^'\"]+['\"]"

    # Discord
    "[MN][A-Za-z\d]{23,}\.[\w-]{6}\.[\w-]{27}"

    # Generic high-entropy strings that look like secrets
    # (commented out - too many false positives)
    # "['\"][0-9a-zA-Z]{32,}['\"]"
)

# =============================================================================
# FILES TO EXCLUDE FROM SCANNING
# =============================================================================
EXCLUDE_PATTERNS=(
    "*.lock"
    "package-lock.json"
    "yarn.lock"
    "pnpm-lock.yaml"
    "*.min.js"
    "*.min.css"
    "*.map"
    "node_modules/*"
    ".git/*"
    "dist/*"
    "build/*"
    ".next/*"
)

# =============================================================================
# MAIN SCANNING FUNCTION
# =============================================================================
scan_for_secrets() {
    local content="$1"
    local found_secrets=0
    local findings=""

    for pattern in "${PATTERNS[@]}"; do
        # Use grep with extended regex, case insensitive
        matches=$(echo "$content" | grep -niE "$pattern" 2>/dev/null || true)
        if [[ -n "$matches" ]]; then
            found_secrets=1
            findings+="  Pattern: $pattern\n"
            findings+="  Matches:\n"
            while IFS= read -r line; do
                # Truncate long lines
                if [[ ${#line} -gt 100 ]]; then
                    line="${line:0:100}..."
                fi
                findings+="    $line\n"
            done <<< "$matches"
            findings+="\n"
        fi
    done

    if [[ $found_secrets -eq 1 ]]; then
        echo -e "$findings"
        return 2
    fi

    return 0
}

# =============================================================================
# GET CONTENT TO SCAN
# =============================================================================
get_staged_diff() {
    # Get the diff of staged changes
    git diff --cached --diff-filter=ACMR 2>/dev/null || echo ""
}

get_unpushed_commits_diff() {
    # Get diff of commits not yet pushed
    local upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "origin/main")
    git diff "$upstream"...HEAD 2>/dev/null || git diff HEAD~5...HEAD 2>/dev/null || echo ""
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================
main() {
    # Determine what to scan based on context
    local content=""
    local scan_type=""

    # Check if we have staged changes (for commits)
    staged=$(get_staged_diff)
    if [[ -n "$staged" ]]; then
        content="$staged"
        scan_type="staged changes"
    else
        # Check unpushed commits (for push)
        unpushed=$(get_unpushed_commits_diff)
        if [[ -n "$unpushed" ]]; then
            content="$unpushed"
            scan_type="unpushed commits"
        fi
    fi

    if [[ -z "$content" ]]; then
        echo '{"status": "continue"}'
        exit 0
    fi

    # Run the scan
    findings=$(scan_for_secrets "$content") || true
    exit_code=$?

    if [[ -n "$findings" ]]; then
        # Secrets found - block the operation
        message="SECRETS DETECTED in $scan_type!\n\n"
        message+="The following sensitive patterns were found:\n\n"
        message+="$findings"
        message+="\nACTION REQUIRED:\n"
        message+="1. Remove the secrets from your code\n"
        message+="2. Use environment variables instead\n"
        message+="3. If already committed, rotate the exposed credentials\n"

        # Output JSON for Claude Code hook
        echo "{\"decision\": \"block\", \"reason\": \"$(echo -e "$message" | head -20 | tr '\n' ' ' | sed 's/"/\\"/g')\"}"
        exit 0
    fi

    # No secrets found
    echo '{"status": "continue"}'
    exit 0
}

# Run main function
main "$@"
