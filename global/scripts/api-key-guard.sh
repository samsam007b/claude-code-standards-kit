#!/usr/bin/env bash
# api-key-guard.sh: stop API keys from leaking into the wrong project.
#
# Event/matcher : PreToolUse on Write|Edit (reads the hook JSON on stdin).
# Exit codes    : 0 = allow (optional reminder on stderr), 2 = block (reason on stderr).
# Failure mode  : SECURITY GUARD for revoked keys (blocks), fail-open on internal errors
#                 (missing registry, missing python3).
#
# Reads a registry (default: $HOME/.claude/secrets-registry.json, override with
# API_KEY_GUARD_REGISTRY). See secrets-registry.example.json:
#   {
#     "known_projects": ["web-app", "mobile-app"],           # substrings matched against the path
#     "keys":    [{"id","prefix","owner","role","allowed_projects":[...],"notes"}],
#     "revoked": [{"id","prefix","reason","blocked_everywhere":true}]
#   }
# Rules:
#   1. A revoked key prefix (blocked_everywhere) is rejected in any file.
#   2. A live key prefix is rejected when the target path matches a known project
#      that is not in the key's allowed_projects.
#
# Dependencies: python3

set -uo pipefail

REGISTRY="${API_KEY_GUARD_REGISTRY:-$HOME/.claude/secrets-registry.json}"

[ -f "$REGISTRY" ] || exit 0
command -v python3 >/dev/null 2>&1 || exit 0

INPUT="$(cat 2>/dev/null || true)"
[ -n "$INPUT" ] || INPUT="${TOOL_INPUT:-}"
[ -n "$INPUT" ] || exit 0

REGISTRY="$REGISTRY" PWD_NOW="$PWD" python3 -c '
import json, os, sys

raw = sys.stdin.read()
try:
    reg = json.load(open(os.environ["REGISTRY"]))
except Exception:
    sys.exit(0)  # fail-open on a broken registry

try:
    data = json.loads(raw)
except Exception:
    data = {}
ti = data.get("tool_input", data) if isinstance(data, dict) else {}
path = ti.get("file_path", "") if isinstance(ti, dict) else ""
content = " ".join(str(ti.get(k, "")) for k in ("content", "new_string")) if isinstance(ti, dict) else raw
if not content.strip():
    content = raw

for r in reg.get("revoked", []):
    if r.get("blocked_everywhere") and r.get("prefix") and r["prefix"] in content:
        print("REVOKED KEY BLOCKED: id=%s prefix=%s. %s. This key must never be written anywhere; "
              "use the current key listed in the registry." % (r.get("id"), r["prefix"], r.get("reason", "")),
              file=sys.stderr)
        sys.exit(2)

context = path or os.environ.get("PWD_NOW", "")
project = ""
for p in reg.get("known_projects", []):
    if p.lower() in context.lower():
        project = p
        break

if project:
    for k in reg.get("keys", []):
        prefix = k.get("prefix")
        if not prefix or prefix not in content:
            continue
        allowed = [a.lower() for a in k.get("allowed_projects", [])]
        if not any(a in project.lower() or project.lower() in a for a in allowed):
            print("API KEY GUARD: key %s (owner: %s, role: %s) is not allowed in project %s. %s "
                  "Use the key meant for this project (see registry)."
                  % (k.get("id"), k.get("owner", "?"), k.get("role", "?"), project, k.get("notes", "")),
                  file=sys.stderr)
            sys.exit(2)
sys.exit(0)
' <<< "$INPUT"
exit $?
