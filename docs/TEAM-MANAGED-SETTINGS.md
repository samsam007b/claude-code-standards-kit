# Organization-level managed settings

For a solo setup, `global/settings.example.json` is enough: it lives in `~/.claude/settings.json`
and anyone with access to the machine can edit it. A team that wants a policy no individual
contributor can quietly loosen needs the managed settings file instead. It is read by Claude Code
before the user's own `settings.json` and is not merged away by it.

See `docs/managed-settings.example.json` for a starting point (native `permissions.deny` and
`sandbox` rules, no hooks required for the base policy).

## File path by OS

Source: the official Claude Code documentation (`/settings` and `/managed-settings` on
https://code.claude.com/docs/en).

| OS | Path |
|---|---|
| macOS | `/Library/Application Support/ClaudeCode/managed-settings.json` |
| Linux / WSL | `/etc/claude-code/managed-settings.json` |
| Windows | `C:\Program Files\ClaudeCode\managed-settings.json` |

Note: the legacy Windows path `C:\ProgramData\ClaudeCode\managed-settings.json` is not read.

macOS can also distribute the same policy through MDM under the `com.anthropic.claudecode`
managed preferences domain, and Windows through the registry (`HKLM\SOFTWARE\Policies\ClaudeCode`,
value `Settings`, type `REG_SZ` or `REG_EXPAND_SZ`) instead of a file on disk.

## What belongs here vs. in `global/settings.example.json`

- Managed settings: the floor every machine must respect (destructive-command deny rules,
  sandbox network/credentials restrictions). Write-protect the file with normal OS permissions
  so only an admin can change it.
- `global/settings.example.json` (installed per user): everything else, including anything a
  given person legitimately needs to tune for their own workflow.

Both files use the same `permissions.deny` / `sandbox` schema. Deploy the managed file once per
machine (or via MDM/registry for a fleet), then let each person install the global layer on top.
