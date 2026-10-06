#!/usr/bin/env bash
# Test suite for heartbeat.sh, notify-push.sh and heartbeat-watchdog.sh.
# Runs entirely in a throwaway state dir with a stub notifier: nothing real is touched.
# Usage: bash global/scripts/tests/test-heartbeat-watchdog.sh

set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS="$(cd "$HERE/.." && pwd)"
T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT

pass=0; fail=0
ok()  { echo "  ok   $1"; pass=$((pass + 1)); }
bad() { echo "  FAIL $1"; fail=$((fail + 1)); }
check() { if eval "$2"; then ok "$1"; else bad "$1"; fi; }

export HEARTBEAT_STATE_DIR="$T/state"
export HEARTBEAT_LOG="$T/watchdog.log"
export HEARTBEAT_FILE="$T/state/heartbeats.tsv"
mkdir -p "$T/state"

# Stub notifier: records calls, exit code controlled by $T/notifier-rc.
cat > "$T/notify-stub.sh" <<STUB
#!/usr/bin/env bash
echo "\$3|\$2|\$1" >> "$T/notifications.log"
exit \$(cat "$T/notifier-rc" 2>/dev/null || echo 0)
STUB
chmod +x "$T/notify-stub.sh"
export HEARTBEAT_NOTIFY_PUSH="$T/notify-stub.sh"
echo 0 > "$T/notifier-rc"

echo "heartbeat.sh"
"$SCRIPTS/lib/heartbeat.sh" job-a
"$SCRIPTS/lib/heartbeat.sh" job-b
"$SCRIPTS/lib/heartbeat.sh" job-a
check "one line per job, no duplicates" '[ "$(wc -l < "$HEARTBEAT_FILE" | tr -d " ")" = "2" ]'
check "timestamp is UTC ISO-8601" 'grep -qE "^job-a	[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9:]{8}Z$" "$HEARTBEAT_FILE"'
check "job names with regex chars do not clobber others" '"$SCRIPTS/lib/heartbeat.sh" "job.*" && grep -q "^job-b" "$HEARTBEAT_FILE"'

echo "watchdog: healthy"
printf 'job-a\t3600\tfake\njob-b\t3600\tfake\n' > "$T/state/heartbeats-expected.tsv"
: > "$T/notifications.log"
bash "$SCRIPTS/heartbeat-watchdog.sh"
check "no alert when all jobs beat" '! grep -q "job(s) down" "$T/notifications.log"'
check "canary fired (silent priority -2)" 'grep -q "^-2|Canary" "$T/notifications.log"'
check "controller beat itself" 'grep -q "^heartbeat-watchdog" "$HEARTBEAT_FILE"'
check "log says OK" 'grep -q "OK, all monitored jobs beat" "$HEARTBEAT_LOG"'

echo "watchdog: second run same day does not re-ring the canary"
: > "$T/notifications.log"
bash "$SCRIPTS/heartbeat-watchdog.sh"
check "canary rate-limited to once per 24 h" '! grep -q "Canary" "$T/notifications.log"'

echo "watchdog: stale + dead + never-instrumented"
old=$(date -u -d '@1' '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date -u -r 1 '+%Y-%m-%dT%H:%M:%SZ')
two_days=$(date -u -d '-2 days' '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date -u -v-2d '+%Y-%m-%dT%H:%M:%SZ')
printf 'job-a\t%s\njob-b\t%s\n' "$two_days" "$old" | sort > "$HEARTBEAT_FILE"
printf 'job-a\t3600\tfake\njob-b\t3600\tfake\njob-never\t3600\tfake\n' > "$T/state/heartbeats-expected.tsv"
: > "$T/notifications.log"
bash "$SCRIPTS/heartbeat-watchdog.sh"
check "alert sent with priority 1" 'grep -q "^1|" "$T/notifications.log"'
check "dead job escalated in the title" 'grep -q "DEAD JOB" "$T/notifications.log"'
check "dead job listed first" 'grep -q "!! job-b DEAD" "$T/notifications.log"'
check "job older than the floor (24 h + 1 h) is flagged as silent" 'grep -q "job-a : silent" "$T/notifications.log"'
check "never-instrumented job logged but not the only reason to ring" 'grep -q "job-never : never instrumented" "$HEARTBEAT_LOG"'
check "streak file written" 'grep -q "^job-b	1	" "$T/state/heartbeat-streaks.tsv"'

echo "watchdog: threshold floor"
fresh=$(date -u -d '-5 hours' '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || date -u -v-5H '+%Y-%m-%dT%H:%M:%SZ')
printf 'job-a\t%s\n' "$fresh" > "$HEARTBEAT_FILE"
printf 'job-a\t3600\tfake\n' > "$T/state/heartbeats-expected.tsv"
: > "$T/notifications.log"
bash "$SCRIPTS/heartbeat-watchdog.sh"
check "5 h silence on a 1 h job is NOT an alert with a daily controller" '! grep -q "job-a" "$T/notifications.log"'

echo "watchdog: missing registry"
rm -f "$T/state/heartbeats-expected.tsv"
: > "$T/notifications.log"
bash "$SCRIPTS/heartbeat-watchdog.sh"; rc=$?
check "exit 1 and notification when registry is missing" '[ "$rc" = "1" ] && grep -q "registry missing" "$T/notifications.log"'

echo "watchdog: undelivered alert is not an exercise of the channel"
rm -f "$T/state/.channel-last-exercise"
printf 'job-b\t%s\n' "$old" > "$HEARTBEAT_FILE"
printf 'job-b\t3600\tfake\n' > "$T/state/heartbeats-expected.tsv"
echo 1 > "$T/notifier-rc"
bash "$SCRIPTS/heartbeat-watchdog.sh"
check "channel-silent line in log" 'grep -q "ALERT CHANNEL SILENT" "$HEARTBEAT_LOG"'
check "exercise not dated" '[ ! -f "$T/state/.channel-last-exercise" ]'

echo "notify-push.sh"
unset NTFY_URL NOTIFY_WEBHOOK_URL PUSHOVER_USER_KEY PUSHOVER_APP_TOKEN
export NOTIFY_ENV="$T/none.env"
NOTIFY_CHANNELS="ntfy,webhook" bash "$SCRIPTS/lib/notify-push.sh" "m" "t" 0 2>/dev/null; rc=$?
check "exit 1 when no channel is configured" '[ "$rc" = "1" ]'
NOTIFY_CHANNELS="ntfy" NTFY_URL="http://127.0.0.1:9/none" bash "$SCRIPTS/lib/notify-push.sh" "m" "t" 0 2>/dev/null; rc=$?
check "exit 1 when the endpoint is unreachable" '[ "$rc" = "1" ]'

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
