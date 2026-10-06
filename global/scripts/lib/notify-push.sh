#!/usr/bin/env bash
# notify-push.sh: send an alert through the first channel that CONFIRMS delivery.
#
# Usage: notify-push.sh "<message>" [title] [priority]
#   priority: -2 silent, -1 quiet, 0 normal (default), 1 high, 2 emergency
# Exit code: 0 = at least one channel confirmed delivery, 1 = nothing was delivered.
#
# Channels (tried in order of NOTIFY_CHANNELS, default "ntfy,webhook,pushover,desktop"):
#   ntfy      POST to $NTFY_URL (e.g. https://ntfy.sh/my-private-topic), optional $NTFY_TOKEN
#   webhook   POST JSON {title,message,priority,text} to $NOTIFY_WEBHOOK_URL (Slack/Discord/Mattermost style)
#   pushover  $PUSHOVER_USER_KEY + $PUSHOVER_APP_TOKEN
#   desktop   macOS notification (osascript) or notify-send on Linux. Never leaves the machine.
# A channel without its variables is skipped. Config is read from
# ${NOTIFY_ENV:-$HOME/.config/notify/notify.env} when that file exists (plain KEY=value lines).
#
# Why "confirms delivery" and not "curl exited 0": `curl -s` returns 0 as soon as the
# connection succeeds. A revoked token, an exhausted quota or an account with no registered
# device all look like success. Three levels fail independently and are all checked:
#   1. curl exit code        (did the network answer)
#   2. HTTP code / status    (did the API accept the message)
#   3. API "info" field      (does the message have a real recipient; Pushover answers
#                             HTTP 200 + status 1 + "no active devices" and drops it)
# If every remote channel fails, the desktop channel is used as a degraded fallback and the
# script still exits 1, so callers know the alert did not reach a person.

set -uo pipefail

MESSAGE="${1:-Notification}"
TITLE="${2:-Alert}"
PRIORITY="${3:-0}"

ENV_FILE="${NOTIFY_ENV:-$HOME/.config/notify/notify.env}"
if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  set -a; . "$ENV_FILE"; set +a
fi

CHANNELS="${NOTIFY_CHANNELS:-ntfy,webhook,pushover,desktop}"
CURL_OPTS=(-s --max-time 20)

log() { echo "[notify-push] $*" >&2; }

json_escape() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import json,sys; print(json.dumps(sys.stdin.read().rstrip("\n")))' <<<"$1"
  else
    printf '"%s"' "$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n' ' ')"
  fi
}

# Each send_* returns 0 only on confirmed delivery; sets REASON otherwise.
REASON=""

send_ntfy() {
  [ -n "${NTFY_URL:-}" ] || { REASON="NTFY_URL not set"; return 2; }
  local prio=$((PRIORITY + 3)) auth=() out code
  [ "$prio" -lt 1 ] && prio=1; [ "$prio" -gt 5 ] && prio=5
  [ -n "${NTFY_TOKEN:-}" ] && auth=(-H "Authorization: Bearer $NTFY_TOKEN")
  out=$(curl "${CURL_OPTS[@]}" "${auth[@]}" -H "Title: $TITLE" -H "Priority: $prio" \
        -d "$MESSAGE" -w '\nHTTP:%{http_code}' "$NTFY_URL" 2>/dev/null) || { REASON="ntfy: curl failed"; return 1; }
  code=$(sed -n 's/^HTTP:\([0-9]*\)$/\1/p' <<<"$out")
  [[ "$code" =~ ^2 ]] || { REASON="ntfy: HTTP ${code:-unknown}"; return 1; }
  return 0
}

