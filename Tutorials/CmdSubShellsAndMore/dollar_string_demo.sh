#!/usr/bin/env bash

#!/usr/bin/env bash

check_shell_demo() {
    local shell_name="$1"
    echo "Function processing: '$shell_name'"

    case "$shell_name" in
        "bash")
            echo "→ Bash case executed"
            ;;
        "zsh")
            echo "→ Zsh case executed"
            ;;
        "")
            echo "→ No argument provided"
            ;;
        *)
            echo "→ Default case: $shell_name"
            ;;
    esac
    echo
}

echo "=== Comparison: Hardcoded vs \$@ ==="
echo

echo "1. Hardcoded approach:"
check_shell_demo "bash"    # Always passes "bash"
check_shell_demo "zsh"     # Always passes "zsh"

echo "2. Using \$@ approach:"
echo "Script arguments: $*"
echo "Number of arguments: $#"
check_shell_demo "$@"      # Passes whatever YOU gave to the script

echo "3. What happens with no arguments:"
if [ $# -eq 0 ]; then
    echo "No arguments provided to script"
    check_shell_demo "$@"  # This passes nothing (empty)
fi
