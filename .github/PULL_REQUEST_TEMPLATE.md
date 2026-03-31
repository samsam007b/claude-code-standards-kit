## Summary

Brief description of changes.

## Type of Change

- [ ] New contract (CONTRACT-NAME.md)
- [ ] Contract update (standards change, threshold adjustment)
- [ ] New skill or command
- [ ] New hook script
- [ ] New agent
- [ ] Bug fix
- [ ] Documentation
- [ ] verify-kit.sh test

## Checklist

### Required
- [ ] `bash scripts/verify-kit.sh --verbose` → 0 errors, 0 warnings
- [ ] All new contracts have a Sources table with Tier 1/2 references
- [ ] All new contracts have `Last validated: YYYY-MM-DD`
- [ ] All new contracts have measurable thresholds (not vague "best practices")
- [ ] No private data (emails, phone numbers, client names, credentials)

### For New Contracts
- [ ] Follows CONTRACT-TEMPLATE.md structure
- [ ] Total points = 100
- [ ] At least one BLOCKING threshold defined

### For New Skills
- [ ] SKILL.md has complete frontmatter (name, description, effort, model, context)
- [ ] Has `argument-hint` if it takes arguments
- [ ] Has `disable-model-invocation: true` if it triggers side effects

### For New Hook Scripts
- [ ] Starts with `#!/usr/bin/env bash` and `set -euo pipefail`
- [ ] Graceful exit (exit 0) when context is missing
- [ ] Logs to `~/.sqwr-hook-log` with timestamp
- [ ] Added to `hooks/hooks.json`

## Testing

How was this tested?

## Related Issues

Closes #
