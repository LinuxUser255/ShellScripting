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


echo "Using the subshell dollar sign (ps -p dollardollar -o comm=) to get the current shell"
echo
current_shell=$(ps -p $$ -o comm=)
echo "Current shell: $current_shell"
echo

echo "Using echo dollar sign SHELL to get the current shell"
echo "$SHELL"

echo












