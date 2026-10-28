# Defense against data exfiltration

A checklist for solo developers and small teams who run Claude Code, a few servers and a managed
database. It assumes an attacker already has code execution somewhere (a vulnerable dependency, a
malicious plugin, a leaked token) and asks one question: how much can they take out?

Each section is a layer. No layer is enough alone.

## 1. Secrets

| Check | Why |
|---|---|
| No secret in shell rc files (`~/.zshrc`, `~/.bashrc`) | Every process you start inherits them, including MCP servers and package install scripts |
| Secrets in an encrypted store loaded per command (age, sops, a vault CLI) | A stolen home directory then yields ciphertext |
| `.env*` files mode 600 | Other local users and sloppy tools cannot read them |
| Run a secret scanner before commit (gitleaks or similar) and over history once | A key removed from HEAD is still in history; rotate it, do not just delete it |
| Rotate every key that ever appeared in a public or shared repo | History rewriting does not undo a clone |
| Keep one key per use, with the narrowest scope the vendor offers | A leak then costs one integration, not the account |

## 2. Supply chain

- Pin MCP servers to an exact version (`pkg@1.2.3`), never `@latest`. `npx` re-resolves `@latest` on
  every start, so a hijacked release runs on your machine the next morning.
- In `.npmrc` set `ignore-scripts=true` and a minimum release age (for example `min-release-age`
  with pnpm's `minimumReleaseAge`). Most npm worms run in `postinstall` within hours of publishing.
- Treat a plugin or marketplace entry as code you run. The kit's `marketplace-add-guard.sh`,
  `plugin-script-exec-guard.sh`, `mcp-tool-trust-gate.sh` and `guard-file-tamper-guard.sh` put a
  human confirmation in front of each of those paths. See `global/hooks/README.md`.
- Run the dependency audit on a schedule and merge fixes from a branch, not straight to main.

### Allowlist pitfalls (learned the hard way)

- **Variables are not expanded.** `plugin-allowlist-check.py` matches the literal path in the command.
  A command written as `${CLAUDE_SKILL_DIR:-/some/path}/scripts/x.py` never matches an allowlist
  line, so the confirmation dialog keeps appearing. Allowlist the resolved path, or call the script
  by its full path.
- **Never allowlist an interpreter, a shell or a package runner** in `permissions.allow`
  (`python3`, `node`, `bash`, `npx`, `uvx`, `npm run *`). Each is arbitrary code execution.
- **Wildcards on `git fetch` are unsafe.** `Bash(git fetch *)` lets `--upload-pack=<cmd>` run a
  command. Allow the exact form (`Bash(git fetch origin)`) instead.
- Allowlist MCP tools one by one, read tools first. A tool whose name contains `evaluate`, `run_code`
  or `exec` is code execution too, decide on it separately.
- Protect the guard files themselves (`chflags uchg` on macOS, `chattr +i` on Linux) so that a
  compromised session cannot edit its own allowlist.

## 3. Egress

An attacker who cannot send data out cannot exfiltrate it.

- **Docker bypasses ufw.** A published port (`-p 2222:22`) is opened in the `DOCKER` iptables chain
  before ufw sees the packet. Bind internal services to loopback (`127.0.0.1:2222:22`) and reach them
  through an SSH jump host or tunnel.
- On servers that do not need the open internet, set `ufw default deny outgoing` and allow DNS, NTP,
  the package mirror and the specific APIs you call. Start in observe mode (log outbound
  connections for a week), then enforce.
- On the workstation, a `PreToolUse` hook on `WebFetch` and `Bash` that checks the destination
  against an allowlist catches a prompt-injected "curl this to my server". Log first, block second.
- Stop SSH password login, restrict `AllowUsers`, and put a passphrase on private keys (store it in
  the OS keychain). An unprotected key in `~/.ssh` is the cheapest thing to steal.

## 4. Database (Supabase / Postgres)

Audit read-only, then write the fixes as a SQL draft that a human applies.

| Look for | Risk | Fix |
|---|---|---|
| Tables without row level security | Anyone with the anon key can read them | `ENABLE ROW LEVEL SECURITY` plus an explicit policy |
| Views owned by `postgres` without `security_invoker = true` | A view runs with its owner's rights and bypasses the RLS of the tables beneath it | `ALTER VIEW ... SET (security_invoker = true)` |
| `SECURITY DEFINER` functions callable by `anon` | Same bypass, through a function | Revoke `EXECUTE` from `anon`/`public`, set `search_path` |
| Policies on `USING (true)` | RLS is on but does nothing | Scope to `auth.uid()` or a tenant column |
| Storage buckets marked public | Listing and download without auth | Private bucket plus signed URLs |
| The service-role key in a client bundle or a repo | Full bypass of RLS | Server only, rotate if exposed |

Before applying a fix, check that the app does not rely on the open behaviour (grep for the view or
table in client code, check logs for anon traffic). Add alerts on bulk exports (large `COPY` or
`SELECT` volume) and a pgTAP test per RLS policy so it cannot regress silently.

## 5. Backups

- Back up to a target the backed-up machine cannot delete: append-only mode, object lock, or a
  separate account.
- Keep the backup password somewhere other than the machine being backed up.
- Restore a snapshot to a scratch directory once. A backup you have not restored is a hope.

## 6. Priority order

1. Rotate leaked secrets, move secrets out of rc files.
2. Close public ports and bind internal services to loopback.
3. Pin MCP and package versions, turn off install scripts.
4. RLS and view audit.
5. Allowlist the tools you use every day, so approval dialogs stay rare enough to be read.
6. Egress allowlist, append-only backups, alerting.

Step 5 matters more than it looks: a dialog that appears twenty times a day is clicked through by
reflex, which defeats it.
