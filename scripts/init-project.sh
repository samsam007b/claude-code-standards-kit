#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# SQWR Project Kit — Initialisation d'un nouveau projet
# ═══════════════════════════════════════════════════════════════
#
# Rôle : Bootstrap automatique d'un nouveau projet SQWR.
#        Copie les templates (CLAUDE.md, .env.example, .gitignore),
#        inclut les contrats selon la stack choisie, et initialise
#        optionnellement un dépôt git.
#
# Usage :
#   bash init-project.sh --name <nom> --stack <stack> --path <chemin>
#
# Arguments :
#   --name   Nom du projet (requis — prompt interactif si absent)
#   --stack  Stack technique (défaut : nextjs-supabase)
#   --path   Chemin de destination (défaut : ./nom-du-projet)
#
# Stacks disponibles :
#   nextjs-supabase      → NextJS + Supabase + Vercel + TypeScript + Design + Security + Testing + Performance + Accessibility
#   nextjs               → NextJS + Vercel + TypeScript + Design + Security + Testing + Performance + Accessibility
#   nextjs-supabase-ai   → nextjs-supabase + AI-Prompting + Anti-Hallucination
#   python               → Python + Security + Testing
#   ios                  → iOS + Accessibility + Security + Testing
#
# Exemples :
#   bash init-project.sh --name "mon-site" --stack "nextjs-supabase"
#   bash init-project.sh --name "api-python" --stack "python" --path "/Desktop/api"
#
# Erreurs fréquentes :
#   "Argument inconnu"    → vérifier l'orthographe des flags (--name, --stack, --path)
#   "Stack non reconnue"  → utiliser une des 4 stacks documentées ci-dessus
#   Permission denied     → lancer avec `bash init-project.sh` (pas besoin de chmod)
#
# Prérequis : bash ≥3.2 (macOS défaut), git (optionnel pour init repo)
# ═══════════════════════════════════════════════════════════════

set -e

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ─── Couleurs ───────────────────────────────────────────────
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  SQWR Project Kit — Init${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# ─── Arguments ──────────────────────────────────────────────
PROJECT_NAME=""
PROJECT_STACK="nextjs-supabase"
PROJECT_PATH=""

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --name) PROJECT_NAME="$2"; shift ;;
    --stack) PROJECT_STACK="$2"; shift ;;
    --path) PROJECT_PATH="$2"; shift ;;
    *) echo -e "${RED}Argument inconnu: $1${NC}"; exit 1 ;;
  esac
  shift
done

# ─── Validation ─────────────────────────────────────────────
if [ -z "$PROJECT_NAME" ]; then
  echo -e "${YELLOW}Nom du projet:${NC} "
  read -r PROJECT_NAME
fi

if [ -z "$PROJECT_PATH" ]; then
  PROJECT_PATH="$(pwd)/$PROJECT_NAME"
fi

echo ""
echo -e "Projet    : ${GREEN}$PROJECT_NAME${NC}"
echo -e "Stack     : ${GREEN}$PROJECT_STACK${NC}"
echo -e "Chemin    : ${GREEN}$PROJECT_PATH${NC}"
echo ""

# ─── Création du dossier ─────────────────────────────────────
if [ ! -d "$PROJECT_PATH" ]; then
  mkdir -p "$PROJECT_PATH"
  echo -e "${GREEN}✓${NC} Dossier créé : $PROJECT_PATH"
fi

# ─── Copie des fichiers de base ──────────────────────────────

# .gitignore
if [ ! -f "$PROJECT_PATH/.gitignore" ]; then
  cp "$KIT_DIR/templates/.gitignore" "$PROJECT_PATH/.gitignore"
  echo -e "${GREEN}✓${NC} .gitignore copié"
fi

# .env.example
cp "$KIT_DIR/templates/.env.example" "$PROJECT_PATH/.env.example"
# Remplacer le placeholder du nom
sed -i '' "s/\[NOM DU PROJET\]/$PROJECT_NAME/" "$PROJECT_PATH/.env.example"
echo -e "${GREEN}✓${NC} .env.example copié"

# CLAUDE.md
cp "$KIT_DIR/templates/CLAUDE.md" "$PROJECT_PATH/CLAUDE.md"
# Remplacer le placeholder du nom
sed -i '' "s/\[NOM DU PROJET\]/$PROJECT_NAME/" "$PROJECT_PATH/CLAUDE.md"
echo -e "${GREEN}✓${NC} CLAUDE.md copié (à compléter !)"

# CHANGELOG.md
cp "$KIT_DIR/templates/CHANGELOG.md" "$PROJECT_PATH/CHANGELOG.md"
sed -i '' "s/YYYY-MM-DD/$(date +%Y-%m-%d)/" "$PROJECT_PATH/CHANGELOG.md"
echo -e "${GREEN}✓${NC} CHANGELOG.md créé (date initialisée : $(date +%Y-%m-%d))"

