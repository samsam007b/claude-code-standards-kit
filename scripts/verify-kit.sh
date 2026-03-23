#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# SQWR Project Kit — Vérificateur d'intégrité
# ═══════════════════════════════════════════════════════════════
#
# Rôle : Valide que le Project Kit est complet et cohérent.
#        Tests automatisés du kit lui-même (méta-tests).
#
# Usage : bash verify-kit.sh [--verbose]
#
# Ce que ça vérifie :
#   1. Tous les fichiers du kit existent (contrats, audits, templates)
#   2. Le template CLAUDE.md a les sections requises
#   3. Chaque contrat cite au moins une source
#   4. Les audits ont des seuils numériques
#   5. Le script init-project.sh référence des contrats existants
#
# Sorties :
#   Exit 0 = kit valide
#   Exit 1 = lacunes détectées
#
# Prérequis : bash ≥3.2 (macOS défaut), grep, awk
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERBOSE=false
ERRORS=0
WARNINGS=0

# ─── Args ───────────────────────────────────────────────────────
for arg in "$@"; do
  case $arg in
    --verbose|-v) VERBOSE=true ;;
  esac
done

# ─── Couleurs ───────────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GRAY='\033[0;37m'
NC='\033[0m'

# ─── Helpers ────────────────────────────────────────────────────
pass() { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; ((ERRORS++)); }
warn() { echo -e "  ${YELLOW}⚠${NC} $1"; ((WARNINGS++)); }
info() { $VERBOSE && echo -e "  ${GRAY}→${NC} $1" || true; }
section() { echo -e "\n${BLUE}▸ $1${NC}"; }

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  SQWR Project Kit — Vérification intégrité${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  Kit : ${GRAY}$KIT_DIR${NC}"

# ═══════════════════════════════════════════════════════════════
# TEST 1 — Fichiers obligatoires
# ═══════════════════════════════════════════════════════════════
section "Test 1 — Fichiers obligatoires"

REQUIRED_FILES=(
  "README.md"
  "IDENTITY-TEMPLATE.md"
  "templates/CLAUDE.md"
  "templates/.env.example"
  "templates/.gitignore"
  "templates/CHANGELOG.md"
  "templates/CONTRIBUTING.md"
  "contracts/CONTRACT-NEXTJS.md"
  "contracts/CONTRACT-SUPABASE.md"
  "contracts/CONTRACT-VERCEL.md"
  "contracts/CONTRACT-DESIGN.md"
  "contracts/CONTRACT-TYPESCRIPT.md"
  "contracts/CONTRACT-TESTING.md"
  "contracts/CONTRACT-SECURITY.md"
  "contracts/CONTRACT-PERFORMANCE.md"
  "contracts/CONTRACT-ACCESSIBILITY.md"
  "contracts/CONTRACT-ANTI-HALLUCINATION.md"
  "contracts/CONTRACT-AI-PROMPTING.md"
  "contracts/CONTRACT-IOS.md"
  "contracts/CONTRACT-PDF-GENERATION.md"
  "contracts/CONTRACT-SEO.md"
  "contracts/CONTRACT-EMAIL.md"
  "contracts/CONTRACT-CICD.md"
  "contracts/CONTRACT-ANALYTICS.md"
  "contracts/CONTRACT-I18N.md"
  "contracts/CONTRACT-PRICING.md"
  "contracts/CONTRACT-ANDROID.md"
  "contracts/CONTRACT-MOTION-DESIGN.md"
  "contracts/CONTRACT-VIDEO-PRODUCTION.md"
  "frameworks/UX-RESEARCH.md"
  "frameworks/SOCIAL-CONTENT.md"
  "audits/AUDIT-RGPD.md"
  "audits/AUDIT-BRAND-STRATEGY.md"
  "frameworks/COMPETITIVE-AUDIT.md"
  "frameworks/CAMPAIGN-STRATEGY.md"
  "audits/AUDIT-INDEX.md"
  "audits/AUDIT-SECURITY.md"
  "audits/AUDIT-PERFORMANCE.md"
  "audits/AUDIT-ACCESSIBILITY.md"
  "audits/AUDIT-CODE-QUALITY.md"
  "audits/AUDIT-AI-GOVERNANCE.md"
  "audits/AUDIT-DESIGN.md"
  "audits/AUDIT-DEPLOYMENT.md"
  "scripts/init-project.sh"
  "scripts/verify-kit.sh"
  "scripts/validate-claude-md.sh"
  "frameworks/BRAND-STRATEGY.md"
  "METHODOLOGY.md"
  "GUIDE-DECOUVERTE.md"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [ -f "$KIT_DIR/$file" ]; then
    info "Trouvé : $file"
    pass "$file"
  else
    fail "MANQUANT : $file"
  fi
done

# ═══════════════════════════════════════════════════════════════
# TEST 2 — Structure du template CLAUDE.md
# ═══════════════════════════════════════════════════════════════
section "Test 2 — Sections obligatoires dans template CLAUDE.md"

TEMPLATE="$KIT_DIR/templates/CLAUDE.md"
REQUIRED_SECTIONS=(
  "Qui travaille avec toi"
  "Ce projet"
  "Architecture"
  "Contrats actifs"
  "Règles absolues"
  "Historique des erreurs"
)

if [ -f "$TEMPLATE" ]; then
  for section_name in "${REQUIRED_SECTIONS[@]}"; do
    if grep -q "$section_name" "$TEMPLATE"; then
      pass "Section : $section_name"
    else
      fail "Section manquante : $section_name"
    fi
  done
  # Vérifier que le template a des placeholders [À COMPLÉTER] (c'est normal)
  PLACEHOLDER_COUNT=$(grep -c "\[À COMPLÉTER\]" "$TEMPLATE" 2>/dev/null || echo "0")
  info "Placeholders [À COMPLÉTER] dans le template : $PLACEHOLDER_COUNT (normal)"
else
  fail "Template CLAUDE.md introuvable"
fi

# ═══════════════════════════════════════════════════════════════
# TEST 3 — Chaque contrat cite au moins une source
# ═══════════════════════════════════════════════════════════════
section "Test 3 — Ancrage scientifique (sources dans contrats)"

for contract in "$KIT_DIR/contracts/"CONTRACT-*.md; do
  contract_name=$(basename "$contract")
  if grep -qiE "(source|référence|https?://|w3\.org|owasp|nist|wcag|google|martin fowler)" "$contract"; then
    pass "$contract_name → sources présentes"
  else
    fail "$contract_name → AUCUNE source détectée"
  fi
done

# ═══════════════════════════════════════════════════════════════
# TEST 4 — Les audits ont des seuils numériques
# ═══════════════════════════════════════════════════════════════
section "Test 4 — Seuils mesurables dans les audits"

for audit in "$KIT_DIR/audits/"AUDIT-*.md; do
  audit_name=$(basename "$audit")
  # Chercher des pourcentages, scores /100, ou chiffres de seuil
  if grep -qE "([0-9]+%|/100|≤[0-9]|≥[0-9]|<[0-9]|>[0-9])" "$audit"; then
    pass "$audit_name → seuils numériques présents"
  else
    warn "$audit_name → pas de seuils numériques détectés"
  fi
done

# ═══════════════════════════════════════════════════════════════
# TEST 5 — init-project.sh référence des contrats existants
# ═══════════════════════════════════════════════════════════════
section "Test 5 — Cohérence init-project.sh ↔ contrats"

INIT_SCRIPT="$KIT_DIR/scripts/init-project.sh"
if [ -f "$INIT_SCRIPT" ]; then
  # Extraire les noms de contrats référencés dans le script
  REFERENCED=$(grep -oE "CONTRACT-[A-Z-]+" "$INIT_SCRIPT" | sort -u)
  for contract_ref in $REFERENCED; do
    if [ -f "$KIT_DIR/contracts/$contract_ref.md" ]; then
      pass "Référence résolue : $contract_ref.md"
    else
      fail "Référence cassée dans init-project.sh : $contract_ref.md INTROUVABLE"
    fi
  done
else
  fail "init-project.sh introuvable"
fi

# ═══════════════════════════════════════════════════════════════
# TEST 6 — IDENTITY-TEMPLATE contient la structure requise
# ═══════════════════════════════════════════════════════════════
section "Test 6 — Structure IDENTITY-TEMPLATE.md"

IDENTITY="$KIT_DIR/IDENTITY-TEMPLATE.md"
REQUIRED_IDENTITY=(
  "Qui je suis"
  "Stack de prédilection"
  "Biais cognitifs"
  "Planning fallacy"
  "Style de travail"
)

if [ -f "$IDENTITY" ]; then
  for item in "${REQUIRED_IDENTITY[@]}"; do
    if grep -q "$item" "$IDENTITY"; then
      pass "Identité : $item présent"
    else
      fail "Identité : $item MANQUANT"
    fi
  done
else
  fail "IDENTITY-TEMPLATE.md introuvable"
fi

# ═══════════════════════════════════════════════════════════════
# TEST 7 — README référence tous les contrats
# ═══════════════════════════════════════════════════════════════
section "Test 7 — README.md référence tous les contrats"

README="$KIT_DIR/README.md"
if [ -f "$README" ]; then
  for contract in "$KIT_DIR/contracts/"CONTRACT-*.md; do
    contract_name=$(basename "$contract" .md)
    if grep -q "$contract_name" "$README"; then
      pass "README référence : $contract_name"
    else
      warn "README ne référence pas : $contract_name"
    fi
  done
else
  fail "README.md introuvable"
fi

# ═══════════════════════════════════════════════════════════════
# RÉSUMÉ
# ═══════════════════════════════════════════════════════════════
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
  echo -e "${GREEN}✅ Kit valide — 0 erreur, 0 avertissement${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  exit 0
elif [ "$ERRORS" -eq 0 ]; then
  echo -e "${YELLOW}⚠️  Kit acceptable — 0 erreur, $WARNINGS avertissement(s)${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  exit 0
else
  echo -e "${RED}❌ Kit invalide — $ERRORS erreur(s), $WARNINGS avertissement(s)${NC}"
  echo -e "   Corriger les erreurs avant d'utiliser le kit sur un nouveau projet."
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  exit 1
fi
