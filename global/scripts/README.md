# Operations scripts

Install to `$HOME/.claude/scripts/` (keep the `lib/` and `tests/` subfolders). All scripts are configured by environment variables, never by hardcoded paths. `CLAUDE_DIR` defaults to `$HOME/.claude`.

| Script | Purpose | Usage example | Dependencies |
|---|---|---|---|
| `env-vault.sh` | age-encrypted `.env` vault: lock, unlock, status, fix-perms | `ENV_VAULT_ROOTS=$HOME/Projects env-vault.sh status` | age |
| `scan-secrets.sh` | PreToolUse hook on commit/push Bash commands (security guard, blocks on a finding) or manual scan of staged changes | `scan-secrets.sh` | git, grep |
| `api-key-guard.sh` | PreToolUse hook (security guard, fails closed): blocks writes that contain known keys. Exit 2 blocks. | settings.json hook on `Write\|Edit\|Bash` | jq or python3 |
| `secrets-registry.example.json` | Example registry for `api-key-guard.sh` | copy and edit | none |
| `setup-worktree.sh` / `delete-worktree.sh` | Create and safely remove git worktrees | `setup-worktree.sh feature-x` | git |
| `heartbeat-watchdog.sh` | Controller: compares job heartbeats with the expected registry, alerts on silence, daily canary | run every 15 min from cron or launchd | bash, python3 |
| `lib/heartbeat.sh` | Each job calls it to record a heartbeat | `lib/heartbeat.sh my-job` | none |
| `lib/notify-push.sh` | Notification channel (ntfy.sh, webhook, Pushover or desktop) chosen by env vars, delivery verified | `lib/notify-push.sh "message" "title" 0` | curl |
| `lib/cron-eval.py` | Cron expression evaluator used by the watchdog | imported by the watchdog; see `tests/test-cron-eval.py` | python3 |
| `heartbeats-expected.example.tsv` | Example expected-jobs registry with fake jobs | copy and edit | none |
| `statusline-ccusage.sh` | Status line with session, day and block cost | `statusLine.command` in settings.json | ccusage, jq |
| `cost-dashboard.sh` | ccusage summary, RTK savings if installed, sessions per project | `cost-dashboard.sh 7` | ccusage, python3 |
| `usage-scan.py` | Measures real skill and agent invocations from transcripts, with a cache | `python3 usage-scan.py` | python3 |
| `skills-index-refresh.py` | Refreshes the inventory block in `skills/INDEX.md` | `python3 skills-index-refresh.py` | python3 |
| `rotate-logs.sh` | Weekly gzip rotation of setup logs, `ROTATE_LOGS_EXTRA` for outside logs | `rotate-logs.sh` | gzip |
| `file-history-rotate.sh` | Age and size budget rotation of `file-history` (the /rewind store) | `BUDGET_MB=250 file-history-rotate.sh` | du, find |
| `hooks-dashboard.sh` | Lists hooks per event and flags blocking ones | `hooks-dashboard.sh` | python3 |
| `auto-format.sh` | PostToolUse hook (fails open): runs the matching formatter on the edited file. Bypass `AUTO_FORMAT_DISABLE=1` | hook on `Edit\|Write\|MultiEdit` | python3, optional formatters |
| `check-subagent-output.sh` | PostToolUse hook on `Agent` (fails open, never blocks): warns on oversized subagent output | hook on `Agent` | jq |
| `audit-page-overflow.mjs` | Detects content cut off at the bottom of paginated HTML via headless Chrome. Exit 2 if cut, 3 if inconclusive | `node audit-page-overflow.mjs doc.html` | node, Chrome |
| `safe-db-operation.js` | The sanctioned way to run a destructive DB operation (delete a record and its cascading rows). Dry-run by default, config-driven (no hardcoded schema), confirmation code required before `--execute` deletes anything, every call logged. This is what `validate-command.js` points `CLAUDE_DB_SAFE_TOOL` at when it blocks a raw destructive DB command. | `CLAUDE_DB_SAFE_CONFIG=./safe-db-operation.config.json node safe-db-operation.js delete-account user@example.com --execute` | node, `@supabase/supabase-js` (or swap `createClient()` for your own driver) |
| `safe-db-operation.config.example.json` | Example config for `safe-db-operation.js`: copy, rename, describe your own tables | copy and edit | none |

## Tests

```
bash tests/test-heartbeat-watchdog.sh
python3 tests/test-cron-eval.py
bash tests/test-safe-db-operation.sh
```
