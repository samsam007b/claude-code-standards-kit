#!/usr/bin/env bash
# PreToolUse hook: guard-file-tamper-guard   (BLOCKING, security guard)
#
# Protects the files of the marketplace-vetting system (the guard hooks, their shared
# confirmation lib, their test suite, the trust registry, and settings.json itself) against
# modification, through Edit/Write/NotebookEdit AND through Bash (echo >, sed -i, cp, mv, tee,
# python -c ... .write(...), and so on). Without this, a compromised skill or third-party
# content could simply disable the protection by overwriting a hook instead of trying to get
# around it. Writing through Bash needs coverage too: a raw redirection would bypass a guard
# that only watches Edit/Write.
#
# Event / matcher : PreToolUse / Bash|Edit|Write|NotebookEdit   (timeout 340 in settings)
# Exit codes      : 0 allow, 2 block.
# Flow            : write to a protected path -> native OS dialog -> physical click allows
#                   (fails closed when no dialog is available). Reads stay allowed.
# Bypass          : none by environment variable.
# Env             : CLAUDE_HOME (default ~/.claude)
#                   CLAUDE_TAMPER_EXTRA_PATHS (colon-separated extra absolute paths to protect)
#
# Limits (honest): a Bash command that builds the path dynamically (variables, base64) can
# evade the literal path match. This is a speed bump with a human gate, not a sandbox.

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
source "$HOOK_DIR/lib/human-confirm-dialog.sh"
source "$HOOK_DIR/lib/hook-input.sh"

PROTECTED_PATHS=(
  "$CLAUDE_HOME/hooks/plugin-script-exec-guard.sh"
  "$CLAUDE_HOME/hooks/plugin-script-exec-allowlist.txt"
  "$CLAUDE_HOME/hooks/marketplace-add-guard.sh"
  "$CLAUDE_HOME/hooks/mcp-tool-trust-gate.sh"
  "$CLAUDE_HOME/hooks/guard-file-tamper-guard.sh"
  "$CLAUDE_HOME/hooks/lib/human-confirm-dialog.sh"
  "$CLAUDE_HOME/hooks/lib/plugin-allowlist-check.py"
  "$CLAUDE_HOME/hooks/lib/trust-registry-check.py"
  "$CLAUDE_HOME/hooks/tests/test-marketplace-vetting.sh"
  "$CLAUDE_HOME/settings.json"
  "$CLAUDE_HOME/skills/marketplace-vetting/TRUST-REGISTRY.md"
)
if [[ -n "${CLAUDE_TAMPER_EXTRA_PATHS:-}" ]]; then
  IFS=':' read -r -a _extra <<< "$CLAUDE_TAMPER_EXTRA_PATHS"
  PROTECTED_PATHS+=("${_extra[@]}")
fi

hook_read_input
TOOL_NAME="$(hook_get tool_name)"

if [[ "$TOOL_NAME" == "Edit" || "$TOOL_NAME" == "Write" || "$TOOL_NAME" == "NotebookEdit" ]]; then
  FILE_PATH="$(hook_get tool_input.file_path)"
  [[ -n "$FILE_PATH" ]] || FILE_PATH="$(hook_get tool_input.notebook_path)"

  IS_PROTECTED=false
  for p in "${PROTECTED_PATHS[@]}"; do
    [[ -n "$p" && "$FILE_PATH" == "$p" ]] && { IS_PROTECTED=true; break; }
  done
  [[ "$IS_PROTECTED" == "true" ]] || exit 0

  if human_confirm_dialog "guard-file-tamper-guard: modification requested on $FILE_PATH, a file of the marketplace-vetting protection system. Confirm only if this change is intentional." 300; then
    exit 0
  fi
  {
    echo "BLOCKED by guard-file-tamper-guard: attempt to modify $FILE_PATH (dialog not confirmed, expired, or unavailable)."
    echo "This file is part of the marketplace-vetting protection system: a modification that is not physically confirmed is never allowed."
  } >&2
  exit 2
fi

if [[ "$TOOL_NAME" == "Bash" ]]; then
  CMD="$(hook_get tool_input.command)"

  TARGETS_PROTECTED=false
  for p in "${PROTECTED_PATHS[@]}"; do
    [[ -n "$p" && "$CMD" == *"$p"* ]] && { TARGETS_PROTECTED=true; break; }
  done
  [[ "$TARGETS_PROTECTED" == "true" ]] || exit 0

  # Real write verbs (cat/grep/ls/head/tail/diff/wc stay allowed)
  if ! printf '%s' "$CMD" | grep -qE '(^|[;&|]|\s)(sed|cp|mv|tee|truncate|rm|dd|awk)\b|>>?[^&]|\.write\(|open\([^)]*["\x27]w'; then
    exit 0
  fi

  if human_confirm_dialog "guard-file-tamper-guard: Bash command that writes to a file of the marketplace-vetting protection system: $CMD. Confirm only if this change is intentional." 300; then
    exit 0
  fi
  {
    echo "BLOCKED by guard-file-tamper-guard: Bash command trying to write to a protected file (dialog not confirmed, expired, or unavailable)."
    echo "Command: $CMD"
  } >&2
  exit 2
fi

exit 0
