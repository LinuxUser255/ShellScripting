# Traditional Regular Expressions Cheat Sheet for Unix Shell Scripting

This cheat sheet covers **Basic Regular Expressions (BRE)** and **Extended
Regular Expressions (ERE)** used in traditional Unix tools like `grep`, `sed`,
`awk`, `egrep`, `vi/vim`, and shell scripting (including Bash’s `=~` operator).
BRE is the default for tools like `grep` and `sed`, while ERE is used with
`grep -E`, `egrep`, or `awk`. The guide includes syntax, descriptions, and
examples tailored for shell scripting, with notes on tool-specific behaviors.

## Key Concepts
- **BRE**: Basic Regular Expressions, used by `grep`, `sed`, and `vi/vim` by default. Some metacharacters (e.g., `|`, `+`, `?`) require escaping (e.g., `\|`, `\+`, `\?`) to be active.
- **ERE**: Extended Regular Expressions, used by `grep -E`, `egrep`, `awk`, and Bash’s `=~`. These support more metacharacters without escaping.
- **Tools**: Each tool interprets regex slightly differently. This cheat sheet notes differences where relevant.
- **Anchors**: Use `^` and `$` to ensure exact matches in most tools.
- **Case Sensitivity**: Most tools are case-sensitive by default. Use flags like `-i` (e.g., `grep -i`) for case-insensitive matching.

## Regex Syntax
### Basic Patterns
| **Pattern**        | **Description**                                                                 | **BRE Example**                                                                 | **ERE Example**                                                                 |
|---------------------|--------------------------------------------------------------------------------|--------------------------------------------------------------------------------|--------------------------------------------------------------------------------|
| `.`                | Matches any single character (except newline).                                 | `grep "c.t" file.txt` → Matches `cat`, `cot`, `cut`.                           | `grep -E "c.t" file.txt` → Same as BRE.                                        |
| `^`                | Anchors match to start of line.                                                | `grep "^cat" file.txt` → Matches `cat` at line start.                          | `grep -E "^cat" file.txt` → Same as BRE.                                       |
| `$`                | Anchors match to end of line.                                                  | `grep "cat$" file.txt` → Matches `cat` at line end.                            | `grep -E "cat$" file.txt` → Same as BRE.                                       |
| `*`                | Matches 0 or more of the previous character.                                    | `grep "ca*t" file.txt` → Matches `ct`, `cat`, `caat`.                          | `grep -E "ca*t" file.txt` → Same as BRE.                                       |
| `\+` (BRE) / `+` (ERE) | Matches 1 or more of the previous character.                                   | `grep "ca\+t" file.txt` → Matches `cat`, `caat`, not `ct`.                     | `grep -E "ca+t" file.txt` → Same as BRE with `\+`.                             |
| `\?` (BRE) / `?` (ERE) | Matches 0 or 1 of the previous character.                                      | `grep "ca\?t" file.txt` → Matches `ct`, `cat`, not `caat`.                     | `grep -E "ca?t" file.txt` → Same as BRE with `\?`.                             |
| `[abc]`            | Matches any single character in the set (e.g., `a`, `b`, or `c`).              | `grep "[ch]at" file.txt` → Matches `cat`, `hat`, not `bat`.                    | `grep -E "[ch]at" file.txt` → Same as BRE.                                     |
| `[^abc]`           | Matches any single character not in the set.                                   | `grep "[^b]at" file.txt` → Matches `cat`, `hat`, not `bat`.                    | `grep -E "[^b]at" file.txt` → Same as BRE.                                     |
| `\|` (BRE) / `|` (ERE) | Matches either the pattern before or after (OR).                              | `grep "cat\|dog" file.txt` → Matches `cat` or `dog`.                           | `grep -E "cat|dog" file.txt` → Same as BRE with `\|`.                          |
| `\(...\)` (BRE) / `(...)` (ERE) | Groups patterns for precedence or capture.                             | `sed 's/\(cat\)/\1s/' file.txt` → Replaces `cat` with `cats`.                  | `awk '/(cat)/{print $1}' file.txt` → Matches `cat` and prints line.            |
| `\{n\}` (BRE) / `{n}` (ERE) | Matches exactly `n` occurrences of the previous character.                 | `grep "ca\{2\}t" file.txt` → Matches `caat`, not `cat`.                        | `grep -E "ca{2}t" file.txt` → Same as BRE with `\{2\}`.                        |
| `\{n,\}` (BRE) / `{n,}` (ERE) | Matches `n` or more occurrences.                                     | `grep "ca\{2,\}t" file.txt` → Matches `caat`, `caaat`, not `cat`.              | `grep -E "ca{2,}t" file.txt` → Same as BRE with `\{2,\}`.                      |
| `\{n,m\}` (BRE) / `{n,m}` (ERE) | Matches between `n` and `m` occurrences.                           | `grep "ca\{1,2\}t" file.txt` → Matches `cat`, `caat`, not `caaat`.             | `grep -E "ca{1,2}t" file.txt` → Same as BRE with `\{1,2\}`.                    |

