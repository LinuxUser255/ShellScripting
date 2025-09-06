#!/usr/bin/env bash


echo "Using the subshell dollar sign (ps -p dollardollar -o comm=) to get the current shell"
echo

current_shell=$(ps -p $$ -o comm=)
echo "Current shell: $current_shell"
echo

echo "Using basename dollar sign SHELL to get the shell name"

echo "SHELL variable contains: $SHELL"
echo "Shell name: $(basename "$SHELL")"

echo

echo "=== Comparison ==="
echo "ps method shows: $current_shell"
echo "SHELL method shows: $(basename "$SHELL")"
echo

echo "=== Why cat \$SHELL doesn't work ==="
echo "\$SHELL is a file path: $SHELL"
echo "cat \$SHELL would display the binary executable (gibberish)"
echo "Use basename \$SHELL instead to get just the name"
