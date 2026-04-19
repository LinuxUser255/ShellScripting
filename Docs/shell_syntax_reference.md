# Comprehensive Shell Scripting Symbol & Syntax Reference

---

## Table of Contents

1. [Command Substitution](#1-command-substitution)
2. [Parameter Expansion](#2-parameter-expansion)
3. [Arithmetic](#3-arithmetic)
4. [Conditional Tests](#4-conditional-tests)
5. [Logical Operators & Control Flow](#5-logical-operators--control-flow)
6. [Redirection & Piping](#6-redirection--piping)
7. [Special Variables](#7-special-variables)
8. [String Operations](#8-string-operations)
9. [Brace Expansion](#9-brace-expansion)
10. [Glob Patterns & Wildcards](#10-glob-patterns--wildcards)
11. [Arrays](#11-arrays)
12. [Associative Arrays](#12-associative-arrays)
13. [Functions](#13-functions)
14. [Process Substitution](#14-process-substitution)
15. [Subshells & Grouping](#15-subshells--grouping)
16. [Job Control](#16-job-control)
17. [Trap & Signals](#17-trap--signals)
18. [Here Documents & Here Strings](#18-here-documents--here-strings)
19. [Variable Declaration & Attributes](#19-variable-declaration--attributes)
20. [Default Values & Null Coalescing](#20-default-values--null-coalescing)
21. [Regular Expressions](#21-regular-expressions)
22. [File Test Operators](#22-file-test-operators)
23. [printf & String Formatting](#23-printf--string-formatting)
24. [Shell Options (set & shopt)](#24-shell-options-set--shopt)
25. [IFS & Word Splitting](#25-ifs--word-splitting)
26. [Quoting Rules](#26-quoting-rules)
27. [Security-Relevant Syntax](#27-security-relevant-syntax)

---

## 1. Command Substitution

```bash
$(command)        # modern syntax — runs command, replaces with stdout output
`command`         # legacy backtick syntax — same as $(), but not nestable
$($(inner))       # nested command substitution — only works with $() form
$(command 2>&1)   # capture both stdout and stderr
output=$(ls -la)  # store command output in a variable
```

---

## 2. Parameter Expansion

```bash
$var              # basic variable expansion (word splitting applies)
${var}            # explicit expansion — required when adjacent to text
${var}suffix      # variable followed immediately by text: ${name}s → names
```

### Substring Extraction
```bash
${var:offset}             # substring from offset to end (0-indexed)
${var:offset:length}      # substring of given length from offset
${var: -3}                # last 3 characters (space before - is required)
${var: -3:2}              # 2 chars starting 3 from end
```

### Pattern Removal
```bash
${var#pattern}            # remove shortest match of pattern from front
${var##pattern}           # remove longest match from front (greedy)
${var%pattern}            # remove shortest match from back
${var%%pattern}           # remove longest match from back (greedy)

# Examples:
file="archive.tar.gz"
${file#*.}    # tar.gz  (removes up to first dot)
${file##*.}   # gz      (removes up to last dot)
${file%.*}    # archive.tar  (removes from last dot)
${file%%.*}   # archive      (removes from first dot)
```

### Substitution
```bash
${var/pattern/replacement}      # replace first match
${var//pattern/replacement}     # replace all matches
${var/#pattern/replacement}     # replace if match at start
${var/%pattern/replacement}     # replace if match at end
```

### Case Conversion (bash 4+)
```bash
${var^}         # uppercase first character
${var^^}        # uppercase all characters
${var,}         # lowercase first character
${var,,}        # lowercase all characters
```

### Length
```bash
${#var}         # length of string value of var
${#arr[@]}      # number of elements in array
```

### Indirect Expansion
```bash
${!var}         # expand the variable whose name is stored in var
name="PATH"
${!name}        # expands to the value of $PATH
```

### Variable Name Listing
```bash
${!prefix*}     # list all variable names starting with prefix
${!prefix@}     # same, but quoted expansion differs
```

---

## 3. Arithmetic

```bash
(( expr ))          # arithmetic evaluation — no $ needed inside
$(( expr ))         # arithmetic expansion — returns the result
let "expr"          # arithmetic command (older style)
expr 5 + 3          # external expr command (POSIX, slow)
```

### Arithmetic Operators
```bash
+    addition
-    subtraction
*    multiplication
/    integer division (truncates)
%    modulo (remainder)
**   exponentiation  (( 2**8 ))  → 256
```

### Bitwise Operators
```bash
&    bitwise AND
|    bitwise OR
^    bitwise XOR
~    bitwise NOT
<<   left shift
>>   right shift
```

### Assignment Operators
```bash
=    assign
+=   add and assign
-=   subtract and assign
*=   multiply and assign
/=   divide and assign
%=   modulo and assign
++   increment (pre or post)
--   decrement (pre or post)
```

### Arithmetic Comparisons (inside (( )))
```bash
==   equal
!=   not equal
<    less than
>    greater than
<=   less than or equal
>=   greater than or equal
```

### Examples
```bash
(( x = 5 + 3 ))     # x = 8
(( x++ ))           # post-increment
(( ++x ))           # pre-increment
echo $(( 16#FF ))   # hex to decimal → 255
echo $(( 8#77 ))    # octal to decimal → 63
echo $(( 2#1010 ))  # binary to decimal → 10
```

---

## 4. Conditional Tests

```bash
[ ]           # POSIX test — portable, more limited
[[ ]]         # bash extended test — supports regex, no word splitting
test expr     # equivalent to [ expr ]
```

### String Tests
```bash
[ -z "$var" ]        # true if string is empty (zero length)
[ -n "$var" ]        # true if string is non-empty
[ "$a" = "$b" ]      # string equality (POSIX: use =, not ==)
[[ "$a" == "$b" ]]   # string equality (bash)
[[ "$a" != "$b" ]]   # string inequality
[[ "$a" < "$b" ]]    # lexicographic less than (bash only)
[[ "$a" > "$b" ]]    # lexicographic greater than (bash only)
[[ "$a" =~ regex ]]  # regex match (bash only) — see Section 21
```

### Integer Comparison ([ ] style)
```bash
[ "$a" -eq "$b" ]   # equal
[ "$a" -ne "$b" ]   # not equal
[ "$a" -lt "$b" ]   # less than
[ "$a" -gt "$b" ]   # greater than
[ "$a" -le "$b" ]   # less than or equal
[ "$a" -ge "$b" ]   # greater than or equal
```

### Compound Conditions
```bash
[ cond1 ] && [ cond2 ]     # AND (POSIX-safe)
[ cond1 ] || [ cond2 ]     # OR  (POSIX-safe)
[[ cond1 && cond2 ]]       # AND inside [[ ]]
[[ cond1 || cond2 ]]       # OR  inside [[ ]]
[[ ! cond ]]               # NOT
```

---

## 5. Logical Operators & Control Flow

```bash
&&        # logical AND — run right side only if left exits 0 (success)
||        # logical OR  — run right side only if left exits non-zero (failure)
!         # logical NOT — negates exit status
;         # command separator — sequential execution regardless of exit status
;;        # end of case pattern in case statements
;&        # fall through to next case pattern (bash 4+)
;;&       # test next case pattern after falling through (bash 4+)
```

### Short-Circuit Examples
```bash
mkdir /tmp/dir && cd /tmp/dir          # cd only if mkdir succeeds
ping -c1 host || echo "host down"      # echo only if ping fails
[ -f file ] && cat file || echo "missing"  # ternary-style
```

### Control Structures
```bash
if condition; then
  commands
elif condition; then
  commands
else
  commands
fi

while condition; do
  commands
done

until condition; do       # loop until condition is true (opposite of while)
  commands
done

for var in list; do
  commands
done

for (( i=0; i<10; i++ )); do   # C-style for loop
  commands
done

case "$var" in
  pattern1)
    commands ;;
  pattern2|pattern3)            # multiple patterns with |
    commands ;;
  *)                            # default/catch-all
    commands ;;
esac

select var in option1 option2; do   # interactive menu
  commands
done
```

---

## 6. Redirection & Piping

```bash
>           # redirect stdout to file (overwrite)
>>          # redirect stdout to file (append)
<           # redirect stdin from file
2>          # redirect stderr to file
2>>         # append stderr to file
&>          # redirect both stdout and stderr to file (bash)
&>>         # append both stdout and stderr (bash)
2>&1        # redirect stderr to wherever stdout is going
1>&2        # redirect stdout to wherever stderr is going
>/dev/null  # discard stdout
2>/dev/null # discard stderr
&>/dev/null # discard all output
```

### Pipes
```bash
cmd1 | cmd2             # pipe stdout of cmd1 to stdin of cmd2
cmd1 |& cmd2            # pipe stdout AND stderr of cmd1 to cmd2 (bash)
cmd1 | cmd2 | cmd3      # pipeline chain
```

### File Descriptors
```bash
exec 3>file             # open file on fd 3 for writing
exec 3>>file            # open file on fd 3 for appending
exec 3<file             # open file on fd 3 for reading
exec 3<>file            # open file on fd 3 for read/write
exec 3>&-               # close fd 3
echo "data" >&3         # write to fd 3
read line <&3           # read from fd 3
```

### Named Pipes (FIFOs)
```bash
mkfifo /tmp/mypipe          # create a named pipe
cmd1 > /tmp/mypipe &        # write to pipe in background
cmd2 < /tmp/mypipe          # read from pipe
```

---

## 7. Special Variables

```bash
$?      # exit status of the last foreground command (0 = success)
$$      # PID of the current shell process
$!      # PID of the last background process
$0      # name of the script or shell
$1-$9   # positional parameters (script arguments)
${10}   # positional parameters beyond 9 require braces
$#      # number of positional parameters
$@      # all positional parameters as separate words (preserves quoting)
$*      # all positional parameters as a single word
"$@"    # expands to "$1" "$2" "$3" ... — always use this in loops
"$*"    # expands to "$1 $2 $3" — all args as one string
$-      # current shell option flags (set with set builtin)
$_      # last argument of the previous command
```

### BASH-Specific Variables
```bash
$BASH           # path to the bash binary
$BASH_VERSION   # bash version string
$BASHPID        # PID of current bash process (differs from $$ in subshells)
$BASH_SOURCE    # array of source filenames (for stack tracing)
$BASH_LINENO    # array of line numbers in call stack
$FUNCNAME       # array of function names in call stack
$LINENO         # current line number in the script
$RANDOM         # random integer 0–32767 (changes each access)
$SECONDS        # seconds since the shell started
$OLDPWD         # previous working directory
$PWD            # current working directory
$HOME           # home directory of current user
$PATH           # colon-separated list of directories to search for commands
$IFS            # internal field separator (default: space, tab, newline)
$EDITOR         # default text editor
$SHELL          # path to the current shell
$HOSTNAME       # machine hostname
$OSTYPE         # operating system type string
$MACHTYPE       # machine hardware type
$PIPESTATUS     # array of exit statuses of last pipeline's commands
$REPLY          # default variable for read builtin when no variable given
$HISTSIZE       # number of commands to remember in history
$HISTFILE       # location of history file
```

---

## 8. String Operations

```bash
# Length
${#var}                     # length of string

# Concatenation
str="${str1}${str2}"        # concatenate two strings
str+=" more"                # append to string (bash)

# Repetition (no built-in — use printf or loop)
printf '%.0s-' {1..20}     # print 20 dashes

# Trim whitespace (no built-in — use parameter expansion)
trimmed="${var#"${var%%[![:space:]]*}"}"   # ltrim
trimmed="${var%"${var##*[![:space:]]}"}"   # rtrim

# Contains substring
[[ "$var" == *"substr"* ]]  # true if var contains substr

# Starts with
[[ "$var" == prefix* ]]

# Ends with
[[ "$var" == *suffix ]]

# Split string into array
IFS=',' read -ra arr <<< "$csv_string"

# Join array into string
joined=$(IFS=','; echo "${arr[*]}")

# Reverse a string
rev <<< "$str"

# String to uppercase/lowercase (bash 4+)
upper="${var^^}"
lower="${var,,}"
```

---

## 9. Brace Expansion

> Brace expansion happens **before** any other expansion. It generates lists. No spaces inside braces unless quoted.

```bash
{a,b,c}           # generates: a b c
{1..5}            # sequence: 1 2 3 4 5
{1..10..2}        # sequence with step: 1 3 5 7 9
{a..z}            # alphabet: a b c ... z
{A..Z}            # uppercase alphabet
{01..05}          # zero-padded: 01 02 03 04 05

# Practical examples:
echo file{1,2,3}.txt          # file1.txt file2.txt file3.txt
cp file.txt{,.bak}            # copy file.txt to file.txt.bak
mkdir -p project/{src,tests,docs,bin}
touch report_{jan,feb,mar}_2025.csv
mv file.{old,new}             # rename file.old to file.new

# Nested brace expansion:
echo {a,b}{1,2}               # a1 a2 b1 b2

# In command injection context (no spaces needed):
{cmd,arg}                     # expands to: cmd arg (space-free command execution)
{sleep,5}                     # expands to: sleep 5
{cat,/etc/passwd}             # expands to: cat /etc/passwd
```

---

## 10. Glob Patterns & Wildcards

```bash
*           # match any string (including empty), excluding leading dot
?           # match any single character
[abc]       # match any one character in the set
[a-z]       # match any one character in range
[^abc]      # match any character NOT in the set
[!abc]      # same as [^abc] (POSIX style)
```

### Extended Globs (enable with: `shopt -s extglob`)
```bash
?(pattern)    # zero or one occurrence of pattern
*(pattern)    # zero or more occurrences
+(pattern)    # one or more occurrences
@(pattern)    # exactly one occurrence
!(pattern)    # anything that does NOT match pattern

# Examples:
ls !(*.log)           # list everything except .log files
rm +(file)[0-9].txt   # remove file1.txt, file2.txt etc.
```

### Globstar (enable with: `shopt -s globstar`)
```bash
**          # match any path recursively (directories and files)
**/*.sh     # all .sh files in any subdirectory
```

### Null Glob (enable with: `shopt -s nullglob`)
```bash
# Without nullglob: unmatched globs pass through literally
# With nullglob:    unmatched globs expand to nothing
shopt -s nullglob
for f in *.xyz; do echo "$f"; done   # does nothing if no .xyz files
```

---

## 11. Arrays (Indexed)

```bash
arr=(a b c d)             # declare and initialize
arr=()                    # declare empty array
declare -a arr            # explicitly declare as array

arr[0]="first"            # assign by index
arr+=("new element")      # append element

${arr[0]}                 # access element at index 0
${arr[-1]}                # last element (bash 4.3+)
${arr[@]}                 # all elements (separate words)
${arr[*]}                 # all elements (one word)
${#arr[@]}                # number of elements
${!arr[@]}                # all indices
${arr[@]:2}               # elements from index 2 onward
${arr[@]:1:3}             # 3 elements starting at index 1

unset arr[2]              # delete element at index 2
unset arr                 # delete entire array

# Iteration
for item in "${arr[@]}"; do
  echo "$item"
done

# Iteration with index
for i in "${!arr[@]}"; do
  echo "$i: ${arr[$i]}"
done

# Slicing
slice=("${arr[@]:1:3}")

# Copy array
copy=("${arr[@]}")

# Concatenate arrays
combined=("${arr1[@]}" "${arr2[@]}")

# readarray / mapfile (read lines into array)
readarray -t lines < file.txt
mapfile -t lines < file.txt       # same as readarray
```

---

## 12. Associative Arrays (bash 4+)

```bash
declare -A map                    # must explicitly declare

map["key"]="value"                # assign
map=(["k1"]="v1" ["k2"]="v2")    # initialize with values

${map["key"]}                     # access by key
${map[@]}                         # all values
${!map[@]}                        # all keys
${#map[@]}                        # number of key-value pairs

unset map["key"]                  # delete a key
unset map                         # delete entire map

# Check if key exists
[[ -v map["key"] ]]               # true if key exists

# Iteration
for key in "${!map[@]}"; do
  echo "$key = ${map[$key]}"
done
```

---

## 13. Functions

```bash
# Definition styles (both equivalent)
function name() { commands; }
name() { commands; }

# Multi-line
my_func() {
  local var="local to function"   # local scope
  echo "$1"                       # access first argument
  return 0                        # explicit return value (0-255)
}

# Calling
my_func arg1 arg2

# Capture return value (exit code)
my_func arg
echo $?

# Capture output
result=$(my_func arg)

# Recursive function
countdown() {
  (( $1 <= 0 )) && return
  echo "$1"
  countdown $(( $1 - 1 ))
}

# Function with default argument
greet() {
  local name="${1:-World}"
  echo "Hello, $name"
}

# Pass array to function (by name reference, bash 4.3+)
process_array() {
  local -n arr_ref=$1             # nameref
  for item in "${arr_ref[@]}"; do
    echo "$item"
  done
}
process_array my_array
```

---

## 14. Process Substitution

> Treats the output of a command as a file. Does not create a subshell for the outer command.

```bash
<(command)    # output of command treated as a file (readable)
>(command)    # input to command treated as a file (writable)

# Examples:
diff <(sort file1) <(sort file2)        # diff two sorted outputs without temp files
comm <(sort a.txt) <(sort b.txt)        # compare sorted files
while read line; do ...; done < <(cmd)  # loop over command output without subshell
tee >(gzip > out.gz) >(wc -l) > /dev/null   # fan out to multiple commands
```

---

## 15. Subshells & Grouping

```bash
( commands )        # subshell — runs in child process, changes don't affect parent
{ commands; }       # command group — runs in CURRENT shell (note: space and ; required)

# Subshell examples:
(cd /tmp && ls)     # cd is local to subshell — parent dir unchanged
x=1; (x=2); echo $x    # prints 1 — subshell change doesn't propagate

# Command group example:
{ echo "start"; cmd1; cmd2; } > output.txt   # redirect all output to file

# Subshell for isolation:
(
  set -e
  risky_cmd1
  risky_cmd2
)   # if either fails, only the subshell exits

# BASHPID vs $$ in subshells:
echo $$         # parent PID
( echo $$ )     # still parent PID (inherited)
( echo $BASHPID )   # actual subshell PID
```

---

## 16. Job Control

```bash
cmd &           # run command in background
jobs            # list background jobs
fg              # bring last background job to foreground
fg %2           # bring job 2 to foreground
bg              # resume last suspended job in background
bg %2           # resume job 2 in background
Ctrl+Z          # suspend foreground job
Ctrl+C          # interrupt foreground job (sends SIGINT)
kill %1         # kill job 1
wait            # wait for all background jobs to finish
wait $PID       # wait for specific PID
disown %1       # remove job from job table (won't be killed on shell exit)
nohup cmd &     # run immune to hangup signal (survives shell logout)
```

---

## 17. Trap & Signals

```bash
trap 'commands' SIGNAL     # run commands when signal is received

# Common signals:
trap 'echo "Ctrl+C caught"' INT       # SIGINT (Ctrl+C)
trap 'echo "terminating"' TERM        # SIGTERM
trap 'cleanup_func' EXIT              # runs on any exit
trap 'echo "line $LINENO"' ERR        # runs on any error
trap '' INT                           # ignore SIGINT
trap - INT                            # reset to default behavior

# Cleanup pattern (most common use):
cleanup() {
  rm -f /tmp/tempfile
  echo "cleaned up"
}
trap cleanup EXIT INT TERM

# Signals reference:
# SIGHUP  (1)  — hangup (terminal closed)
# SIGINT  (2)  — interrupt (Ctrl+C)
# SIGQUIT (3)  — quit (Ctrl+\)
# SIGKILL (9)  — kill (cannot be caught or ignored)
# SIGTERM (15) — terminate (default kill signal)
# SIGSTOP (19) — stop (cannot be caught or ignored)
# SIGCONT (18) — continue stopped process
# SIGUSR1 (10) — user-defined signal 1
# SIGUSR2 (12) — user-defined signal 2
```

---

## 18. Here Documents & Here Strings

```bash
# Here document — multi-line stdin
command << EOF
line one
line two
$variable is expanded
EOF

# Quoted heredoc — NO expansion (treats content as literal)
command << 'EOF'
$variable is NOT expanded
`backticks` not executed
EOF

# Indented heredoc — strip leading tabs (bash, use tabs not spaces)
command <<- EOF
	indented content
	leading tabs stripped
EOF

# Here string — single string as stdin
command <<< "string input"
read var <<< "hello world"
grep pattern <<< "$variable"

# Heredoc to file
cat > /tmp/file.txt << EOF
content line 1
content line 2
EOF

# Heredoc into variable
var=$(cat << EOF
multi
line
string
EOF
)
```

---

## 19. Variable Declaration & Attributes

```bash
declare -i var        # integer — arithmetic automatically applied on assignment
declare -r var        # readonly — cannot be changed or unset
declare -x var        # export — available to child processes (same as export)
declare -a var        # indexed array
declare -A var        # associative array (bash 4+)
declare -l var        # lowercase — value auto-converted to lowercase
declare -u var        # uppercase — value auto-converted to uppercase
declare -n ref=other  # nameref — var is a reference to another variable
declare -p var        # print declaration of var (useful for debugging)
declare -f            # print all function definitions
declare -F            # print all function names

readonly var          # make variable readonly
export var            # export to environment
unset var             # delete variable
local var             # function-local variable (only inside functions)

# Print all environment variables:
env
printenv
declare -x
```

---

## 20. Default Values & Null Coalescing

```bash
${var:-default}       # use default if var is unset or empty
${var:=default}       # assign default to var if unset or empty, then expand
${var:+alternate}     # use alternate if var IS set and non-empty
${var:?error_msg}     # print error and exit if var is unset or empty

# Without colon — only triggers if unset (not if empty):
${var-default}        # use default if var is unset (empty string is ok)
${var=default}        # assign if unset
${var+alternate}      # use alternate if set (even if empty)
${var?error_msg}      # error if unset only

# Examples:
name="${1:-Anonymous}"          # script arg with fallback
: "${CONFIG:=/etc/app.conf}"    # set default if unset
echo "${DEBUG:+--verbose}"      # add flag only if DEBUG is set
${REQUIRED:?'REQUIRED must be set'}  # fail fast if not set
```

---

## 21. Regular Expressions

```bash
# =~ operator in [[ ]] — matches ERE (Extended Regular Expression)
[[ "$str" =~ ^[0-9]+$ ]]       # true if str is all digits
[[ "$str" =~ ^[a-zA-Z] ]]      # true if str starts with a letter
[[ "$str" =~ error|fail ]]      # true if str contains "error" or "fail"

# Capture groups stored in BASH_REMATCH array
[[ "2025-04-19" =~ ([0-9]{4})-([0-9]{2})-([0-9]{2}) ]]
echo "${BASH_REMATCH[0]}"   # full match: 2025-04-19
echo "${BASH_REMATCH[1]}"   # year: 2025
echo "${BASH_REMATCH[2]}"   # month: 04
echo "${BASH_REMATCH[3]}"   # day: 19

# Common regex patterns:
^           # start of string
$           # end of string
.           # any single character
*           # zero or more of preceding
+           # one or more of preceding
?           # zero or one of preceding
[abc]       # character class
[^abc]      # negated character class
(a|b)       # alternation
{n}         # exactly n repetitions
{n,m}       # between n and m repetitions
\d          # digit (not supported in bash ERE — use [0-9])
\w          # word character (not supported — use [a-zA-Z0-9_])
\s          # whitespace (not supported — use [[:space:]])

# POSIX character classes (supported in bash):
[[:alpha:]]     # letters
[[:digit:]]     # digits
[[:alnum:]]     # letters and digits
[[:space:]]     # whitespace
[[:upper:]]     # uppercase letters
[[:lower:]]     # lowercase letters
[[:punct:]]     # punctuation
[[:print:]]     # printable characters
```

---

## 22. File Test Operators

```bash
[ -e file ]     # exists (any type)
[ -f file ]     # exists and is a regular file
[ -d file ]     # exists and is a directory
[ -L file ]     # exists and is a symbolic link
[ -s file ]     # exists and is non-empty (size > 0)
[ -r file ]     # exists and is readable
[ -w file ]     # exists and is writable
[ -x file ]     # exists and is executable
[ -b file ]     # exists and is a block device
[ -c file ]     # exists and is a character device
[ -p file ]     # exists and is a named pipe (FIFO)
[ -S file ]     # exists and is a socket
[ -g file ]     # exists and has setgid bit set
[ -u file ]     # exists and has setuid bit set
[ -k file ]     # exists and has sticky bit set
[ -O file ]     # exists and is owned by current user
[ -G file ]     # exists and belongs to current group
[ -t fd ]       # file descriptor fd is open and refers to a terminal

# File comparison:
[ file1 -nt file2 ]    # file1 is newer than file2 (by modification time)
[ file1 -ot file2 ]    # file1 is older than file2
[ file1 -ef file2 ]    # file1 and file2 are the same file (same inode)
```

---

## 23. printf & String Formatting

```bash
printf "format" args     # formatted output (no trailing newline by default)
printf "%s\n" "$var"     # print string with newline
printf "%d\n" 42         # print integer
printf "%05d\n" 42       # zero-padded integer: 00042
printf "%10s\n" "right"  # right-aligned in 10-char field
printf "%-10s\n" "left"  # left-aligned in 10-char field
printf "%f\n" 3.14       # floating point
printf "%.2f\n" 3.14159  # 2 decimal places: 3.14
printf "%x\n" 255        # hexadecimal: ff
printf "%X\n" 255        # uppercase hex: FF
printf "%o\n" 8          # octal: 10
printf "%b\n" "line1\nline2"  # interpret backslash escapes

# Escape sequences:
\n    newline
\t    tab
\r    carriage return
\\    literal backslash
\a    bell
\e    escape character (useful for ANSI color codes)

# ANSI color codes:
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${RED}Error:${RESET} something failed"
printf "${GREEN}Success${RESET}\n"

# printf to variable:
printf -v myvar "formatted %s" "string"   # store in var without subshell
```

---

## 24. Shell Options (set & shopt)

### set options
```bash
set -e          # exit immediately on error (errexit)
set -u          # treat unset variables as errors (nounset)
set -x          # print each command before executing (xtrace) — for debugging
set -o pipefail # pipeline fails if any command in it fails
set -n          # read commands but don't execute (syntax check)
set -v          # print input lines as they are read (verbose)
set -f          # disable glob expansion (noglob)
set -C          # prevent overwriting files with > (noclobber)
set -b          # report job status immediately
set -h          # remember locations of commands (hashall)

# Combined best practice for robust scripts:
set -euo pipefail

# Turn off options:
set +e          # re-enable error tolerance
set +x          # stop tracing

# View all current options:
set -o
```

### shopt options
```bash
shopt -s extglob        # enable extended glob patterns
shopt -s globstar       # enable ** recursive glob
shopt -s nullglob       # unmatched globs expand to nothing
shopt -s dotglob        # * matches dotfiles too
shopt -s nocaseglob     # case-insensitive glob
shopt -s autocd         # cd to dir by just typing dirname
shopt -s cdspell        # autocorrect minor cd typos
shopt -s checkwinsize   # update LINES/COLUMNS after each command
shopt -s histappend     # append to history instead of overwriting
shopt -s cmdhist        # save multi-line commands as one history entry
shopt -s dirspell       # spell check directory names in completion

# Query a specific option:
shopt extglob           # shows if on or off

# Disable:
shopt -u extglob
```

---

## 25. IFS & Word Splitting

```bash
IFS             # Internal Field Separator — controls word splitting
                # Default value: space, tab, newline (" \t\n")

# Split CSV into array:
IFS=',' read -ra arr <<< "a,b,c,d"

# Join array with custom delimiter:
IFS=':'; echo "${arr[*]}"     # a:b:c:d

# Disable word splitting temporarily:
IFS=''                        # empty IFS — no splitting at all

# Reset to default:
unset IFS                     # restores default splitting behavior

# Read file line by line safely:
while IFS= read -r line; do   # IFS= prevents trimming leading/trailing whitespace
  echo "$line"                # -r prevents backslash interpretation
done < file.txt

# Process NULL-delimited output (for filenames with spaces):
while IFS= read -r -d '' file; do
  echo "$file"
done < <(find . -name "*.sh" -print0)
```

---

## 26. Quoting Rules

```bash
'single quotes'   # literal — no expansion whatsoever, no escaping
"double quotes"   # allows: $var, $(cmd), `cmd`, \escape sequences
$'...'            # ANSI-C quoting — interprets \n \t \\ etc.
\                 # escape next character (outside quotes)
""                # empty string

# Double quotes prevent:
#   word splitting
#   glob expansion
# Double quotes allow:
#   variable expansion: "$var"
#   command substitution: "$(cmd)"
#   arithmetic: "$((expr))"
#   certain escapes: \$ \` \\ \" \newline

# Always quote variables to prevent word splitting and glob issues:
echo "$var"           # correct
echo $var             # dangerous — splits on whitespace, expands globs

# ANSI-C quoting examples:
$'\t'   # tab
$'\n'   # newline
$'\033' # escape
$'\\'   # backslash
$'\''   # single quote

# Quote concatenation:
echo 'it'"'"'s'    # it's — mix quoting styles to include single quote
echo "it's"        # simpler — single quote fine inside double quotes
```

---

## 27. Security-Relevant Syntax

> Critical patterns for secure scripting and understanding injection vulnerabilities.

### Command Injection Vectors
```bash
# All of these execute commands:
`command`                   # backtick substitution
$(command)                  # modern substitution
$((command))                # arithmetic (limited but eval-like in some contexts)
eval "command"              # executes string as shell code — extremely dangerous
exec command                # replaces shell with command

# Space substitutes (bypass space filters):
${IFS}                      # expands to default IFS (space tab newline)
{cmd,arg}                   # brace expansion: cmd arg (no space needed)
cmd$'\x20'arg               # ANSI-C hex space
cmd$'\t'arg                 # tab as separator (sometimes works)
X=$'\x20';cmd${X}arg        # store space in variable
```

### Injection-Safe Patterns
```bash
# NEVER do this with user input:
eval "$user_input"
bash -c "$user_input"
sh -c "$user_input"
system("$user_input")       # (other languages calling shell)

# Safe command building — use arrays, never strings:
cmd=("grep" "-r" "--include=*.py" "$user_pattern" "$dir")
"${cmd[@]}"                 # each element is a separate argument

# Validate input before use:
[[ "$input" =~ ^[a-zA-Z0-9_-]+$ ]] || { echo "invalid"; exit 1; }

# Use -- to separate options from arguments:
grep -- "$user_pattern" file     # prevents pattern starting with - from being a flag
```

### Privilege & Environment
```bash
# Check if running as root:
(( EUID == 0 )) && echo "root"
[ "$EUID" -ne 0 ] && { echo "must be root"; exit 1; }

# Drop privileges (after doing what needs root):
exec su -c "command" nobody

# Sanitize PATH in scripts:
export PATH='/usr/local/bin:/usr/bin:/bin'

# Unset dangerous variables:
unset IFS LD_PRELOAD LD_LIBRARY_PATH CDPATH ENV BASH_ENV

# Restrict file creation permissions:
umask 077     # new files: owner read/write only (600)
umask 022     # new files: world-readable (644) — default
```

### Temp File Safety
```bash
# NEVER do this (race condition / predictable path):
tmpfile="/tmp/script.$$"

# ALWAYS use mktemp:
tmpfile=$(mktemp)
tmpdir=$(mktemp -d)

# Cleanup on exit:
trap 'rm -f "$tmpfile"' EXIT
```

### Readonly & Restricted Shell
```bash
readonly var            # prevent modification
declare -r var          # same
bash -r                 # restricted shell — limits dangerous operations
rbash                   # same (restricted bash)
```

---

## Quick Reference Card

| Symbol | Meaning |
|--------|---------|
| `$()` | command substitution |
| `` `` ` `` ` `` | legacy command substitution |
| `${}` | parameter expansion |
| `$(())` | arithmetic expansion |
| `(())` | arithmetic evaluation |
| `[[]]` | extended conditional test |
| `[]` | POSIX test |
| `()` | subshell |
| `{}` | command grouping / brace expansion |
| `<()` | process substitution (read) |
| `>()` | process substitution (write) |
| `\|` | pipe |
| `\|&` | pipe stdout+stderr |
| `>` | redirect stdout (overwrite) |
| `>>` | redirect stdout (append) |
| `2>` | redirect stderr |
| `&>` | redirect stdout+stderr |
| `<<<` | here string |
| `<<EOF` | here document |
| `&&` | logical AND |
| `\|\|` | logical OR |
| `!` | logical NOT |
| `;` | command separator |
| `&` | background execution |
| `$?` | last exit status |
| `$$` | current PID |
| `$!` | last background PID |
| `$#` | argument count |
| `$@` | all arguments (separate) |
| `$*` | all arguments (combined) |
| `${IFS}` | field separator (space substitute) |
| `{a,b}` | brace expansion list |
| `{1..n}` | brace expansion sequence |

---

*Reference covers bash 4.x/5.x. Some features (associative arrays, declare -n, brace step sequences) require bash 4+. POSIX sh compatibility noted where relevant.*
