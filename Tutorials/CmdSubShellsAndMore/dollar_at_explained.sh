#!/usr/bin/env bash

#!/usr/bin/env bash

echo "=== Understanding \$@ vs hardcoded strings ==="
echo

# Function that shows what it receives
show_arguments() {
    echo "Function received $# arguments:"
    local count=1
    for arg in "$@"; do
        echo "  Argument $count: '$arg'"
        ((count++))
    done
    echo
}

echo "1. With hardcoded string:"
show_arguments "bash"
echo

echo "2. With \$@ (script arguments):"
show_arguments "$@"
echo

echo "Script was called with: $0 $*"
echo "Number of arguments passed to script: $#"
