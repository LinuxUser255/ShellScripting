
# `BASH_REMATCH`

### Using Shell Built-ins for grepping


Good topic to go deep on — `=~` with `BASH_REMATCH` is one of those things that
looks intimidating until you see the indexing model clearly, and then it clicks
permanently.

---

## The Indexing Model First

Before any examples, this mental model makes everything else obvious.

`BASH_REMATCH` is a regular Bash array. The `=~` operator populates it
automatically after every successful match. The rule for what goes where is
simple and never changes:

```
[[ "string" =~ (group1)(group2)(group3) ]]

BASH_REMATCH[0]  →  the entire match (everything =~ found)
BASH_REMATCH[1]  →  whatever (group1) captured
BASH_REMATCH[2]  →  whatever (group2) captured
BASH_REMATCH[3]  →  whatever (group3) captured
```

Index 0 is always the full match. Index 1 is always the first `(...)`. Count
the opening parentheses left to right — that's the index.

If the match **fails**, `BASH_REMATCH` is cleared. Its contents from a previous match are gone.

---

## Simple Examples

### Example 1 — Does this string contain a number?

Start with no capture groups at all. Just a true/false test.

```bash
#!/usr/bin/env bash
set -euo pipefail

check_has_number() {
  local input="$1"

  if [[ "$input" =~ [0-9]+ ]]; then
    printf 'FOUND a number in: "%s"\n' "$input"
    printf 'Matched text:      "%s"\n' "${BASH_REMATCH[0]}"
  else
    printf 'NO number in: "%s"\n' "$input"
  fi
  return 0
}

check_has_number "hello world"        # no match
check_has_number "error on line 42"   # match
check_has_number "3 items remaining"  # match
```

Output:
```
NO number in: "hello world"
FOUND a number in: "error on line 42"
Matched text:      "42"
FOUND a number in: "3 items remaining"
Matched text:      "3"
```

**What happened:** No capture group, so `BASH_REMATCH[1]` is empty.
`BASH_REMATCH[0]` still holds whatever the regex found — the actual matched
substring. The regex `[0-9]+` means "one or more digits." It stops at the first
match it finds and does not scan for more.

---

### Example 2 — Capture one thing

Now add one `(...)` to pull a specific piece out.

```bash
#!/usr/bin/env bash
set -euo pipefail

extract_number() {
  local input="$1"
  local num=""

  if [[ "$input" =~ ([0-9]+) ]]; then
    num="${BASH_REMATCH[1]}"   # the digits captured by (...)
    printf 'Input:   "%s"\n' "$input"
    printf '[0]:     "%s"  (full match)\n'    "${BASH_REMATCH[0]}"
    printf '[1]:     "%s"  (capture group 1)\n' "${BASH_REMATCH[1]}"
  else
    printf 'No match in: "%s"\n' "$input"
  fi
  return 0
}

extract_number "pid 3821 exited"
extract_number "no numbers here"
```

Output:
```
Input:   "pid 3821 exited"
[0]:     "3821"  (full match)
[1]:     "3821"  (capture group 1)
No match in: "no numbers here"
```

**What happened:** `[0]` and `[1]` are identical here because the entire regex
is wrapped in one group. That changes the moment the regex has text *outside*
the group:

```bash
# Regex with surrounding context outside the capture group
input="pid 3821 exited"

if [[ "$input" =~ pid[[:space:]]([0-9]+) ]]; then
  printf '[0]: "%s"\n' "${BASH_REMATCH[0]}"   # → "pid 3821"
  printf '[1]: "%s"\n' "${BASH_REMATCH[1]}"   # → "3821"
fi
```

Now `[0]` is `"pid 3821"` — the full text the regex consumed. `[1]` is just `"3821"` — only the digits inside the `(...)`. This distinction matters when you want a specific piece from a larger pattern.

---

### Example 3 — Two capture groups