send_webhook() {
  [ -n "${NOTIFY_WEBHOOK_URL:-}" ] || { REASON="NOTIFY_WEBHOOK_URL not set"; return 2; }
  local payload out code
  payload=$(printf '{"title":%s,"message":%s,"priority":%s,"text":%s}' \
    "$(json_escape "$TITLE")" "$(json_escape "$MESSAGE")" "$PRIORITY" "$(json_escape "$TITLE: $MESSAGE")")
  out=$(curl "${CURL_OPTS[@]}" -H 'Content-Type: application/json' -d "$payload" \
        -w '\nHTTP:%{http_code}' "$NOTIFY_WEBHOOK_URL" 2>/dev/null) || { REASON="webhook: curl failed"; return 1; }
  code=$(sed -n 's/^HTTP:\([0-9]*\)$/\1/p' <<<"$out")
  [[ "$code" =~ ^2 ]] || { REASON="webhook: HTTP ${code:-unknown}"; return 1; }
  return 0
}

send_pushover() {
  [ -n "${PUSHOVER_USER_KEY:-}" ] && [ -n "${PUSHOVER_APP_TOKEN:-}" ] || { REASON="pushover tokens not set"; return 2; }
  local out code body status info
  out=$(curl "${CURL_OPTS[@]}" \
    --form-string "token=$PUSHOVER_APP_TOKEN" --form-string "user=$PUSHOVER_USER_KEY" \
    --form-string "message=$MESSAGE" --form-string "title=$TITLE" --form-string "priority=$PRIORITY" \
    -w '\nHTTP:%{http_code}' https://api.pushover.net/1/messages.json 2>/dev/null) || { REASON="pushover: curl failed"; return 1; }
  code=$(sed -n 's/^HTTP:\([0-9]*\)$/\1/p' <<<"$out")
  body=$(sed '$d' <<<"$out")
  status=$(sed -n 's/.*"status":[[:space:]]*\([0-9]*\).*/\1/p' <<<"$body")
  info=$(sed -n 's/.*"info":"\([^"]*\)".*/\1/p' <<<"$body")
  [ "$code" = "200" ] || { REASON="pushover: HTTP ${code:-unknown}"; return 1; }
  [ "$status" = "1" ] || { REASON="pushover: refused (status ${status:-none})"; return 1; }
  [ -z "$info" ] || { REASON="pushover: accepted but undeliverable: $info"; return 1; }
  return 0
}

send_desktop() {
  local m t
  if [ "$(uname -s)" = "Darwin" ] && command -v osascript >/dev/null 2>&1; then
    m=$(printf '%s' "$MESSAGE" | sed 's/\\/\\\\/g; s/"/\\"/g')
    t=$(printf '%s' "$TITLE" | sed 's/\\/\\\\/g; s/"/\\"/g')
    osascript -e "display notification \"$m\" with title \"$t\"" >/dev/null 2>&1 && return 0
    REASON="desktop: osascript failed"; return 1
  elif command -v notify-send >/dev/null 2>&1; then
    notify-send "$TITLE" "$MESSAGE" >/dev/null 2>&1 && return 0
    REASON="desktop: notify-send failed"; return 1
  fi
  REASON="desktop: no notifier available"; return 2
}

delivered=""
failures=""
IFS=',' read -r -a LIST <<<"$CHANNELS"
for ch in "${LIST[@]}"; do
  ch="${ch// /}"
  [ -n "$ch" ] || continue
  # The desktop channel does not leave the machine: only use it when nothing remote worked.
  if [ "$ch" = "desktop" ] && [ -z "$delivered" ]; then
    :
  elif [ "$ch" = "desktop" ]; then
    continue
  fi
  REASON=""
  "send_$ch" 2>/dev/null
  rc=$?
  if [ $rc -eq 0 ]; then
    if [ "$ch" = "desktop" ]; then
      # Desktop alone counts as delivery only when no remote channel failed before it.
      if [ -z "$failures" ]; then delivered="desktop"; else failures="$failures; desktop fallback used"; fi
    else
      delivered="$ch"
      break
    fi
  elif [ $rc -eq 1 ]; then
    failures="${failures:+$failures; }$REASON"
  fi
done

if [ -n "$delivered" ]; then
  log "delivered via $delivered: $TITLE"
  exit 0
fi
log "NOT DELIVERED (${failures:-no channel configured}). Set NTFY_URL, NOTIFY_WEBHOOK_URL or Pushover tokens in $ENV_FILE."
exit 1
