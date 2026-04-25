# No-Subshell Bash — Refactoring Reference Guide

*Based on: Pure Bash Bible · bash-best-practices.md · Google Shell Style Guide*
*Rule annotations reference `bash-best-practices.md` sections (e.g. §5, §2)*

---

## What Is a Subshell and Why Does It Cost You?

When Bash evaluates `$(...)`, it does not just run a command. It forks the
entire shell process — creating a full copy of the current process in memory,
complete with every variable, every open file descriptor, and every function
definition. That child process runs, writes its output to a pipe, exits, and
the parent reads from that pipe.

Even for something as trivial as extracting a file extension, that sequence
looks like this under the hood:

```
fork() → child shell created
  → child execs "cut" (another fork)
  → cut writes to pipe stdout
  → cut exits
→ parent reads pipe
→ child shell exits
→ parent resumes
```

That is two process creations (`fork` + `exec`) for a one-character string
operation. On a workstation running a handful of commands, this is invisible.
In a loop over thousands of files, or in a function called dozens of times per
second, it becomes the dominant runtime cost.

**The three concrete costs of every subshell:**

1. **Memory** — `fork()` copies the parent's address space. Bash is not small.
2. **Time** — process creation, scheduling, and teardown take real CPU cycles.
3. **Scope isolation** — variables set inside a subshell are lost when it exits.
   This third cost is the one that causes bugs, not just slowness.

```bash
# The scope isolation trap — this silently does nothing useful
get_value() {
  RESULT=$(compute_something)   # RESULT is set inside the subshell
  echo "$RESULT"                # printed, but RESULT is gone after $() exits
}
# In the parent: RESULT is still unset
```

Bash parameter expansion, built-in test constructs, and `mapfile` do all of
this inside the current shell process — no fork, no pipe, no scope boundary.

---

## The §2 &&-Trap: Why Every Refactored Function Needs `return 0`

Before the patterns, one critical rule from `bash-best-practices.md §2` that
applies to nearly every function in this guide.

Under `set -euo pipefail`, a function that ends on a `[[ ]]` test or `&&`
chain exits with a non-zero code when the condition is false. That non-zero
exit propagates up and **silently kills the entire script** with no error
message.

```bash
# BROKEN under set -e
# When DEBUG=0: [[ ]] returns 1, && short-circuits,
# function exits 1, set -e terminates the script silently
debug() { [[ "${DEBUG:-0}" == 1 ]] && printf '[DEBUG] %s\n' "$*"; }

# SAFE — return 0 is load-bearing, not cosmetic
debug() {
  [[ "${DEBUG:-0}" == 1 ]] && printf '[DEBUG] %s\n' "$*"
  return 0  # §2 &&-trap: explicit return 0 under set -e
}
```

Every function in this guide follows the safe pattern. When you see
`return 0` at the end of a function, it is not boilerplate — it is a
deliberate guard against `set -e` triggering on a conditional that
evaluated false.

---

## Pattern 1 — File Extension (`cut` → `##*.`)

### The subshell version

```bash
get_extension() {
  local filename="$1"
  local ext
  ext=$(echo "$filename" | cut -d. -f2)   # fork: echo + cut
  printf '%s\n' "$ext"
  return 0
}
```

`echo` writes the string to a pipe. `cut` reads from that pipe, splits on `.`,
and returns field 2. Two processes for a string operation that never needed
to leave the shell.

### The pure-bash version

```bash
get_extension() {
  local filename="$1"
  local ext="${filename##*.}"   # §5 no-fork: parameter expansion
  printf '%s\n' "$ext"
  return 0
}
```

### How `##*.` works

`#` and `##` strip a pattern from the **left** side of the string.

| Operator | Greed  | Meaning                            |
|----------|--------|------------------------------------|
| `#pat`   | Short  | Strip shortest match from the left |
| `##pat`  | Long   | Strip longest match from the left  |

The pattern `*.` means "any characters followed by a literal dot."
`##` (longest match) strips everything up to and including the **last** dot.
What remains is the final extension.

```
filename = "archive.tar.gz"
##*.  →  strip "archive.tar."  →  "gz"
#*.   →  strip "archive."      →  "tar.gz"   (shortest, stops at first dot)
```

Use `##*.` when you want the final extension. Use `#*.` when you want
everything after the first dot (including compound extensions like `tar.gz`).

### Live comparison

