# A focused reference of bash built-ins that complement it, organized by what subshell they replace:

---

## Bash Built-in Variables — No Fork Required

### Process & Runtime Info
| Variable | Value | Replaces |
|---|---|---|
| `$$` | PID of current shell | `$(sh -c 'echo $$')` |
| `$PPID` | Parent process PID | `$(ps -o ppid= $$)` |
| `$BASHPID` | PID of current subshell (differs from `$$` inside `()`) | — |
| `$BASH_SUBSHELL` | Subshell depth (0 = top level) | — |
| `$SHLVL` | Shell nesting level | — |
| `$BASH_VERSION` | Full version string | `$(bash --version)` |
| `$BASH_VERSINFO[@]` | Version as array `[major minor patch...]` | `$(bash --version \| cut...)` |

### Randomness & Uniqueness
| Variable | Value | Replaces |
|---|---|---|
| `$RANDOM` | Integer 0–32767, new value each read | `$(shuf -i 0-32767 -n1)` |
| `$SRANDOM` | 32-bit random (Bash 5.1+), non-repeating | `$(openssl rand -hex 4)` |

```bash
# Unique temp path — no mktemp fork
tmpdir="/tmp/build-$$-$RANDOM"
mkdir -p "$tmpdir"
```

### OS & Environment Detection
| Variable | Value | Replaces |
|---|---|---|
| `$OSTYPE` | `linux-gnu`, `darwin23`, `freebsd13` | `$(uname -s)` |
| `$HOSTTYPE` | `x86_64`, `aarch64`, `arm` | `$(uname -m)` |
| `$MACHTYPE` | `x86_64-pc-linux-gnu` (full triplet) | `$(gcc -dumpmachine)` |
| `$HOSTNAME` | System hostname | `$(hostname)` |

### Timing
| Variable | Value | Replaces |
|---|---|---|
| `$SECONDS` | Seconds since shell started | `$(date +%s)` for elapsed time |
| `$EPOCHSECONDS` | Unix timestamp (Bash 5.0+) | `$(date +%s)` |
| `$EPOCHREALTIME` | Unix timestamp with microseconds (Bash 5.0+) | `$(date +%s%N)` |

```bash
# Elapsed time — no date fork
start=$SECONDS
do_something
elapsed=$(( SECONDS - start ))
printf 'Took %s seconds\n' "$elapsed"
```

### Script & Call Stack
| Variable | Value | Replaces |
|---|---|---|
| `$0` | Script name/path | `$(basename "$0")` (with expansion) |
| `$BASH_SOURCE[@]` | Array of source filenames in call stack | — |
| `$FUNCNAME[@]` | Array of function names in call stack | — |
| `$BASH_LINENO[@]` | Line numbers in call stack | — |
| `$LINENO` | Current line number | — |

```bash
# Script's own directory — no subshell
script_dir="${BASH_SOURCE[0]%/*}"

# Current function name in error messages
err() { printf '[%s] %s\n' "${FUNCNAME[1]}" "$*" >&2; }
```

### String & I/O
| Variable | Value | Replaces |
|---|---|---|
| `$IFS` | Field separator (default space/tab/newline) | Controls `read` splitting |
| `$REPLY` | Default variable for `read` with no args | Avoids declaring a temp var |
| `$BASH_REMATCH[@]` | Regex capture groups from `[[ =~ ]]` | `$(grep -oP)` |
| `$MAPFILE[@]` | Default array for `mapfile` with no `-t` | — |

### Terminal & Interactive
| Variable | Value | Replaces |
|---|---|---|
| `$COLUMNS` | Terminal width | `$(tput cols)` |
| `$LINES` | Terminal height | `$(tput lines)` |
| `$TERM` | Terminal type | `$(tput longname)` (partial) |
| `$PS1` `$PS2` | Prompt strings | — |

```bash
# Center text without tput fork
pad=$(( (COLUMNS - ${#title}) / 2 ))
printf '%*s%s\n' "$pad" '' "$title"
```

---

## What To Add To Your Guide

These three are the most impactful ones not yet in your reference table:

```
$EPOCHSECONDS          →  $(date +%s)
$OSTYPE                →  $(uname -s)
$$-$RANDOM             →  $(mktemp -d) for unique paths
```

`$EPOCHSECONDS` in particular is a common missed opportunity — most scripts that timestamp log lines are spawning `date` in a loop, which is one of the most expensive patterns in automation scripts.
