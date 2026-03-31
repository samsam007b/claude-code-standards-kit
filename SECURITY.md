# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 3.x     | ✅ Fully supported |
| 2.x     | ⚠️ Security fixes only (until 2026-12-31) |
| 1.x     | ❌ End of life |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

To report a security vulnerability in the SQWR Project-Kit:

1. **Email**: Use the GitHub Security Advisories feature at the repository page
2. **Response time**: We aim to acknowledge reports within 48 hours
3. **Disclosure**: We follow responsible disclosure — we will work with you to understand and fix the issue before public disclosure

Please include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Any suggested remediation (optional)

We will never take legal action against researchers who responsibly disclose vulnerabilities.

## Security Features

### Hook Security

All SQWR hooks use `${CLAUDE_PLUGIN_ROOT}` for portable paths — no hardcoded absolute paths that could be manipulated.

Key security hooks:
- **hook-no-secrets.sh** — Blocks `git commit` and `git add` when potential secrets are detected (API keys, tokens, passwords). Exit code 2 = hard block.
- **hook-no-dangerous-html.sh** — Warns when dangerous HTML patterns (onclick with eval, script src with data:) are written to files.
- **hook-permission-guard.sh** — Blocks destructive PermissionRequest events (rm -rf, sudo rm, chmod 777).

### Automated Security Auditing

This kit includes `agents/AGENT-SECURITY-AUDIT.md` — an automated security audit agent that:
- Checks 14+ security criteria across 4 verification levels
- Enforces a minimum score of 70/100 (below = deployment blocked)
- References OWASP Top 10, NIST SSDF, and CWE/SANS Top 25

### Contract-Based Security

`contracts/CONTRACT-SECURITY.md` defines security standards based on:
- OWASP Top 10 (2021)
- NIST Secure Software Development Framework (SSDF)
- OWASP Top 10 for Agentic AI (2025)
- NIST AI 600-1

### No Private Data

This kit contains no personal data, private keys, credentials, or client-specific information. It is designed to be cloned and used by any developer.

## Security Audit Badge

Run the security audit on this kit itself:

```bash
# Ask Claude to run the security audit
# In Claude Code: "Run agents/AGENT-SECURITY-AUDIT.md"
```

## Known Limitations

- Hook scripts require `bash` — not compatible with `sh`-only environments
- `hook-no-secrets.sh` uses regex patterns — it may miss obfuscated secrets
- Hooks are advisory for most events; only `hook-no-secrets.sh` and `hook-permission-guard.sh` are hard-blocking (exit 2)
