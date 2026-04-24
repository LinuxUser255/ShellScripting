
# No Subshell 1

## Function Refactor

---

### The Refactor

```bash
# BEFORE — two subshells (rg pipeline + wc)
count_matches() {
  MATCHES=$(rg -c "$TERM" "$DIR" 2>/dev/null | wc -l)
  printf 'Files with matches: %s\n\n' "$MATCHES"
}

# AFTER — mapfile captures lines into array, no subshell for counting
count_matches() {
  mapfile -t _matches < <(rg -c "$TERM" "$DIR" 2>/dev/null)
  printf 'Files with matches: %s\n\n' "${#_matches[@]}"
  return 0
}
```

> Note: the `< <(...)` is process substitution — it avoids a subshell for `mapfile` itself while still letting `rg` run as an external command. The `wc -l` fork is eliminated entirely — array length `${#_matches[@]}` replaces it.

---

## Practice Set

Refactor each one. Answers below — try them first.

```bash
# 1
get_extension() {
  EXT=$(echo "$FILENAME" | cut -d. -f2)
  echo "$EXT"
}

# 2
to_upper() {
  RESULT=$(echo "$1" | tr '[:lower:]' '[:upper:]')
  echo "$RESULT"
}

# 3
get_dirname() {
  PARENT=$(dirname "$FILEPATH")
  echo "$PARENT"
}

# 4
contains_word() {
  FOUND=$(echo "$SENTENCE" | grep -c "error")
  echo "$FOUND"
}

# 5
get_length() {
  LEN=$(echo -n "$1" | wc -c)
  echo "Length: $LEN"
}
```

---

## Answers

```bash
# 1 — cut replaced by parameter expansion
get_extension() {
  EXT="${FILENAME##*.}"
  printf '%s\n' "$EXT"
  return 0
}

# 2 — tr replaced by ,, expansion
to_upper() {
  RESULT="${1^^}"
  printf '%s\n' "$RESULT"
  return 0
}

# 3 — dirname replaced by parameter expansion
get_dirname() {
  PARENT="${FILEPATH%/*}"
  printf '%s\n' "$PARENT"
  return 0
}

# 4 — grep -c replaced by [[ == ]]
contains_word() {
  local found=0
  [[ "$SENTENCE" == *"error"* ]] && found=1
  printf '%s\n' "$found"
  return 0
}

# 5 — wc -c replaced by ${#}
get_length() {
  printf 'Length: %s\n' "${#1}"
  return 0
}
```

---

## The Pattern to Internalize

| Subshell use | Replace with |
|---|---|
| `$(echo \| cut)` | `${var##*.}` / `${var%%:*}` |
| `$(echo \| tr)` | `${var^^}` / `${var,,}` |
| `$(dirname)` | `${var%/*}` |
| `$(basename)` | `${var##*/}` |
| `$(echo \| wc -c)` | `${#var}` |
| `$(echo \| grep -c)` | `[[ == *word* ]]` |
| `$(cmd \| wc -l)` | `mapfile -t arr < <(cmd); ${#arr[@]}` |