# CONTRIBUTING.md
cp "$KIT_DIR/templates/CONTRIBUTING.md" "$PROJECT_PATH/CONTRIBUTING.md"
sed -i '' "s/\[NOM DU PROJET\]/$PROJECT_NAME/" "$PROJECT_PATH/CONTRIBUTING.md"
echo -e "${GREEN}✓${NC} CONTRIBUTING.md créé"

# ─── Contrats par stack ──────────────────────────────────────
CONTRACTS_TO_INCLUDE=""

case $PROJECT_STACK in
  nextjs-supabase)
    CONTRACTS_TO_INCLUDE="CONTRACT-NEXTJS CONTRACT-SUPABASE CONTRACT-VERCEL CONTRACT-TYPESCRIPT CONTRACT-DESIGN CONTRACT-SECURITY CONTRACT-TESTING CONTRACT-PERFORMANCE CONTRACT-ACCESSIBILITY CONTRACT-OBSERVABILITY CONTRACT-RESILIENCE CONTRACT-SEO CONTRACT-CICD"
    ;;
  nextjs)
    CONTRACTS_TO_INCLUDE="CONTRACT-NEXTJS CONTRACT-VERCEL CONTRACT-TYPESCRIPT CONTRACT-DESIGN CONTRACT-SECURITY CONTRACT-TESTING CONTRACT-PERFORMANCE CONTRACT-ACCESSIBILITY CONTRACT-SEO CONTRACT-CICD"
    ;;
  nextjs-supabase-ai)
    CONTRACTS_TO_INCLUDE="CONTRACT-NEXTJS CONTRACT-SUPABASE CONTRACT-VERCEL CONTRACT-TYPESCRIPT CONTRACT-DESIGN CONTRACT-SECURITY CONTRACT-TESTING CONTRACT-PERFORMANCE CONTRACT-ACCESSIBILITY CONTRACT-OBSERVABILITY CONTRACT-RESILIENCE CONTRACT-AI-PROMPTING CONTRACT-ANTI-HALLUCINATION CONTRACT-SEO CONTRACT-CICD"
    ;;
  python)
    CONTRACTS_TO_INCLUDE="CONTRACT-PYTHON CONTRACT-SECURITY CONTRACT-TESTING"
    ;;
  ios)
    CONTRACTS_TO_INCLUDE="CONTRACT-IOS CONTRACT-ACCESSIBILITY CONTRACT-SECURITY CONTRACT-TESTING"
    ;;
  *)
    echo -e "${YELLOW}ℹ${NC}  Stack '$PROJECT_STACK' non reconnue. Contrats à ajouter manuellement."
    ;;
esac

# Créer dossier docs/contracts si contrats à inclure
if [ -n "$CONTRACTS_TO_INCLUDE" ]; then
  mkdir -p "$PROJECT_PATH/docs/contracts"
  for contract in $CONTRACTS_TO_INCLUDE; do
    if [ -f "$KIT_DIR/contracts/$contract.md" ]; then
      cp "$KIT_DIR/contracts/$contract.md" "$PROJECT_PATH/docs/contracts/"
      echo -e "${GREEN}✓${NC} $contract.md inclus"
    fi
  done
fi

# ─── .env.local vierge ──────────────────────────────────────
if [ ! -f "$PROJECT_PATH/.env.local" ]; then
  echo "# Copié depuis .env.example — remplir les valeurs" > "$PROJECT_PATH/.env.local"
  cat "$PROJECT_PATH/.env.example" >> "$PROJECT_PATH/.env.local"
  echo -e "${GREEN}✓${NC} .env.local créé (à remplir)"
fi

# ─── Git init ───────────────────────────────────────────────
if [ ! -d "$PROJECT_PATH/.git" ]; then
  echo ""
  echo -e "${YELLOW}Initialiser git dans ce projet ? (o/N)${NC} "
  read -r INIT_GIT
  if [[ "$INIT_GIT" =~ ^[Oo]$ ]]; then
    git -C "$PROJECT_PATH" init
    git -C "$PROJECT_PATH" add .gitignore .env.example CLAUDE.md CHANGELOG.md CONTRIBUTING.md
    git -C "$PROJECT_PATH" commit -m "chore: init projet $PROJECT_NAME depuis SQWR Project Kit"
    echo -e "${GREEN}✓${NC} Git initialisé + commit initial"
  fi
fi

# ─── Résumé ─────────────────────────────────────────────────
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Projet initialisé avec succès !${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Prochaines étapes :"
echo -e "  1. Compléter ${YELLOW}$PROJECT_PATH/CLAUDE.md${NC} (sections [À COMPLÉTER])"
echo -e "  2. Remplir ${YELLOW}$PROJECT_PATH/.env.local${NC} avec les vraies valeurs"
echo -e "  3. Mettre à jour ${YELLOW}$PROJECT_PATH/CHANGELOG.md${NC} à chaque release"
echo -e "  4. Ouvrir avec ${YELLOW}cursor $PROJECT_PATH${NC} ou ${YELLOW}code $PROJECT_PATH${NC}"
echo ""
