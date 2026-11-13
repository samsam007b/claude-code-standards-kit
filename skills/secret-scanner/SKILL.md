---
name: secret-scanner
description: Scan staged files to detect credentials, API keys, tokens and secrets before any git commit.
tags: [security, git, secrets, credentials]
model: sonnet
---

# Secret Scanner - Protection against credential leaks

## Description

This skill provides automatic protection against leaking secrets (passwords, API keys, tokens) in Git commits. It automatically analyzes every `git commit` and `git push` before execution.

## How it works

The `PreToolUse` hook intercepts Bash commands containing:
- `git commit`
- `git push`
- `git commit --amend`

It then runs the `scan-secrets.sh` script, which:
1. Retrieves the staged changes (`git diff --cached`)
2. Analyzes the content with 30+ regex patterns
3. Blocks the operation if secrets are detected

## Detected patterns

### Passwords
- `password = "..."`
- `pwd = "..."`
- `passwd = "..."`

### API Keys
- AWS: `AKIA...` (16 chars)
- Stripe: `sk_live_...`, `sk_test_...`, `whsec_...`
- Google: `AIza...` (35 chars)
- GitHub: `ghp_...`, `gho_...`
- Supabase JWT tokens
- SendGrid: `SG....`
- Slack: `xox[baprs]-...`

### Generic tokens
- `api_key = "..."`
- `secret_key = "..."`
- `auth_token = "..."`
- `access_token = "..."`
- `bearer ...`

### Private keys
- `-----BEGIN PRIVATE KEY-----`
- `-----BEGIN RSA PRIVATE KEY-----`
- `-----BEGIN PGP PRIVATE KEY BLOCK-----`

### Connection strings
- MongoDB: `mongodb://user:pass@...`
- PostgreSQL: `postgres://user:pass@...`
- MySQL: `mysql://user:pass@...`
- Redis: `redis://user:pass@...`

## Files

- **Hook script**: `.claude/hooks/scan-secrets.sh`
- **Configuration**: `.claude/settings.json` (PreToolUse hook)

## Customization

To add new patterns, edit the `PATTERNS` array in `scan-secrets.sh`:

```bash
PATTERNS=(
    # Add your pattern here
    "my_custom_pattern"
    ...
)
```

## Limitations

- Does NOT remove secrets from Git history
- Does not scan binary files
- May produce false positives on some generic patterns

## What to do if a secret is detected?

1. **Do not commit**: the hook blocks automatically
2. **Remove the secret from the code**: use environment variables
3. **If already committed**: rotate the exposed secret immediately
4. **Optional**: clean the history with `git filter-branch` or BFG

## Examples of good practice

```javascript
// ❌ BAD - Hardcoded secret
const apiKey = "sk_live_abc123xyz";

// ✅ GOOD - Environment variable
const apiKey = process.env.STRIPE_SECRET_KEY;
```

```python
# ❌ BAD
password = "SuperSecret123"

# ✅ GOOD
import os
password = os.environ.get("DB_PASSWORD")
```
