#!/usr/bin/env bash

echo "=== Different ways to get shell information ==="
echo

echo "1. The Current running shell (ps method):"
echo "  \$(ps -p \$\$ -o comm=) $(ps -p $$ -o comm=)"

echo

echo "2. The login shell (SHELL variable):"
echo "  \$SHELL" = "$SHELL"
echo

echo "3. Login shell name (basename method):"
echo "   \$(basename \"\$SHELL\") = $(basename "$SHELL")"
echo " basename gets the shell name from the path."
echo

echo "4. What happens with cat \$SHELL:"
echo "   This would show binary data because \$SHELL is a file path!"
echo "   \$SHELL points to: $SHELL"
echo "   That's an executable file, not text to read"
echo

echo "5. echo \$SHELL"
echo "$SHELL"
echo

echo "=== Correct approaches ==="
echo "✓ For current shell: ps -p \$\$ -o comm="
echo "✓ For login shell: basename \"\$SHELL\""
echo "✗ Never use: cat \"\$SHELL\""

