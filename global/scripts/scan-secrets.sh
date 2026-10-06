#!/usr/bin/env bash
# scan-secrets.sh: scan staged changes (or unpushed commits) for secrets.
#
# Use as a Claude Code PreToolUse hook on Bash commands that commit or push,
# or run it by hand before committing. SECURITY GUARD: it blocks on a finding.
#   - no finding : prints {"status": "continue"}, exit 0
#   - finding    : prints {"decision": "block", "reason": "..."}, exit 0
#                  (hook JSON protocol), and exits 2 instead when SCAN_SECRETS_STRICT_EXIT=1
#
# Only added lines are inspected, so removing a secret never blocks a commit.
#
# Environment:
#   SCAN_SECRETS_EXTRA_PATTERNS  file with extra ERE patterns, one per line ('#' comments ok)
#   SCAN_SECRETS_STRICT_EXIT     1 = exit 2 on finding (for plain git hooks / CI)
#
# Dependencies: git, grep -E, python3 (JSON escaping; falls back to sed)

set -uo pipefail

PATTERNS=(
  # Passwords in code
  "password[[:space:]]*[:=][[:space:]]*['\"][^'\"]{4,}['\"]"
  "passwd[[:space:]]*[:=][[:space:]]*['\"][^'\"]{4,}['\"]"
  # Generic API keys
  "api[_-]?key[[:space:]]*[:=][[:space:]]*['\"][^'\"]{10,}['\"]"
  # Cloud providers
  "AKIA[0-9A-Z]{16}"
  "aws[_-]?secret[_-]?access[_-]?key[[:space:]]*[:=][[:space:]]*['\"][^'\"]+['\"]"
  "AIza[0-9A-Za-z_-]{35}"
  # Payments
  "sk_live_[0-9a-zA-Z]{24,}"
  "rk_live_[0-9a-zA-Z]{24,}"
  "whsec_[0-9a-zA-Z]{24,}"
  # JWTs / service-role style tokens
  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9\.[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+"
  "service_role[[:space:]]*[:=][[:space:]]*['\"]eyJ[^'\"]+['\"]"
  # Source hosts
  "ghp_[0-9a-zA-Z]{36}"
  "gho_[0-9a-zA-Z]{36}"
  "github[_-]?token[[:space:]]*[:=][[:space:]]*['\"][^'\"]+['\"]"
  # AI providers
  "sk-ant-[a-zA-Z0-9_-]{20,}"
  "sk-[a-zA-Z0-9]{32,}"
  # Private keys
  "-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----"
  "-----BEGIN PGP PRIVATE KEY BLOCK-----"
  # Generic secrets
  "secret[_-]?key[[:space:]]*[:=][[:space:]]*['\"][^'\"]{8,}['\"]"
  "auth[_-]?token[[:space:]]*[:=][[:space:]]*['\"][^'\"]{8,}['\"]"
  "access[_-]?token[[:space:]]*[:=][[:space:]]*['\"][^'\"]{8,}['\"]"
  "bearer[[:space:]]+[a-zA-Z0-9_-]{20,}"
  # Connection strings with credentials
  "mongodb(\+srv)?://[^:'\"[:space:]]+:[^@'\"[:space:]]+@"
  "postgres(ql)?://[^:]+:[^@]+@"
  "mysql://[^:]+:[^@]+@"
  "redis://[^:]+:[^@]+@"
  # Chat / mail providers
  "xox[baprs]-[0-9a-zA-Z-]+"
  "SG\.[a-zA-Z0-9_-]{22}\.[a-zA-Z0-9_-]{43}"
)

if [[ -n "${SCAN_SECRETS_EXTRA_PATTERNS:-}" && -f "$SCAN_SECRETS_EXTRA_PATTERNS" ]]; then
  while IFS= read -r p; do
    [[ -z "$p" || "$p" == \#* ]] && continue
    PATTERNS+=("$p")
  done < "$SCAN_SECRETS_EXTRA_PATTERNS"
fi

# Pathspec excludes (lockfiles, minified, build output).
EXCLUDES=(':!*.lock' ':!package-lock.json' ':!yarn.lock' ':!pnpm-lock.yaml' ':!*.min.js' ':!*.min.css' ':!*.map' ':!node_modules' ':!dist' ':!build' ':!.next')

git rev-parse --git-dir >/dev/null 2>&1 || { echo '{"status": "continue"}'; exit 0; }

scan_type="staged changes"
content=$(git diff --cached --diff-filter=ACMR -- . "${EXCLUDES[@]}" 2>/dev/null || true)
if [[ -z "$content" ]]; then
  scan_type="unpushed commits"
  upstream=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || echo "")
  if [[ -n "$upstream" ]]; then
    content=$(git diff "$upstream"...HEAD -- . "${EXCLUDES[@]}" 2>/dev/null || true)
  fi
fi

if [[ -z "$content" ]]; then
  echo '{"status": "continue"}'
  exit 0
fi

added=$(printf '%s\n' "$content" | grep -E '^\+' | grep -vE '^\+\+\+' || true)

findings=""
for pattern in "${PATTERNS[@]}"; do
  matches=$(printf '%s\n' "$added" | grep -niE -- "$pattern" 2>/dev/null | head -3 || true)
  if [[ -n "$matches" ]]; then
    findings+="Pattern: $pattern"$'\n'
    while IFS= read -r line; do
      [[ ${#line} -gt 100 ]] && line="${line:0:100}..."
      findings+="    $line"$'\n'
    done <<< "$matches"
  fi
done

if [[ -z "$findings" ]]; then
  echo '{"status": "continue"}'
  exit 0
fi

message="SECRETS DETECTED in $scan_type. 1) Remove them, 2) use environment variables, 3) if already committed, rotate the credentials."$'\n'"$findings"
message=$(printf '%s\n' "$message" | head -30)

if command -v python3 >/dev/null 2>&1; then
  python3 -c 'import json,sys; print(json.dumps({"decision":"block","reason":sys.stdin.read()}))' <<< "$message"
else
  esc=$(printf '%s' "$message" | tr '\n' ' ' | sed 's/\\/\\\\/g; s/"/\\"/g')
  echo "{\"decision\": \"block\", \"reason\": \"$esc\"}"
fi
[[ "${SCAN_SECRETS_STRICT_EXIT:-0}" = "1" ]] && exit 2
exit 0
