#!/bin/bash
# Hook: check-http-blocking-await
# Détecte les awaits Supabase bloquants avant le return de la réponse HTTP
# dans les routes track/* (open, click, unsubscribe, bounce).
# Ces awaits retardent le retour du pixel/redirect → tracking incomplet.
# Bug-07 audit mai 2026.
#
# Volontairement PostToolUse : lit `git diff --cached` (état de staging git), pas `tool_input`.
# Ce n'est pas le même bug que les hooks migrés vers PreToolUse (audit 2026-07-10, Tier 1-3) —
# c'est un garde-fou post-commit légitime, pas un hook Claude Code cassé. Ne pas re-signaler.

set -euo pipefail

ERRORS=()
STAGED_FILES=$(git diff --cached --name-only 2>/dev/null || echo "")

if [ -z "$STAGED_FILES" ]; then
  exit 0
fi

TRACK_FILES=$(echo "$STAGED_FILES" | grep -E "\.(ts|tsx)$" | grep -E "src/app/api/track/" || true)

if [ -z "$TRACK_FILES" ]; then
  exit 0
fi

for file in $TRACK_FILES; do
  [ -f "$file" ] || continue

  # Cherche: await supabase.(...) avant return new Response(
  # dans la même fonction GET/POST — signal que la réponse HTTP est bloquée
  python3 - "$file" <<'PYEOF' 2>/dev/null && ERRORS+=("HTTP-BLOCKING-AWAIT: $file — await supabase.* bloquant avant return Response() dans route track. Utiliser fire-and-forget: void (async () => { await supabase... })().catch(console.error). Bug-07 audit mai 2026.")
import sys, re

content = open(sys.argv[1]).read()

# Find async function bodies
fn_pattern = re.compile(r'export async function (GET|POST)\s*\(.*?\)\s*\{', re.DOTALL)
for fn_match in fn_pattern.finditer(content):
    start = fn_match.end()
    # Extract function body (naive brace counting)
    depth = 1
    pos = start
    while pos < len(content) and depth > 0:
        if content[pos] == '{':
            depth += 1
        elif content[pos] == '}':
            depth -= 1
        pos += 1
    body = content[start:pos]

    # Check for blocking await supabase before return new Response(
    # Exclude patterns already wrapped in void (() => or .then()
    lines = body.split('\n')
    found_blocking_await = False
    found_return_response = False

    for i, line in enumerate(lines):
        stripped = line.strip()
        # Skip fire-and-forget patterns (void, .then, Promise.all in wrapper)
        if re.search(r'void\s*\(', stripped) or re.search(r'void\s+\(async', stripped):
            continue
        if re.search(r'^\s*//|^\s*\*', stripped):
            continue
        # Check for blocking await on supabase
        if re.search(r'\bawait\s+supabase\b', stripped) and not re.search(r'void\s*\(async', stripped):
            found_blocking_await = True
        # Check for return Response
        if re.search(r'return\s+(?:new\s+Response|Response\.json)', stripped):
            found_return_response = True

    # If both found and blocking await comes before return response
    if found_blocking_await and found_return_response:
        # More precise: find first blocking await line index and first return response line index
        await_lines = [i for i, l in enumerate(lines) if re.search(r'\bawait\s+supabase\b', l.strip()) and not re.search(r'void\s*\(', l)]
        return_lines = [i for i, l in enumerate(lines) if re.search(r'return\s+(?:new\s+Response|Response\.json)', l.strip())]
        if await_lines and return_lines:
            first_await = min(await_lines)
            first_return = min(return_lines)
            if first_await < first_return:
                sys.exit(1)

sys.exit(0)
PYEOF

done

if [ ${#ERRORS[@]} -gt 0 ]; then
  echo ""
  echo "╔══════════════════════════════════════════════════════════════════╗"
  echo "║  check-http-blocking-await — AWAIT BLOQUANT DANS TRACK ROUTE    ║"
  echo "╚══════════════════════════════════════════════════════════════════╝"
  echo ""
  for err in "${ERRORS[@]}"; do
    echo "  ✗ $err"
    echo ""
  done
  echo "  Pattern correct :"
  echo "  void (async () => { await supabase.from(...).update(...); })().catch(console.error);"
  echo "  return new Response(GIF_1X1, { ... }); // retourné immédiatement"
  echo ""
  echo "  Référence : feedback_b2b_code_patterns.md (bug 07)"
  echo ""
  exit 2
fi

exit 0
