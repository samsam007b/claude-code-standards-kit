#!/usr/bin/env bash
# Regression suite for the marketplace-vetting hooks:
#   plugin-script-exec-guard.sh, marketplace-add-guard.sh, mcp-tool-trust-gate.sh,
#   guard-file-tamper-guard.sh
#
# Usage: bash global/hooks/tests/test-marketplace-vetting.sh
# Re-run after any change to one of the four hooks, the shared libs, or the trust registry.
#
# The hooks are invoked directly (bash <hook> < payload), never through a real Bash tool call of
# the harness, so the suite cannot contradict itself. Do not embed a literal plugin-cache path
# or a "sudo"/"claude plugin ..." command in this file outside the printf payloads, or the file
# itself would be blocked when run through the harness Bash tool.
#
# CLAUDE_HOOK_TEST_MODE=1: a "blocked" path really calls human_confirm_dialog(), which would pop
# a real dialog and wait up to 300 s. Test mode makes it refuse immediately without any dialog.
# It can never auto-confirm, so the mode introduces no bypass: it only proves the path REACHES
# the confirmation gate. The physical click is verified by hand.
set -u
export CLAUDE_HOOK_TEST_MODE=1

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$(cd "$HERE/.." && pwd)"

# Sandboxed config home: nothing here touches the real ~/.claude.
SANDBOX="$(mktemp -d)"
trap 'rm -rf "$SANDBOX"' EXIT
export CLAUDE_HOME="$SANDBOX/.claude"
mkdir -p "$CLAUDE_HOME/skills/marketplace-vetting"
cat > "$CLAUDE_HOME/skills/marketplace-vetting/TRUST-REGISTRY.md" <<'REG'
| Server slug | Trusted | Notes |
|---|---|---|
| `context7` | ✅ | docs lookup |
| `_my-tool` | ✅ | slug with a leading underscore |
| `sketchy` | ❌ | rejected |
REG
export CLAUDE_TRUST_REGISTRY="$CLAUDE_HOME/skills/marketplace-vetting/TRUST-REGISTRY.md"
export CLAUDE_PLUGIN_ALLOWLIST="$SANDBOX/empty-allowlist.txt"
printf '# empty on purpose\n' > "$CLAUDE_PLUGIN_ALLOWLIST"

H1="$HOOKS_DIR/plugin-script-exec-guard.sh"
H2="$HOOKS_DIR/marketplace-add-guard.sh"
H3="$HOOKS_DIR/mcp-tool-trust-gate.sh"
H4="$HOOKS_DIR/guard-file-tamper-guard.sh"
HOME_DIR="$SANDBOX/home"
MP="$CLAUDE_HOME/plugins/marketplaces/some-marketplace/scripts"

PASS=0
FAIL=0

# run <hook> <payload>  -> prints the hook exit code
run() { printf '%s' "$2" | bash "$1" >/dev/null 2>&1; echo $?; }

check() {
  local desc="$1" expected="$2" actual="$3"
  if [[ "$actual" == "$expected" ]]; then
    echo "PASS: $desc"; PASS=$((PASS+1))
  else
    echo "FAIL: $desc (expected exit=$expected, got exit=$actual)"; FAIL=$((FAIL+1))
  fi
}

# --- plugin-script-exec-guard.sh ---
check "absolute exec inside marketplace -> blocked" 2 \
  "$(run "$H1" "$(printf '{"tool_name":"Bash","cwd":"%s","tool_input":{"command":"bash %s/x.sh"}}' "$HOME_DIR" "$MP")")"
check "relative exec, cwd inside marketplace -> blocked" 2 \
  "$(run "$H1" "$(printf '{"tool_name":"Bash","cwd":"%s","tool_input":{"command":"./x.sh"}}' "$MP")")"
check "relative exec, cwd outside marketplace -> allowed" 0 \
  "$(run "$H1" "$(printf '{"tool_name":"Bash","cwd":"%s","tool_input":{"command":"./x.sh"}}' "$HOME_DIR")")"
check "read (cat) inside marketplace -> allowed" 0 \
  "$(run "$H1" "$(printf '{"tool_name":"Bash","cwd":"%s","tool_input":{"command":"cat %s/x.sh"}}' "$HOME_DIR" "$MP")")"
