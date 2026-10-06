#!/usr/bin/env bash
# cost-dashboard.sh: quick observability dashboard for your Claude Code setup.
#
# Usage: cost-dashboard.sh [days]        (default 7)
# Shows: ccusage summary, RTK savings (if installed), sessions per project,
# blocked-command count (if a security log exists), configured MCP servers, agents.
#
# Environment: CLAUDE_DIR (default $HOME/.claude), SECURITY_LOG (default $CLAUDE_DIR/security.log)
# Dependencies: optional ccusage, rtk, python3

set -uo pipefail

DAYS="${1:-7}"
case "$DAYS" in ''|*[!0-9]*) echo "Usage: $0 [days]" >&2; exit 1 ;; esac
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
PROJECTS_DIR="$CLAUDE_DIR/projects"
SECURITY_LOG="${SECURITY_LOG:-$CLAUDE_DIR/security.log}"
TODAY=$(date +%Y-%m-%d)

BOLD=$'\033[1m'; DIM=$'\033[2m'; BLUE=$'\033[0;34m'; RESET=$'\033[0m'
rule="=================================================="

echo
echo "${BOLD}$rule${RESET}"
echo "${BOLD}  Claude Code observability dashboard${RESET}"
echo "${DIM}  Last ${DAYS} days, generated ${TODAY}${RESET}"
echo "${BOLD}$rule${RESET}"
echo

echo "${BLUE}${BOLD}[1] Global usage (ccusage)${RESET}"
if command -v ccusage >/dev/null 2>&1; then
  ccusage 2>/dev/null || echo "  (ccusage: no data)"
else
  echo "  ccusage not installed (npm i -g ccusage)"
fi
echo

echo "${BLUE}${BOLD}[2] RTK savings${RESET}"
if command -v rtk >/dev/null 2>&1; then
  rtk gain 2>/dev/null | head -20 || echo "  (no RTK data)"
else
  echo "  rtk not installed (optional)"
fi
echo

echo "${BLUE}${BOLD}[3] Sessions per project (${DAYS}d)${RESET}"
if [ -d "$PROJECTS_DIR" ]; then
  for project_dir in "$PROJECTS_DIR"/*/; do
    [ -d "$project_dir" ] || continue
    name=$(basename "$project_dir" | sed 's|^-Users-[^-]*-||; s|^-home-[^-]*-||')
    # Session transcripts modified within the window.
    count=$(find "$project_dir" -maxdepth 1 -name "*.jsonl" -mtime "-${DAYS}" 2>/dev/null | wc -l | tr -d ' ')
    [ "$count" -gt 0 ] && printf "  %-50s %s sessions\n" "${name:0:50}" "$count"
  done
else
  echo "  no $PROJECTS_DIR"
fi
echo

echo "${BLUE}${BOLD}[4] Blocked commands today${RESET}"
if [ -f "$SECURITY_LOG" ]; then
  blocked=$(grep "$TODAY" "$SECURITY_LOG" 2>/dev/null | grep -c "BLOCKED" || true)
  echo "  ${blocked:-0} (from $SECURITY_LOG)"
else
  echo "  no security log at $SECURITY_LOG"
fi
echo

echo "${BLUE}${BOLD}[5] MCP servers${RESET}"
for cfg in "$CLAUDE_DIR/mcp.json" "$HOME/.claude.json"; do
  [ -f "$cfg" ] || continue
  python3 - "$cfg" <<'PY' 2>/dev/null || echo "  (cannot read $cfg)"
import json, sys
cfg = json.load(open(sys.argv[1]))
servers = cfg.get("mcpServers", {})
for n in servers:
    print("  - %s" % n)
print("  Total: %d server(s) in %s" % (len(servers), sys.argv[1]))
PY
done
echo

echo "${BLUE}${BOLD}[6] Agents${RESET}"
if [ -d "$CLAUDE_DIR/agents" ]; then
  n=$(find "$CLAUDE_DIR/agents" -maxdepth 1 -name "*.md" | wc -l | tr -d ' ')
  echo "  $n agent(s) in $CLAUDE_DIR/agents/"
  find "$CLAUDE_DIR/agents" -maxdepth 1 -name "*.md" -exec basename {} .md \; | sort | sed 's/^/  - /'
else
  echo "  none"
fi
echo
echo "${DIM}  Tip: ccusage session, rtk gain --history${RESET}"
echo
