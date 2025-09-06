#!/usr/bin/env bash

#!/usr/bin/env bash

# The function DEFINITION - this creates the function
check_shell_with_case_basic() {
    local shell_name="$1"  # $1 receives the first argument passed to the function

    echo "Function received argument: '$shell_name'"

    case "$shell_name" in
        "bash")
            echo "→ Bash case executed"
            ;;
        "zsh")
            echo "→ Zsh case executed"
            ;;
        *)
            echo "→ Default case executed"
            ;;
    esac
}

echo "=== Understanding Function Arguments ==="
echo

echo "Call 1: check_shell_with_case_basic \"bash\""
check_shell_with_case_basic "bash"    # "bash" becomes $1 inside the function
echo

echo "Call 2: check_shell_with_case_basic \"zsh\""
check_shell_with_case_basic "zsh"     # "zsh" becomes $1 inside the function
echo

echo "Call 3: check_shell_with_case_basic \"fish\""
check_shell_with_case_basic "fish"    # "fish" becomes $1 inside the function
