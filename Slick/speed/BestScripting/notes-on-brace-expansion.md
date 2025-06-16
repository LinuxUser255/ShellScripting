# Title

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


