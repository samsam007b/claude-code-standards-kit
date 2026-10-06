#!/usr/bin/env bash
# heartbeat-watchdog.sh: the single controller that reads every heartbeat.
#
# Reads an expected-jobs registry and the heartbeat file (written by lib/heartbeat.sh),
# and notifies about any job whose last heartbeat is older than its maximum age, or that
# never beat. Schedule it once a day (cron, launchd, systemd timer).
#
# Deliberately NO `set -e`: one silent job must never prevent reporting the others.
# The only unacceptable failure mode of a watchdog is silence.
#
# Files (all under HEARTBEAT_STATE_DIR, default $HOME/.claude/state):
#   heartbeats.tsv           job <TAB> UTC timestamp         (written by jobs via lib/heartbeat.sh)
#   heartbeats-expected.tsv  job <TAB> max_age_seconds <TAB> description
#                            (see heartbeats-expected.example.tsv)
#   heartbeat-streaks.tsv    consecutive alerts per job (internal, enables escalation)
#   heartbeats-launchd-map.tsv (optional, macOS) launchd label <TAB> job
#
# Environment:
#   HEARTBEAT_STATE_DIR       state directory
#   HEARTBEAT_NOTIFY_PUSH     notifier script (default lib/notify-push.sh next to this script)
#   HEARTBEAT_LOG             log file (default $HOME/.claude/logs/heartbeat-watchdog.log)
#   HEARTBEAT_WATCHDOG_PERIOD seconds between two runs of this controller (default 86400)
#   HEARTBEAT_LAUNCHD_REGEX   ERE matching the launchd labels you own (enables the map check)
#   HEARTBEAT_CANARY          0 = disable the daily alert-channel canary (default 1)
#
# Three ideas worth knowing:
#
# 1. Threshold floor. A controller that runs once a day cannot detect a failure faster than
#    24 h, whatever the threshold. A threshold shorter than the controller's own period adds
#    no sensitivity, it only manufactures false positives (for example an interval job that
#    legitimately sleeps overnight). Short thresholds are therefore floored to
#    `controller period + declared threshold`; thresholds already above the period are kept.
#    The registry keeps declaring the job's real frequency; the floor is computed here.
#
# 2. Escalation. A job silent for more than 3x its effective threshold is reported as DEAD
#    at the top of the message with its consecutive-alert streak, so it is not drowned in the
#    day's ordinary delays.
#
# 3. Alert-channel canary. Everything above is useless if the output is blocked (an API that
#    accepts and drops every message). Once a day the channel is exercised with a silent,
#    low-priority message, and the result is read, not assumed. An alert that was not
#    DELIVERED must never count as proof the channel is healthy.
#
# The watchdog also beats itself, which does not let it detect its own death (a dead process
# signals nothing) but makes its silence measurable: its heartbeat age is readable at a glance.
# To close that gap fully, check that age from something independent of the scheduler
# (for example a SessionStart hook).

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="${HEARTBEAT_STATE_DIR:-$HOME/.claude/state}"
# Exported on purpose: lib/heartbeat.sh reads HEARTBEAT_FILE from the environment, so a test
# run in a throwaway state dir must never fall through to the real registry.
export HEARTBEAT_FILE="$STATE_DIR/heartbeats.tsv"
EXPECTED_FILE="$STATE_DIR/heartbeats-expected.tsv"
STREAK_FILE="$STATE_DIR/heartbeat-streaks.tsv"
MAP_FILE="$STATE_DIR/heartbeats-launchd-map.tsv"
NOTIFY_PUSH="${HEARTBEAT_NOTIFY_PUSH:-$SCRIPT_DIR/lib/notify-push.sh}"
HEARTBEAT_LIB="$SCRIPT_DIR/lib/heartbeat.sh"
LOG="${HEARTBEAT_LOG:-$HOME/.claude/logs/heartbeat-watchdog.log}"
WATCHDOG_PERIOD="${HEARTBEAT_WATCHDOG_PERIOD:-86400}"
CANARY="${HEARTBEAT_CANARY:-1}"

mkdir -p "$(dirname "$LOG")" "$STATE_DIR"

