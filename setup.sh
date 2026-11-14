#!/usr/bin/env bash
# Starter setup for Claude Code (macOS and Linux). Stage 1: machine tier.
# Stage 2 happens inside Claude Code with /welcome (or /pro-samuel).
#
# Usage: ./setup.sh [--lang en|fr] [--pro-samuel] [--dry-run]
#   --lang       language of the messages (default: from $LANG, else en)
#   --pro-samuel direct mode: one recap, one confirmation, no explanations
#   --dry-run    show what would be done, change nothing
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LANG_CODE="en"; case "${LANG:-}" in fr*) LANG_CODE="fr";; esac
PRO=0; DRY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --lang) LANG_CODE="${2:-en}"; shift 2;;
    --pro-samuel) PRO=1; shift;;
    --dry-run) DRY=1; shift;;
    -h|--help) sed -n '2,8p' "$0"; exit 0;;
    *) echo "Unknown option: $1" >&2; exit 2;;
  esac
done
[ "$LANG_CODE" = "fr" ] || LANG_CODE="en"

# t "<en>" "<fr>"
t() { if [ "$LANG_CODE" = "fr" ]; then printf '%s' "$2"; else printf '%s' "$1"; fi; }
say() { printf '%s\n' "$(t "$1" "$2")"; }
run() { if [ "$DRY" = 1 ]; then echo "  [dry-run] $*"; else "$@"; fi; }

ask() { # ask "<en>" "<fr>" -> 0 for yes
  local a; printf '%s [y/N] ' "$(t "$1" "$2")"; read -r a || a=""
  case "$a" in y|Y|yes|YES|o|O|oui|OUI) return 0;; *) return 1;; esac
}

OS="$(uname -s)"
case "$OS" in Darwin|Linux) ;; *) say "Unsupported system. On Windows use setup.ps1." "Système non pris en charge. Sous Windows, utilisez setup.ps1."; exit 1;; esac

have() { command -v "$1" >/dev/null 2>&1; }

# name | what it is (en) | what it is (fr) | install command
tool_info() {
  case "$1" in
    brew)   t "Homebrew: an installer for developer tools (like an app store you drive by typing)." "Homebrew : un installateur d'outils (comme un app store que l'on pilote en tapant).";;
    git)    t "Git: records every version of your files so you can go back." "Git : garde toutes les versions de vos fichiers pour pouvoir revenir en arrière.";;
    node)   t "Node.js: the engine Claude Code and Playwright run on." "Node.js : le moteur sur lequel tournent Claude Code et Playwright.";;
    python) t "Python: a language many scripts and tools use." "Python : un langage utilisé par de nombreux scripts et outils.";;
    claude) t "Claude Code: the assistant itself, in your terminal." "Claude Code : l'assistant lui-même, dans votre terminal.";;
  esac
}

pw_note() {
  say "  Your computer will ask for its password. Nothing shows while you type it: that is normal. It can take a few minutes." \
      "  Votre ordinateur va demander son mot de passe. Rien ne s'affiche quand vous le tapez : c'est normal. Cela peut durer quelques minutes."
}

install_tool() {
  if [ "$DRY" = 0 ]; then
    case "$1" in
      brew) pw_note;;
      git|node|python) [ "$OS" = Linux ] && pw_note;;
    esac
  fi
  if [ "$OS" = Darwin ] && [ "$1" != brew ] && [ "$1" != claude ] && [ "$DRY" = 0 ] && ! have brew; then
    say "  Cannot install $1 without Homebrew. Rerun and accept Homebrew first." "  Impossible d'installer $1 sans Homebrew. Relancez et acceptez Homebrew d'abord."
    return 0
  fi
  case "$1" in
    brew)
      run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)";;
    git)    if [ "$OS" = Darwin ]; then run brew install git; else run sudo apt-get install -y git; fi;;
    node)   if [ "$OS" = Darwin ]; then run brew install node; else run sudo apt-get install -y nodejs npm; fi;;
    python) if [ "$OS" = Darwin ]; then run brew install python; else run sudo apt-get install -y python3; fi;;
    claude)
      if ! run npm install -g @anthropic-ai/claude-code; then
        say "  The install was refused (permissions). Install Claude Code the official way instead: https://code.claude.com/docs/en/setup" \
            "  L'installation a été refusée (droits). Installez Claude Code par la voie officielle : https://code.claude.com/docs/en/setup"
      fi;;
  esac
}

is_present() {
  case "$1" in
    python) have python3;;
    *) have "$1";;
  esac
}

# Homebrew is only needed on macOS.
TOOLS="git node python claude"; [ "$OS" = Darwin ] && TOOLS="brew $TOOLS"

MISSING=""
say "Checking your machine..." "Vérification de votre machine..."
for x in $TOOLS; do
  if is_present "$x"; then echo "  ok  $x"; else echo "  --  $x"; MISSING="$MISSING $x"; fi
done

if [ -n "$MISSING" ]; then
  if [ "$PRO" = 1 ]; then
    say "To install:$MISSING" "À installer :$MISSING"
    ask "Proceed?" "Continuer ?" || { say "Stopped, nothing changed." "Arrêt, rien n'a été modifié."; exit 0; }
    for x in $MISSING; do install_tool "$x"; done
  else
    for x in $MISSING; do
      echo
      tool_info "$x"; echo
      if ask "Install it?" "L'installer ?"; then install_tool "$x"
      else say "Skipped. Claude Code needs git, node and claude to work fully." "Ignoré. Claude Code a besoin de git, node et claude pour fonctionner pleinement."; fi
    done
  fi
else
  say "Everything needed is already installed." "Tout le nécessaire est déjà installé."
fi

# Starter skills and glossary: copied, never overwritten.
DEST="$HOME/.claude"
copy_new() { # copy_new <src> <dst>
  if [ -e "$2" ]; then echo "  keep  $2"; else run mkdir -p "$(dirname "$2")"; run cp -R "$1" "$2"; echo "  add   $2"; fi
}
echo
say "Adding the starter skills..." "Ajout des skills de démarrage..."
for s in welcome explain pro-samuel; do copy_new "$ROOT/skills/$s" "$DEST/skills/$s"; done
copy_new "$ROOT/docs/glossary" "$DEST/kit/glossary"
copy_new "$ROOT/starter/hooks" "$DEST/kit/hooks"   # guardrails: registered later by /welcome, only after a yes

# Minimal profile, only if none exists. /welcome completes it.
PROFILE="$DEST/kit/profile.json"
if [ ! -e "$PROFILE" ]; then
  MODE="learner"; [ "$PRO" = 1 ] && MODE="pro"
  run mkdir -p "$DEST/kit"
  if [ "$DRY" = 0 ]; then printf '{\n  "language": "%s",\n  "mode": "%s",\n  "level": null,\n  "terms_seen": []\n}\n' "$LANG_CODE" "$MODE" > "$PROFILE"; fi
fi

echo
if [ "$PRO" = 1 ]; then
  say "Done. Run: claude   then type: /pro-samuel" "Terminé. Lancez : claude   puis tapez : /pro-samuel"
else
  say "Done. Run: claude   then type: /welcome" "Terminé. Lancez : claude   puis tapez : /welcome"
fi
