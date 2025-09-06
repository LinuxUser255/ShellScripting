#!/usr/bin/env bash

#!/usr/bin/env bash

# This function has multiple code paths (branches)
demo_case_function() {
    local input="$1"

    case "$input" in
        "bash")
            echo "Path A: Bash-specific logic"
            echo "Setting BASH_OPTIONS..."
            ;;
        "zsh")
            echo "Path B: Zsh-specific logic"
            echo "Setting ZSH_OPTIONS..."
            ;;
        "sh")
            echo "Path C: POSIX shell logic"
            echo "Using basic features only..."
            ;;
        *)
            echo "Path D: Unknown shell logic"
            echo "Using generic fallback..."
            ;;
    esac
}

echo "=== Why We Test Different Arguments ==="
echo

echo "Testing ensures ALL code paths work correctly:"
echo

echo "Test 1 - Bash path:"
demo_case_function "bash"    # Tests the "bash" case
echo

echo "Test 2 - Zsh path:"
demo_case_function "zsh"     # Tests the "zsh" case
echo

echo "Test 3 - POSIX path:"
demo_case_function "sh"      # Tests the "sh" case
echo

echo "Test 4 - Default path:"
demo_case_function "unknown" # Tests the "*" default case
echo

echo "Without testing different arguments, we wouldn't know if all cases work!"
