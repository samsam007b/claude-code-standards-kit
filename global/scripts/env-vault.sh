#!/usr/bin/env bash
# env-vault: manage .env secrets encrypted with age.
#
# Usage: env-vault.sh <command> [file]
#   fix-perms          chmod 600 on every .env* found under the scan roots
#   status             list every .env with permissions and encryption state
#   encrypt <file>     .env -> .env.age (keeps the plaintext)
#   decrypt <file>     .env.age -> .env
#   lock <file>        encrypt, then delete the plaintext
#   unlock <file>      decrypt only
#   lock-all           lock every file listed in the critical-files list
#   unlock-all         unlock every file listed in the critical-files list
#
# Configuration (no project list is hardcoded):
#   ENV_VAULT_ROOTS       colon-separated directories to scan (default: $HOME/Projects:$HOME/dev)
#   ENV_VAULT_FILES_LIST  file with one critical .env path per line, '#' comments allowed
#                         (default: ${XDG_CONFIG_HOME:-$HOME/.config}/env-vault/critical-files)
#   ENV_VAULT_FILES       optional extra critical files, colon-separated
#   AGE_KEY               age identity file (default: $HOME/.age/key.txt)
#
# Dependencies: age, age-keygen (brew install age / apt install age)

set -euo pipefail

AGE_KEY="${AGE_KEY:-$HOME/.age/key.txt}"
AGE_BIN="$(command -v age 2>/dev/null || echo age)"
KEYGEN_BIN="$(command -v age-keygen 2>/dev/null || echo age-keygen)"
ROOTS="${ENV_VAULT_ROOTS:-$HOME/Projects:$HOME/dev}"
FILES_LIST="${ENV_VAULT_FILES_LIST:-${XDG_CONFIG_HOME:-$HOME/.config}/env-vault/critical-files}"

