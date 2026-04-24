#!/usr/bin/env bash
# =============================================================================
# SCRIPT:       refactor_practice.sh
# DESCRIPTION:  Practice refactoring subshell patterns to pure-bash equivalents.
#               Each exercise runs both versions and prints results side by side
#               so you can verify the output is identical.
# USAGE:        ./refactor_practice.sh
# DEPENDENCIES: bash >= 4.0
# =============================================================================
set -euo pipefail
IFS=$'\n\t'

# Disable unicode — pure ASCII processing
LC_ALL=C
LANG=C

# --- Colors ------------------------------------------------------------------
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Suppress color when stdout is not a terminal
[[ -t 1 ]] || { RED=''; GREEN=''; YELLOW=''; CYAN=''; NC=''; }

# --- State variables (all initialized to satisfy set -u) ---------------------
DIR="${1:-.}"
TERM="${2:-error}"
DEBUG="${DEBUG:-0}"

# --- Helpers -----------------------------------------------------------------

# §2 &&-trap: return 0 prevents set -e triggering when DEBUG=0
debug() {
  [[ "$DEBUG" == 1 ]] && printf '[DEBUG] %s\n' "$*"
  return 0
}

err() { printf '%b\n' "${RED}[ERROR]${NC} $*" >&2; }

# Print a section header
header() {
  printf '\n%b\n' "${CYAN}══════════════════════════════════════════${NC}"
  printf '%b\n'   "${CYAN}  Exercise: %s${NC}" "$*"
  printf '%b\n'   "${CYAN}══════════════════════════════════════════${NC}"
  return 0
}

# Compare two results and print pass/fail
compare() {
  local label="$1"
  local before="$2"
  local after="$3"
  debug "compare called: label=${label} before=${before} after=${after}"
  printf '  %-28s' "$label"
  if [[ "$before" == "$after" ]]; then
    printf '%b\n' "${GREEN}[PASS]${NC} both = '%s'" "$after"
  else
    printf '%b\n' "${RED}[FAIL]${NC} before='%s' after='%s'" "$before" "$after"
  fi
  return 0
}

 Print before/after code side by side
show_refactor() {
  local before_code="$1"
  local after_code="$2"
  printf '\n%b  %s\n' "${YELLOW}[BEFORE]${NC}" "$before_code"
  printf '%b   %s\n'  "${GREEN}[AFTER]${NC}"  "$after_code"
  return 0
}

# =============================================================================
# Exercise 1 — File extension extraction
# =============================================================================
ex1_before() {
  local filename="$1"
  local ext
  ext=$(echo "$filename" | cut -d. -f2)   # subshell + fork
  printf '%s' "$ext"
  return 0
}

ex1_after() {
    ext="${filename##*.}"                           # §5 pure-bash: ## expansion
    printf '\n%s' "$ext"
}

run_ex1() {
  header "1 — File Extension  (cut → parameter expansion)"
  show_refactor \
    'ext=$(echo "$filename" | cut -d. -f2)' \
    'ext="${filename##*.}"'
  local test_file="exploit.py"
  compare "filename='$test_file'" \
    "$(ex1_before "$test_file")" \
    "$(ex1_after  "$test_file")"
  return 0
}

# =============================================================================
# Exercise 2 — Uppercase conversion
# =============================================================================
ex2_before() {
  local result
  result=$(echo "$1" | tr '[:lower:]' '[:upper:]')  # subshell + fork
  printf '%s' "$result"
  return 0
}

ex2_after() {
  local result="${1^^}"                              # §5 pure-bash: ,, expansion
  printf '%s' "$result"
  return 0
}

run_ex2() {
  header "2 — Uppercase  (tr → \${^^})"
  show_refactor \
    'result=$(echo "$1" | tr [:lower:] [:upper:])' \
    'result="${1^^}"'
  local test_str="hack the box"
  compare "input='$test_str'" \
    "$(ex2_before "$test_str")" \
    "$(ex2_after  "$test_str")"
  return 0
}

# =============================================================================
# Exercise 3 — Dirname extraction
# =============================================================================
ex3_before() {
  local parent
  parent=$(dirname "$1")     # subshell + fork
  printf '%s' "$parent"
  return 0
}

ex3_after() {
  local parent="${1%/*}"     # §5 pure-bash: strip from last /
  printf '%s' "$parent"
  return 0
}

run_ex3() {
  header "3 — Dirname  (dirname → parameter expansion)"
  show_refactor \
    'parent=$(dirname "$FILEPATH")' \
    'parent="${FILEPATH%/*}"'
  local test_path="/home/kali/htb/targets/box.txt"
  compare "path='$test_path'" \
    "$(ex3_before "$test_path")" \
    "$(ex3_after  "$test_path")"
  return 0
}

# =============================================================================
# Exercise 4 — Contains word check
# =============================================================================
ex4_before() {
  local sentence="$1"
  local found
  found=$(echo "$sentence" | grep -c "error")   # subshell + fork
  printf '%s' "$found"
  return 0
}

ex4_after() {
  local sentence="$1"
  local found=0
  [[ "$sentence" == *"error"* ]] && found=1     # §5 pure-bash: glob match
  printf '%s' "$found"
  return 0
}