```bash
#!/usr/bin/env bash
set -euo pipefail

parse_host_port() {
  local input="$1"   # expects something like "connect to 192.168.1.1:8080"
  local host=""
  local port=""

  #                     (  host part  ) : (port part)
  if [[ "$input" =~ ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+):([0-9]+) ]]; then
    host="${BASH_REMATCH[1]}"
    port="${BASH_REMATCH[2]}"
    printf 'Full match:  "%s"\n' "${BASH_REMATCH[0]}"
    printf 'Host [1]:    "%s"\n' "$host"
    printf 'Port [2]:    "%s"\n' "$port"
  else
    printf 'No host:port pattern found in: "%s"\n' "$input"
  fi
  return 0
}

parse_host_port "connect to 192.168.1.100:443 failed"
parse_host_port "localhost only, no port"
```

Output:
```
Full match:  "192.168.1.100:443"
Host [1]:    "192.168.1.100"
Port [2]:    "443"
No host:port pattern found in: "localhost only, no port"
```

**Count the parentheses left to right:**
```
([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+):([0-9]+)
^                                  ^
group 1 → BASH_REMATCH[1]          group 2 → BASH_REMATCH[2]
```

The `:` between the groups is a literal colon in the pattern — it is consumed by the match and appears in `[0]`, but it belongs to no capture group so it appears nowhere in `[1]` or `[2]`.

---

## Intermediate Examples

### Example 4 — Log line parser (three groups)

A realistic use case: parsing structured log output into components.

```bash
#!/usr/bin/env bash
set -euo pipefail

# Parses lines like:
# [2024-03-15 14:32:01] ERROR: connection refused (attempt 3)

parse_log_line() {
  local line="$1"
  local timestamp=""
  local level=""
  local message=""

  #           ( timestamp  )space(level):space(  message   )
  if [[ "$line" =~ \[([^\]]+)\][[:space:]]([A-Z]+):[[:space:]](.+) ]]; then
    timestamp="${BASH_REMATCH[1]}"
    level="${BASH_REMATCH[2]}"
    message="${BASH_REMATCH[3]}"

    printf 'Timestamp [1]:  "%s"\n' "$timestamp"
    printf 'Level     [2]:  "%s"\n' "$level"
    printf 'Message   [3]:  "%s"\n' "$message"
    printf '\n'
  else
    printf 'Line did not match expected format\n'
    printf 'Input: "%s"\n' "$line"
  fi
  return 0
}

parse_log_line "[2024-03-15 14:32:01] ERROR: connection refused (attempt 3)"
parse_log_line "[2024-03-15 14:33:07] INFO: retry succeeded"
parse_log_line "malformed line no brackets"
```

Output:
```
Timestamp [1]:  "2024-03-15 14:32:01"
Level     [2]:  "ERROR"
Message   [3]:  "connection refused (attempt 3)"

Timestamp [1]:  "2024-03-15 14:33:07"
Level     [2]:  "INFO"
Message   [3]:  "retry succeeded"

Line did not match expected format
Input: "malformed line no brackets"
```

**Breaking down the regex:**

```
\[          literal [  (escaped because [ has special regex meaning)
([^\]]+)    group 1: one or more chars that are NOT ]
\]          literal ]
[[:space:]] one whitespace character (POSIX class — ERE, not \s)
([A-Z]+)    group 2: one or more uppercase letters
:           literal colon
[[:space:]] one whitespace character
(.+)        group 3: one or more of anything — greedy, takes the rest of the line
```

`[^\]]+` deserves attention — it is a negated character class. `[^...]` means "any character NOT in this set." `\]` inside the class is an escaped `]`. So the whole thing reads: "one or more characters that are not a closing bracket." This is the clean way to match "everything inside brackets" without using a greedy `.*` that might overshoot.

---

### Example 5 — Looping over input and collecting matches

