#!/usr/bin/env bash
# =============================================================================
# subshell_drills.sh — Practice avoiding subshells, one pattern at a time.
#
# USAGE:  bash subshell_drills.sh
#
# HOW TO USE THIS FILE:
#   1. Run it as-is first — read every line of output.
#   2. Scroll to "YOUR TURN" at the bottom.
#   3. Fill in the blanks, re-run, check that YOUR result matches EXPECTED.
# =============================================================================

# ------------------------------------------------------------------
# Tiny helpers — ignore these, they just print nicely
# ------------------------------------------------------------------
_sep()    { printf '\n%s\n' "────────────────────────────────────────"; }
_label()  { printf '\n  %-10s %s\n' "$1" "$2"; }
_pass()   { printf '  %-10s %s  ✓\n' "RESULT:" "$1"; }
_expect() { printf '  %-10s %s\n' "EXPECTED:" "$1"; }
_note()   { printf '  %-10s %s\n' "WHY:" "$1"; }

# ==============================================================================
# DRILL 1 — Get a file extension
#   Pattern:   $(echo "$var" | cut -d. -f2)
#   Replace:   ${var##*.}
# ==============================================================================
_sep
printf 'DRILL 1 — File extension\n'

filename="report.pdf"

# BEFORE (costs one subshell + one fork to cut)
ext_before=$(echo "$filename" | cut -d. -f2)

# AFTER (zero processes — pure bash string stripping)
ext_after="${filename##*.}"
#                   ^^
#  ## = strip from LEFT, longest match
#  *. = "anything up to and including the last dot"
#  What's left: everything after the last dot → the extension

_label "BEFORE:" "$ext_before"
_label "AFTER:"  "$ext_after"
_note  '${filename##*.} strips everything left of the last dot — no fork'


# ==============================================================================
# DRILL 2 — Get the directory path  (dirname)
#   Pattern:   $(dirname "$path")
#   Replace:   ${path%/*}
# ==============================================================================
_sep
printf 'DRILL 2 — Directory name\n'

filepath="/home/user/projects/script.sh"

parent_before=$(dirname "$filepath")
parent_after="${filepath%/*}"
#                      ^
# % = strip from RIGHT, shortest match
# /* = "a slash followed by anything"
# Shortest match stops at the LAST slash → strips only the filename

_label "BEFORE:" "$parent_before"
_label "AFTER:"  "$parent_after"
_note  '${path%/*} strips the filename off the right — no fork'


# ==============================================================================
# DRILL 3 — Get the filename only  (basename)
#   Pattern:   $(basename "$path")
#   Replace:   ${path##*/}
# ==============================================================================
_sep
printf 'DRILL 3 — Base filename\n'

filepath="/home/user/projects/script.sh"

base_before=$(basename "$filepath")
base_after="${filepath##*/}"
#                     ^^^
# ## = strip from LEFT, longest match
# */ = "anything up to and including the last slash"
# What's left: just the filename

_label "BEFORE:" "$base_before"
_label "AFTER:"  "$base_after"
_note  '${path##*/} strips everything up to the last slash — no fork'


# ==============================================================================
# DRILL 4 — Uppercase a string  (tr)
#   Pattern:   $(echo "$str" | tr '[:lower:]' '[:upper:]')
#   Replace:   ${str^^}
# ==============================================================================
_sep
printf 'DRILL 4 — Uppercase\n'

word="hello world"

upper_before=$(echo "$word" | tr '[:lower:]' '[:upper:]')
upper_after="${word^^}"
#                 ^^
# ^^ = uppercase entire string  (bash 4+)
# ^  = uppercase first char only

_label "BEFORE:" "$upper_before"
_label "AFTER:"  "$upper_after"
_note  '${var^^} uppercases in the interpreter — no echo, no tr, no fork'


# ==============================================================================
# DRILL 5 — Lowercase a string  (tr)
#   Pattern:   $(echo "$str" | tr '[:upper:]' '[:lower:]')
#   Replace:   ${str,,}
# ==============================================================================
_sep
printf 'DRILL 5 — Lowercase\n'

word="ALERT: CRITICAL ERROR"

lower_before=$(echo "$word" | tr '[:upper:]' '[:lower:]')
lower_after="${word,,}"
#                 ^^
# ,, = lowercase entire string  (bash 4+)
# ,  = lowercase first char only

_label "BEFORE:" "$lower_before"
_label "AFTER:"  "$lower_after"
_note  '${var,,} lowercases in the interpreter — no echo, no tr, no fork'


