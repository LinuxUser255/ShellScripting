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

