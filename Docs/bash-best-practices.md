# Bash / Shell Scripting Best Practices & Rule Set
*(Comprehensive, battle-tested — synthesized from Pure Bash Bible, Google Shell Style Guide,
Greg's Wiki/BashFAQ/BashPitfalls, ShellCheck, process-level parallelism research, and
real-world debugging sessions — updated 2026)*

**Goal**: Write scripts that are **safe**, **fast**, **lightweight**, **maintainable**, and **secure**.

Use this document as a rule set for Warp, LLM agents, or code review. For every fix made,
add an inline comment referencing the section (e.g. `# §1 strict-mode` or `# §2.3 no-fork`).
Never change script behavior — only fix violations.

---

## ⚠️ The Golden Rule: `set -euo pipefail` Makes Bash Behave Like a Compiled Language

> Any non-zero exit code, anywhere, for any reason, terminates the script immediately and silently.
> Patterns that are harmless without strict mode become **silent killers** with it.
> Every function, every helper, every conditional chain must be written with the assumption
> that a non-zero exit will terminate the entire script with no output and no error message.

This is the single most important thing to internalize before reading the rest of this document.

---

## §1 — Core Foundations (Always Apply)

### Shebang
```bash
#!/usr/bin/env bash
```
- Portable — finds bash on `$PATH` rather than hardcoding `/bin/bash`.
- `/usr/bin/env` is one of the few binaries guaranteed to be in the same location
  across all Unix-like systems.
- Do not change it to `#!/bin/bash` — breaks on macOS (Homebrew), NixOS, some BSDs.

### Strict Mode
Place immediately after the shebang and header block — before any logic:
```bash
set -euo pipefail
IFS=$'\n\t'
```

| Flag | Meaning |
|------|---------|
| `-e` | Exit on any **non-zero return code** — including inside functions, short-circuit `&&` chains, and `[[ ]]` tests that evaluate false. A function that ends on a failed test **is a non-zero exit**. |
| `-u` | Treat unset variables as an error. Any reference to an uninitialized variable terminates the script. Use `${var:-default}` for optional values. |
| `-o pipefail` | A pipeline fails if **any** command in it fails, not just the last one. |
| `IFS=$'\n\t'` | Prevents word-splitting on spaces. The `\t` prevents tab-separated fields from being split unexpectedly in loops over file lists. Without this, filenames with spaces silently corrupt loops. |

### Error Output Helper
All errors must go to stderr:
```bash
err() { printf '[ERROR] %s\n' "$*" >&2; }  # §1 errors to stderr
```

### Constants
Declare constants as `readonly` immediately after strict mode:
```bash
readonly MIN_VERSION="1.27.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

### No SUID/SGID
Never set SUID or SGID on shell scripts — it is a security risk and behavior
is undefined across platforms.

---

## §2 — The `&&` Short-Circuit Trap (Critical Under `set -e`)

> **This is the most common source of silent script termination under strict mode.**
> Any function or expression that ends on a `&&` or `||` chain, or a `[[ ]]`
> test that can evaluate false, must explicitly `return 0` if the false case
> is not an error condition.

```bash
# BROKEN under set -e — returns exit code 1 when condition is false,
# silently killing the entire script at the call site
is_verbose() { [[ "${VERBOSE:-0}" == 1 ]] && printf 'verbose mode\n'; }

# SAFE — always returns 0; set -e has nothing to trigger on
is_verbose() {
  [[ "${VERBOSE:-0}" == 1 ]] && printf 'verbose mode\n'
  return 0  # §2 &&-trap: explicit return 0 under set -e
}
```

**Common places this silently kills scripts:**
- Guard/flag check functions (`is_debug`, `is_verbose`, `has_feature`)
- Conditional print helpers (`log_if`, `warn_if`, `debug`)
- Any function whose last line is a `[[ ]]` test or a `&&`/`||` chain
- The `debug()` helper itself (see §6)

**Safe patterns for conditional-only functions:**
```bash
# Option 1: explicit return 0
my_guard() {
  [[ "$CONDITION" == "yes" ]] && do_thing
  return 0
}

