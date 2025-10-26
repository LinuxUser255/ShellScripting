# CODING & SCRITPTING STYLE GUIDE FOR `cars.sh`


## Table of Contents:

 1. [Code Golf Style](#1-code-golf-syle)
 2. [Processes Level Parallelism](#2-processes-level-parallelism)
 3. [Appearance](#3-appearance--aestetics)


<br>

# 1. Code Golf Syle

## Shorter `for` loop syntax


```bash
# Tiny C Style.
for((;i++<10;)){ echo "$i";}

# Undocumented method.
for i in {1..10};{ echo "$i";}

# Expansion.
for i in {1..10}; do echo "$i"; done

# C Style.
for((i=0;i<=10;i++)); do echo "$i"; done
```

<br>


## Shorter infinite loops
```bash
# Normal method
while :; do echo hi; done

# Shorter
for((;;)){ echo hi;}
```

<br>

## Shorter function declaration
```bash
# Normal method
f(){ echo hi;}

# Using a subshell
f()(echo hi)

# Using arithmetic
# This can be used to assign integer values.
# Example: f a=1
#          f a++
f()(($1))

# Using tests, loops etc.
# NOTE: ‘while’, ‘until’, ‘case’, ‘(())’, ‘[[]]’ can also be used.
f()if true; then echo "$1"; fi

f()for i in "$@"; do echo "$i"; done

```

<br>

## Shorter if syntax
```bash
# One line
# Note: The 3rd statement may run when the 1st is true
[[ $var == hello ]] && echo hi || echo bye
[[ $var == hello ]] && { echo hi; echo there; } || echo bye

# Multi line (no else, single statement)
# Note: The exit status may not be the same as with an if statement
[[ $var == hello ]] &&
    echo hi

# Multi line (no else)
[[ $var == hello ]] && {
    echo hi
    # ...
}

```

<br>


## Simpler case statement to set variable
The `:` built-in can be used to avoid repeating `variable=` in a case statement.
The `$_` variable stores the last argument of the last command. `:` always succeeds
so it can be used to store the variable value.


```bash
# Modified snippet from Neofetch.
case "$OSTYPE" in
    "darwin"*)
        : "MacOS"
    ;;

    "linux"*)
        : "Linux"
    ;;

    *"bsd"* | "dragonfly" | "bitrig")
        : "BSD"
    ;;

    "cygwin" | "msys" | "win32")
        : "Windows"
    ;;

    *)
        printf '%s\n' "Unknown OS detected, aborting..." >&2
        exit 1
    ;;
esac

# Finally, set the variable.
os="$_"

```

<br>

## The `get_shell()` function from Neofetch

```bash
get_shell() {
    case $shell_path in
        on)  shell="$SHELL " ;;
        off) shell="${SHELL##*/} " ;;
    esac

    [[ $shell_version != on ]] && return

    case ${shell_name:=${SHELL##*/}} in
        bash)
            [[ $BASH_VERSION ]] ||
                BASH_VERSION=$("$SHELL" -c "printf %s "\$BASH_VERSION"")

            shell+=${BASH_VERSION/-*}
        ;;

        sh|ash|dash|es) ;;

        *ksh)
            shell+=$("$SHELL" -c "printf %s "\$KSH_VERSION"")
            shell=${shell/ * KSH}
            shell=${shell/version}
        ;;

        osh)
            if [[ $OIL_VERSION ]]; then
                shell+=$OIL_VERSION
            else
                shell+=$("$SHELL" -c "printf %s "\$OIL_VERSION"")
            fi
        ;;

        tcsh)
            shell+=$("$SHELL" -c "printf %s \$tcsh")
        ;;

        yash)
            shell+=$("$SHELL" --version 2>&1)
            shell=${shell/ $shell_name}
            shell=${shell/ Yet another shell}
            shell=${shell/Copyright*}
        ;;

        nu)
            shell+=$("$SHELL" -c "version | get version")
            shell=${shell/ $shell_name}
        ;;


        *)
            shell+=$("$SHELL" --version 2>&1)
            shell=${shell/ $shell_name}
        ;;
    esac

    # Remove unwanted info.
    shell=${shell/, version}
    shell=${shell/xonsh\//xonsh }
    shell=${shell/options*}
    shell=${shell/\(*\)}
}

```

<br>

# 2. Processes Level Parallelism

## Some concise and practical guidelines for writing efficient, fast, and lightweight Bash/Shell scripts

**especially for system tasks or automation:**


## 🔧 1. **General Principles**

* **Keep it POSIX-compatible** unless Bash-specific features are necessary.
* **Write small, modular scripts** – easier to test and reuse.
* **Prefer built-ins**  (`echo`, `read`, `test`, `[ ]`, `cd` )
* over external commands for speed.
* **Minimize forks** – every external command (like `grep`, `awk`) spawns a process.

---

## ⚡ 2. **Performance Optimization**

* **Avoid subshells** (`$(...)` or `(...)`) unless needed.
* Use **Batch operations**  instead of  looping (e.g., use `xargs`, brace expansion).
* **Use arrays** in Bash when processing large input sets.
* **Redirect once** instead of per line:
  Bad:

  ```bash
  while read line; do echo "$line" >> output; done < file
  ```

  Better:

  ```bash
  while read line; do echo "$line"; done < file > output
  ```

---

## 📦 3. **Tool Selection Tips**

* Prefer:

  * `[[ ... ]]` over `[ ... ]` (Bash)
  * `(( ... ))` for arithmetic
  * `read -r` to avoid backslash escapes
  * `printf` over `echo` (more portable and predictable)
* Use:

  * `cut`, `tr`, `sed`, `awk` **judiciously**
  * `grep -q` for silent matches (faster than piping to `/dev/null`)

---

## 🧠 4. **Code Practices**

* **Quote everything** unless expansion is intended:

  ```bash
  "$var" vs $var
  ```
* **Use `set -euo pipefail`** at the top for robustness:

  ```bash
  set -euo pipefail
  ```
* **Check return codes**, don’t assume success:

  ```bash
  if ! do_something; then
    echo "Failed"
    exit 1
  fi
  ```

---

## 🧪 5. **Testing & Debugging**

* Use `bash -n script.sh` for syntax check.
* Use `bash -x script.sh` for step-by-step tracing.
* Add log/debug mode:

  ```bash
  debug() { [[ "$DEBUG" == 1 ]] && echo "[DEBUG] $*"; }
  ```

---

* Rely on coreutils when possible (`basename`, `dirname`, `sort`, `uniq`).
* Use `/bin/sh` shebang if Bash isn't required.

---

## 📁 7. **Files and Paths**

* Use absolute paths in cron or system scripts.
* Quote file paths: `"$filename"` (handles spaces).
* Prefer `/tmp` or `mktemp` for temporary files.

---

## 🔐 8. **Security**

* Sanitize input:

  ```bash
  case "$user_input" in
    [a-zA-Z0-9]*) ;; # acceptable
    *) echo "Invalid input"; exit 1 ;;
  esac
  ```
* Avoid `eval` unless absolutely necessary.
* Don’t trust user input in filenames or commands.

---

## ✅ 9. **Use Functions**

* Break large scripts into functions for reuse and clarity.
* Keep global state minimal; pass arguments explicitly.

  ```bash
  do_backup() {
    local src="$1"
    local dst="$2"
    cp -r "$src" "$dst"
  }
  ```

---

## 📌 10. **Structure Template**

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

check_requirements() {
  command -v curl >/dev/null || { echo "curl required"; exit 1; }
}

parse_args() {
  # Parse command-line arguments
}

run_task() {
  # Main task here
}

main() {
  check_requirements
  parse_args "$@"
  run_task
}

main "$@"
```

---


# Parallel & thread example

```bash
#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

# Maximum number of parallel jobs (threads)
MAX_JOBS=$(nproc)  # Or set manually, e.g., MAX_JOBS=4

# Print messages with timestamps
log() {
  printf "[%s] %s\n" "$(date +%H:%M:%S)" "$*"
}

# Fake task simulating a heavy job
fake_job() {
  local task_id=$1
  log "Starting task $task_id"
  sleep $((RANDOM % 4 + 1))  # Sleep between 1-4 seconds
  log "Finished task $task_id"
}

# Thread pool: run job in background and wait if pool is full
run_in_pool() {
  fake_job "$1" &

  # Track jobs
  joblist+=($!)

  if [[ ${#joblist[@]} -ge $MAX_JOBS ]]; then
    wait "${joblist[0]}" 2>/dev/null || true
    joblist=("${joblist[@]:1}")
  fi
}

main() {
  joblist=()

  log "Starting parallel job runner with max $MAX_JOBS jobs"

  for i in {1..12}; do
    run_in_pool "$i"
  done

  # Final wait for all remaining jobs
  wait

  log "All tasks complete"
}

main "$@"

```


## Threading specific

Threading in shell scripting isn't *real* multithreading like in compiled
languages (C, Rust) or high-level scripting languages (Python). Instead, it's
**process-level parallelism** — but it's powerful and efficient for many
automation tasks.

 **process-level parallelism**
Below is a **complete guide to threading/parallelism in shell scripts**:

---

## 🧠 Core Concept: Simulated Threading via Background Processes

* In Bash, every command can run **in the background** using `&`:

  ```bash
  command &  # background job
  ```

* Use `wait` to **pause** the script until those background jobs finish:

  ```bash
  wait  # waits for all background jobs
  ```

---

## ✅ Minimal Example: Run Tasks in Parallel

```bash
#!/bin/bash

task() {
  echo "Task $1 started"
  sleep 2
  echo "Task $1 done"
}

for i in {1..3}; do
  task "$i" &
done

wait  # Wait for all background tasks
echo "All tasks complete"
```

Output (unordered due to concurrency):

```
Task 1 started
Task 2 started
Task 3 started
Task 1 done
Task 3 done
Task 2 done
All tasks complete
```

---

## 🧵 Example: Thread Pool with Max Parallel Jobs

This is essential to **limit concurrency** (like CPU threads):

```bash
#!/bin/bash
set -e

MAX_JOBS=4
joblist=()

task() {
  echo "Working on $1"
  sleep 3
  echo "Done with $1"
}

run_in_pool() {
  task "$1" &

  joblist+=($!)

  # If too many jobs are running, wait for the first to finish
  if (( ${#joblist[@]} >= MAX_JOBS )); then
    wait "${joblist[0]}"
    joblist=("${joblist[@]:1}")
  fi
}

for i in {1..10}; do
  run_in_pool "$i"
done

wait  # Final wait for remaining jobs
echo "Finished all"
```

---

## ⚡ Tools for Parallelism

### 1. **`xargs -P`** (Parallel from stdin)

```bash
cat urls.txt | xargs -n 1 -P 4 curl -O
```

* `-n 1`: One argument per command
* `-P 4`: Max 4 parallel jobs

### 2. **`GNU parallel`** (Highly recommended)

```bash
parallel -j 8 echo ::: a b c d e f g h
```

* `-j 8`: Run 8 parallel jobs
* `:::`: Input list

```bash
# Download 5 files at once
parallel -j 5 curl -O ::: https://site/file{1..20}.zip
```

> 📦 Install: `sudo apt install parallel`

---

## 🔒 Safe Practices

* Always `wait` to avoid leaving zombie processes.
* Redirect logs to individual files when running jobs concurrently:

  ```bash
  ./job.sh "$i" > logs/job$i.out 2>&1 &
  ```
* Use `mktemp` for temporary files in parallel scripts.

---

## 💡 Advanced Patterns

### Parallelizing Functions Dynamically:

```bash
run_task() {
  echo "Doing task $1"
  sleep $((RANDOM % 5 + 1))
  echo "Finished task $1"
}

for i in {A..E}; do
  run_task "$i" &
done

wait
```

### Parallel Loop Over Files:

```bash
for file in *.log; do
  gzip "$file" &
done
wait
```

### Parallelize With `find`:

```bash
find . -type f -name '*.log' | xargs -n 1 -P 4 gzip
```

---

## ✅ Summary: When & How to Use “Threading” in Shell Scripts

| Use Case                   | Best Technique               |
| -------------------------- | ---------------------------- |
| Simple background job      | `cmd &` + `wait`             |
| Concurrency with limits    | Thread pool via `wait` array |
| Command-line args or stdin | `xargs -P`                   |
| Complex pipelines          | `GNU parallel`               |
| One-off job batching       | Brace expansion `{}`         |

---

## 🧪 Template

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

MAX_PROCS=4
joblist=()

my_task() {
  echo "Starting $1"
  sleep 2
  echo "Done $1"
}

run_parallel() {
  my_task "$1" &
  joblist+=($!)
  if [[ ${#joblist[@]} -ge $MAX_PROCS ]]; then
    wait "${joblist[0]}"
    joblist=("${joblist[@]:1}")
  fi
}

for arg in "$@"; do
  run_parallel "$arg"
done

wait
```

---

## Above script explained

Here's a **detailed analysis and explanation** of this Bash script — which
implements a **parallel job runner with a controlled thread pool** using native
Bash constructs.

---

## ✅ Overview

This script simulates **multithreading in Bash** by:

* Running background tasks with `&`
* Tracking their process IDs (PIDs)
* Limiting the number of parallel jobs to `MAX_JOBS`
* Waiting on jobs as the queue fills
* Cleaning up after all jobs finish

This is a **classic thread pool pattern** — very useful in systems automation, deployment scripts, and heavy task batching.

---

## 🔍 Line-by-Line Breakdown

### Shebang and safety

```bash
#!/usr/bin/env bash
```

* Uses the `env` tool to find the user's preferred `bash` binary.

```bash
set -euo pipefail
IFS=$'\n\t'
```

* `-e`: Exit on any command error.
* `-u`: Treat unset variables as errors.
* `-o pipefail`: If any command in a pipeline fails, the whole pipeline fails.
* `IFS=$'\n\t'`: Ensures safe word-splitting — avoids bugs when filenames have spaces.

---

### Set max parallel jobs (thread pool size)

```bash
MAX_JOBS=$(nproc)
```

* Uses the number of CPU cores (`nproc`) to determine how many tasks can safely run in parallel.
* You can override this by manually setting `MAX_JOBS=4`, etc.

---

### Timestamped logging

```bash
log() {
  printf "[%s] %s\n" "$(date +%H:%M:%S)" "$*"
}
```

* Utility function to log messages with the current time (for progress tracking).
* Clean and helpful for debugging concurrency.

---

### Simulated task (the “job”)

```bash
fake_job() {
  local task_id=$1
  log "Starting task $task_id"
  sleep $((RANDOM % 4 + 1))  # 1–4 seconds
  log "Finished task $task_id"
}
```

* Represents a CPU-bound or I/O-bound task (like a build, fetch, or compress).
* Random sleep simulates jobs taking different times.

---

### The thread pool logic

```bash
run_in_pool() {
  fake_job "$1" &
  joblist+=($!)
```

* Runs `fake_job` in the background (`&`) and stores its PID in `joblist`.

```bash
  if [[ ${#joblist[@]} -ge $MAX_JOBS ]]; then
    wait "${joblist[0]}" 2>/dev/null || true
    joblist=("${joblist[@]:1}")
  fi
}
```

* When the job queue hits the max (`MAX_JOBS`), it waits for the **first** job to finish.
* Then removes it from the `joblist` to make room for the next.

✅ **This is the core logic** that simulates threading by controlling the concurrency pool manually.

---

### Main controller

```bash
main() {
  joblist=()
  log "Starting parallel job runner with max $MAX_JOBS jobs"
```

* Initializes the job list.
* Logs startup message.

```bash
  for i in {1..12}; do
    run_in_pool "$i"
  done
```

* Launches 12 fake jobs in parallel.
* Only `MAX_JOBS` run concurrently; the rest wait their turn as previous ones finish.

```bash
  wait
  log "All tasks complete"
}
```

* Ensures the **remaining background jobs** (after loop finishes) are completed before exit.
* Logs success.

---

## 🧠 What Makes This Script Powerful?

| Feature                     | Description                                                    |
| --------------------------- | -------------------------------------------------------------- |
| ✅ Efficient parallelism     | Runs `MAX_JOBS` tasks at once, no more                         |
| ✅ Portable Bash             | No need for `xargs -P` or `parallel`                           |
| ✅ Minimal CPU overcommit    | Respects system resource constraints (via `nproc`)             |
| ✅ Lightweight thread pool   | Tracks job PIDs manually, behaves like true threading          |
| ✅ Safe to use in automation | Robust thanks to `set -euo pipefail` and error-tolerant `wait` |

---

## 🔄 What Could Be Improved?

| Suggestion                           | Benefit                                  |
| ------------------------------------ | ---------------------------------------- |
| Use named functions per job type     | Easier to modularize multiple task types |
| Add error handling inside `fake_job` | Prevent partial failure or debug issues  |
| Add output redirection per job       | Log parallel output to files             |
| Use `trap` to handle script abort    | Clean up zombie jobs on Ctrl+C           |

---

## 🔚 Summary

This is a well-structured and efficient **Bash threading emulation pattern**
using a PID queue and `wait`. It’s especially valuable when:

* You can't install tools like `parallel`
* You want full control over job behavior
* You need parallel task execution with resource limits



---

### ✅ What *Does* Affect Performance in Parallel Bash Scripts?

| Factor                           | Affects Speed? | Explanation                                                               |
| -------------------------------- | -------------- | ------------------------------------------------------------------------- |
| **Number of background jobs**    | ✅ Yes          | More jobs = more concurrency, up to CPU/memory limits.                    |
| **How you manage concurrency**   | ✅ Yes          | Using `wait`, `xargs -P`, or `GNU parallel` properly improves throughput. |
| **Subshell avoidance**           | ✅ Yes          | Fewer subshells = fewer forks = faster.                                   |
| **Minimizing external commands** | ✅ Yes          | Built-ins are much faster than invoking `awk`, `grep`, `sed`, etc.        |
| **Loop type (`for` vs C-style)** | ❌ No           | Purely syntax: both compile to the same kind of interpreted loop in Bash. |


---

<br>

# 3. Appearance & aesthetics

### use 8 spaces for the function body


<br>