now=$(date +%s)
today=$(date '+%F')
down=()       # beat then went quiet: real outage
silent=()     # never instrumented: wiring defect, not an outage
escalated=0
new_streaks=""

notify() { [ -x "$NOTIFY_PUSH" ] && "$NOTIFY_PUSH" "$@"; }

# UTC ISO-8601 -> epoch seconds. GNU date, then BSD date, then python3.
iso_to_epoch() {
  local ts="$1" e
  e=$(date -u -d "$ts" +%s 2>/dev/null) && [ -n "$e" ] && { echo "$e"; return; }
  e=$(TZ=UTC date -j -f '%Y-%m-%dT%H:%M:%SZ' "$ts" +%s 2>/dev/null) && [ -n "$e" ] && { echo "$e"; return; }
  python3 -c 'import sys,datetime as d; print(int(d.datetime.strptime(sys.argv[1],"%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=d.timezone.utc).timestamp()))' "$ts" 2>/dev/null
}

if [ ! -f "$EXPECTED_FILE" ]; then
  echo "$(date '+%F %T') FATAL: registry $EXPECTED_FILE missing" >> "$LOG"
  notify "Heartbeat registry missing, no job is monitored any more" "Watchdog" 1
  exit 1
fi

streak_of() {
  awk -F'\t' -v j="$1" '$1 == j {print $2; exit}' "$STREAK_FILE" 2>/dev/null
}

while IFS=$'\t' read -r job max_age desc; do
  case "$job" in ''|\#*) continue ;; esac
  [ -n "$max_age" ] || continue
  case "$max_age" in *[!0-9]*) continue ;; esac

  effective=$max_age
  if [ "$max_age" -lt "$WATCHDOG_PERIOD" ]; then
    effective=$(( WATCHDOG_PERIOD + max_age ))
  fi

  last=$(awk -F'\t' -v j="$job" '$1 == j {print $2; exit}' "$HEARTBEAT_FILE" 2>/dev/null)
  if [ -z "$last" ]; then
    silent+=("$job : never instrumented")
    continue
  fi

  last_epoch=$(iso_to_epoch "$last")
  if [ -z "$last_epoch" ]; then
    down+=("!! $job : unreadable timestamp ($last)")
    continue
  fi

  age=$(( now - last_epoch ))
  [ "$age" -le "$effective" ] && continue

  streak=$(streak_of "$job")
  streak=$(( ${streak:-0} + 1 ))
  new_streaks="${new_streaks}${job}"$'\t'"${streak}"$'\t'"${today}"$'\n'

  if [ "$age" -gt $(( effective * 3 )) ]; then
    down=("!! $job DEAD: $(( age / 3600 )) h without a heartbeat, alert #${streak} in a row" "${down[@]}")
    escalated=1
  else
    down+=("$job : silent for $(( age / 3600 )) h (threshold $(( effective / 3600 )) h)")
  fi
done < "$EXPECTED_FILE"

# --- Map check (optional, macOS): are we watching the right jobs? --------------------
# Everything above answers "do the monitored jobs beat?". Nothing there answers "do we
# monitor the right jobs?". Compare the loaded launchd agents you own against a map, in
# both directions: a loaded agent missing from the map is a job nobody decided to watch,
# and a mapped agent that is no longer loaded is an automation you believe is active.
unmapped=()
unloaded=()
if [ -n "${HEARTBEAT_LAUNCHD_REGEX:-}" ] && command -v launchctl >/dev/null 2>&1; then
  if [ -f "$MAP_FILE" ]; then
    loaded=$(launchctl list 2>/dev/null | awk -v re="$HEARTBEAT_LAUNCHD_REGEX" '$3 ~ re {print $3}' | sort)
    mapped=$(grep -v '^#' "$MAP_FILE" | awk -F'\t' 'NF>1 {print $1}' | sort)
    while IFS= read -r label; do
      [ -n "$label" ] || continue
      grep -qxF "$label" <<< "$mapped" || unmapped+=("$label : loaded agent missing from the map, decide whether it is watched")
    done <<< "$loaded"
    while IFS= read -r label; do
      [ -n "$label" ] || continue
      grep -qxF "$label" <<< "$loaded" || unloaded+=("$label : in the map but no longer loaded by launchd")
    done <<< "$mapped"
  else
    unmapped+=("launchd map missing ($MAP_FILE), the map check is not running")
  fi