# Option 2: negate with if/fi (no trailing non-zero possible)
my_guard() {
  if [[ "$CONDITION" == "yes" ]]; then
    do_thing
  fi
}
```

---

## §3 — Strict Mode Interaction With Argument Parsing

`set -u` kills the script silently if `parse_args()` or any pre-main function
references a variable that has not been initialized. This is the most common
cause of `--help` and similar flags producing no output.

**Rules:**
1. Initialize ALL variables with defaults before `set -euo pipefail` takes effect,
   or use `${var:-}` safe expansion throughout.
2. `--help` must be detected **before** the parsing loop, using a glob match
   against the full argument string, referencing only `:-`-safe variables.
3. `show_help()` must be defined as its own function, using only string literals
   or variables explicitly initialized at script top.

```bash
# §3 set-u safe: detect --help before loop can touch unset vars
parse_args() {
  [[ "${*}" == *"--help"* ]] && { show_help; exit 0; }

  for arg in "$@"; do
    case "$arg" in
      --help)        show_help; exit 0 ;;
      --verbose)     VERBOSE=1 ;;
      --dry-run)     DRY_RUN=1 ;;
      *)             err "Unknown argument: $arg"; exit 2 ;;
    esac
  done
}
```

---

## §4 — Dependency & Environment Validation

### Rule: Never Execute a Binary to Test Its Presence

> Use `command -v` exclusively for existence checks.
> Executing an unknown or broken binary can trigger crashes, Python tracebacks,
> or other uncontrolled output before the script can handle anything.

```bash
# WRONG — executes the binary, may crash or produce unexpected output
if docker-compose --version &>/dev/null; then ...