```bash
filename="exploit.py"
ext_before=$(echo "$filename" | cut -d. -f2)   # spawns 2 processes
ext_after="${filename##*.}"                     # zero processes

# Both produce: "py"
```

---

## Pattern 2 — Directory Path (`dirname` → `%/*`)

### The subshell version

```bash
get_dir() {
  local filepath="$1"
  local parent
  parent=$(dirname "$filepath")   # fork: dirname binary
  printf '%s\n' "$parent"
  return 0
}
```

### The pure-bash version

```bash
get_dir() {
  local filepath="$1"
  local parent="${filepath%/*}"   # §5 no-fork: strip from right
  printf '%s\n' "$parent"
  return 0
}
```

### How `%/*` works

`%` and `%%` strip a pattern from the **right** side of the string.

| Operator | Greed  | Meaning                             |
|----------|--------|-------------------------------------|
| `%pat`   | Short  | Strip shortest match from the right |
| `%%pat`  | Long   | Strip longest match from the right  |

The pattern `/*` means "a slash followed by anything." `%` (shortest match)
stops at the **last** slash, stripping only the final path component — leaving
the directory.

```
filepath = "/home/kali/tools/exploit.py"
%/*   →  strip "/exploit.py"   →  "/home/kali/tools"
%%/*  →  strip "/tools/exploit.py"  →  "/home/kali"   (strips from first /)
```

`%/*` is the correct operator for dirname behavior. `%%/*` would strip too
much.

### Live comparison

```bash
filepath="/home/kali/htb/targets/box.txt"
parent_before=$(dirname "$filepath")   # spawns dirname binary
parent_after="${filepath%/*}"          # zero processes

# Both produce: "/home/kali/htb/targets"
```

> **Edge case**: If `filepath` has no `/`, `%/*` returns the original string
> unchanged. `dirname` returns `.`. For scripts where bare filenames are
> possible, handle this explicitly or use `dirname` and accept the fork.

---

## Pattern 3 — Filename Only (`basename` → `##*/`)

### The subshell version

```bash
get_basename() {
  local filepath="$1"
  local base
  base=$(basename "$filepath")   # fork: basename binary
  printf '%s\n' "$base"
  return 0
}
```

### The pure-bash version

```bash
get_basename() {
  local filepath="$1"
  local base="${filepath##*/}"   # §5 no-fork: strip from left up to last slash
  printf '%s\n' "$base"
  return 0
}
```

### How `##*/` works

`##*/` is the mirror image of `%/*`. Where `%/*` stripped the right side
(the filename), `##*/` strips the left side (everything up to and including
the last slash), leaving only the filename.

```
filepath = "/home/kali/tools/exploit.py"
##*/  →  strip "/home/kali/tools/"  →  "exploit.py"
```

The pair `%/*` and `##*/` always go together: one gives you the directory,
the other gives you the filename.

```bash
filepath="/home/kali/tools/exploit.py"
dir="${filepath%/*}"     # → "/home/kali/tools"
base="${filepath##*/}"   # → "exploit.py"
```

---

## Pattern 4 — Uppercase (`tr` → `^^`)

### The subshell version

```bash
to_upper() {
  local result
  result=$(echo "$1" | tr '[:lower:]' '[:upper:]')   # fork: echo + tr
  printf '%s\n' "$result"
  return 0
}
```

### The pure-bash version

```bash
to_upper() {
  local result="${1^^}"   # §5 no-fork: case expansion (bash 4+)
  printf '%s\n' "$result"
  return 0
}
```

### How `^^` and `,,` work

These are Bash 4.0+ **case modification operators**. They live inside `${}`,
after the variable name.

| Operator | Effect                        |
|----------|-------------------------------|
| `^^`     | Uppercase the entire string   |
| `^`      | Uppercase first character only|
| `,,`     | Lowercase the entire string   |
| `,`      | Lowercase first character only|

```bash
word="hello world"
upper="${word^^}"    # → "HELLO WORLD"
first="${word^}"     # → "Hello world"

word="ALERT: ERROR"
lower="${word,,}"    # → "alert: error"
first="${word,}"     # → "aLERT: ERROR"
```

### Live comparison

```bash
word="hack the box"
upper_before=$(echo "$word" | tr '[:lower:]' '[:upper:]')   # 2 forks
upper_after="${word^^}"                                      # 0 forks

# Both produce: "HACK THE BOX"
```