# ==============================================================================
# DRILL 6 — String length  (wc -c)
#   Pattern:   $(echo -n "$str" | wc -c)
#   Replace:   ${#str}
# ==============================================================================
_sep
printf 'DRILL 6 — String length\n'

password="S3cur3P@ssw0rd"

len_before=$(echo -n "$password" | wc -c)
len_after="${#password}"
#              ^
# # before the var name = "how many characters"
# Works on arrays too: ${#array[@]} = number of elements

_label "BEFORE:" "$len_before"
_label "AFTER:"  "$len_after"
_note  '${#var} is the length operator — no echo, no wc, no fork'


# ==============================================================================
# DRILL 7 — Substring / word check  (grep -c)
#   Pattern:   $(echo "$str" | grep -c "word")  → returns 0 or 1
#   Replace:   [[ "$str" == *"word"* ]]
# ==============================================================================
_sep
printf 'DRILL 7 — Does string contain a word?\n'

logline="ERROR: connection refused on port 443"

# BEFORE — spawns echo + grep just for a true/false answer
found_before=$(echo "$logline" | grep -c "ERROR")

# AFTER — [[ ]] is a bash built-in, no fork
found_after=0
[[ "$logline" == *"ERROR"* ]] && found_after=1
#               ^       ^
# The * wildcards mean "anything before / after"
# This is a GLOB match (not regex) — fast and built-in

_label "BEFORE:" "$found_before   (1=found, 0=not found)"
_label "AFTER:"  "$found_after   (1=found, 0=not found)"
_note  '[[ == *word* ]] is a built-in glob test — no fork at all'


# ==============================================================================
# QUICK REFERENCE
# ==============================================================================
_sep
printf '\nQUICK REFERENCE\n\n'
printf '  %-40s  %s\n'  'SUBSHELL (expensive)'           'PURE BASH (free)'
printf '  %-40s  %s\n'  '--------------------------------------'  '-----------------------'
printf '  %-40s  %s\n'  '$(echo "$v" | cut -d. -f2)'     '${v##*.}'
printf '  %-40s  %s\n'  '$(dirname "$v")'                 '${v%/*}'
printf '  %-40s  %s\n'  '$(basename "$v")'                '${v##*/}'
printf '  %-40s  %s\n'  '$(echo "$v" | tr lower upper)'   '${v^^}'
printf '  %-40s  %s\n'  '$(echo "$v" | tr upper lower)'   '${v,,}'
printf '  %-40s  %s\n'  '$(echo -n "$v" | wc -c)'         '${#v}'
printf '  %-40s  %s\n'  '$(echo "$v" | grep -c "word")'   '[[ $v == *word* ]] && found=1'
printf '\n'


# ==============================================================================
# YOUR TURN — fill in the blanks below, then re-run the script
#
# Replace every  ???  with the correct pure-bash expression.
# The expected answer is printed so you can check yourself.
# ==============================================================================
_sep
printf '\nYOUR TURN\n'

# --- Challenge 1 ---
challenge1_input="backup_2024.tar.gz"
your_extension="???"                      # get everything after the last dot
expected_ext="gz"

printf '\nChallenge 1 — extension of "%s"\n' "$challenge1_input"
_pass    "$your_extension"
_expect  "$expected_ext"

# --- Challenge 2 ---
challenge2_input="/var/log/syslog"
your_dir="???"                            # get the directory part only
expected_dir="/var/log"

printf '\nChallenge 2 — directory of "%s"\n' "$challenge2_input"
_pass    "$your_dir"
_expect  "$expected_dir"

# --- Challenge 3 ---
challenge3_input="kali"
your_upper="???"                          # uppercase it
expected_upper="KALI"

printf '\nChallenge 3 — uppercase "%s"\n' "$challenge3_input"
_pass    "$your_upper"
_expect  "$expected_upper"

# --- Challenge 4 ---
challenge4_input="SuperSecretKey"
your_len="???"                            # character count
expected_len="14"

printf '\nChallenge 4 — length of "%s"\n' "$challenge4_input"
_pass    "$your_len"
_expect  "$expected_len"

# --- Challenge 5 ---
challenge5_input="disk usage warning: 91% full"
your_check=0
# set your_check=1 if the string contains "warning" (no subshell!)
expected_check="1"

printf '\nChallenge 5 — does "%s" contain "warning"?\n' "$challenge5_input"
_pass    "$your_check"
_expect  "$expected_check"

_sep
printf '\nWhen all RESULT lines match EXPECTED — you are done.\n\n'
