#!/usr/bin/env bash

#!/usr/bin/env bash

# Let's trace exactly what happens
trace_function_call() {
    echo "--- Function called with argument: '$1' ---"
    local shell_name="$1"
    echo "Inside function: shell_name = '$shell_name'"

    case "$shell_name" in
        "bash")
            echo "Case matched: bash branch"
            echo "Executing bash-specific code"
            ;;
        "zsh")
            echo "Case matched: zsh branch"
            echo "Executing zsh-specific code"
            ;;
        *)
            echo "Case matched: default branch"
            echo "Executing default code for: $shell_name"
            ;;
    esac
    echo "--- Function finished ---"
}

echo "=== Tracing Function Calls ==="
echo

echo "1. Calling: trace_function_call \"bash\""
trace_function_call "bash"
echo

echo "2. Calling: trace_function_call \"zsh\""
trace_function_call "zsh"
echo

echo "3. Calling: trace_function_call \"unknown\""
trace_function_call "unknown"