> **Bash version check**: `^^` and `,,` require Bash 4.0 or later. macOS
> ships with Bash 3.2 (GPLv2). On macOS without a Homebrew Bash, use `tr`
> or check the version with `bash --version`. On Kali, Ubuntu, and most
> Linux systems, Bash 5.x is standard — `^^` is safe.

---

## Pattern 5 — Lowercase (`tr` → `,,`)

### The subshell version

```bash
to_lower() {
  local result
  result=$(echo "$1" | tr '[:upper:]' '[:lower:]')   # fork: echo + tr
  printf '%s\n' "$result"
  return 0
}
```

### The pure-bash version

```bash
to_lower() {
  local result="${1,,}"   # §5 no-fork: case expansion (bash 4+)
  printf '%s\n' "$result"
  return 0
}
```

### Live comparison

```bash
word="ALERT: CRITICAL ERROR"
lower_before=$(echo "$word" | tr '[:upper:]' '[:lower:]')   # 2 forks
lower_after="${word,,}"                                      # 0 forks

# Both produce: "alert: critical error"
```

---

## Pattern 6 — String Length (`wc -c` → `${#var}`)

### The subshell version

```bash
get_length() {
  local len
  len=$(echo -n "$1" | wc -c)   # fork: echo + wc; -n required to suppress newline
  printf 'Length: %s\n' "$len"
  return 0
}
```

### The pure-bash version

```bash
get_length() {
  local len="${#1}"   # §5 no-fork: length operator
  printf 'Length: %s\n' "$len"
  return 0
}
```

### How `${#var}` works

When `#` appears inside `${}` **before the variable name**, it means "number
of characters in this variable's value." It is distinct from the `#` and `##`
operators which appear **after** the variable name and strip patterns.

```bash
str="SuperSecretKey"
len="${#str}"    # → 14

# Also works on arrays — returns number of elements
declare -a items=("one" "two" "three")
count="${#items[@]}"   # → 3
```

The `echo -n` in the subshell version is not optional — without `-n`, `echo`
appends a newline and `wc -c` overcounts by 1. `${#var}` has no newline edge
case because it operates directly on the variable value in memory.

### Live comparison

```bash
password="S3cur3P@ssw0rd"
len_before=$(echo -n "$password" | wc -c)   # 2 forks; -n required
len_after="${#password}"                     # 0 forks; no edge case

# Both produce: 14
```

---

## Pattern 7 — Substring / Word Check (`grep -c` → `[[ == *word* ]]`)

### The subshell version

```bash
contains_word() {
  local sentence="$1"
  local found
  found=$(echo "$sentence" | grep -c "error")   # fork: echo + grep
  printf '%s\n' "$found"
  return 0
}
```

### The pure-bash version

```bash
contains_word() {
  local sentence="$1"
  local found=0
  [[ "$sentence" == *"error"* ]] && found=1   # §5 no-fork: built-in glob test
  printf '%s\n' "$found"
  return 0
}
```

### How `[[ == *word* ]]` works

`[[ ]]` is a Bash built-in test construct — it never forks. The `*` characters
are **glob wildcards** meaning "zero or more of any character." Together,
`*"error"*` means "anything, then the literal string 'error', then anything"
— which is substring match.

This is a glob match, **not a regex**. For regex matching, use `=~` instead
(see Pattern 8). Glob matching is faster and sufficient for fixed substring
checks.

```bash
sentence="sql error on line 42"

# Glob — fast, literal substring
[[ "$sentence" == *"error"* ]]   # true

# Regex — slower, but supports patterns
[[ "$sentence" =~ error[[:space:]]on ]]   # true
```

The `&&` after the test sets `found=1` only when the match succeeds. Under
`set -e`, this line is safe because the function ends with `return 0` — the
`&&-trap` is handled. Without `return 0`, a non-matching sentence would leave
the function with exit code 1 and kill the script silently.

### Live comparison

```bash
logline="ERROR: connection refused on port 443"
found_before=$(echo "$logline" | grep -c "ERROR")   # 2 forks, returns "1" or "0"
found_after=0
[[ "$logline" == *"ERROR"* ]] && found_after=1      # 0 forks

# Both produce: 1
```

---

## Pattern 8 — Regex Capture (`grep -oP` → `BASH_REMATCH`)

### The subshell version

```bash
extract_version() {
  local input="$1"
  local version
  version=$(echo "$input" | grep -oP '\d+\.\d+\.\d+')   # fork: echo + grep -oP
  printf '%s\n' "$version"
  return 0
}
```

### The pure-bash version