check "sudo + marketplace -> hard blocked" 2 \
  "$(run "$H1" "$(printf '{"tool_name":"Bash","cwd":"%s","tool_input":{"command":"sudo bash %s/x.sh"}}' "$HOME_DIR" "$MP")")"
# Regression: a literal grep on '"tool_name":"Bash"' (no space) silently disabled the whole hook
# when the real payload spaced the JSON colons differently. The field is now JSON-parsed.
check "spaced JSON (tool_name with a space) -> still blocked" 2 \
  "$(run "$H1" "$(printf '{"tool_name": "Bash", "cwd": "%s", "tool_input": {"command": "bash %s/x.sh"}}' "$HOME_DIR" "$MP")")"
check "non-JSON input -> allowed (fail-open, no crash)" 0 "$(run "$H1" 'not json at all')"

# --- marketplace-add-guard.sh ---
check "marketplace add -> blocked" 2 \
  "$(run "$H2" '{"tool_name":"Bash","tool_input":{"command":"claude plugin marketplace add foo/bar"}}')"
check "plugins install -> blocked" 2 \
  "$(run "$H2" '{"tool_name":"Bash","tool_input":{"command":"claude plugins install foo@bar"}}')"
check "neutral command -> allowed" 0 \
  "$(run "$H2" '{"tool_name":"Bash","tool_input":{"command":"git status"}}')"
check "spaced JSON -> still blocked" 2 \
  "$(run "$H2" '{"tool_name": "Bash", "tool_input": {"command": "claude plugin marketplace add foo/bar"}}')"

# --- mcp-tool-trust-gate.sh ---
check "trusted MCP server (context7) -> allowed" 0 "$(run "$H3" '{"tool_name":"mcp__context7__query-docs"}')"
check "trusted MCP server with leading underscore slug -> allowed" 0 "$(run "$H3" '{"tool_name":"mcp___my-tool__search"}')"
check "server marked rejected in registry -> blocked" 2 "$(run "$H3" '{"tool_name":"mcp__sketchy__do_thing"}')"
check "unknown MCP server -> blocked" 2 "$(run "$H3" '{"tool_name":"mcp__unknown-server-xyz__do_thing"}')"
check "non-MCP tool -> allowed" 0 "$(run "$H3" '{"tool_name":"Bash"}')"

# --- guard-file-tamper-guard.sh ---
check "Edit on a protected hook -> blocked" 2 \
  "$(run "$H4" "$(printf '{"tool_name":"Edit","tool_input":{"file_path":"%s/hooks/mcp-tool-trust-gate.sh"}}' "$CLAUDE_HOME")")"
check "Write on settings.json -> blocked" 2 \
  "$(run "$H4" "$(printf '{"tool_name":"Write","tool_input":{"file_path":"%s/settings.json"}}' "$CLAUDE_HOME")")"
check "Edit on the trust registry -> blocked" 2 \
  "$(run "$H4" "$(printf '{"tool_name":"Edit","tool_input":{"file_path":"%s/skills/marketplace-vetting/TRUST-REGISTRY.md"}}' "$CLAUDE_HOME")")"
check "Edit on an unprotected file -> allowed" 0 \
  "$(run "$H4" '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/some-other-file.md"}}')"
check "non Edit/Write tool without a path vector -> allowed" 0 \
  "$(run "$H4" '{"tool_name":"Bash","tool_input":{"command":"echo hi"}}')"
# Regression: v1 only covered Edit/Write/NotebookEdit, a raw shell redirection escaped it.
check "Bash redirection > into settings.json -> blocked" 2 \
  "$(run "$H4" "$(printf '{"tool_name":"Bash","tool_input":{"command":"echo evil > %s/settings.json"}}' "$CLAUDE_HOME")")"
check "Bash sed -i on a protected hook -> blocked" 2 \
  "$(run "$H4" "$(printf '{"tool_name":"Bash","tool_input":{"command":"sed -i .bak s/x/y/ %s/hooks/mcp-tool-trust-gate.sh"}}' "$CLAUDE_HOME")")"
check "Bash read (cat) of settings.json -> allowed" 0 \
  "$(run "$H4" "$(printf '{"tool_name":"Bash","tool_input":{"command":"cat %s/settings.json"}}' "$CLAUDE_HOME")")"

echo ""
echo "=== $PASS passed / $((PASS+FAIL)) total ==="
[[ "$FAIL" -eq 0 ]]