if [[ -t 1 ]]; then
  RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[1;33m'
  BLUE=$'\033[0;34m'; BOLD=$'\033[1m'; NC=$'\033[0m'
else
  RED=""; GREEN=""; YELLOW=""; BLUE=""; BOLD=""; NC=""
fi

# Portable octal permission read (BSD stat, then GNU stat).
file_perms() {
  stat -f "%OLp" "$1" 2>/dev/null || stat -c "%a" "$1" 2>/dev/null || echo "???"
}

short() { echo "${1/#$HOME/~}"; }

# Critical files: list file + ENV_VAULT_FILES.
critical_files() {
  if [[ -f "$FILES_LIST" ]]; then
    { grep -vE '^\s*(#|$)' "$FILES_LIST" || true; } | sed "s|^~|$HOME|"
  fi
  if [[ -n "${ENV_VAULT_FILES:-}" ]]; then
    tr ':' '\n' <<<"$ENV_VAULT_FILES" | sed "s|^~|$HOME|"
  fi
}

# Print NUL-separated .env files under the scan roots.
find_env_files() {
  local root
  local IFS=:
  for root in $ROOTS; do
    [[ -d "$root" ]] || continue
    find "$root" \
      \( -name node_modules -o -name .git -o -name .cache -o -name Library \) -prune -o \
      -type f \( -name ".env" -o -name ".env.local" -o -name ".env.*.local" -o -name ".env.production" \) \
      -print0 2>/dev/null
  done
}

check_age() {
  if ! command -v "$AGE_BIN" >/dev/null 2>&1; then
    echo "${RED}age not found. Install it: brew install age${NC}" >&2; exit 1
  fi
  if [[ ! -f "$AGE_KEY" ]]; then
    echo "${RED}age key not found: $AGE_KEY${NC}" >&2
    echo "Generate one: mkdir -p ~/.age && age-keygen -o ~/.age/key.txt && chmod 600 ~/.age/key.txt" >&2
    exit 1
  fi
}

get_pubkey() { "$KEYGEN_BIN" -y "$AGE_KEY"; }

cmd_fix_perms() {
  echo "${BOLD}Fixing permissions on .env* files...${NC}"
  local count=0 file perms
  while IFS= read -r -d '' file; do
    perms=$(file_perms "$file")
    if [[ "$perms" != "600" ]]; then
      chmod 600 "$file"
      echo "  ${GREEN}ok${NC} $(basename "$file")  ${YELLOW}$perms${NC} -> ${GREEN}600${NC}  ${BLUE}$(short "$file")${NC}"
      count=$((count + 1))
    fi
  done < <(find_env_files)
  if [[ $count -eq 0 ]]; then
    echo "  ${GREEN}All files already 600.${NC}"
  else
    echo; echo "${GREEN}$count file(s) fixed.${NC}"
  fi
}

cmd_status() {
  echo "${BOLD}Secret files state${NC}"; echo
  printf "%-8s %-14s %s\n" "PERMS" "STATE" "FILE"
  printf "%-8s %-14s %s\n" "-------" "-------------" "----"
  local file perms state perm_color state_color
  while IFS= read -r -d '' file; do
    perms=$(file_perms "$file")
    [[ "$perms" == "600" ]] && perm_color="$GREEN" || perm_color="$RED"
    if [[ -f "${file}.age" ]]; then state="encrypted"; state_color="$GREEN"
    else state="plaintext only"; state_color="$YELLOW"; fi
    printf "${perm_color}%-8s${NC} ${state_color}%-14s${NC} ${BLUE}%s${NC}\n" "$perms" "$state" "$(short "$file")"
  done < <(find_env_files)
}

cmd_encrypt() {
  check_age
  local file="${1:-}"
  [[ -n "$file" ]] || { echo "${RED}Usage: env-vault encrypt <file>${NC}" >&2; exit 1; }
  [[ -f "$file" ]] || { echo "${RED}File not found: $file${NC}" >&2; exit 1; }
  local out="${file}.age"
  "$AGE_BIN" -r "$(get_pubkey)" -o "$out" "$file"
  chmod 600 "$out"
  echo "${GREEN}Encrypted: ${BLUE}$(short "$file")${GREEN} -> ${BLUE}$(short "$out")${NC}"
}

cmd_decrypt() {
  check_age
  local file="${1:-}"
  [[ -n "$file" ]] || { echo "${RED}Usage: env-vault decrypt <file.age>${NC}" >&2; exit 1; }
  local age_file="$file"
  [[ "$file" == *.age ]] || age_file="${file}.age"
  [[ -f "$age_file" ]] || { echo "${RED}.age file not found: $age_file${NC}" >&2; exit 1; }
  local out="${age_file%.age}"
  "$AGE_BIN" -d -i "$AGE_KEY" -o "$out" "$age_file"
  chmod 600 "$out"
  echo "${GREEN}Decrypted: ${BLUE}$(short "$age_file")${GREEN} -> ${BLUE}$(short "$out")${NC}"
}

cmd_lock() {
  local file="${1:-}"
  [[ -n "$file" ]] || { echo "${RED}Usage: env-vault lock <file>${NC}" >&2; exit 1; }
  cmd_encrypt "$file"
  # Verify the ciphertext exists and is non-empty before deleting the plaintext.
  [[ -s "${file}.age" ]] || { echo "${RED}Encryption failed, plaintext kept.${NC}" >&2; exit 1; }
  rm -f "$file"
  echo "${YELLOW}  Plaintext deleted: $(short "$file")${NC}"
}

cmd_unlock() { cmd_decrypt "${1:-}"; }

require_list() {
  if [[ -z "$(critical_files)" ]]; then
    echo "${YELLOW}No critical files configured.${NC}" >&2
    echo "Add paths (one per line) to $FILES_LIST or set ENV_VAULT_FILES." >&2
    exit 1
  fi
}

cmd_lock_all() {
  check_age; require_list
  echo "${BOLD}Locking all critical files...${NC}"; echo
  local file
  while IFS= read -r file; do
    if [[ -f "$file" ]]; then cmd_lock "$file"
    elif [[ -f "${file}.age" ]]; then echo "  ${BLUE}$(short "$file")${NC} already locked."
    else echo "  ${YELLOW}Not found: $(short "$file")${NC}"; fi
  done < <(critical_files)
  echo; echo "${GREEN}lock-all done.${NC}"
}

cmd_unlock_all() {
  check_age; require_list
  echo "${BOLD}Unlocking all critical files...${NC}"; echo
  local file
  while IFS= read -r file; do
    if [[ -f "${file}.age" ]]; then cmd_decrypt "${file}.age"
    elif [[ -f "$file" ]]; then echo "  ${BLUE}$(short "$file")${NC} already unlocked."
    else echo "  ${YELLOW}Not found: $(short "$file").age${NC}"; fi
  done < <(critical_files)
  echo; echo "${GREEN}unlock-all done.${NC}"
}

cmd_help() {
  sed -n '2,22p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  echo; echo "age key: $AGE_KEY (BACK IT UP, without it the .age files are unrecoverable)"
}

COMMAND="${1:-help}"
shift || true
case "$COMMAND" in
  fix-perms)  cmd_fix_perms ;;
  status)     cmd_status ;;
  encrypt)    cmd_encrypt "${1:-}" ;;
  decrypt)    cmd_decrypt "${1:-}" ;;
  lock)       cmd_lock "${1:-}" ;;
  unlock)     cmd_unlock "${1:-}" ;;
  lock-all)   cmd_lock_all ;;
  unlock-all) cmd_unlock_all ;;
  help|--help|-h) cmd_help ;;
  *) echo "${RED}Unknown command: $COMMAND${NC}" >&2; cmd_help; exit 1 ;;
esac
