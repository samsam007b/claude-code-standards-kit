#!/bin/bash
# CONTRACT-TOKEN-ECONOMY TE-5.1 — Monitor subagent output size
# PostToolUse hook (matcher: Agent)
# Alerts when a subagent returns more than 800 words (likely exceeding 400 token limit)

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

if [ "$tool_name" = "Agent" ]; then
  output=$(echo "$input" | jq -r '.tool_output // empty')
  word_count=$(echo "$output" | wc -w | tr -d ' ')

  if [ "$word_count" -gt 800 ]; then
    echo "WARNING TOKEN-ECONOMY: Subagent returned ${word_count} words (limit: 800). Consider tightening the prompt or splitting the query. See CONTRACT-TOKEN-ECONOMY TE-2.2." >&2
  fi
fi

# Always return valid JSON to not block the pipeline
echo "{}"
