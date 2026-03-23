#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# SQWR Project Kit — Validateur CLAUDE.md
# ═══════════════════════════════════════════════════════════════
#
# Rôle : Vérifie qu'un CLAUDE.md de projet est complet.
#        Bloque si des [À COMPLÉTER] restent ou si des sections
#        obligatoires sont absentes.
#
# Usage : bash validate-claude-md.sh [chemin/vers/CLAUDE.md]
#         Par défaut : ./CLAUDE.md (depuis la racine du projet)
#
# Exemples :
#   bash ~/.../Project-Kit/scripts/validate-claude-md.sh
#   bash ~/.../Project-Kit/scripts/validate-claude-md.sh /path/to/project/CLAUDE.md
#
# Sorties :
#   Exit 0 = CLAUDE.md valide
#   Exit 1 = CLAUDE.md incomplet
#
# Prérequis : bash ≥3.2, grep
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

# ─── Couleurs ───────────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

pass() { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; ((ERRORS++)); }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; ((WARNINGS++)); }

# ─── Localiser le fichier ───────────────────────────────────────
CLAUDE_FILE="${1:-$(pwd)/CLAUDE.md}"

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  SQWR — Validation CLAUDE.md${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  Fichier : $CLAUDE_FILE"
echo ""

if [ ! -f "$CLAUDE_FILE" ]; then
  echo -e "${RED}❌ CLAUDE.md introuvable : $CLAUDE_FILE${NC}"
  echo -e "   Créer un CLAUDE.md depuis le template :"
  echo -e "   cp ~/.../Project-Kit/templates/CLAUDE.md ./CLAUDE.md"
  exit 1
fi

# ═══════════════════════════════════════════════════════════════
# TEST 1 — Sections obligatoires présentes
# ═══════════════════════════════════════════════════════════════
echo -e "${BLUE}▸ Sections obligatoires${NC}"

REQUIRED_SECTIONS=(
  "Qui travaille avec toi"
  "Ce projet"
  "Architecture"
  "Contrats actifs"
  "Règles absolues"
  "Historique des erreurs"
)

for section in "${REQUIRED_SECTIONS[@]}"; do
  if grep -q "$section" "$CLAUDE_FILE"; then
    pass "Section présente : $section"
  else
    fail "Section MANQUANTE : $section"
  fi
done

# ═══════════════════════════════════════════════════════════════
# TEST 2 — Aucun [À COMPLÉTER] restant
# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${BLUE}▸ Placeholders non remplis${NC}"

PLACEHOLDER_COUNT=$(grep -c "\[À COMPLÉTER\]" "$CLAUDE_FILE" 2>/dev/null || echo "0")
if [ "$PLACEHOLDER_COUNT" -eq 0 ]; then
  pass "Aucun placeholder [À COMPLÉTER] restant"
else
  fail "$PLACEHOLDER_COUNT placeholder(s) [À COMPLÉTER] non rempli(s) :"
  grep -n "\[À COMPLÉTER\]" "$CLAUDE_FILE" | while read -r line; do
    echo -e "     Ligne $line"
  done
fi

# ═══════════════════════════════════════════════════════════════
# TEST 3 — Identité utilisateur présente
# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${BLUE}▸ Identité utilisateur${NC}"

# Vérifie que le CLAUDE.md a été personnalisé (pas de placeholder générique)
if grep -q "\[VOTRE NOM\]" "$CLAUDE_FILE"; then
  warn "Section identité non remplie — remplacer [VOTRE NOM] par votre nom"
else
  pass "Identité personnalisée (pas de placeholder [VOTRE NOM])"
fi

if grep -qE "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" "$CLAUDE_FILE"; then
  pass "Email présent dans le CLAUDE.md"
else
  warn "Aucun email trouvé — ajouter vos coordonnées depuis IDENTITY-TEMPLATE.md"
fi

# ═══════════════════════════════════════════════════════════════
# TEST 4 — Au moins une règle "Ne jamais faire"
# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${BLUE}▸ Règles absolues${NC}"

if grep -qiE "(ne jamais|never|jamais faire|JAMAIS)" "$CLAUDE_FILE"; then
  pass "Règles 'Ne jamais faire' présentes"
else
  fail "Aucune règle 'Ne jamais faire' — section Règles absolues vide"
fi

if grep -qiE "(toujours faire|always|TOUJOURS)" "$CLAUDE_FILE"; then
  pass "Règles 'Toujours faire' présentes"
else
  warn "Aucune règle 'Toujours faire' (optionnel mais recommandé)"
fi

# ═══════════════════════════════════════════════════════════════
# TEST 5 — Tableau historique des erreurs présent
# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${BLUE}▸ Historique des erreurs${NC}"

if grep -qE "\|.*Date.*\|" "$CLAUDE_FILE"; then
  pass "Tableau historique des erreurs présent"
else
  fail "Tableau historique des erreurs MANQUANT"
fi

# ═══════════════════════════════════════════════════════════════
# TEST 6 — Stack documentée
# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${BLUE}▸ Stack technique${NC}"

if grep -qiE "(next\.js|python|react|supabase|vercel|swift)" "$CLAUDE_FILE"; then
  pass "Stack technique documentée"
else
  warn "Stack technique non détectée — section 'Ce projet' peut être incomplète"
fi

# ═══════════════════════════════════════════════════════════════
# RÉSUMÉ
# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
  echo -e "${GREEN}✅ CLAUDE.md valide — prêt pour le travail IA${NC}"
  exit 0
elif [ "$ERRORS" -eq 0 ]; then
  echo -e "${YELLOW}⚠️  CLAUDE.md acceptable — $WARNINGS avertissement(s) à corriger${NC}"
  exit 0
else
  echo -e "${RED}❌ CLAUDE.md incomplet — $ERRORS erreur(s) bloquante(s)${NC}"
  echo -e "   Compléter le fichier avant de démarrer une session IA."
  exit 1
fi
