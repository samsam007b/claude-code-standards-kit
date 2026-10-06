#!/usr/bin/env bash
# UserPromptSubmit hook: detect-frustration-pattern   (ADVISORY, never blocks)
#
# Scores a prompt for frustration or "scrap and redo" signals (repeated exclamation marks,
# swearing, "that's nonsense", a prompt that opens with "no", "start over"...). At or above the
# threshold it prints a one-line hint on stdout (shown to the model as added context) suggesting
# that the incident be captured as a lesson or a preventive hook, and optionally appends a
# record to a jsonl log so unprocessed signals can be reviewed later.
#
# Event / matcher : UserPromptSubmit (no matcher)       (timeout 3)
# Exit codes      : always 0.
# Env:
#   CLAUDE_FRUSTRATION_HOOK=off        disable the hook
#   CLAUDE_FRUSTRATION_THRESHOLD       score that triggers the hint (default 3)
#   CLAUDE_FRUSTRATION_EXTRA_REGEX     extra extended regex (case-insensitive) worth +3, for
#                                      your own language or vocabulary
#   CLAUDE_FRUSTRATION_LOG             jsonl path to append records to (default: no logging)
#   CLAUDE_FRUSTRATION_HINT            text printed after the score
#                                      (default: "consider capturing this as a lesson or a preventive hook")

[[ "${CLAUDE_FRUSTRATION_HOOK:-on}" == "off" ]] && exit 0

INPUT="$(cat)"
PROMPT="$(printf '%s' "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('prompt',''))" 2>/dev/null)"
[[ -n "$PROMPT" ]] || exit 0

THRESHOLD="${CLAUDE_FRUSTRATION_THRESHOLD:-3}"
SCORE=0
SIGNALS=""

hit() { # hit <points> <label> <regex>
  if printf '%s' "$PROMPT" | grep -iqE "$3"; then
    SCORE=$((SCORE + $1))
    SIGNALS="${SIGNALS} [$2]"
  fi
}

hit 2 'exclamation burst'  '!{3,}'
hit 3 'nonsense'           "(that'?s|this is) (complete )?(nonsense|garbage|rubbish)|what the hell|makes no sense"
hit 2 'swearing'           '\b(damn|dammit|wtf|ffs|shit|crap)\b'
hit 1 'opens with no'      '^[[:space:]]*no[,.! ]'
hit 1 'you do not get it'  "you (still )?(don'?t|do not) (understand|get it)|i (already )?(told|said) you"
hit 3 'scrap and redo'     '\b(scrap (this|that|it)|start over|redo (this|that|it)|from scratch|throw (this|that) away)\b'
if [[ -n "${CLAUDE_FRUSTRATION_EXTRA_REGEX:-}" ]]; then
  hit 3 'custom' "$CLAUDE_FRUSTRATION_EXTRA_REGEX"
fi

if [[ "$SCORE" -ge "$THRESHOLD" ]]; then
  echo "Frustration signal (score ${SCORE}):${SIGNALS}"
  echo "  -> ${CLAUDE_FRUSTRATION_HINT:-consider capturing this as a lesson or a preventive hook}"

  LOG="${CLAUDE_FRUSTRATION_LOG:-}"
  if [[ -n "$LOG" ]]; then
    mkdir -p "$(dirname "$LOG")" 2>/dev/null
    # Pass values through the environment, never interpolate them into the python source.
    FR_SCORE="$SCORE" FR_SIGNALS="$SIGNALS" FR_PROMPT="$PROMPT" FR_LOG="$LOG" python3 -c '
import json, os, datetime
entry = {
  "timestamp": datetime.datetime.now().isoformat(),
  "score": int(os.environ["FR_SCORE"]),
  "signals": os.environ["FR_SIGNALS"].strip(),
  "prompt_excerpt": " ".join(os.environ["FR_PROMPT"].split())[:200],
}
with open(os.environ["FR_LOG"], "a") as f:
    f.write(json.dumps(entry, ensure_ascii=False) + "\n")
' 2>/dev/null
  fi
fi

exit 0
