# Global hooks

Generic, anonymised Claude Code hooks. Each script's header documents what it blocks, its event
and matcher, its exit-code semantics, its bypass and whether it fails open or closed.

## Install

```bash
mkdir -p ~/.claude/hooks
cp -R global/hooks/. ~/.claude/hooks/          # scripts, lib/, tests/, allowlist, sha256 sidecar
rm ~/.claude/hooks/README.md ~/.claude/hooks/settings-hooks.json   # optional, docs only
```

Then merge the `hooks` block of `settings-hooks.json` into `~/.claude/settings.json` (merge
the arrays per event, do not overwrite hooks you already have). Paths use `$HOME/.claude/hooks/...`.
Drop any entry you do not want: every hook is independent.

Requirements: `bash`, `python3`, `node` (validate-command only), `jq` and `rtk` (rtk-rewrite only,
it is a silent no-op without them).

## Hook protocol in 5 lines

- The payload is JSON on stdin. Exit `0` allows, exit `2` blocks (stderr is shown to the model).
- Any other non-zero exit is a non-blocking error: the action proceeds.
- A PreToolUse hook that times out or crashes is non-blocking too, so a guard that needs a long
  human step must keep its own wait below the `timeout` of its settings entry (340 s vs 300 s here).
- Always JSON-parse `tool_name`. A literal grep on `"tool_name":"Bash"` silently disables the hook
  as soon as the payload spaces its colons differently.
- Never rely on a `/tmp` flag an agent can create itself for a security decision. Use a hook on
  `UserPromptSubmit` (human-typed text) or a native OS dialog.

## Hooks

| Hook | Event | Matcher | Mode | Bypass |
|---|---|---|---|---|
| `validate-command.js` | PreToolUse | `Bash` | Blocking: destructive shell commands (hard reset, recursive force delete, force push, pipe-to-shell, disk and permission abuse). Opt-in DB-drop rules | Edit the pattern list. `CLAUDE_DB_PROTECT=1` / `CLAUDE_DB_PROTECT_DIRS` enable DB rules, `CLAUDE_SECURITY_LOG=off` mutes the log |
| `external-send-guard.sh` | PreToolUse | `mcp__.*\|Bash` | Blocking, fails closed: any outbound email, chat or social send without a fresh human confirmation | `CLAUDE_SEND_GUARD=off` |
| `user-prompt-submit.sh` | UserPromptSubmit | none | Advisory: arms the send-guard flag when you type a confirmation phrase. Optional prompt log | `CLAUDE_SEND_CONFIRM_REGEX` (phrases), `CLAUDE_PROMPT_LOG=1` (log, off by default) |
| `rtk-rewrite.sh` (+ `.rtk-hook.sha256`) | PreToolUse | `Bash` | Rewrites commands to their `rtk` equivalent, never blocks | Remove the settings entry or `rtk` from PATH |
| `api-key-isolation-guard.sh` | PreToolUse | `Edit\|Write` | Blocking, no-op until `CLAUDE_KEY_ISOLATION_DIRS` is set: keeps a credential pattern out of chosen project dirs | `CLAUDE_KEY_ISOLATION_OVERRIDE=1` |
| `check-compiled-files.sh` | PreToolUse | `Edit\|Write` | Blocking: hand edits of generated files (header marker or path regex) | `CLAUDE_ALLOW_COMPILED_EDIT=1` |
| `check-force-push.sh` | PreToolUse | `Bash` | Blocking: plain forced push (lease form allowed) | `CLAUDE_ALLOW_FORCE_PUSH=1` |
| `no-haiku-for-code.sh` | PreToolUse | `Task\|Agent` | Blocking: small model requested for a subagent outside a read-only whitelist | `CLAUDE_ALLOW_SMALL_MODEL=1`, `CLAUDE_SMALL_MODEL_PATTERN`, `CLAUDE_SMALL_MODEL_ALLOW` |
| `memory-novelty-gate.py` | PreToolUse | `mcp__memory__add_observations` | Advisory: warns on a near-duplicate memory observation | `CLAUDE_NOVELTY_THRESHOLD`, `MEMORY_FILE_PATH` |
| `plugin-script-exec-guard.sh` | PreToolUse | `Bash` | Blocking, human dialog: executing scripts from plugin or marketplace directories. Empty example allowlist | Native confirm dialog, or `plugin-script-exec-allowlist.txt` |
| `marketplace-add-guard.sh` | PreToolUse | `Bash` | Blocking, human dialog: `plugin marketplace add`, `plugin install` | Native confirm dialog |
| `mcp-tool-trust-gate.sh` | PreToolUse | `mcp__.*` | Blocking, human dialog: calls to MCP servers not marked trusted in `TRUST-REGISTRY.md` | Native confirm dialog, or mark the server trusted in the registry |
| `guard-file-tamper-guard.sh` | PreToolUse | `Bash\|Edit\|Write` | Blocking, human dialog: edits to the guards themselves, `settings.json`, the registry. A speed bump, not a sandbox | Native confirm dialog, `CLAUDE_TAMPER_EXTRA_PATHS` extends the list |
| `detect-frustration-pattern.sh` | UserPromptSubmit | none | Advisory: suggests capturing a lesson after a frustrated or scrap-and-redo prompt | `CLAUDE_FRUSTRATION_HOOK=off`, `_THRESHOLD`, `_EXTRA_REGEX`, `_LOG` |
| `pre-compact-save.sh` | PreCompact | none | Advisory: snapshots cwd, active plan and in-progress todos | `CLAUDE_PRECOMPACT=off` |
| `local-search-before-uncertainty.py` | Stop | none | Blocking: reply states uncertainty without a targeted local search first | `CLAUDE_UNCERTAINTY_GUARD=off`, `CLAUDE_UNCERTAINTY_LANG=en,fr` |
| `memory-context-load.sh` | SessionStart | none | Advisory: injects an index (names only) of the MCP memory graph | `CLAUDE_MEMORY_INDEX=off` |
| `cleanup-orphan-processes.sh` | SessionEnd | none | Best effort: kills leftover `tsc --noEmit` and one-shot jest runs | `CLAUDE_ORPHAN_CLEANUP=off`, `CLAUDE_ORPHAN_PATTERNS` adds patterns |
| `session-end-capture.sh` | SessionEnd | none | Advisory: appends a lessons checklist to a per-day log | `CLAUDE_SESSION_CAPTURE=off`, `CLAUDE_SESSION_NOTIFY=1` |

