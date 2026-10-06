#!/usr/bin/env python3
"""PreToolUse hook: memory-novelty-gate   (ADVISORY, never blocks, fail-open)

Before an `mcp__memory__add_observations` call, compares every new observation with the
existing observations of the same entity (difflib similarity). When a close one already exists,
it warns on stderr instead of letting a paraphrased duplicate pile up silently. The MCP memory
server has no novelty gating of its own, so it is wired on the client side.

Event / matcher : PreToolUse / mcp__memory__add_observations   (timeout 3)
Exit codes      : always 0. A false positive (a legitimate update of a fact that changed) must
                  never be blocked, only flagged.
Environment:
  MEMORY_FILE_PATH             path of the memory server's jsonl store
                               (default ~/.claude-memory/memory.jsonl, point it at your server's file)
  CLAUDE_NOVELTY_THRESHOLD     similarity ratio 0..1 that triggers the warning (default 0.62)
"""
import difflib
import json
import os
import sys

MEMORY_FILE = os.path.expanduser(os.environ.get("MEMORY_FILE_PATH", "~/.claude-memory/memory.jsonl"))
try:
    SIMILARITY_THRESHOLD = float(os.environ.get("CLAUDE_NOVELTY_THRESHOLD", "0.62"))
except ValueError:
    SIMILARITY_THRESHOLD = 0.62


def load_entities():
    entities = {}
    if not os.path.exists(MEMORY_FILE):
        return entities
    with open(MEMORY_FILE, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                d = json.loads(line)
            except json.JSONDecodeError:
                continue
            if d.get("type") == "entity":
                entities[d.get("name", "")] = d.get("observations", [])
    return entities


def strip_prefix(obs):
    # drop a leading [YYYY-MM-DD] or [tag] prefix before comparing
    if obs.startswith("[") and "]" in obs:
        return obs.split("]", 1)[1].strip()
    return obs


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    observations_input = (data.get("tool_input", {}) or {}).get("observations", [])
    if not observations_input:
        sys.exit(0)

    try:
        entities = load_entities()
    except Exception:
        sys.exit(0)
    warnings = []

    for item in observations_input:
        entity_name = item.get("entityName", "")
        existing = [strip_prefix(o) for o in entities.get(entity_name, []) if isinstance(o, str)]
        for new_obs in item.get("contents", []):
            new_clean = strip_prefix(new_obs)
            for old in existing:
                ratio = difflib.SequenceMatcher(None, new_clean, old).ratio()
                if ratio >= SIMILARITY_THRESHOLD:
                    warnings.append(
                        f"[{entity_name}] new observation is {int(ratio * 100)}% similar to an existing one:\n"
                        f"  new     : {new_obs[:120]}\n"
                        f"  existing: {old[:120]}"
                    )
                    break

    if warnings:
        print("NOVELTY-GATE (warning, not blocking): possibly redundant observations:", file=sys.stderr)
        for w in warnings:
            print(w, file=sys.stderr)
        print(
            "If it is really new, ignore this. If it updates a fact that changed, prefer "
            "delete_observations + add_observations over accumulating variants.",
            file=sys.stderr,
        )

    sys.exit(0)


if __name__ == "__main__":
    main()
