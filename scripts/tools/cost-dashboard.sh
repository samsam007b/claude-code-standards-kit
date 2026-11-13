#!/usr/bin/env bash
# cost-dashboard.sh — Observability dashboard: token usage + cost per session
# Usage: bash ~/.claude/scripts/cost-dashboard.sh [--days N] [--project NAME]

set -euo pipefail

DAYS=${1:-7}
CLAUDE_DIR="$HOME/.claude"
PROJECTS_DIR="$CLAUDE_DIR/projects"
TODAY=$(date +%Y-%m-%d)

# Colors
BOLD='\033[1m'
DIM='\033[2m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
RESET='\033[0m'

echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BOLD}  Claude Code — Dashboard Observabilité${RESET}"
echo -e "${DIM}  Période: ${DAYS} derniers jours · Généré le ${TODAY}${RESET}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# ── SECTION 1: ccusage summary ──────────────────────────────────────────────
echo -e "${BLUE}${BOLD}[1] Usage global (ccusage)${RESET}"
if command -v ccusage &>/dev/null; then
  ccusage 2>/dev/null || echo "  (ccusage: pas de données pour cette session)"
else
  echo "  ccusage non disponible"
fi
echo ""

# ── SECTION 2: RTK savings ──────────────────────────────────────────────────
echo -e "${BLUE}${BOLD}[2] Économies RTK (token-killer)${RESET}"
if command -v rtk &>/dev/null; then
  rtk gain 2>/dev/null | head -20 || echo "  (pas de données RTK)"
else
  echo "  rtk non disponible"
fi
echo ""

# ── SECTION 3: Sessions par projet ──────────────────────────────────────────
echo -e "${BLUE}${BOLD}[3] Sessions par projet (${DAYS}j)${RESET}"
if [ -d "$PROJECTS_DIR" ]; then
  declare -A project_sessions
  cutoff=$(date -v-${DAYS}d +%Y-%m-%d 2>/dev/null || date -d "${DAYS} days ago" +%Y-%m-%d 2>/dev/null || echo "2000-01-01")

  for project_dir in "$PROJECTS_DIR"/*/; do
    project_name=$(basename "$project_dir" | sed -E 's/-Users-[^-]+-/~\//g' | sed 's/-Desktop-/\/Desktop\//g' | sed 's/-/ /g')
    session_count=0

    # Count JSONL files modified in last N days
    if [ -d "$project_dir" ]; then
      while IFS= read -r -d '' f; do
        file_date=$(date -r "$f" +%Y-%m-%d 2>/dev/null || echo "1970-01-01")
        if [[ "$file_date" > "$cutoff" ]] || [[ "$file_date" == "$cutoff" ]]; then
          ((session_count++))
        fi
      done < <(find "$project_dir" -name "*.jsonl" -print0 2>/dev/null)
    fi

    if [ "$session_count" -gt 0 ]; then
      printf "  %-50s %s sessions\n" "${project_name:0:50}" "$session_count"
    fi
  done
fi
echo ""

# ── SECTION 4: Hooks fired (last 24h) ───────────────────────────────────────
echo -e "${BLUE}${BOLD}[4] Hook activity (dernières 24h)${RESET}"
hook_fires=$(find /tmp -name "claude-stop-hook-fired-*" -newer /tmp 2>/dev/null | wc -l | tr -d ' ')
echo "  Stop hooks déclenchés: ${hook_fires}"

if [ -f "$CLAUDE_DIR/security.log" ]; then
  blocked_today=$(grep "$(date +%Y-%m-%d)" "$CLAUDE_DIR/security.log" 2>/dev/null | grep -c "BLOCKED" || echo 0)
  echo "  Commandes bloquées aujourd'hui: ${blocked_today}"
fi
echo ""

# ── SECTION 5: MCP status ───────────────────────────────────────────────────
echo -e "${BLUE}${BOLD}[5] MCP Servers configurés${RESET}"
if [ -f "$CLAUDE_DIR/mcp.json" ]; then
  python3 -c "
import json
with open('$CLAUDE_DIR/mcp.json') as f:
  cfg = json.load(f)
servers = cfg.get('mcpServers', {})
for name in servers:
  print(f'  ✓ {name}')
print(f'  Total: {len(servers)} serveurs')
" 2>/dev/null || echo "  (erreur lecture mcp.json)"
fi
echo ""

# ── SECTION 6: Agents disponibles ───────────────────────────────────────────
echo -e "${BLUE}${BOLD}[6] Agents disponibles${RESET}"
if [ -d "$CLAUDE_DIR/agents" ]; then
  agent_count=$(ls "$CLAUDE_DIR/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
  echo "  ${agent_count} agents dans ~/.claude/agents/"
  ls "$CLAUDE_DIR/agents/"*.md 2>/dev/null | xargs -I{} basename {} .md | sed 's/^/  · /'
fi
echo ""

# ── SECTION 7: Veille stats ──────────────────────────────────────────────────
echo -e "${BLUE}${BOLD}[7] Veille — fichiers générés (30j)${RESET}"
VEILLE_DIR="$HOME/Desktop/Setup claude sam/veille/notes/daily"
if [ -d "$VEILLE_DIR" ]; then
  daily_count=$(find "$VEILLE_DIR" -name "*.md" -newer "$(date -v-30d +%Y-%m-%d 2>/dev/null || echo /dev/null)" 2>/dev/null | wc -l | tr -d ' ')
  total_count=$(ls "$VEILLE_DIR"/*.md 2>/dev/null | wc -l | tr -d ' ')
  echo "  Daily digests total: ${total_count}"
  echo "  Derniers 30j: ${daily_count}"
  latest=$(ls -t "$VEILLE_DIR"/*.md 2>/dev/null | head -1 | xargs basename 2>/dev/null || echo "aucun")
  echo "  Dernier: ${latest}"
fi
echo ""

echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${DIM}  Astuce: ccusage session · rtk gain --history · rtk discover${RESET}"
echo ""
