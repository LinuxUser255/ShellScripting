# if else, to ternary

In **Bash scripting**, there is no direct "ternary operator" like in languages
such as C, Java, or JavaScript. However, you can achieve similar functionality
using **logical operators** and the `&&` (AND) and `||` (OR) operators.

<br>

### **Traditional `if` statement in Bash:**

```bash
if [ condition ]; then
    # Execute if true
else
    # Execute if false
fi
```

### **Equivalent "ternary" in Bash:**

The general structure for a ternary-like operation in Bash is:

```bash
[ condition ] && command_if_true || command_if_false
```

### **Explanation:**

* `[ condition ]` — The test condition (like an `if` check).
* `&&` — Logical AND, meaning if the condition is true, execute the first command.
* `||` — Logical OR, meaning if the condition is false, execute the second command.

#### **Formula (Pseudo-code / sudo-code):**

```bash
[ condition ] && action_if_true || action_if_false
```

This can be thought of like:

```bash
if condition:
    action_if_true
else:
    action_if_false
```

### **Example:**

Let's take an example where we check if a file exists and print a message based
on that:

#### Traditional `if` statement:

```bash
if [ -f "file.txt" ]; then
    echo "File exists"
else
    echo "File does not exist"
fi
```

#### Ternary-like Bash:

```bash
[ -f "file.txt" ] && echo "File exists" || echo "File does not exist"
```

### **Important Notes:**

1. **Short-circuit behavior**: The `&&` and `||` operators in Bash **short-circuit**. This means that if the first condition (`&&`) is true, the second part (`||`) won't be executed. However, if the first condition fails, the second part will be executed.

   So, if the first command (`echo "File exists"`) has an error, the second part (`echo "File does not exist"`) will be run **even if the condition is true**. To handle this more safely, we might need to add a `;` after the first command, like so:

   ```bash
   [ -f "file.txt" ] && echo "File exists" || echo "File does not exist"
   ```

   Alternatively, you could use an explicit `if` for more complex logic.

### **Edge Case (using only `&&` and `||`):**

For a case where you need to avoid unwanted execution of the false branch, you
might need a nested ternary structure or the `;` to ensure the false command
doesn't get executed when the true condition is met.


<br>

