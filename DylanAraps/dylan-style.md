# Bash Refactoring Style Guide

This guide provides concise Bash scripting patterns for refactoring shell scripts.
Use these to replace external commands (e.g., `sed`, `awk`, `cut`) with pure Bash alternatives, prioritizing performance, readability, and compatibility. Each section includes two examples to guide the refactoring process.

## STRINGS

Use parameter expansion and built-in regex for string manipulation.

- **Trim leading/trailing whitespace**:
  ```sh
  trim_string() { : "${1#"${1%%[![:space:]]*}"}"; : "${_%"${_##*[![:space:]]}"}"; printf '%s\n' "$_"; }
  # Example: trim_string "   Hello   " -> "Hello"
  ```

- **Convert to lowercase** (Bash 4+):
  ```sh
  lower() { printf '%s\n' "${1,,}"; }
  # Example: lower "HeLLo" -> "hello"
  ```

## ARRAYS

Leverage Bash arrays for efficient data handling.

- **Reverse an array** (requires `shopt -s compat44` in Bash 5.0+):
  ```sh
  reverse_array() { shopt -s extdebug; f()(printf '%s\n' "${BASH_ARGV[@]}"); f "$@"; shopt -u extdebug; }
  # Example: reverse_array 1 2 3 -> 3 2 1
  ```

- **Remove duplicates** (Bash 4+):
  ```sh
  remove_array_dups() { declare -A tmp; for i in "$@"; do [[ $i ]] && tmp["${i:- }"]=1; done; printf '%s\n' "${!tmp[@]}"; }
  # Example: remove_array_dups 1 1 2 2 -> 1 2
  ```

## LOOPS

Use Bash-native loops instead of external tools like `seq`.

- **Loop over a range**:
  ```sh
  for i in {1..10}; do echo "$i"; done
  # Example: Outputs 1 to 10
  ```

- **Loop over an array**:
  ```sh
  arr=(a b c); for e in "${arr[@]}"; do echo "$e"; done
  # Example: Outputs a b c
  ```

## FILE HANDLING

Avoid `cat`, `head`, `tail`, etc., using Bash built-ins.

- **Read file to string**:
  ```sh
  file_data="$(<file.txt)"
  # Example: Reads entire file content into file_data
  ```

- **Read file to array** (Bash 4+):
  ```sh
  mapfile -t arr < file.txt
  # Example: Each line of file.txt becomes an array element
  ```

## FILE PATHS

Use parameter expansion for path manipulation.

- **Get directory name**:
  ```sh
  dirname() { local tmp=${1:-.}; [[ $tmp != *[!/]* ]] && { printf '/\n'; return; }; tmp=${tmp%%"${tmp##*[!/]}"};
  [[ $tmp != */* ]] && { printf '.\n'; return; }; tmp=${tmp%/*}; tmp=${tmp%%"${tmp##*[!/]}"};
  printf '%s\n' "${tmp:-/}"; }
  # Example: dirname "/home/user/file.txt" -> "/home/user"
  ```

- **Get base name**:
  ```sh
  basename() { local tmp=${1%"${1##*[!/]}"};
  tmp=${tmp##*/}; tmp=${tmp%"${2/"$tmp"}"}; printf '%s\n' "${tmp:-/}"; }
  # Example: basename "/home/user/file.txt" ".txt" -> "file"
  ```

## VARIABLES

Use dynamic variable handling for flexibility.

- **Indirect variable access**:
  ```sh
  hello_world="value"; var="world"; ref="hello_$var"; printf '%s\n' "${!ref}"
  # Example: Outputs "value"
  ```

- **Dynamic variable naming**:
  ```sh
  var="world"; declare "hello_$var=value"; printf '%s\n' "$hello_world"
  # Example: Outputs "value"
  ```

## ESCAPE SEQUENCES

Use raw ANSI escape sequences for terminal control.

- **Set text color**:
  ```sh
  printf '\e[38;5;1mRed text\e[m\n'
  # Example: Outputs red text
  ```

- **Clear screen**:
  ```sh
  printf '\e[2J\e[H'
  # Example: Clears screen and moves cursor to top-left
  ```

## PARAMETER EXPANSION

Use parameter expansion for string and variable manipulation.

- **Remove pattern from start**:
  ```sh
  var="Hello World"; printf '%s\n' "${var#H*o}"
  # Example: Outputs " World"
  ```

- **Default value**:
  ```sh
  var=""; printf '%s\n' "${var:-default}"
  # Example: Outputs "default"
  ```

## BRACE EXPANSION

Use brace expansion for concise iteration.

- **Number range**:
  ```sh
  echo {1..5}
  # Example: Outputs 1 2 3 4 5
  ```

- **String list**:
  ```sh
  echo {apple,banana,orange}
  # Example: Outputs apple banana orange
  ```

## CONDITIONAL EXPRESSIONS

Use `[[ ]]` for robust conditionals.

- **Check if file exists**:
  ```sh
  [[ -f file.txt ]] && echo "File exists"
  # Example: Outputs "File exists" if file.txt exists
  ```

- **String comparison**:
  ```sh
  [[ "abc" == "abc" ]] && echo "Equal"
  # Example: Outputs "Equal"
  ```

## TRAPS

Use traps for signal handling.

- **Run on exit**:
  ```sh
  trap 'echo "Script exited"' EXIT
  # Example: Prints "Script exited" on script termination
  ```

- **Ignore SIGINT**:
  ```sh
  trap '' INT
  # Example: Prevents script termination on Ctrl+C
  ```

## PERFORMANCE

Optimize scripts for speed.

- **Disable Unicode**:
  ```sh
  LC_ALL=C LANG=C
  # Example: Speeds up string operations in ASCII environments
  ```

- **Minimize subshells**:
  ```sh
  var=$(<file.txt)  # Instead of var=$(cat file.txt)
  # Example: Reads file without spawning a subshell
  ```

## INTERNAL VARIABLES

Use Bash internal variables for system info.

- **Current working directory**:
  ```sh
  echo "$PWD"
  # Example: Outputs /home/user
  ```

- **Random number**:
  ```sh
  echo "$RANDOM"
  # Example: Outputs a number between 0 and 32767
  ```

## CODE GOLF

Use concise syntax for brevity.

- **Short for loop**:
  ```sh
  for((;i++<5;)){ echo "$i"; }
  # Example: Outputs 1 2 3 4
  ```

- **Short if statement**:
  ```sh
  [[ $var == hello ]] && echo "Hi"
  # Example: Outputs "Hi" if var equals "hello"
  ```

## OTHER

Miscellaneous useful patterns.

- **Sleep alternative** (Bash 4+):
  ```sh
  read_sleep() { read -rt "$1" <> <(:) || :; }
  # Example: read_sleep 1  # Pauses for 1 second
  ```

- **Check program in PATH**:
  ```sh
  command -v ls &>/dev/null && echo "ls is available"
  # Example: Outputs "ls is available" if ls is in PATH
  ```

