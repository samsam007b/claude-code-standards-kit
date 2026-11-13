# Windows

## Tier 1 (Starter): native, nothing special

`setup.ps1` uses winget to install Git, Node.js, Python and Claude Code. `/welcome`, `/explain` and the glossary work as on macOS. The two beginner safeguards are written in Node, so they run natively.

Requirements: Windows 10 (1809+) or 11, and winget (ships with "App Installer" from the Microsoft Store).

```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1          # add -Lang fr for French
```

If a tool is "not found" right after installing, close and reopen the terminal: the PATH refreshes only for new windows.

## Advanced tier: WSL2 only

The advanced kit (18 global hooks, `install.sh`, `verify-kit.sh`) is written in bash. It is not ported to PowerShell. On Windows, run it inside WSL2, a real Linux system inside Windows.

1. In an administrator PowerShell: `wsl --install`, then restart.
2. Open the Ubuntu app, install the requirements: `sudo apt update && sudo apt install -y git jq nodejs npm python3`.
3. Clone the kit inside Linux (not under `/mnt/c`): `git clone https://github.com/samsam007b/claude-code-standards-kit ~/claude-starter`.
4. Follow the macOS instructions from there.

Claude Code inside WSL2 has its own `~/.claude`, separate from the Windows one. Install Claude Code in the side you work in.

## Known limits

- No Windows-native version of the advanced hooks.
- `setup.ps1` was written without access to a Windows machine at first release: report anything odd as an issue.
- Corporate machines may block winget or script execution: ask your IT team, or use WSL2.

Ask Claude: `/explain WSL2`.