run_ex4() {
  header "4 — Contains Word  (grep -c → [[ == *word* ]])"
  show_refactor \
    'found=$(echo "$SENTENCE" | grep -c "error")' \
    '[[ "$sentence" == *"error"* ]] && found=1'

  local hit="sql error on line 42"
  local miss="reverse shell connected"
  compare "match case  '$hit'" \
    "$(ex4_before "$hit")" \
    "$(ex4_after  "$hit")"
  compare "no-match    '$miss'" \
    "$(ex4_before "$miss")" \
    "$(ex4_after  "$miss")"
  return 0
}

# =============================================================================
# Exercise 5 — String length
# =============================================================================
ex5_before() {
  local len
  len=$(echo -n "$1" | wc -c)    # subshell + fork
  printf '%s' "$len"
  return 0
}

ex5_after() {
  local len="${#1}"               # §5 pure-bash: ${#var}
  printf '%s' "$len"
  return 0
}

run_ex5() {
  header "5 — String Length  (wc -c → \${#var})"
  show_refactor \
    'len=$(echo -n "$1" | wc -c)' \
    'len="${#1}"'
  local test_str="sqlmap --dbs --batch"
  compare "input='$test_str'" \
    "$(ex5_before "$test_str")" \
    "$(ex5_after  "$test_str")"
  return 0
}

# =============================================================================
# Exercise 6 — Count matching lines (the original count_matches refactor)
# =============================================================================
ex6_before() {
  local term="$1"
  local dir="$2"
  local matches
  matches=$(rg -c "$term" "$dir" 2>/dev/null | wc -l)   # two subshells
  printf '%s' "$matches"
  return 0
}

ex6_after() {
  local term="$1"
  local dir="$2"
  local -a _matches=()
  mapfile -t _matches < <(rg -c "$term" "$dir" 2>/dev/null)  # §5 mapfile: wc -l eliminated
  printf '%s' "${#_matches[@]}"
  return 0
}

run_ex6() {
  header "6 — Count Matches  (rg | wc -l → mapfile + \${#arr[@]})"
  show_refactor \
    'matches=$(rg -c "$TERM" "$DIR" 2>/dev/null | wc -l)' \
    'mapfile -t _matches < <(rg -c "$TERM" "$DIR" 2>/dev/null); ${#_matches[@]}'

  if ! command -v rg &>/dev/null; then
    printf '  %b\n' "${YELLOW}[SKIP]${NC} ripgrep not installed — skipping live run"
    return 0
  fi
  compare "dir='$DIR' term='$TERM'" \
    "$(ex6_before "$TERM" "$DIR")" \
    "$(ex6_after  "$TERM" "$DIR")"
  return 0
}

# =============================================================================
# Exercise 7 — Regex capture (grep -oP → BASH_REMATCH)
# =============================================================================
ex7_before() {
  local input="$1"
  local version
  version=$(echo "$input" | grep -oP '\d+\.\d+\.\d+')   # subshell + fork
  printf '%s' "$version"
  return 0
}

ex7_after() {
  local input="$1"
  local version=""
  if [[ "$input" =~ ([0-9]+\.[0-9]+\.[0-9]+) ]]; then   # §5 BASH_REMATCH: no fork
    version="${BASH_REMATCH[1]}"
  fi
  printf '%s' "$version"
  return 0
}

run_ex7() {
  header "7 — Regex Capture  (grep -oP → BASH_REMATCH)"
  show_refactor \
    'version=$(echo "$input" | grep -oP '\''\d+\.\d+\.\d+'\'' )' \
    '[[ "$input" =~ ([0-9]+\.[0-9]+\.[0-9]+) ]] && version="${BASH_REMATCH[1]}"'
  local test_str="Docker version 24.0.5, build abc123"
  compare "input='$test_str'" \
    "$(ex7_before "$test_str")" \
    "$(ex7_after  "$test_str")"
  return 0
}

# =============================================================================
# Summary
# =============================================================================
print_summary() {
  printf '\n%b\n' "${CYAN}══════════════════════════════════════════${NC}"
  printf '%b\n'   "${GREEN}  All exercises complete${NC}"
  printf '%b\n'   "${CYAN}══════════════════════════════════════════${NC}"
  printf '\n%s\n' "Pattern reference:"
  printf '  %-40s %s\n' 'echo "$v" | cut -d. -f2'        '→  ${v##*.}'
  printf '  %-40s %s\n' 'echo "$v" | tr [:lower:] [:upper:]' '→  ${v^^}'
  printf '  %-40s %s\n' 'dirname "$v"'                    '→  ${v%/*}'
  printf '  %-40s %s\n' 'basename "$v"'                   '→  ${v##*/}'
  printf '  %-40s %s\n' 'echo -n "$v" | wc -c'            '→  ${#v}'
  printf '  %-40s %s\n' 'echo "$v" | grep -c "word"'      '→  [[ $v == *word* ]]'
  printf '  %-40s %s\n' 'cmd | wc -l'                     '→  mapfile -t a < <(cmd); ${#a[@]}'
  printf '  %-40s %s\n' 'echo "$v" | grep -oP "regex"'    '→  [[ $v =~ (regex) ]]; ${BASH_REMATCH[1]}'
  printf '\n'
  return 0
}

# =============================================================================
# Main
# =============================================================================
main() {
  debug "main called — DIR=${DIR} TERM=${TERM}"
  run_ex1
  run_ex2
  run_ex3
  run_ex4
  run_ex5
  run_ex6
  run_ex7
  print_summary
  return 0
}

main "$@"
