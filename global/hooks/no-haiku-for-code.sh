#!/usr/bin/env bash
# PreToolUse hook: no-haiku-for-code   (BLOCKING, deterministic, fail-open on parse error)
#
# Blocks an Agent/Task call that requests a small model for a subagent that is not on a
# read-only whitelist. Turns the prose rule "never use the small model to write or modify code,
# minimum mid-tier" (about 70% adherence as prose) into a deterministic check.
#
# Event / matcher : PreToolUse / Task|Agent            (timeout 3)
# Exit codes      : 0 allow, 2 block.
# Env (all optional):
#   CLAUDE_SMALL_MODEL_PATTERN  case-insensitive substring/regex of the model name to police
#                               (default: haiku)
#   CLAUDE_SMALL_MODEL_ALLOW    regex of subagent_type values allowed to use it, i.e. read-only
#                               research/reading agents
#                               (default: ^(researcher|doc-reader|Explore|.*-researcher|.*-reader)$)
#   CLAUDE_ALLOW_SMALL_MODEL=1  bypass for the session.

[[ "${CLAUDE_ALLOW_SMALL_MODEL:-0}" == "1" ]] && exit 0

MODEL_PATTERN="${CLAUDE_SMALL_MODEL_PATTERN:-haiku}"
ALLOW_REGEX="${CLAUDE_SMALL_MODEL_ALLOW:-^(researcher|doc-reader|Explore|.*-researcher|.*-reader)$}"

INPUT="$(cat)"

OUT="$(printf '%s' "$INPUT" | python3 -c '
import sys, json
try:
    d = json.load(sys.stdin)
    inp = d.get("tool_input", {}) or {}
    print((inp.get("model") or "").lower())
    print(inp.get("subagent_type") or "")
except Exception:
    print(""); print("")
' 2>/dev/null)"
MODEL="$(printf '%s\n' "$OUT" | sed -n 1p)"
SUBAGENT="$(printf '%s\n' "$OUT" | sed -n 2p)"

printf '%s' "$MODEL" | grep -qiE "$MODEL_PATTERN" || exit 0
printf '%s' "$SUBAGENT" | grep -qE "$ALLOW_REGEX" && exit 0

echo "BLOCKED: model '$MODEL' requested for subagent '${SUBAGENT:-<none>}', which is not on the read-only whitelist ($ALLOW_REGEX). Rule: never use the small model to write or modify code, use a mid-tier model or above. If this agent only reads or researches, add it to CLAUDE_SMALL_MODEL_ALLOW, or set CLAUDE_ALLOW_SMALL_MODEL=1 for this session." >&2
exit 2
