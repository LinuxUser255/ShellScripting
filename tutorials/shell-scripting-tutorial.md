# Various Shell Scripting explanations & lessons

---

### 🧠 Line 1: `for file in *.c; do`

#### ✅ **What it does:**

This is a **`for` loop** in Bash that:

* Expands `*.c` into a list of all files in the current directory that end in `.c`
* Iterates over each of those files, assigning each one to the variable `file`

#### ✅ **Breakdown of syntax:**

* `for ... in ...` → standard Bash loop syntax
* `*.c` → **filename globbing**; Bash expands this into a list like:

  ```bash
  struct_pointers.c structs_basics.c structs_typedef.c
  ```
* `file` → a variable that holds the name of the current file in each iteration
* `do` → begins the body of the loop

#### 🧠 **When to use it:**

Use this syntax when:

* You want to do something with **each file matching a pattern**
* You need to process files in the current directory (e.g., compile, rename, delete, move)

---

### 🧠 Line 2: `output="${file%.c}"`

#### ✅ **What it does:**

This sets a new variable called `output`, and gives it the value of the current file name **with the `.c` extension removed**.

For example:

```bash
file="structs_typedef.c"
output="structs_typedef"
```

#### ✅ **Breakdown of syntax:**

* `output=` → assigns a value to the variable `output`
* `"${file%.c}"` → **parameter expansion** with pattern removal

Let’s break this down further:

| Part     | Meaning                                                       |
| -------- | ------------------------------------------------------------- |
| `${...}` | Bash syntax for variable expansion                            |
| `file`   | The variable holding the filename (e.g., `abc.c`)             |
| `%.c`    | This means **remove the shortest match of `.c` from the end** |

So if `file="abc.c"`, then:

```bash
output="${file%.c}"  # becomes "abc"
```

This is called **"suffix removal"** in Bash parameter expansion.

#### 🧠 **When to use it:**

Use this syntax when:

* You want to **manipulate strings in variables**
* You need to remove file extensions, directory paths, etc.
* You're writing shell scripts that need to generalize to many files

---

### 🔎 Related syntax cheatsheet:

| Expression        | Meaning                              |
| ----------------- | ------------------------------------ |
| `${var#pattern}`  | Remove shortest match from **start** |
| `${var##pattern}` | Remove longest match from **start**  |
| `${var%pattern}`  | Remove shortest match from **end**   |
| `${var%%pattern}` | Remove longest match from **end**    |

---

### ✅ Example with explanation:

```bash
file="lesson.c"
output="${file%.c}"   # removes `.c`, becomes "lesson"
```

This way, you can name the output file after the source file.

---

Let me know if you'd like a mini-practice set or script to help you get fluent with globbing and parameter expansion!






Absolutely! Here's a **mini-practice set** and a **hands-on Bash script** to help you get fluent with:

* **Globbing** (e.g., `*.c`)
* **Bash parameter expansion** (`${var%.ext}` and friends)

---

## 🧠 Mini-Practice Set: Globbing & Parameter Expansion

### 📁 Setup:

First, create a directory to practice in:

```bash
mkdir bash-practice && cd bash-practice
touch hello.c goodbye.c script.sh README.md notes.txt
```

---

### ✅ Practice 1: Globbing

Try these one-liners in your terminal and observe the output:

```bash
# List all .c files
echo *.c

# List all files that start with s
echo s*

# List all files that end with .sh or .md
echo *.sh *.md
```

### ✅ Practice 2: Parameter Expansion

```bash
file="hello.c"

# Remove .c from end
echo "${file%.c}"    # hello

# Remove everything after first dot
echo "${file%%.*}"   # hello

# Remove everything before first dot
echo "${file#*.}"    # c

# Remove longest suffix matching *.c
echo "${file%%.c}"   # hello (same in this case)
```

---

## 🧪 Script: Interactive Bash Expansion Trainer

Save this as `expansion_trainer.sh` and run it to test your understanding:

