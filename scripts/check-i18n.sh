#!/usr/bin/env bash
# Parity check: English is the source, French is the mirror.
# Fails if a French file is missing or its structure (## headings, table rows) drifts from the English one.
# Usage: scripts/check-i18n.sh   (exit 0 = parity, exit 1 = drift)
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ERR=0

fail() { echo "  ✗ $1"; ERR=$((ERR+1)); }
ok()   { echo "  ✓ $1"; }

count() { grep -c -E "$2" "$1" || true; }

compare() { # compare <en> <fr> <label>
  local en="$1" fr="$2" label="$3"
  if [ ! -f "$fr" ]; then fail "$label: missing French file ($fr)"; return; fi
  local ok_=1
  [ "$(count "$en" '^## ')" = "$(count "$fr" '^## ')" ] || { fail "$label: number of '##' sections differs"; ok_=0; }
  [ "$(count "$en" '^\|')" = "$(count "$fr" '^\|')" ] || { fail "$label: number of table rows differs"; ok_=0; }
  [ "$(count "$en" '^- \*\*')" = "$(count "$fr" '^- \*\*')" ] || { fail "$label: number of card fields differs"; ok_=0; }
  [ "$ok_" = 1 ] && ok "$label"
}

for s in welcome explain pro-samuel; do
  compare "$ROOT/skills/$s/SKILL.md" "$ROOT/skills/$s/SKILL.fr.md" "skill $s"
done
compare "$ROOT/docs/glossary/en/README.md" "$ROOT/docs/glossary/fr/README.md" "glossary"

# Glossary: same ordered list of term titles.
diff <(grep '^## ' "$ROOT/docs/glossary/en/README.md") <(grep '^## ' "$ROOT/docs/glossary/fr/README.md") >/dev/null \
  && ok "glossary term titles identical" || fail "glossary term titles differ"

[ -f "$ROOT/README.fr.md" ] && ok "README.fr.md present" || fail "README.fr.md missing"

# No em dash in the starter content.
if grep -l -E '—|–' "$ROOT"/skills/{welcome,explain,pro-samuel}/SKILL*.md "$ROOT"/docs/glossary/*/README.md "$ROOT"/README.fr.md "$ROOT"/docs/WINDOWS.md 2>/dev/null; then
  fail "em dash found in starter content"
else ok "no em dash"; fi

if [ "$ERR" -gt 0 ]; then echo "i18n: $ERR drift(s)"; exit 1; fi
echo "i18n: parity OK"