fi

# Rewritten only here: a job absent from new_streaks beat again, so its streak resets.
printf '%s' "$new_streaks" > "$STREAK_FILE"

# The controller beats too, placed before the branch below so it beats on the "all fine"
# path and the "alert" path alike (one that only beat on quiet days would look dead on the
# first detected failure).
[ -x "$HEARTBEAT_LIB" ] && "$HEARTBEAT_LIB" heartbeat-watchdog 2>/dev/null || true

# --- Alert-channel canary ----------------------------------------------------------
# Defined as a function and called on EVERY exit path. Written at the end of the file it
# sat behind the early `exit 0` of the "all jobs beat" case, so the canary only rang on
# days an alert was already leaving, never during the long calm periods it exists to cover.
canary_channel() {
  [ "$CANARY" = "1" ] || return 0
  local last_file="$STATE_DIR/.channel-last-exercise" t last=0
  t=$(date +%s)
  [ -f "$last_file" ] && last=$(cat "$last_file" 2>/dev/null || echo 0)
  if [ $(( t - last )) -ge 86400 ] && [ -x "$NOTIFY_PUSH" ]; then
    if "$NOTIFY_PUSH" "Alert channel verified, nothing to report." "Canary" -2 >/dev/null 2>&1; then
      echo "$(date '+%F %T') alert channel: delivery confirmed" >> "$LOG"
      echo "$t" > "$last_file"
    else
      echo "$(date '+%F %T') !! ALERT CHANNEL SILENT: this controller's alerts reach nobody" >> "$LOG"
      # The exercise is NOT dated: while the channel is dead, retry on every run.
    fi
  fi
}

if [ ${#down[@]} -eq 0 ] && [ ${#silent[@]} -eq 0 ] \
   && [ ${#unmapped[@]} -eq 0 ] && [ ${#unloaded[@]} -eq 0 ]; then
  echo "$(date '+%F %T') OK, all monitored jobs beat" >> "$LOG"
  canary_channel
  exit 0
fi

lines=()
[ ${#down[@]} -gt 0 ] && lines+=("${down[@]}")
[ ${#silent[@]} -gt 0 ] && lines+=("${silent[@]}")
[ ${#unmapped[@]} -gt 0 ] && lines+=("${unmapped[@]}")
[ ${#unloaded[@]} -gt 0 ] && lines+=("${unloaded[@]}")
msg=$(printf '%s\n' "${lines[@]}")

echo "$(date '+%F %T') ALERT ${#down[@]} down, ${#silent[@]} not instrumented, ${#unmapped[@]} unmapped, ${#unloaded[@]} unloaded"$'\n'"$msg" >> "$LOG"

# Never-instrumented jobs alone do not notify: a known, stable wiring defect must not wake
# a phone every morning. They stay in the log. A map divergence does notify: it is rare by
# nature and needs a one-line human decision.
if [ ${#unmapped[@]} -gt 0 ] || [ ${#unloaded[@]} -gt 0 ]; then
  gap=$(printf '%s\n' "${unmapped[@]}" "${unloaded[@]}" | grep -v '^$')
  notify "$gap" "Scheduler and registry diverge" 0
fi

if [ ${#down[@]} -gt 0 ]; then
  title="${#down[@]} job(s) down"
  [ "$escalated" -eq 1 ] && title="DEAD JOB: $title"
  delivered=0
  notify "$msg" "$title" 1 && delivered=1
  # An alert only counts as an exercise of the channel if it was DELIVERED.
  if [ "$delivered" -eq 1 ]; then
    date +%s > "$STATE_DIR/.channel-last-exercise" 2>/dev/null || true
  else
    echo "$(date '+%F %T') !! ALERT CHANNEL SILENT: the alert above was delivered to nobody" >> "$LOG"
  fi
  exit 0
fi

canary_channel
exit 0
