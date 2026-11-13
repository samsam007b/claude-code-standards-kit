#!/bin/bash
# Hook PostToolUse pour Agent : avertit si un subagent retourne un résultat trop long
# Objectif : empêcher les dumps bruts qui polluent le contexte Opus

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

# Ne s'applique qu'aux appels Agent
if [ "$tool_name" = "Agent" ]; then
  output=$(echo "$input" | jq -r '.tool_output // empty')
  if [ -n "$output" ]; then
    # Compter les mots approximativement (proxy pour les tokens)
    word_count=$(echo "$output" | wc -w | tr -d ' ')

    if [ "$word_count" -gt 800 ]; then
      echo "⚠️ ALERTE TOKEN-ECONOMY : Le subagent a retourné ~${word_count} mots (~$((word_count * 4 / 3)) tokens). Le pattern 2 phases impose max 400 tokens. Rappel : résumé court + tableau 'à approfondir', pas de dump complet." >&2
    fi
  fi
fi

# Toujours laisser passer (informatif, pas bloquant)
echo "{}"
