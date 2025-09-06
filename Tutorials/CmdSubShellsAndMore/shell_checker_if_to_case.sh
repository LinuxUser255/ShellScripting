#!/usr/bin/env bash

# Simple demonstration of $(ps -p $$ -o comm=)
# This script shows how to detect the current shell

echo "=== Shell Detection Demo ==="
echo

## Get the current shell name
current_shell="$(ps -p $$ -o comm=)"
echo "Current shell: $current_shell"
echo
#


#check_shell_with_if(){
#    if [ "$current_shell" = "bash" ]; then
#        echo "You're running this script in Bash!"
#        echo "Bash-specific features are available."
#
#    elif [ "$current_shell" = "zsh" ]; then
#        echo "You're running this script in Zsh!"
#        echo "Zsh-specific features are available."
#
#    elif [ "$current_shell" = "sh" ]; then
#        echo "You're running this script in basic sh shell."
#        echo "Using POSIX-compatible features only."
#
#    else
#        echo "You're running this script in: $current_shell"
#        echo "This is a different shell type."
#    fi
#}

check_shell_with_case_basic() {
    # use a parameter. Get the shell name from the function argument.
    local shell_name="$1"

    case "$shell_name" in
        "bash")
            echo "You're running this script in Bash!"
            echo "Bash-specific features are available."
            ;;
        "zsh")
            echo "You're running this script in ZSh!"
            echo "Zsh-specific features are available."
            ;;
        "sh")
            echo "You're running this script in basic sh shell."
            echo "Using POSIX-compatible features only."
            ;;
        *)
            echo "Unknown shell: $shell_name"
            ;;
    esac

}

#check_shell_with_if
#check_shell_with_case_basic "$@" # corresponds to the argument passed to the script local shell_name="$1"

echo "---Basic case conversion---"
check_shell_with_case_basic "bash"
echo
check_shell_with_case_basic "zsh"
































#echo
## Test the function
#echo "=== Testing if-elif version ==="
#check_shell_with_if "bash"
#echo
#check_shell_with_if "zsh"
#echo
#check_shell_with_if "fish"
#echo
#check_shell_with_if "unknown"
#echo
#



