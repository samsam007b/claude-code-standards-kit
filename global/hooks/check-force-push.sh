#!/usr/bin/env bash
# PreToolUse hook: check-force-push   (BLOCKING, fail-open on parse error)
#
# Blocks `git push --force` and `git push -f` on any branch: a force push can overwrite work in
# production or destroy shared history. `--force-with-lease` is allowed (it refuses to overwrite
# commits you have not seen).
#
# Event / matcher : PreToolUse / Bash                  (timeout 3)
# Exit codes      : 0 allow, 2 block.
# Bypass          : CLAUDE_ALLOW_FORCE_PUSH=1 for the session.
# Note            : validate-command.js blocks the same family of commands (plus other git
#                   destructive forms). Using both is redundant but harmless, this hook gives a
#                   focused message and its own bypass.

[[ "${CLAUDE_ALLOW_FORCE_PUSH:-0}" == "1" ]] && exit 0

INPUT="$(cat)"
CMD="$(printf '%s' "$INPUT" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null)"

# Strip the allowed lease form before testing, so "--force-with-lease" does not match "--force".
STRIPPED="$(printf '%s' "$CMD" | sed -E 's/--force-with-lease(=[^ ]*)?//g')"

if printf '%s' "$STRIPPED" | grep -qE 'git[[:space:]]+push' && printf '%s' "$STRIPPED" | grep -qE '(^|[[:space:]])(--force|-f)([[:space:]]|$)'; then
  {
    echo "BLOCKED: git push --force is not allowed."
    echo "  Risk: irreversible overwrite of shared history."
    echo "  Prefer: git push --force-with-lease. If a plain force push is really needed, ask the user"
    echo "  for explicit confirmation, then set CLAUDE_ALLOW_FORCE_PUSH=1."
  } >&2
  exit 2
fi

exit 0