```bash
#!/bin/bash

echo "🧠 Bash Expansion Trainer"
echo "--------------------------"

files=("main.c" "utils.c" "notes.txt" "script.sh")

for file in "${files[@]}"; do
  echo ""
  echo "📄 File: $file"

  base="${file%.c}"
  echo "🔹 Remove .c from end (%.c): $base"

  base_no_ext="${file%%.*}"
  echo "🔹 Remove extension (%%.*): $base_no_ext"

  ext="${file#*.}"
  echo "🔹 Get extension (#*.): $ext"

  echo "-----"
done
```

Run it like this:

```bash
chmod +x expansion_trainer.sh
./expansion_trainer.sh
```

---

## 💡 Bonus: String Manipulation Summary

| Syntax           | What it does                              | Example (`file=main.c`) |
| ---------------- | ----------------------------------------- | ----------------------- |
| `${file%.c}`     | Remove shortest `.c` from end             | `main`                  |
| `${file%%.*}`    | Remove longest extension from end         | `main`                  |
| `${file#*.}`     | Remove up to first dot (keep extension)   | `c`                     |
| `${file##*.}`    | Remove up to last dot (if multi-dot name) | `c`                     |
| `${file/sh/SH}`  | Replace first `sh` with `SH`              | `script.SH`             |
| `${file//sh/SH}` | Replace **all** `sh` with `SH`            | `script.SH`             |

---

## 🚀 Final Challenge (your own test script)

Write a script that loops over `*.c` files and echoes the file name **with and without the extension**. Example:

```bash
#!/bin/bash

for file in *.c; do
  echo "Original: $file"
  echo "No extension: ${file%.c}"
done
```

---

Let me know if you'd like the same kind of hands-on practice for `awk`, `sed`, or `cut`, or how to incorporate this into a Makefile!


Awesome! Here's a **hands-on practice guide** for learning and mastering `awk`, `sed`, and `grep` — plus how to **integrate them into a Makefile**.

---

## 🛠️ Setup Your Practice Environment

1. Create a practice directory and file:

```bash
mkdir text-tools-practice && cd text-tools-practice

cat <<EOF > data.txt
ID,Name,Age,Email
1,Alice,30,alice@example.com
2,Bob,25,bob@example.com
3,Charlie,35,charlie@example.com
EOF
```

---

## 🔍 GREP PRACTICE

```bash
# Find lines containing the word 'Alice'
grep 'Alice' data.txt

# Find lines starting with '2'
grep '^2' data.txt

# Find lines that contain numbers
grep '[0-9]' data.txt

# Invert match (lines NOT containing Bob)
grep -v 'Bob' data.txt
```

---

## 🧬 SED PRACTICE (Stream Editor)

```bash
# Replace 'Bob' with 'Robert'
sed 's/Bob/Robert/' data.txt

# Replace all lowercase letters with X (global)
sed 's/[a-z]/X/g' data.txt

# Delete the header row
sed '1d' data.txt

# Append " - Active" to every line
sed 's/$/ - Active/' data.txt
```

---

## 📊 AWK PRACTICE (Field-based Processing)

```bash
# Print only the Name column (2nd field)
awk -F, '{ print $2 }' data.txt

# Print names and ages
awk -F, '{ print $2, $3 }' data.txt

# Skip the header row
awk -F, 'NR > 1 { print $2, $3 }' data.txt

# Sum all ages
awk -F, 'NR > 1 { sum += $3 } END { print "Total Age:", sum }' data.txt
```

---

## 🧰 Create a Makefile to Use These Tools

```Makefile
# Makefile in the same directory

data := data.txt

.PHONY: all grep sed awk clean

all: grep sed awk

grep:
	@echo "🔍 GREP Results:"
	@grep 'Charlie' $(data)

sed:
	@echo "🧬 SED Transformation:"
	@sed 's/@example.com/@domain.com/' $(data)

awk:
	@echo "📊 AWK Processed Output:"
	@awk -F, 'NR > 1 { print $$2 " is " $$3 " years old." }' $(data)

clean:
	@echo "🧹 Nothing to clean right now!"
```

### 🔧 Usage:

```bash
make           # runs all grep, sed, awk
make grep      # just grep
make clean     # cleanup task
```

---

## 🧠 Mini Challenge (Try Yourself)

1. Add a `make sum` target to sum all the ages.
2. Add a `make rename` target that uses `sed` to replace "Charlie" with "Chuck".
3. Add a `make count` target that uses `grep` to count how many emails are in the file.

---