```bash
extract_version() {
  local input="$1"
  local version=""
  if [[ "$input" =~ ([0-9]+\.[0-9]+\.[0-9]+) ]]; then   # §5 no-fork: BASH_REMATCH
    version="${BASH_REMATCH[1]}"
  fi
  printf '%s\n' "$version"
  return 0
}
```

### How `=~` and `BASH_REMATCH` work

`[[ expr =~ regex ]]` is a Bash built-in regex test. When the match succeeds:

- `BASH_REMATCH[0]` holds the **entire matched string**
- `BASH_REMATCH[1]` holds **capture group 1** (the first `(...)`)
- `BASH_REMATCH[2]` holds capture group 2, and so on

The regex uses POSIX ERE syntax. Note that `grep -oP` uses Perl-compatible
regex (`\d`), while `=~` uses ERE (`[0-9]`). The two are similar but not
identical — `\d`, `\w`, `\s` must be written as `[0-9]`, `[a-zA-Z0-9_]`,
`[[:space:]]` in ERE.

```bash
input="Docker version 24.0.5, build abc123"

if [[ "$input" =~ ([0-9]+\.[0-9]+\.[0-9]+) ]]; then
  echo "Full match:     ${BASH_REMATCH[0]}"   # → "24.0.5"
  echo "Capture group:  ${BASH_REMATCH[1]}"   # → "24.0.5"
fi
```

The `if` form is used here instead of `[[ ]] && ...` because the match may
fail and we want clean handling without the `&&-trap` risk.

### Live comparison

```bash
test_str="Docker version 24.0.5, build abc123"
version_before=$(echo "$test_str" | grep -oP '\d+\.\d+\.\d+')   # 2 forks
version_after=""
[[ "$test_str" =~ ([0-9]+\.[0-9]+\.[0-9]+) ]] && version_after="${BASH_REMATCH[1]}"

# Both produce: "24.0.5"
```

---

## Pattern 9 — Counting Lines (`cmd | wc -l` → `mapfile + ${#arr[@]}`)

This is the most nuanced pattern. It eliminates `wc -l` and, as a bonus,
gives you the actual lines as an array for further processing.

### The subshell version

```bash
count_matches() {
  local term="$1"
  local dir="$2"
  local count
  count=$(rg -c "$term" "$dir" 2>/dev/null | wc -l)   # two forks: rg pipeline + wc
  printf 'Files with matches: %s\n' "$count"
  return 0
}
```

### The pure-bash version

```bash
count_matches() {
  local term="$1"
  local dir="$2"
  local -a matches=()
  mapfile -t matches < <(rg -c "$term" "$dir" 2>/dev/null)   # §5 mapfile: wc -l eliminated
  printf 'Files with matches: %s\n' "${#matches[@]}"
  return 0
}
```

### How `mapfile` and `< <(...)` work

This line has two distinct mechanisms — they are easy to confuse.

**`mapfile -t arr`** is a Bash built-in that reads lines from stdin into an
array. The `-t` flag strips the trailing newline from each element. Each line
of output becomes one array element. No fork. Runs in the current shell, so
the array survives after the line completes.

**`< <(cmd)`** is process substitution, not a subshell. The `<(cmd)` part
tells Bash to run `cmd` and make its stdout available as a file descriptor
(a named pipe under `/dev/fd/`). The leading `<` redirects that file
descriptor into `mapfile`. The key distinction:

```bash
# WRONG — pipe puts mapfile in a subshell (right side of |)
# The array is populated inside the subshell and lost immediately
rg -c "$term" "$dir" | mapfile -t matches
echo "${#matches[@]}"   # → 0, array is gone

# RIGHT — process substitution runs mapfile in the current shell
mapfile -t matches < <(rg -c "$term" "$dir")
echo "${#matches[@]}"   # → correct count, array is intact
```

After `mapfile` populates the array, `${#matches[@]}` gives the element count
— identical to what `wc -l` would have returned, but computed entirely by the
interpreter.

**The extra benefit**: the array is now available. You can iterate over the
matching files, inspect them, sort them — without running any additional
commands.

```bash
count_matches() {
  local term="$1"
  local dir="$2"
  local -a matches=()
  mapfile -t matches < <(rg -c "$term" "$dir" 2>/dev/null)
  printf 'Files with matches: %s\n' "${#matches[@]}"

  # The array is available — no extra command needed
  local line
  for line in "${matches[@]}"; do
    printf '  %s\n' "$line"
  done
  return 0
}
```

