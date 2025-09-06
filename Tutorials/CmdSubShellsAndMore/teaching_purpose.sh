#!/usr/bin/env bash


# In my teaching example, I wanted to show you:

educational_case_demo() {
    local shell_type="$1"

    echo "Processing shell type: $shell_type"

    case "$shell_type" in
        "bash")
            echo "✓ Bash case works correctly"
            ;;
        "zsh")
            echo "✓ Zsh case works correctly"
            ;;
        *)
            echo "✓ Default case works correctly"
            ;;
    esac
}

echo "=== Educational Demonstration ==="
echo

echo "Goal: Show that case statement handles different inputs correctly"
echo

echo "Demo 1: What happens with 'bash' input?"
educational_case_demo "bash"
echo

echo "Demo 2: What happens with 'zsh' input?"
educational_case_demo "zsh"
echo

echo "Demo 3: What happens with unexpected input?"
educational_case_demo "fish"
echo

echo "This proves the case statement logic is working!"
