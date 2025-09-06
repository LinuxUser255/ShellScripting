#!/usr/bin/env bash

echo

# Simple demonstration of $(ps -p $$ -o comm=)
# This script shows how to detect the current shell

echo "=== Shell Detection Demo ==="
echo

# - `$$` is a special shell variable that contains the Process ID (PID) of the current shell process
# - `ps -p $$` runs the `ps` command to show information about the process with PID `$$` (the current shell)
# - `-o` specifies custom output format
# - `comm` is a column name that shows the command name (the executable name of the process)
# -  The `=` after `comm` tells `ps` to omit the column header

# first example: Output the command name of the current shell process
echo "Example 1: Output the command name of the current shell process"
echo

current_shell=$(ps -p $$ -o comm=)
echo "Current shell: $current_shell"
echo

echo "using the = and not using the = to output the column header"
echo "Without the '='"
echo
ps -p $$ -o comm

echo
echo "With the '=' omitting the column header"
ps -p $$ -o comm=

echo
echo "Example 2: Checking if current shell is bash, zsh, or sh"
echo "============================================="
echo

current_shell=$(ps -p $$ -o comm=)

if [ "$current_shell" = "bash" ]; then
    echo "bash shell."

elif [ "$current_shell" = "zsh" ]; then
    echo "zsh shell."

elif [ "$current_shell" = "sh" ]; then
    echo "POSIX shell sh"

else
    echo "You're running this script in: $current_shell"
    echo "This is a different shell type."


fi

echo


# Show process ID and shell info
echo "Example 3: Show process ID and shell info"
echo "Current process ID ($$): $$"
echo "Parent process ID (\$PPID): $PPID"
echo "Shell executable path: $(command -v "$current_shell")"
echo
