### Character Classes
| **Pattern**        | **Description**                                                                 | **Example**                                                                    |
|---------------------|--------------------------------------------------------------------------------|--------------------------------------------------------------------------------|
| `[[:alpha:]]`      | Matches any letter (a-z, A-Z).                                                 | `grep "[[:alpha:]]\+$" file.txt` → Lines ending with letters.                  |
| `[[:digit:]]`      | Matches any digit (0-9).                                                       | `grep "[[:digit:]]\+$" file.txt` → Lines ending with digits.                   |
| `[[:alnum:]]`      | Matches any alphanumeric character (a-z, A-Z, 0-9).                            | `grep "[[:alnum:]]\+$" file.txt` → Lines ending with alphanumeric.             |
| `[[:space:]]`      | Matches any whitespace (space, tab, etc.).                                     | `grep "[[:space:]]" file.txt` → Lines containing whitespace.                   |
| `[[:upper:]]`      | Matches any uppercase letter (A-Z).                                            | `grep "[[:upper:]]\+$" file.txt` → Lines ending with uppercase letters.         |
| `[[:lower:]]`      | Matches any lowercase letter (a-z).                                            | `grep "[[:lower:]]\+$" file.txt` → Lines ending with lowercase letters.         |
| `\w` (ERE/awk)     | Matches word characters (a-z, A-Z, 0-9, `_`).                                  | `awk "/\w+/" file.txt` → Lines with word characters.                           |
| `\b` (ERE/awk)     | Matches a word boundary.                                                       | `grep -E "\bcat\b" file.txt` → Matches `cat` as a whole word, not `cats`.      |

### Escaping Special Characters
| **Character**      | **Description**                                                                 | **Example**                                                                    |
|---------------------|--------------------------------------------------------------------------------|--------------------------------------------------------------------------------|
| `\.`, `\$`, `\*`, etc. | Escapes metacharacters to match them literally.                             | `grep "\." file.txt` → Matches a literal dot (`.`).                            |
| `\\`               | Matches a literal backslash.                                                   | `sed 's/\\//g' file.txt` → Replaces `\` with nothing.                          |

## Tool-Specific Notes
- **`grep`**: Uses BRE by default. Use `grep -E` for ERE. Case-insensitive with `-i`. Use `-w` for word boundaries.
- **`sed`**: Uses BRE. Use `sed -E` (or `-r` on some systems) for ERE. Capture groups with `\(...\)` in BRE.
- **`awk`**: Uses ERE by default. No need to escape `|`, `+`, `?`, etc. Capture groups with `(...)`.
- **`vi/vim`**: Uses BRE by default. Enable ERE with `:set magic` or escape metacharacters. Use `\%(...\)` for groups.
- **Bash `=~`**: Uses ERE in `[[ ... ]]`. No escaping needed for `|`, `+`, `?`. Capture groups in `${BASH_REMATCH[n]}`.
- **Portability**: BRE is more portable for older systems. ERE is more modern and expressive.

## Practical Examples in Shell Scripting
Below are examples showing regex usage in `grep`, `sed`, `awk`, `vi/vim`, and Bash’s `=~`. Each includes a script or command and explanation.

### 1. Find Lines Starting with a Number (`grep`)
**Goal**: Find lines in a file starting with a digit.
```bash
#!/usr/bin/env bash
# file.txt: 123abc, abc123, 456def
grep "^[[:digit:]]" file.txt
```
- **Pattern**: `^[[:digit:]]` (BRE)
  - Matches any line starting with a digit.
- **Output**: `123abc`, `456def`.
- **ERE Alternative**: `grep -E "^[0-9]" file.txt` (same result).

### 2. Replace Phone Numbers with XXX (`sed`)
**Goal**: Replace phone numbers like `123-456-7890` with `XXX-XXX-XXXX`.
```bash
#!/usr/bin/env bash
# file.txt: Call 123-456-7890 or 987-654-3210
sed 's/[[:digit:]]\{3\}-[[:digit:]]\{3\}-[[:digit:]]\{4\}/XXX-XXX-XXXX/g' file.txt
```
- **Pattern**: `[[:digit:]]\{3\}-[[:digit:]]\{3\}-[[:digit:]]\{4\}` (BRE)
  - Matches three digits, hyphen, three digits, hyphen, four digits.
- **Output**: `Call XXX-XXX-XXXX or XXX-XXX-XXXX`.
- **ERE Alternative**: `sed -E 's/[0-9]{3}-[0-9]{3}-[0-9]{4}/XXX-XXX-XXXX/g' file.txt`.

### 3. Extract Words with Exactly 3 Letters (`awk`)
**Goal**: Print words that are exactly three letters long.
```bash
#!/usr/bin/env bash
# file.txt: cat dog mouse
awk '{for(i=1;i<=NF;i++) if($i ~ /^[[:alpha:]]{3}$/) print $i}' file.txt
```
- **Pattern**: `^[[:alpha:]]{3}$` (ERE)
  - Matches exactly three letters, anchored to full word.
- **Output**: `cat`, `dog`.
- **Note**: `awk` uses ERE, so no escaping for `{3}`.

### 4. Validate Input in Bash (`=~`)
**Goal**: Check if input is `yes` or `y` (case-insensitive).
```bash
#!/usr/bin/env bash
read -r -p "Proceed? (yes/y): " input
input=$(echo "$input" | tr '[:upper:]' '[:lower:]')
if [[ "$input" =~ ^(yes|y)$ ]]; then
    echo "Proceeding..."
