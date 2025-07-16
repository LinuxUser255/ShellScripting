
**Basics of Shell Scripting Reference Guide**

---

### 1. **Difference Between the Operators: `>` and `<`**

In shell scripting, `>` and `<` are **redirection operators** that control the flow of input and output between commands and files.

#### `>` — Output Redirection

* Redirects **standard output (stdout)** to a file.
* If the file exists, it **overwrites** it.
* If it doesn’t exist, it will be **created**.

**Example:**

```bash
echo "Hello, World!" > output.txt
```

* Writes "Hello, World!" to `output.txt`.

#### `<` — Input Redirection

* Redirects **standard input (stdin)** from a file.
* Feeds the content of a file as input to a command.

**Example:**

```bash
sort < names.txt
```

* Takes the contents of `names.txt` and sorts them.

---

### 2. **Understanding `<< EOF` (Here Document)**

`<< EOF` is used to define a **Here Document** (also called heredoc). It allows you to provide **multi-line input** directly within a script or command.

#### Syntax:

```bash
command <<EOF
text line 1
text line 2
EOF
```

* `EOF` is a **delimiter**; it can be any word, but `EOF` is conventional.
* Everything between `<<EOF` and the ending `EOF` is passed as **standard input** to the command.

#### Common Use: Feeding input to `cat`

```bash
cat <<EOF
This is line 1
This is line 2
EOF
```

#### Another Example: Using `heredoc` in a script

```bash
#!/bin/bash

cat <<EOF > message.txt
Dear User,

Welcome to Shell Scripting Basics!

Best,
Admin
EOF
```

* Writes a multi-line message into `message.txt`.

#### Notes:

* You can use `<<-EOF` (with a dash) to allow **tab-indented** lines (tabs will be stripped).
* To prevent variable expansion, use quotes: `<<'EOF'`

```bash
cat <<'EOF'
$HOME will not be expanded
EOF
```

---

In Bash scripting, **`$1`** is a **positional parameter** that refers to the **first argument** passed to a script or function.

---

### Explanation of the Command:

```bash
echo hello $1
```

* `echo` is used to print text to the terminal.
* `$1` gets replaced with the first argument provided when the script is run.

---

### Example:

Suppose you have a script called `greet.sh` with this content:

```bash
#!/bin/bash
echo hello $1
```

If you run the script like this:

```bash
./greet.sh Alice
```

The output will be:

```
hello Alice
```

---

### Summary of Positional Parameters:

* `$0` → Name of the script
* `$1` → First argument
* `$2` → Second argument
* ...
* `$@` → All arguments as separate words
* `$*` → All arguments as a single word


In shell scripting, **`$?`** holds the **exit status** (also called return code) of the **last command that was executed**.

---

### ✅ What Does `$?` Mean?

* `$?` stores an **integer**:

  * `0` usually means **success**
  * Any non-zero value (like `1`) means **failure** or **error**

---

### 📌 Your Script:

```bash
if [ $? = 1 ]; then
```

This checks:

* "Did the **last command** fail with exit status `1`?"

If so, the `then` block will be executed.

---

### 🔍 Example Use Case:

```bash
#!/bin/bash

grep "Hello" myfile.txt
if [ $? = 1 ]; then
    echo "Pattern not found."
fi
```

* `grep` tries to find "Hello" in `myfile.txt`
* If it doesn't find it, `grep` exits with code `1`
* The script then prints "Pattern not found."

---

### 🧠 Common Exit Codes:

| Code | Meaning                                  |
| ---- | ---------------------------------------- |
| 0    | Success                                  |
| 1    | General error / not found                |
| 2+   | Specific errors (depends on the command) |

---