# RIGHT — filesystem/PATH check only, never executes the binary
if command -v docker-compose &>/dev/null; then ...
```

### Canonical `check_requirements()` Pattern

Run this as the **first call in `main()`**, before any side effects:

```bash
check_requirements() {
  local -a missing=()
  for cmd in docker git curl; do
    command -v "$cmd" &>/dev/null || missing+=("$cmd")  # §4 command -v only
  done
  if (( ${#missing[@]} > 0 )); then
    err "Missing required commands: ${missing[*]}"
    exit 1
  fi
}
```

### Required Environment Variables
Use `${VAR:?message}` to fail fast with a clear message if a required
environment variable is unset:
```bash
: "${API_KEY:?API_KEY must be set in the environment}"
```

### Version Comparison (Pure Bash — No `grep` Fork)
```bash
# §2.3 pure-bash: semver comparison without grep fork
version_ge() {
  local IFS=.
  local -a a=( ${1} ) b=( ${2} )
  (( a[0] > b[0] )) && return 0
  (( a[0] == b[0] && a[1] > b[1] )) && return 0
  (( a[0] == b[0] && a[1] == b[1] && a[2] >= b[2] )) && return 0
  return 1
}

# Usage
if ! version_ge "$detected_ver" "$MIN_VERSION"; then
  err "Version $detected_ver is below minimum $MIN_VERSION"
  exit 1
fi
```

---

## §5 — Performance Optimization & Fork Reduction

### Prefer Built-ins Over External Commands
Every external command spawns a new process. Use Bash parameter expansion instead:

| External (avoid) | Pure Bash (prefer) |
|---|---|
| `echo "$str" \| tr '[:lower:]' '[:upper:]'` | `"${str^^}"` |
| `echo "$str" \| tr '[:upper:]' '[:lower:]'` | `"${str,,}"` |
| `echo "$str" \| sed 's/foo/bar/'` | `"${str/foo/bar}"` |
| `echo "$str" \| cut -d: -f1` | `"${str%%:*}"` |
| `echo "$str" \| grep -o 'pattern'` | `[[ "$str" =~ pattern ]] && "${BASH_REMATCH[1]}"` |
| `basename "$path"` | `"${path##*/}"` |
| `dirname "$path"` | `"${path%/*}"` |
| `wc -l < file` | `mapfile -t lines < file; echo "${#lines[@]}"` |

### Avoid Subshells Unless Necessary
```bash
# AVOID — spawns a subshell
result=$(some_function)

# PREFER — if the function sets a variable, use a nameref or global
some_function() { RESULT="computed"; }
some_function
echo "$RESULT"
```

### Redirect Once Outside Loops
```bash
# BAD — opens/closes the file on every iteration
while read -r line; do echo "$line" >> output.txt; done < input.txt

# GOOD — one redirect for the entire loop
while read -r line; do echo "$line"; done < input.txt > output.txt
```

### Use `grep -q` When Output Is Discarded
```bash
if grep -q "pattern" file; then ...   # §5 grep -q: silent match, no pipe needed
```

---

## §6 — Process-Level Parallelism

Use parallelism **only** after minimizing forks and confirming the task is I/O
or CPU-bound. Parallelism adds overhead — for short-lived tasks it is often slower.

### Simple Background Jobs
```bash
cmd1 & cmd2 & wait   # §6 parallelism: background + wait, lightest overhead
```

### Thread Pool With Concurrency Limit
```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

MAX_JOBS=$(nproc)   # or set manually
readonly MAX_JOBS
joblist=()

log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }

my_task() {
  local task_id="$1"
  log "Starting $task_id"
  sleep 2
  log "Finished $task_id"
}

run_in_pool() {
  my_task "$1" &
  joblist+=($!)
  if [[ ${#joblist[@]} -ge $MAX_JOBS ]]; then
    wait "${joblist[0]}" 2>/dev/null || true
    joblist=("${joblist[@]:1}")  # §6 pool: shift first PID off the queue
  fi
  return 0  # §2 &&-trap: explicit return 0
}

main() {
  for i in {1..12}; do run_in_pool "$i"; done
  wait
  log "All tasks complete"
}

main "$@"
```

### File/List Processing — `xargs -P`
```bash
find . -name "*.log" | xargs -P4 -I{} gzip "{}"  # §6 xargs -P: parallel with limit
```

### Complex Workflows — GNU Parallel
```bash
parallel -j8 process_file ::: *.log  # §6 GNU parallel: ordered output, retries
```

### Parallelism Safety Rules
- Always `wait` — never leave zombie processes.
- Limit jobs to `2× nproc` as a safe starting ceiling.
- Redirect per-job output to separate log files:
  ```bash
  ./job.sh "$i" > "logs/job${i}.out" 2>&1 &
  ```
- Use `mktemp` for temporary files in parallel scripts.
- Never launch thousands of background jobs without limiting — it will thrash the system.

---

## §7 — Tool Selection

| Use | Instead of |
|---|---|
| `[[ ... ]]` | `[ ... ]` — supports regex, no word-splitting |
| `(( ... ))` | `[ ]` with `-eq`, `-lt` etc. |
| `printf` | `echo` — more portable and predictable |
| `read -r` | `read` — avoids backslash escape processing |
| `grep -q` | `grep \| /dev/null` |
| `command -v` | `which`, `type`, or executing the binary |

---

## §8 — Code Practices

### Quote Everything
```bash
# Always quote variables and command substitutions
"${var}"          # preferred over "$var" for clarity
"$(command)"      # always quote command substitutions
"${array[@]}"     # always quote array expansions
```

### The `${var:-default}` Pattern
Use for optional variables that may be unset, especially under `set -u`:
```bash
DEBUG="${DEBUG:-0}"       # safe default under set -u
VERBOSE="${VERBOSE:-0}"
LISTEN_IP="${LISTEN_IP:-0.0.0.0}"
```

### `readonly` for Constants
```bash
readonly MIN_VERSION="1.27.0"
readonly MAX_RETRIES=3
```

### Avoid `for` Over Command Substitution
```bash
# BAD — word-splits on spaces, breaks on filenames with spaces
for f in $(ls *.log); do ...

# GOOD — safe glob expansion
for f in *.log; do ...

# GOOD — safe multiline command output
mapfile -t lines < <(some_command)
for line in "${lines[@]}"; do ...
```

### Check Return Codes Explicitly
```bash
if ! do_something; then
  err "do_something failed"
  exit 1
fi
```

---

## §9 — Error Handling & Security

### Exit Codes
| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | General runtime error |
| `2` | Misuse / bad arguments (wrong flags, missing args) |
| `127` | Command not found |

> Never use `exit 0` after printing an error. Never use `exit 1` for bad arguments — use `exit 2`.

### `trap` for Cleanup
Register cleanup **before** any side-effecting work:
```bash
trap 'cleanup' EXIT INT TERM

cleanup() {
  # Runs on any exit — including set -e triggered exits
  [[ -n "${tmp_file:-}" ]] && rm -f "$tmp_file"
  debug "Cleanup complete"
  return 0  # §2 &&-trap
}
```

### Input Validation
```bash
case "$user_input" in
  [a-zA-Z0-9_-]*) ;;   # acceptable
  *) err "Invalid input: $user_input"; exit 2 ;;
esac
```

### Security Rules
- Never use `eval`.
- Never parse `ls` output — use globs or `mapfile`.
- Never trust user input in filenames or commands.
- Validate all CLI args and environment variables before use.
- Do not pipe to `sh` or `bash` from untrusted sources.

---

## §10 — Functions

### Declaration Style
```bash
function_name() {
  local arg1="$1"
  local arg2="$2"
  # ...
}
```

### Rules
- `local` for **every** variable inside a function — no exceptions.
- Declare and assign on separate lines when using command substitution
  (combined declaration masks the exit code under `set -e`):
  ```bash
  # BAD — local masks the exit code of the command substitution
  local result=$(might_fail)

  # GOOD — assignment is a separate statement; set -e can catch failures
  local result
  result=$(might_fail)
  ```
- No implicit globals — pass all inputs as explicit arguments.
- Keep functions short and single-purpose.

### Function Definition Order
> Functions must be defined **before** their first call site.
> Define in this order: utility functions (`err`, `debug`, `log`, `show_help`)
> → logic functions → `main()` last.

---

## §11 — The `debug()` Helper (Canonical Safe Pattern)

The commonly documented pattern for `debug()` is **broken under `set -e`**:

```bash
# BROKEN — when DEBUG != 1, [[ ]] returns 1, && short-circuits,
# function exits with code 1, set -e kills the script silently
debug() { [[ "$DEBUG" == 1 ]] && echo "[DEBUG] $*"; }
```

**The correct pattern — `return 0` is load-bearing, not decoration:**
```bash
debug() {
  [[ "${DEBUG:-0}" == 1 ]] && printf '[DEBUG] %s\n' "$*"
  return 0  # §2 &&-trap: must always exit 0 under set -e
}
```

Add a `debug` call at the start of every major function:
```bash
my_function() {
  debug "my_function called with args: $*"
  # ...
  return 0
}
```

---

## §12 — Style & Formatting (Google Shell Style Guide)

- **Indentation**: 2 spaces — no tabs.
- **Line length**: ≤ 80 characters. Break long pipelines and strings.
- **Pipelines**: One command per line, `|` at the start of the continuation line:
  ```bash
  some_command \
    | grep -v "exclude" \
    | sort \
    | uniq
  ```
- **Control structures**: `; then` / `; do` on the same line as `if`/`for`/`while`.
  `fi` / `done` aligned on their own line.
- **Variables**: local/lowercase+underscores (`my_var`); constants UPPER_CASE.
- **Arrays**: Use Bash arrays for lists — never space-separated strings.
  ```bash
  declare -a items=("one" "two" "three")
  for item in "${items[@]}"; do ...
  ```

---

## §13 — Color Output

### Standard Color Variable Block
```bash
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Suppress color when stdout is not a terminal (pipes, logs, CI)
[[ -t 1 ]] || { RED=''; GREEN=''; YELLOW=''; CYAN=''; NC=''; }
```

### Usage — always `printf '%b\n'`, never `echo -e`
```bash
printf '%b\n' "${GREEN}[✓]${NC} Task complete"
printf '%b\n' "${RED}[ERROR]${NC} Something failed"
```

---

## §14 — Files, Paths & Script Self-Location

### Script Self-Location (Robust Pattern)
```bash
# Works when called from any directory, including via symlink
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
```

### Path Rules
- Quote every path variable: `"${SCRIPT_DIR}/deploy"`.
- Use absolute paths in cron or system scripts.
- Use `mktemp` for temporary files:
  ```bash
  tmp_file=$(mktemp)
  trap 'rm -f "$tmp_file"' EXIT
  ```

---

## §15 — ShellCheck

- **Mandatory**: Run ShellCheck on every script. Integrate in editor and CI.
- Fix all warnings unless intentionally suppressed.
- When a violation is intentional, suppress with a line-level `disable` comment
  and always add an explanation:
  ```bash
  # shellcheck disable=SC2086 — intentional: $COMPOSE_CMD must word-split into "docker compose"
  $COMPOSE_CMD pull
  ```
- Common suppressions that need documenting:
  - `SC2086`: intentional word-splitting
  - `SC2046`: intentional word-splitting in command substitution
  - `SC2206`: intentional unquoted array assignment

---

## §16 — Testing & Debugging

```bash
bash -n script.sh   # syntax check only — no execution
bash -x script.sh   # step-by-step execution trace
```

Enable trace mode conditionally inside the script:
```bash
[[ "${TRACE:-0}" == 1 ]] && set -x
```

---

## §17 — Script Structure Template

```bash
#!/usr/bin/env bash
# =============================================================================
# SCRIPT:       script_name.sh
# DESCRIPTION:  What this script does and why.
# USAGE:        ./script_name.sh [OPTIONS]
# OPTIONS:
#   --verbose     Enable verbose output
#   --dry-run     Print actions without executing
#   --help        Show this help message and exit
# DEPENDENCIES: curl (>= 7.0), docker compose plugin (>= 1.27.0)
# AUTHOR:
# REPO:
# =============================================================================
set -euo pipefail
IFS=$'\n\t'

# --- Constants ---------------------------------------------------------------
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly MIN_VERSION="1.0.0"

# --- Color output ------------------------------------------------------------
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'
[[ -t 1 ]] || { RED=''; GREEN=''; YELLOW=''; CYAN=''; NC=''; }

# --- State variables (with safe defaults for set -u) -------------------------
VERBOSE="${VERBOSE:-0}"
DRY_RUN="${DRY_RUN:-0}"
DEBUG="${DEBUG:-0}"

# --- Utility functions (define first) ----------------------------------------

err() { printf '%b\n' "${RED}[ERROR]${NC} $*" >&2; }

debug() {
  [[ "${DEBUG:-0}" == 1 ]] && printf '[DEBUG] %s\n' "$*"
  return 0  # §2 &&-trap: must always exit 0 under set -e
}

log() { printf '%b\n' "${CYAN}[INFO]${NC} $*"; }

show_help() {
  printf '%s\n' "Usage: $(basename "$0") [OPTIONS]"
  printf '%s\n' ""
  printf '%s\n' "Options:"
  printf '%s\n' "  --verbose     Enable verbose output"
  printf '%s\n' "  --dry-run     Print actions without executing"
  printf '%s\n' "  --help        Show this help message"
}

# --- Dependency validation ---------------------------------------------------

check_requirements() {
  debug "check_requirements called"
  local -a missing=()
  for cmd in curl docker; do
    command -v "$cmd" &>/dev/null || missing+=("$cmd")  # §4 command -v only
  done
  if (( ${#missing[@]} > 0 )); then
    err "Missing required commands: ${missing[*]}"
    exit 1
  fi
  return 0
}

# --- Argument parsing --------------------------------------------------------

parse_args() {
  debug "parse_args called with: $*"
  [[ "${*}" == *"--help"* ]] && { show_help; exit 0; }  # §3 pre-loop help check

  for arg in "$@"; do
    case "$arg" in
      --verbose)  VERBOSE=1 ;;
      --dry-run)  DRY_RUN=1 ;;
      --help)     show_help; exit 0 ;;
      *)          err "Unknown argument: ${arg}"; exit 2 ;;
    esac
  done
  return 0
}

# --- Cleanup -----------------------------------------------------------------

cleanup() {
  debug "cleanup called"
  return 0
}

trap 'cleanup' EXIT INT TERM

# --- Main logic --------------------------------------------------------------

run_task() {
  debug "run_task called"
  log "Running task..."
  return 0
}

main() {
  debug "main called"
  check_requirements
  parse_args "$@"
  run_task
  return 0
}

main "$@"
```

---

## §18 — When to Use Shell (Google Rule)

- Only for **small utilities** or simple wrappers around system commands.
- If the script exceeds ~100 lines of logic, or requires heavy data manipulation,
  string parsing, or complex control flow — consider Python or Go instead.
- Shell is appropriate for: deployment automation, service health checks,
  environment setup, Docker orchestration wrappers, and CI/CD helpers.

---

## Quick-Reference Checklist

Before committing any script, verify:

- [ ] Shebang is `#!/usr/bin/env bash`
- [ ] `set -euo pipefail` and `IFS=$'\n\t'` immediately after header
- [ ] Every function ends with `return 0` or an explicit non-zero exit
- [ ] `debug()` uses the safe pattern with `return 0`
- [ ] `--help` is detected before the argument parsing loop
- [ ] All variables initialized with `${var:-default}` before use
- [ ] Constants declared `readonly`
- [ ] No `eval` anywhere
- [ ] No `[ ]` — all tests use `[[ ]]` or `(( ))`
- [ ] No `echo` — all output uses `printf`
- [ ] No external commands where a bash built-in suffices
- [ ] Every variable inside a function declared `local`
- [ ] `local` and command substitution assigned on separate lines
- [ ] All path variables quoted
- [ ] `command -v` used for binary existence checks — never execute to test
- [ ] `check_requirements()` is the first call in `main()`
- [ ] `trap cleanup EXIT INT TERM` registered before side effects
- [ ] ShellCheck passes with no unaddressed warnings
- [ ] Color output suppressed when stdout is not a terminal
