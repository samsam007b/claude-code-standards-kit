#!/bin/bash
# PostToolUse hook for Agent: warns if a subagent returns an overly long result
# Goal: prevent raw dumps that pollute the main model's context

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

# Only applies to Agent calls
if [ "$tool_name" = "Agent" ]; then
  output=$(echo "$input" | jq -r '.tool_output // empty')
  if [ -n "$output" ]; then
    # Count words approximately (proxy for tokens)
    word_count=$(echo "$output" | wc -w | tr -d ' ')

    if [ "$word_count" -gt 800 ]; then
      echo "⚠️ TOKEN-ECONOMY ALERT: the subagent returned ~${word_count} words (~$((word_count * 4 / 3)) tokens). The 2-phase pattern caps output at 400 tokens. Reminder: short summary + 'to dig deeper' table, no full dump." >&2
    fi
  fi
fi

# Always let it through (informational, non-blocking)
echo "{}"