else
    echo "Exiting."
    exit 1
fi
```
- **Pattern**: `^(yes|y)$` (ERE)
  - Matches `yes` or `y` exactly.
- **Matches**: `yes`, `y`, `YES`, `Y` (after lowercase conversion).
- **Non-matches**: `no`, `yep`.

### 5. Search and Replace in `vi/vim`
**Goal**: Replace all instances of `cat` or `dog` with `pet` in a file.
- In `vi/vim`, enter command mode (`:`) and type:
  ```
  :%s/\<\(cat\|dog\)\>/pet/g
  ```
- **Pattern**: `\<\(cat\|dog\)\>` (BRE)
  - `\<` and `\>` are word boundaries.
  - `\(cat\|dog\)` matches `cat` or `dog`.
- **Output**: Replaces `cat` or `dog` with `pet` (e.g., `cat` → `pet`).
- **ERE Alternative**: In Vim with `:set magic`, use `:%s/\<(cat|dog)\>/pet/g`.

### 6. Filter Filenames with Specific Extensions (`find` + `grep`)
**Goal**: Find files ending with `.md` or `.txt`.
```bash
#!/usr/bin/env bash
find . -type f | grep "\.\(md\|txt\)$"
```
- **Pattern**: `\.\(md\|txt\)$` (BRE)
  - `\.` matches a literal dot.
  - `\(md\|txt\)` matches `md` or `txt`.
  - `$` anchors to the end.
- **Output**: Lists files like `./document.md`, `./note.txt`.
- **ERE Alternative**: `find . -type f | grep -E "\.(md|txt)$"`.

## Tips for Traditional Regex in Shell Scripting
- **Choose BRE or ERE**: Use BRE for `grep`, `sed`, `vi/vim` unless you specify `-E` or `-r`. Use ERE for `grep -E`, `egrep`, `awk`, or Bash `=~`.
- **Escape in BRE**: Metacharacters like `|`, `+`, `?`, `{}` need escaping in BRE (e.g., `\|`, `\+`, `\{n\}`).
- **Word Boundaries**: Use `\<` and `\>` in `grep` and `vi/vim` (BRE), or `\b` in `grep -E` and `awk` (ERE).
- **Capture Groups**: Use `\(...\)` in BRE, `(...)` in ERE. Access in `sed` with `\1`, in Bash with `${BASH_REMATCH[n]}`, or in `awk` with `$1`, `$2`, etc.
- **Test Patterns**: Use `echo` with `grep` or `awk` to test regex before scripting.
- **Portability**: Stick to BRE for maximum compatibility across Unix systems. ERE is more modern but not universal in older tools.

## Common Pitfalls
- **Forgetting Escapes in BRE**: In `grep`, `cat|dog` is literal without `-E`. Use `cat\|dog` or `grep -E "cat|dog"`.
- **Unanchored Patterns**: Without `^` or `$`, `grep "cat"` matches `cats`. Use `^cat$` for exact matches.
- **Tool Differences**: `sed` BRE doesn’t support `+` without `\+`, but `awk` does. Always check the tool’s regex flavor.
- **Quoting**: In Bash, quote patterns to avoid variable expansion (e.g., `[[ $var =~ "$pattern" ]]`).

## Testing Regex
To test regex patterns interactively:
```bash
# Test with grep
echo "cat" | grep "^c.t$"
# Test with sed
echo "cat" | sed -n "/^c.t$/p"
# Test with awk
echo "cat" | awk "/^c.t$/{print}"
# Test in Bash
input="cat"; if [[ $input =~ ^c.t$ ]]; then echo "Match"; fi
```

