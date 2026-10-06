#!/usr/bin/env bash
# Test suite for safe-db-operation.js.
# No real database or network call is made: every case fails before reaching
# the Supabase client, which is exactly what should happen without a config
# or without connection env vars. Usage: bash global/scripts/tests/test-safe-db-operation.sh

set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS="$(cd "$HERE/.." && pwd)"
SCRIPT="$SCRIPTS/safe-db-operation.js"
T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT

pass=0; fail=0
ok()  { echo "  ok   $1"; pass=$((pass + 1)); }
bad() { echo "  FAIL $1"; fail=$((fail + 1)); }
check() { if eval "$2"; then ok "$1"; else bad "$1"; fi; }

command -v node >/dev/null 2>&1 || { echo "node not found, skipping"; exit 0; }

echo "safe-db-operation.js"

node --check "$SCRIPT" >/dev/null 2>"$T/syntax.err"
check "valid JS syntax" '[ ! -s "$T/syntax.err" ]'

out="$(node "$SCRIPT" 2>&1)"; rc=$?
check "no args: exit 0" '[ "$rc" = "0" ]'
check "no args: prints usage" 'echo "$out" | grep -q "Usage: node safe-db-operation.js"'

out="$(CLAUDE_DB_SAFE_CONFIG="$T/missing.json" node "$SCRIPT" delete-account foo@example.com 2>&1)"; rc=$?
check "missing config: exit 1" '[ "$rc" = "1" ]'
check "missing config: clear error" 'echo "$out" | grep -q "No config file at"'

cat > "$T/config.json" <<'JSON'
{
  "operations": {
    "delete-account": {
      "table": "users",
      "idColumn": "id",
      "lookupColumn": "email",
      "relatedTables": [{ "name": "orders", "column": "user_id" }]
    }
  }
}
JSON

(unset SUPABASE_URL SUPABASE_SERVICE_ROLE_KEY; out="$(CLAUDE_DB_SAFE_CONFIG="$T/config.json" node "$SCRIPT" delete-account foo@example.com 2>&1)"; rc=$?
echo "$out" > "$T/noenv.out"; echo "$rc" > "$T/noenv.rc")
check "config ok, no connection env: exit 1" '[ "$(cat "$T/noenv.rc")" = "1" ]'
check "config ok, no connection env: clear error" 'grep -q "Missing SUPABASE_URL" "$T/noenv.out"'

out="$(CLAUDE_DB_SAFE_CONFIG="$T/config.json" node "$SCRIPT" unknown-operation foo@example.com 2>&1)"; rc=$?
check "unknown operation: exit 1" '[ "$rc" = "1" ]'
check "unknown operation: lists what is defined" 'echo "$out" | grep -q "delete-account"'

cat > "$T/load-check.js" <<JS
process.env.CLAUDE_DB_SAFE_CONFIG = "$T/config.json";
const { loadConfig } = require("$SCRIPT");
const c = loadConfig();
if (!c.operations["delete-account"]) process.exit(1);
JS
node "$T/load-check.js" 2>"$T/load.err"; rc=$?
check "loadConfig() reads the operations map" '[ "$rc" = "0" ]'

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
