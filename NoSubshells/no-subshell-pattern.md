## Pattern-by-Pattern Breakdown

---

### 1. `$(echo | cut)` → `${var##*.}` / `${var%%:*}`

**Before:**
```bash
ext=$(echo "$filename" | cut -d. -f2)
```
- `$()` opens a subshell — a full child process
- `echo` writes the string to stdout
- `cut -d. -f2` forks another process, splits on `.` delimiter, returns field 2
- Two processes spawned for a simple string operation

**After:**
```bash
ext="${filename##*.}"   # greedy strip from left up to last dot
ext="${filename%%:*}"   # greedy strip from right from first colon
```
The `#` and `%` operators are bash parameter expansion — no process spawned:

| Operator | Direction | Greed | Meaning |
|---|---|---|---|
| `#` | strips from left | shortest match | `${var#pattern}` |
| `##` | strips from left | longest match | `${var##pattern}` |
| `%` | strips from right | shortest match | `${var%pattern}` |
| `%%` | strips from right | longest match | `${var%%pattern}` |

So `${filename##*.}` means "strip everything from the left up to and including the last `.`" — leaving only the extension. And `${var%%:*}` means "strip everything from the right starting at the first `:` " — useful for `host:port` strings.

---

### 2. `$(echo | tr)` → `${var^^}` / `${var,,}`

**Before:**
```bash
upper=$(echo "$str" | tr '[:lower:]' '[:upper:]')
lower=$(echo "$str" | tr '[:upper:]' '[:lower:]')
```
- Subshell + `echo` + `tr` fork — three operations for a case conversion

**After:**
```bash
upper="${str^^}"   # convert entire string to uppercase
lower="${str,,}"   # convert entire string to lowercase
```
`^^` and `,,` are bash 4.0+ case modification operators built directly into parameter expansion. Single character versions also exist:
```bash
"${str^}"    # capitalize first character only
"${str,}"    # lowercase first character only
```
Zero processes. Pure bash interpreter operation.

---

### 3. `$(dirname)` → `${var%/*}`

**Before:**
```bash
parent=$(dirname "$filepath")
```
- Subshell + `dirname` binary fork just to strip the filename off a path

**After:**
```bash
parent="${filepath%/*}"
```
`%` strips from the right, shortest match, up to and including the last `/`. So `/home/kali/tools/exploit.py` becomes `/home/kali/tools`. The pattern `/*` means "a slash followed by anything" — and `%` (shortest) stops at the last slash, leaving the directory path intact.

---

### 4. `$(basename)` → `${var##*/}`

**Before:**
```bash
filename=$(basename "$filepath")
```
- Subshell + `basename` binary fork just to strip the directory off a path

**After:**
```bash
filename="${filepath##*/}"
```
`##` strips from the left, longest match, everything up to and including the last `/`. So `/home/kali/tools/exploit.py` becomes `exploit.py`. It's the mirror image of the dirname pattern — `%/*` strips the right side, `##*/` strips the left side.

---

### 5. `$(echo | wc -c)` → `${#var}`

**Before:**
```bash
len=$(echo -n "$str" | wc -c)
```
- Subshell + `echo` + `wc` fork — two processes to count characters
- The `-n` on `echo` is required to suppress the newline, otherwise `wc -c` overcounts by 1

**After:**
```bash
len="${#str}"
```
`#` inside `${}` before a variable name means "length of". Returns the number of characters in the string. No process, no newline edge case, no off-by-one risk. Works on arrays too — `${#array[@]}` returns the number of elements.

---

### 6. `$(echo | grep -c)` → `[[ == *word* ]]`

**Before:**
```bash
found=$(echo "$sentence" | grep -c "error")
```
- Subshell + `echo` + `grep` fork — returns `1` if found, `0` if not
- Stores a count in a variable just to use as a boolean

**After:**
```bash
if [[ "$sentence" == *"error"* ]]; then ...
```
`[[ ]]` is a bash built-in test construct — no fork. The `*` on either side of `"error"` are glob wildcards meaning "anything before" and "anything after". This is a substring match, not a regex. It evaluates directly to true/false — no intermediate variable needed. If you do need a `0/1` integer:
```bash
found=0
[[ "$sentence" == *"error"* ]] && found=1
```

---

### 7. `$(cmd | wc -l)` → `mapfile -t arr < <(cmd); ${#arr[@]}`

**Before:**
```bash
count=$(some_command | wc -l)
```
- Subshell captures output of `some_command`
- `wc -l` forks to count newlines
- Result stored in variable

**After:**
```bash
mapfile -t arr < <(some_command)
count="${#arr[@]}"
```
This one is the most nuanced of the group — two new concepts:

**`mapfile -t arr`** — a bash built-in that reads lines from stdin into an array. The `-t` strips the trailing newline from each element. No fork. Each line of output becomes one array element.

**`< <(some_command)`** — this is process substitution, not a subshell. The `<(cmd)` part runs `some_command` and presents its output as a file descriptor. The leading `<` redirects that into `mapfile`. Crucially, `mapfile` itself runs in the **current shell**, not a subshell — so the array is accessible after the line completes. A plain `some_command | mapfile -t arr` would put `mapfile` in a subshell (right side of a pipe) and the array would vanish.

**`${#arr[@]}`** — array length operator from pattern 5. Counts elements instead of calling `wc -l`.

The net result: `wc -l` is eliminated entirely, and the array is available for further use if you need to inspect the actual lines, not just count them.

