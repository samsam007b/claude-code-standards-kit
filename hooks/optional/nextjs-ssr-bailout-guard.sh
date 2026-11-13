#!/bin/bash
# PreToolUse hook: nextjs-ssr-bailout-guard
# Detects `dynamic(..., { ssr: false })` applied to a component that wraps {children}.
# Such a component cannot be server-rendered, so Next.js bails out of server rendering
# for EVERYTHING it contains (not just itself), and the content becomes invisible to
# crawlers that do not run JS (real bug observed: the homepage and all pages shipped
# 63 characters of visible HTML instead of several thousand, caused by an error-tracking
# provider loaded client-only).
#
# Advisory, non-blocking (exit 0 + stderr warning): the legitimate pattern (leaf modal/map/chart,
# without {children}) is far more common than the real bug, so a hard block would create
# too many false positives on a pattern that is otherwise correct in 95% of the repo's ssr:false uses.

INPUT=$(cat)

RESULT=$(echo "$INPUT" | python3 -c "
import sys, json, re

try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)

tool_input = d.get('tool_input', {})
file_path = tool_input.get('file_path', '')

if not re.search(r'\.(tsx|ts)$', file_path):
    sys.exit(0)

# Content to inspect: Write -> content, Edit -> new_string (+ existing file if available for context)
new_content = tool_input.get('content') or tool_input.get('new_string') or ''

full_content = new_content
try:
    with open(file_path, encoding='utf-8') as f:
        existing = f.read()
    full_content = existing + '\n' + new_content
except Exception:
    pass

if 'ssr: false' not in full_content and 'ssr:false' not in full_content:
    sys.exit(0)

# Variables assigned via dynamic(...) with ssr:false in their config
risky_names = []
for m in re.finditer(r'const\s+(\w+)\s*=\s*(?:nextDynamic|dynamic)\s*\(', full_content):
    name = m.group(1)
    window = full_content[m.end():m.end()+500]
    if re.search(r'ssr:\s*false', window):
        risky_names.append(name)

if not risky_names:
    sys.exit(0)

flagged = []
for name in risky_names:
    # Direct wrapping: {children} must be the very first JSX child found
    # right after the opening tag (whitespace/newlines tolerated, nothing else),
    # which avoids false positives where {children} appears further down the file for
    # a completely different component.
    # (?<!/) excludes self-closing tags <Name ... />
    wrap_pattern = re.compile(r'<' + re.escape(name) + r'(?:\s[^>]*)?(?<!/)>\s*\{children\}')
    if wrap_pattern.search(full_content):
        flagged.append(name)

if flagged:
    print('FLAGGED:' + ','.join(dict.fromkeys(flagged)))
" 2>/dev/null)

if [[ "$RESULT" == FLAGGED:* ]]; then
  NAMES="${RESULT#FLAGGED:}"
  echo "" >&2
  echo "⚠️  nextjs-ssr-bailout-guard: dynamic(..., { ssr: false }) appears to wrap {children}" >&2
  echo "" >&2
  echo "  Affected component(s): $NAMES" >&2
  echo "  An ssr:false component that wraps {children} blocks server rendering of EVERYTHING it" >&2
  echo "  contains, not just itself. If this component wraps part of the app" >&2
  echo "  (provider, layout), the pages below become invisible to non-JS crawlers." >&2
  echo "  Real bug already encountered: an error-tracking provider loaded client-only" >&2
  echo "  (cause of pages not indexed by Google)." >&2
  echo "" >&2
  echo "  If this component has no objective reason to be client-only (no browser API" >&2
  echo "  at module level, no SSR-incompatible lib), remove ssr:false. dynamic() without" >&2
  echo "  ssr:false still code-splits the JS, just without blocking SSR." >&2
  echo "" >&2
fi

exit 0
