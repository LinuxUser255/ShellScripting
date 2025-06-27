
To copy the file `pure-bash.md` into the directory `test-scripts`, the best `cp` command is:

```bash
cp pure-bash.md test-scripts/
```

---

### ✅ Explanation:

* `cp`: The copy command.
* `pure-bash.md`: The source file.
* `test-scripts/`: The target directory (`/` makes it clear it's a directory).

---

### 🧠 Good Practices:

* Make sure the `test-scripts` directory exists:

  ```bash
  ls -ld test-scripts
  ```
* If you're unsure whether `test-scripts` exists, and want to create it if it doesn't:

  ```bash
  mkdir -p test-scripts && cp pure-bash.md test-scripts/
  ```

---

### 🚨 Optional Flags (for advanced use):

* `-v`: Verbose (shows what's being copied)
* `-i`: Interactive (asks before overwrite)
* `-u`: Copy only if source is newer than destination
* `-p`: Preserve metadata (timestamps, permissions)

Example:

```bash
cp -vip pure-bash.md test-scripts/
```