Shared code lives in `lib/`: `human-confirm-dialog.sh`, `hook-input.sh`, `plugin-allowlist-check.py`,
`trust-registry-check.py`, `external-send-classify.py`, `send-guard-flag.sh`.

## How the send-guard confirmation works

1. The agent tries to send. `external-send-guard.sh` blocks and explains.
2. The agent shows you the content and asks for confirmation.
3. You type a short phrase (`confirm send`, `go send`, `send now`...).
4. `user-prompt-submit.sh` sees that human-typed message and touches a mode-600 flag file.
5. The retry consumes the flag (single use, 120 s TTL) and exactly one send goes through.

The flag can only be created from text you typed, never from a tool call. Recognised sends are
provider-agnostic (tool slugs and names such as `*_SEND_EMAIL`, `*_POST_MESSAGE`, `mcp__*__send_*`,
plus Bash vectors: mail CLIs, chat and social webhooks). Tune with `CLAUDE_SEND_GUARD_REGEX`,
`_EXTRA_REGEX` and `_ALLOW_REGEX`.

## Human-confirm dialog (marketplace-vetting guards)

The four vetting guards replace an agent-forgeable flag with a native dialog the agent cannot click.
macOS uses `osascript`, Linux uses `zenity` or `kdialog`. With no dialog tool available the hook
fails closed with a clear message. `CLAUDE_HOOK_TEST_MODE=1` makes the dialog refuse immediately
(tests only, it can never confirm).

## Tests

```bash
bash global/hooks/tests/smoke-test-hooks.sh            # 43 checks, sandboxed, runs the suite below too
bash global/hooks/tests/test-marketplace-vetting.sh    # 24 checks for the four vetting guards
```

Tests run against temp dirs and env overrides, they never touch your real `~/.claude`.
If you edit `rtk-rewrite.sh`, refresh the sidecar: `shasum -a 256 rtk-rewrite.sh > .rtk-hook.sha256`.

## Layered defense: native deny > sandbox > hooks

Three layers, in the order Claude Code actually evaluates them (source: the official docs at
https://code.claude.com/docs/en/settings and https://code.claude.com/docs/en/sandboxing):

1. **`permissions.deny` in `settings.json`** (native, non-bypassable). Evaluated before any hook
   runs, before `ask` and before `allow`. This is where an obviously destructive command or an
   obviously sensitive read belongs: `Bash(git push --force*)`, `Bash(git reset --hard*)`,
   `Read(./.env)`, `Read(**/secrets/**)`. See `global/settings.example.json`. A `Read` deny rule
   also blocks `Edit`/`Write` on the same path. No regex to maintain, nothing for a hook to parse.
2. **Sandbox** (`sandbox.*` in `settings.json`, opt-in). Confines what a Bash command can actually
   reach: filesystem (`allowRead`/`denyRead`/`allowWrite`), network (`allowedDomains`), and
   credential files/env vars it should never see even if a command tries. It covers cases `deny`
   cannot express cleanly, such as "no network except these domains" or "no write outside this
   directory", regardless of how the command is phrased. See the `sandbox` block in
   `global/settings.example.json`.
3. **Hooks** (this directory). Everything `deny` and the sandbox cannot express: pattern families
   that need judgement (`validate-command.js`'s destructive-shell patterns, the DB-protect rules),
   a human-in-the-loop confirmation (`external-send-guard.sh`, the marketplace-vetting dialogs),
   or a pedagogical message pointing the model at the safe alternative (e.g. `CLAUDE_DB_SAFE_TOOL`
   instead of a raw `DROP TABLE`). Hooks are the right layer when the rule needs context or a
   message, the wrong layer when a flat deny rule would already do the job.

Rule of thumb: if you can write it as a `deny` pattern, write it there first, a hook is one more
moving part that can crash or be out of date. Reserve hooks for what the native layers cannot say.

## Honest limits

- The tamper guard is a speed bump, not a sandbox: a determined shell can still edit files through
  vectors it does not parse. Pair it with OS-level file flags (`chflags uchg` on macOS,
  `chattr +i` on Linux) for the guard files.
- Regex guards (`validate-command.js`, send classification) catch the common forms, not every
  obfuscation. They reduce accidents, they are not a security boundary against a hostile agent.
- Fail-open hooks (everything except the send guard and the dialog guards) allow the action when
  they crash or the payload is unparseable. That is deliberate: a broken validator must not freeze work.