`=~` runs once per `[[ ]]` evaluation. To scan multiple lines and collect results, combine it with `mapfile` and a loop — no subshells anywhere.

```bash
#!/usr/bin/env bash
set -euo pipefail

# Extract all IP addresses from a block of text
# Input: a file or heredoc with mixed content

extract_ips() {
  local -a lines=()
  local -a found_ips=()
  local line=""

  # Read all input lines into array — no subshell (§5 mapfile)
  mapfile -t lines < <(cat "$1" 2>/dev/null)

  for line in "${lines[@]}"; do
    if [[ "$line" =~ ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}) ]]; then
      found_ips+=("${BASH_REMATCH[1]}")
    fi
  done

  if (( ${#found_ips[@]} == 0 )); then
    printf 'No IPs found\n'
    return 0
  fi

  printf 'Found %s IP(s):\n' "${#found_ips[@]}"
  local ip=""
  for ip in "${found_ips[@]}"; do
    printf '  %s\n' "$ip"
  done
  return 0
}

# Test with a heredoc via process substitution
extract_ips <(printf '%s\n' \
  "connecting to 10.10.14.5 on port 4444" \
  "no address here" \
  "target is 192.168.1.100, backup is 192.168.1.101" \
  "gateway: 10.0.0.1"
)
```

Output:
```
Found 4 IP(s):
  10.10.14.5
  192.168.1.100
  192.168.1.101
  10.0.0.1
```

**Key point here:** `=~` only finds the **first** match per line. If a line has two IPs, you get the leftmost one. If you need all matches on a single line, you either split the line further or accept the limitation and reach for `grep -oP` in that specific case — it is one of those honest exceptions.

---

## ERE Syntax Quick Reference

Since `=~` uses ERE and not PCRE, the translation table you'll hit most often:

| What you want | PCRE (`grep -oP`) | ERE (`=~`) |
|---|---|---|
| One digit | `\d` | `[0-9]` |
| Non-digit | `\D` | `[^0-9]` |
| Word char | `\w` | `[a-zA-Z0-9_]` |
| Whitespace | `\s` | `[[:space:]]` |
| Non-whitespace | `\S` | `[^[:space:]]` |
| Any char | `.` | `.` (same) |
| Start of string | `^` | `^` (same) |
| End of string | `$` | `$` (same) |
| One or more | `+` | `+` (same) |
| Zero or more | `*` | `*` (same) |
| Optional | `?` | `?` (same) |
| Literal dot | `\.` | `\.` (same) |
| Either/or | `cat\|dog` | `cat\|dog` (same) |
| N to M times | `{2,4}` | `{2,4}` (same) |

POSIX character classes (the `[[:...:]]` form) are always safe in ERE and
worth knowing:

```bash
[[:alpha:]]    # letters only — [a-zA-Z]
[[:digit:]]    # digits only — [0-9]
[[:alnum:]]    # letters and digits
[[:space:]]    # whitespace including \t \n
[[:upper:]]    # uppercase letters
[[:lower:]]    # lowercase letters
[[:punct:]]    # punctuation characters
```

---

## The One Gotcha: Quoting the Regex

Do not quote the regex on the right side of `=~`. Quoting forces a literal string match and disables all special characters.

```bash
input="version 2.4.1"

# WRONG — quoted: looks for the literal string "[0-9]+"
if [[ "$input" =~ "[0-9]+" ]]; then ...   # never matches

# RIGHT — unquoted: regex engine interprets [0-9]+
if [[ "$input" =~ [0-9]+ ]]; then ...     # matches "2"

# RIGHT — store in variable first (also avoids quoting issues)
pattern='[0-9]+\.[0-9]+\.[0-9]+'
if [[ "$input" =~ $pattern ]]; then ...   # clean, readable, correct
```

Storing the pattern in a variable first is the cleanest approach for anything longer than a few characters — it keeps the `[[ ]]` line readable and sidesteps any quoting ambiguity entirely.
