#!/bin/bash
# PreToolUse hook — team-git-guard
# Protège les opérations git dangereuses en collaboration multi-agents.
# No-op silencieux tant que .claude/team-registry.md n'existe pas dans le repo
# (== team-init.sh jamais lancé sur ce projet) — capacité disponible, jamais forcée.
# Porté depuis experiments/team-coordination/ (contrat $TOOL_INPUT/JSON status
# incompatible avec le hook system réel) vers le contrat stdin JSON + exit code.

INPUT=$(cat)

read -r TOOL_NAME CMD <<< "$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    name = d.get('tool_name', '')
    cmd = d.get('tool_input', {}).get('command', '').replace(chr(10), ' ')
    print(name, cmd[:200])
except Exception:
    print('', '')
" 2>/dev/null)"

[[ "$TOOL_NAME" != "Bash" ]] && exit 0
echo "$CMD" | grep -qE '^\s*git\s+' || exit 0

GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
[[ -z "$GIT_ROOT" ]] && exit 0

REGISTRY_FILE="$GIT_ROOT/.claude/team-registry.md"
[[ ! -f "$REGISTRY_FILE" ]] && exit 0

CMD_FULL=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    print(json.load(sys.stdin).get('tool_input', {}).get('command', ''))
except Exception:
    print('')
" 2>/dev/null)

block() {
  echo "TEAM GUARD: $1"
  exit 2
}

# --- Hard blocks ---
echo "$CMD_FULL" | grep -qE 'git\s+add\s+(\.|--all|-A)\s*$' && \
  block "'git add .' interdit en projet multi-agents. Stage des fichiers précis : git add path/to/file. Vérifie .claude/team-registry.md."

echo "$CMD_FULL" | grep -qE 'git\s+push\s+.*--force' && \
  block "Force push interdit — pourrait détruire le travail d'autres agents."

echo "$CMD_FULL" | grep -qE 'git\s+reset\s+--hard' && \
  block "Hard reset interdit — détruirait du travail non commité d'autres agents."

echo "$CMD_FULL" | grep -qE 'git\s+clean\s+-[fd]' && \
  block "git clean interdit — supprimerait des fichiers non trackés d'autres agents."

# --- Soft checks (avertissement, non bloquant) ---
ACTIVE_AGENTS=$(grep -cE '^\| agent-[a-z0-9]+-[0-9]+' "$REGISTRY_FILE" 2>/dev/null || echo "0")

if [[ "$ACTIVE_AGENTS" -gt "0" ]] && echo "$CMD_FULL" | grep -qE 'git\s+commit'; then
  echo "TEAM GUARD (info) : $ACTIVE_AGENTS agent(s) actif(s) dans le registre. Vérifie que seuls tes fichiers claimed sont stagés avant de commit." >&2
fi

if [[ "$ACTIVE_AGENTS" -gt "0" ]] && echo "$CMD_FULL" | grep -qE 'git\s+(merge|rebase)'; then
  echo "TEAM GUARD (info) : $ACTIVE_AGENTS agent(s) actif(s) — merge/rebase peut entrer en conflit avec du travail non commité. Coordonne d'abord via .claude/team-registry.md." >&2
fi

exit 0
