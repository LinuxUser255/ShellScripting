
# Shell Scripting Symbol & Syntax Cheat Sheet

---


```bash
`$()`         command substitution — runs a command and replaces with its output
```

```bash
``cmd``       legacy command substitution — same as `$()`, but less readable
```

```bash
${}           parameter expansion — access or manipulate variable values
```

```bash
(( ))         arithmetic evaluation — used for integer math
```

```bash
[[ ]]         conditional test — used in `if`, `while`, etc. (bash extended test)
```

```bash
[ ]           test — POSIX-style test command (more portable, but less powerful)
```

```bash
((cond)) && action   arithmetic conditional + short-circuit AND logic
```

```bash
[[ cond ]] || action string or file conditional + short-circuit OR logic
```

```bash
!             logical NOT — negates a condition
```

```bash
&&            logical AND — runs right side only if left side succeeds
```

```bash
||            logical OR — runs right side only if left side fails
```

```bash
;             command separator — allows multiple commands on one line
```

```bash
;;            end of case pattern — used in `case` statements
```

```bash
&             background — runs a command in the background
```

```bash
|             pipe — passes output of one command as input to another
```

```bash
>             redirect stdout — overwrite file with output
```

```bash
>>            append stdout — append output to file
```

```bash
<             redirect stdin — takes input from a file
```

```bash
2>            redirect stderr — send error messages to a file
```

```bash
&>            redirect both stdout and stderr to a file (bash)
```

```bash
<<<           here string — provides string input directly to stdin
```

```bash
<< EOF        here document — multi-line string input to stdin
EOF
```

```bash
$?            exit status — result of the last command (0 = success)
```

```bash
$0            script name — the name of the current script
```

```bash
$1 - $9       positional parameters — arguments passed to the script
```

```bash
$@            all arguments as separate words (preserves quotes)
```

```bash
$*            all arguments as one word (may collapse quotes)
```

```bash
"$@"          expands to "$1" "$2" ... — safe way to loop through args
```

```bash
"$*"          expands to "$1 $2 ..." — all args in one string
```

```bash
${#var}       length — gets the length of a string or array
```

```bash
${var:offset}             substring — returns substring from offset
```

```bash
${var:offset:length}      substring — returns substring of given length
```

```bash
${var#pattern}            remove shortest match of pattern from front
```

```bash
${var##pattern}           remove longest match of pattern from front
```

```bash
${var%pattern}            remove shortest match from back
```

```bash
${var%%pattern}           remove longest match from back
```

```bash
${var/pattern/replacement}      replace first match
```

```bash
${var//pattern/replacement}     replace all matches
```

```bash
declare -a name           declare an array variable
```

```bash
arr=(1 2 3)               creates an array with 3 elements
```

```bash
${arr[0]}                 access array element by index
```

```bash
${arr[@]}                 all elements of the array
```

```bash
${#arr[@]}                number of elements in array
```

```bash
for item in "${arr[@]}"  iterate over array safely
```

```bash
function name() { }       defines a function
```

```bash
name() { }                alternative function definition
```

```bash
return n                 return from a function with exit code n
```

```bash
exit n                   exit the script with exit code n
```

```bash
set -e                  exit on error (fail fast)
```

```bash
set -x                  print each command before running it (debug)
```

<br>