### Live comparison

```bash
# BEFORE — two subshells
count=$(rg -c "$TERM" "$DIR" 2>/dev/null | wc -l)

# AFTER — wc -l eliminated; array available for reuse
mapfile -t _matches < <(rg -c "$TERM" "$DIR" 2>/dev/null)
count="${#_matches[@]}"
```

---

## Pattern 10 — String Replacement (`sed` → `${var/old/new}`)

### The subshell version

```bash
replace_word() {
  local str="$1"
  local result
  result=$(echo "$str" | sed 's/foo/bar/')   # fork: echo + sed
  printf '%s\n' "$result"
  return 0
}
```

### The pure-bash version

```bash
replace_word() {
  local str="$1"
  local result="${str/foo/bar}"   # §5 no-fork: replace first occurrence
  printf '%s\n' "$result"
  return 0
}
```

### How `${var/old/new}` works

| Operator         | Effect                              |
|------------------|-------------------------------------|
| `${var/old/new}` | Replace **first** occurrence of `old` with `new` |
| `${var//old/new}`| Replace **all** occurrences          |
| `${var/#old/new}`| Replace only if `old` is at the **start** |
| `${var/%old/new}`| Replace only if `old` is at the **end**   |

```bash
str="the cat sat on the cat mat"

first="${str/cat/dog}"     # → "the dog sat on the cat mat"
all="${str//cat/dog}"      # → "the dog sat on the dog mat"
prefix="${str/#the/a}"     # → "a cat sat on the cat mat"
suffix="${str/%mat/rug}"   # → "the cat sat on the cat rug"
```

The pattern supports globs (`*`, `?`, `[...]`) but not full regex. For regex
replacement you still need `sed`. Use `${var//old/new}` for simple literal
substitution — it covers the majority of `sed 's/foo/bar/g'` use cases.

---

## Pattern 11 — Field Extraction (`cut` → `%%:*` / `#*:`)

### The subshell version

```bash
get_host() {
  local hostport="$1"           # e.g. "192.168.1.1:8080"
  local host
  host=$(echo "$hostport" | cut -d: -f1)   # fork: echo + cut
  printf '%s\n' "$host"
  return 0
}
```

### The pure-bash version

```bash
get_host() {
  local hostport="$1"
  local host="${hostport%%:*}"   # §5 no-fork: strip from right, longest match
  printf '%s\n' "$host"
  return 0
}

get_port() {
  local hostport="$1"
  local port="${hostport##*:}"   # §5 no-fork: strip from left, longest match
  printf '%s\n' "$port"
  return 0
}
```

### How `%%:*` and `##*:` work for field splitting

```
hostport = "192.168.1.1:8080"

%%:*  →  strip ":8080"      →  "192.168.1.1"   (strip right, longest match of :*)
##*:  →  strip "192.168.1.1:"  →  "8080"        (strip left, longest match of *:)
```

For two-field strings (host:port, user:group, key:value), this covers `cut`
entirely. For more than two fields, `IFS`-splitting with `read -r` is the
pure-bash alternative:

```bash
# Three-field split without a subshell
line="alice:1001:staff"
IFS=: read -r username uid group <<< "$line"
# username="alice"  uid="1001"  group="staff"
```

The `<<<` is a here-string — it feeds a string directly to a command's stdin
without a pipe, and runs in the current shell.

---

## The `local` + Command Substitution Rule (§10)

When you do use a subshell (sometimes unavoidable — see the next section),
never combine `local` with command substitution on the same line. Under
`set -e`, `local` always returns 0 regardless of whether the command
substitution failed, masking errors silently.

```bash
# WRONG — local masks the exit code of the command substitution
# If "might_fail" exits non-zero, set -e does NOT trigger
local result=$(might_fail)

# RIGHT — two lines: local declares, assignment propagates the exit code
local result
result=$(might_fail)   # §10 local+subshell: assign separately so set -e fires
```

This applies every time you cannot eliminate the subshell. The declaration
and assignment must be on separate lines.

---

## When You Cannot Avoid a Subshell

Not everything can be eliminated. These cases require external commands and
therefore subshells — use them correctly, not fearfully.

| Unavoidable case | Why pure-bash falls short |
|---|---|
| `$(date +%Y-%m-%d)` | Time/date has no built-in — `date` is required |
| `$(curl ...)` | Network I/O — no built-in alternative |
| `$(find ...)` with complex predicates | Glob expansion covers simple cases; complex `-exec` chains need `find` |
| `$(openssl rand ...)` | Cryptographic operations require external tools |
| `$(git rev-parse ...)` | VCS queries require the `git` binary |
| `$(sed ...)` for multi-line regex | `${var/old/new}` handles single-line literals only |

