#!/usr/bin/env bash
# rotate-logs.sh: weekly log rotation for your Claude Code setup logs.
#
# Archives each oversized log as gzip, keeps the last lines in the active file, and
# prunes archives older than MAX_ARCHIVE_DAYS. Schedule it weekly (cron / launchd / systemd).
#
# Rotated: $CLAUDE_DIR/security.log, data-operations.log, every $CLAUDE_DIR/logs/*.log,
# plus any extra paths in ROTATE_LOGS_EXTRA. Logs that live OUTSIDE $CLAUDE_DIR are the
# classic blind spot (a backup log can silently reach gigabytes): list them in
# ROTATE_LOGS_EXTRA.
#
# Environment:
#   CLAUDE_DIR           default $HOME/.claude
#   ROTATE_LOGS_EXTRA    colon-separated extra log files
#   MAX_ARCHIVE_DAYS     default 90
#   MIN_SIZE_BYTES       skip files smaller than this (default 10240)
#   KEEP_LINES           lines kept in the active log (default 1000)
#
# Writes a heartbeat (lib/heartbeat.sh) if present: this job only logs when it actually
# rotates something, so dead and idle look identical without it.
#
# Dependencies: gzip, tail, find

set -euo pipefail

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
LOG_DIR="$CLAUDE_DIR/logs"
ARCHIVE_DIR="$LOG_DIR/archive"
TIMESTAMP=$(date +%Y-%m-%d)
MAX_ARCHIVE_DAYS="${MAX_ARCHIVE_DAYS:-90}"
MIN_SIZE_BYTES="${MIN_SIZE_BYTES:-10240}"
KEEP_LINES="${KEEP_LINES:-1000}"

mkdir -p "$ARCHIVE_DIR"

rotate_file() {
  local file="$1" base size archive
  [ -f "$file" ] || return 0
  base=$(basename "$file" .log)
  size=$(wc -c < "$file" 2>/dev/null || echo 0)
  [ "$size" -ge "$MIN_SIZE_BYTES" ] || return 0

  archive="$ARCHIVE_DIR/${base}-${TIMESTAMP}.log"
  cp "$file" "$archive"
  gzip -f "$archive"

  tail -n "$KEEP_LINES" "$file" > "${file}.tmp"
  mv "${file}.tmp" "$file"
  echo "[$(date)] Rotated $file -> ${archive}.gz (was ${size} bytes)"
}

rotate_file "$CLAUDE_DIR/security.log"
rotate_file "$CLAUDE_DIR/data-operations.log"

if [ -n "${ROTATE_LOGS_EXTRA:-}" ]; then
  IFS=':' read -r -a extras <<< "$ROTATE_LOGS_EXTRA"
  for f in "${extras[@]}"; do rotate_file "$f"; done
fi

if [ -d "$LOG_DIR" ]; then
  for f in "$LOG_DIR"/*.log; do
    [ -f "$f" ] && rotate_file "$f"
  done
fi

find "$CLAUDE_DIR" -maxdepth 2 -name "security_warnings_state_*.json" -mtime +30 -delete 2>/dev/null || true
find "$ARCHIVE_DIR" -name "*.log.gz" -mtime "+$MAX_ARCHIVE_DAYS" -delete 2>/dev/null || true

echo "[$(date)] Log rotation complete."

HB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/heartbeat.sh"
[ -x "$HB" ] && "$HB" rotate-logs 2>/dev/null || true
exit 0
