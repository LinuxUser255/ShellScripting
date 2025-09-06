#!/usr/bin/env bash

#!/usr/bin/env bash

echo "=== Comparison: \$SHELL vs ps command ==="
echo

echo "1. SHELL environment variable:"
echo "   \$SHELL = $SHELL"
echo "   basename \$SHELL = $(basename "$SHELL")"
echo

echo "2. Current running shell (ps method):"
echo "   \$(ps -p \$\$ -o comm=) = $(ps -p $$ -o comm=)"
echo

echo "3. Parent shell:"
echo "   \$(ps -p \$PPID -o comm=) = $(ps -p $PPID -o comm=)"
echo

echo "=== Key Differences ==="
echo

echo "SHELL variable shows:"
echo "  - Your LOGIN/DEFAULT shell (set at login)"
echo "  - What's in /etc/passwd for your user"
echo "  - Doesn't change when you switch shells"
echo

echo "ps command shows:"
echo "  - The ACTUAL shell currently running"
echo "  - Changes when you exec into different shells"
echo "  - Shows the real process name"
echo

echo "=== Demonstration ==="
echo "Try these commands in your terminal:"
echo "  echo \$SHELL        # Shows your login shell"
echo "  bash               # Start a bash session"
echo "  echo \$SHELL        # Still shows your login shell!"
echo "  ps -p \$\$ -o comm= # Shows 'bash' (actual current shell)"
echo "  exit               # Return to your original shell"