When a subshell is unavoidable:

1. Declare `local` and assign on **separate lines** (§10).
2. Quote the command substitution: `result="$(cmd)"`.
3. Consider whether the result can be reused from the array instead
   of re-running the command.

```bash
# Unavoidable — time has no bash built-in
get_timestamp() {
  local ts             # §10 local+subshell: declare first
  ts="$(date +%s)"    # §10 local+subshell: assign separately
  printf '%s\n' "$ts"
  return 0
}
```

---

## Complete Quick-Reference Table

| Subshell pattern (avoid) | Pure-bash replacement (prefer) | §Rule |
|---|---|---|
| `$(echo "$v" \| cut -d. -f2)` | `"${v##*.}"` | §5 |
| `$(echo "$v" \| cut -d: -f1)` | `"${v%%:*}"` | §5 |
| `$(echo "$v" \| cut -d: -f2)` | `"${v##*:}"` | §5 |
| `$(dirname "$v")` | `"${v%/*}"` | §5 |
| `$(basename "$v")` | `"${v##*/}"` | §5 |
| `$(echo "$v" \| tr lower upper)` | `"${v^^}"` | §5 |
| `$(echo "$v" \| tr upper lower)` | `"${v,,}"` | §5 |
| `$(echo "$v" \| sed 's/a/b/')` | `"${v/a/b}"` | §5 |
| `$(echo "$v" \| sed 's/a/b/g')` | `"${v//a/b}"` | §5 |
| `$(echo -n "$v" \| wc -c)` | `"${#v}"` | §5 |
| `$(cmd \| wc -l)` | `mapfile -t a < <(cmd); "${#a[@]}"` | §5 |
| `$(echo "$v" \| grep -c "word")` | `[[ "$v" == *"word"* ]] && found=1` | §5 |
| `$(echo "$v" \| grep -oP "regex")` | `[[ "$v" =~ (regex) ]]; "${BASH_REMATCH[1]}"` | §5 |

---

## Operator Cheat Sheet

### Strip from the left (`#`, `##`)

```
${var#pattern}   →  strip shortest match from left
${var##pattern}  →  strip longest match from left

${file##*.}      →  extension           ("report.tar.gz" → "gz")
${file#*.}       →  compound extension  ("report.tar.gz" → "tar.gz")
${path##*/}      →  filename only       ("/a/b/c.txt"    → "c.txt")
```

### Strip from the right (`%`, `%%`)

```
${var%pattern}   →  strip shortest match from right
${var%%pattern}  →  strip longest match from right

${path%/*}       →  directory only      ("/a/b/c.txt"    → "/a/b")
${var%%:*}       →  before first colon  ("host:port"     → "host")
${var%.*}        →  strip extension     ("report.tar.gz" → "report.tar")
```

### Case modification (Bash 4+)

```
${var^^}   →  UPPERCASE ALL
${var,,}   →  lowercase all
${var^}    →  Capitalize first character
${var,}    →  lowercase first character
```

### Length and replacement

```
${#var}          →  character count of var
${#array[@]}     →  element count of array
${var/old/new}   →  replace first occurrence
${var//old/new}  →  replace all occurrences
${var/#old/new}  →  replace at start only
${var/%old/new}  →  replace at end only
```

### Safe defaults (§8)

```
${var:-default}  →  use default if var is unset or empty
${var:=default}  →  assign and use default if var is unset or empty
${var:?message}  →  exit with message if var is unset or empty
```

---

## Pre-Commit Checklist for No-Subshell Code

Before committing any refactored function, verify:

- [ ] Every `$(echo | cmd)` replaced with a parameter expansion where possible
- [ ] Every function that ends on `[[ ]]` or `&&` has an explicit `return 0` (§2)
- [ ] Any remaining `$()` uses declare-then-assign, never `local x=$(cmd)` (§10)
- [ ] `mapfile -t arr < <(cmd)` used instead of `cmd | mapfile` (pipe trap)
- [ ] `[[ ]]` used for all tests — never `[ ]` (§7)
- [ ] All variables inside functions declared `local` (§10)
- [ ] `printf` used instead of `echo` for all output (§7)
- [ ] ShellCheck passes with no unaddressed warnings (§15)
