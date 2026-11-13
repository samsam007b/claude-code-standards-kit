#!/bin/bash
# Cleanup orphaned node processes (tsc, jest) when a Claude Code session ends.
# These processes are spawned by Claude agents and can accumulate if not cleaned up.

# Kill orphaned tsc --noEmit processes
pids_tsc=$(ps -eo pid,command | grep '[n]ode.*tsc --noEmit' | awk '{print $1}')
if [ -n "$pids_tsc" ]; then
  echo "$pids_tsc" | xargs kill 2>/dev/null
fi

# Kill orphaned jest processes
pids_jest=$(ps -eo pid,command | grep '[n]ode.*jest' | grep -v 'jest.*watch' | awk '{print $1}')
if [ -n "$pids_jest" ]; then
  echo "$pids_jest" | xargs kill 2>/dev/null
fi

# Kill orphaned next dev servers that might be leftover
pids_next=$(ps -eo pid,command | grep '[n]ode.*next dev' | awk '{print $1}')
if [ -n "$pids_next" ]; then
  echo "$pids_next" | xargs kill 2>/dev/null
fi
