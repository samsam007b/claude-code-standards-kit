#!/usr/bin/env bash
set -euo pipefail
# Installs the user-level layer (global/) into ~/.claude.
#
# Usage: bash global/install-global.sh [--dry-run] [--force] [--with-claude-md]
#   --dry-run          print what would happen, change nothing
#   --force            overwrite files that already exist (a timestamped backup is always taken first)
#   --with-claude-md   also install global/CLAUDE.md (by default it is copied to CLAUDE.kit.md for you to merge)
#
# Never deletes anything. Existing settings.json is merged, not replaced: hooks from
# global/hooks/settings-hooks.json are appended per event, skipping commands already present.

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${CLAUDE_HOME:-$HOME/.claude}"
DRY=0; FORCE=0; WITH_MD=0
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --force) FORCE=1 ;;
    --with-claude-md) WITH_MD=1 ;;
    -h|--help) sed -n 2,11p "$0"; exit 0 ;;
    *) echo "Unknown option: $a" >&2; exit 2 ;;
  esac
done

command -v jq >/dev/null || { echo "ERROR: jq is required (brew install jq / apt install jq)." >&2; exit 1; }

if ! command -v node >/dev/null; then
  echo "WARNING: node was not found on PATH." >&2
  echo "         global/hooks/validate-command.js (the main destructive-command guard: blocks" >&2
  echo "         hard reset, recursive force delete, force push, DROP TABLE and friends) is a" >&2
  echo "         Node script. Without node it will be silently inactive: the hook entry stays" >&2
  echo "         in settings.json but every PreToolUse call for it fails and Claude Code treats" >&2
  echo "         a failing hook as non-blocking, so the command runs anyway." >&2
  echo "         Install node (brew install node / apt install nodejs), then re-run this script" >&2
  echo "         or just re-check: command -v node." >&2
fi

STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$DEST/backups/kit-install-$STAMP"
run() { if [ "$DRY" = 1 ]; then echo "  [dry-run] $*"; else "$@"; fi; }

copy_tree() { # $1 = subfolder of global/
  local sub="$1" f rel target
  [ -d "$SRC/$sub" ] || return 0
  while IFS= read -r -d '' f; do
    rel="${f#"$SRC/"}"
    target="$DEST/$rel"
    if [ -e "$target" ] && [ "$FORCE" = 0 ]; then
      echo "  skip (exists): $rel"
      continue
    fi
    if [ -e "$target" ]; then
      run mkdir -p "$BACKUP/$(dirname "$rel")"
      run cp -p "$target" "$BACKUP/$rel"
    fi
    run mkdir -p "$(dirname "$target")"
    run cp -p "$f" "$target"
    case "$f" in *.sh|*.py|*.js|*.mjs) run chmod +x "$target" ;; esac
    echo "  installed: $rel"
  done < <(find "$SRC/$sub" -type f ! -name '.DS_Store' -print0)
}

echo "Installing user-level layer into $DEST"
run mkdir -p "$DEST"
for sub in hooks scripts skills commands agents; do copy_tree "$sub"; done

# CLAUDE.md: never silently replace the user's own instructions.
if [ "$WITH_MD" = 1 ] && [ ! -e "$DEST/CLAUDE.md" ]; then
  run cp "$SRC/CLAUDE.md" "$DEST/CLAUDE.md"; echo "  installed: CLAUDE.md"
else
  run cp "$SRC/CLAUDE.md" "$DEST/CLAUDE.kit.md"
  echo "  wrote CLAUDE.kit.md (merge the parts you want into your CLAUDE.md)"
fi

# settings.json: merge base + hooks.
SETTINGS="$DEST/settings.json"
HOOKS_JSON="$SRC/hooks/settings-hooks.json"
if [ -e "$SETTINGS" ]; then
  run mkdir -p "$BACKUP"; run cp -p "$SETTINGS" "$BACKUP/settings.json"
  BASE="$SETTINGS"
else
  BASE="$SRC/settings.example.json"
fi
if [ -f "$HOOKS_JSON" ]; then
  MERGED="$(jq -s '
    (.[0] | del(._comment)) as $base | (.[1].hooks // .[1]) as $new
    | $base * {hooks: (
        reduce ($new | keys[]) as $ev (($base.hooks // {});
          .[$ev] = ((.[$ev] // []) as $cur
            | ([$cur[].hooks[]?.command]) as $have
            | $cur + [ $new[$ev][] | .hooks |= map(select(.command as $c | ($have | index($c)) | not)) | select(.hooks | length > 0) ]))
      )}' "$BASE" "$HOOKS_JSON")"
  if [ "$DRY" = 1 ]; then
    echo "  [dry-run] would write merged settings.json ($(echo "$MERGED" | jq '[.hooks[][].hooks[]] | length') hook entries)"
  else
    echo "$MERGED" > "$SETTINGS"; echo "  merged hooks into settings.json"
  fi
fi

[ -d "$BACKUP" ] && echo "Backup of replaced files: $BACKUP"
echo
echo "Next steps:"
echo "  1. Read $DEST/hooks/README.md and disable any hook you do not want (settings.json > hooks)."
echo "  2. Merge CLAUDE.kit.md into your CLAUDE.md, replace the <PLACEHOLDERS>."
echo "  3. Required: jq (already checked above), node (runs validate-command.js, the main"
echo "     destructive-command guard: without it that hook is inactive). Optional: rtk, ccusage,"
echo "     age (env-vault), python3 (several hooks/scripts)."
echo "  4. Run: bash $DEST/hooks/tests/smoke-test-hooks.sh"
