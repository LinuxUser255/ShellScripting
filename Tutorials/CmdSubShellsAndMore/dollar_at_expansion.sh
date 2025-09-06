#!/usr/bin/env bash

#!/usr/bin/env bash

echo "=== Understanding \$@ Expansion ==="
echo

# Function to show exactly what it receives
show_expansion() {
    echo "Function received $# arguments:"
    echo "  \$1 = '$1'"
    echo "  \$2 = '$2'"
    echo "  \$3 = '$3'"
    echo "  \$4 = '$4'"
    echo
}

echo "Script called with: $0 $*"
echo "Number of arguments: $#"
echo

echo "What \$@ expands to:"
echo "Arguments: $*"
echo

echo "Calling function with \$@:"
show_expansion "$@"

echo "This is equivalent to calling:"
echo "show_expansion \"$1\" \"$2\" \"$3\" \"$4\""
