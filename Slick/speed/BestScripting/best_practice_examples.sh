#!/usr/bin/env bash


# set strict mode to catch errors as soon as possible
set -euo pipefail

basic_var(){
        # Example 1: Basic variable usage and string manipulation
        echo "=== Example 1: Basic Variables and Strings ==="
        name="Bash Scripting"
        echo "Hello, $name!"
        echo "Length of name: ${#name}"
        echo "Uppercase: ${name^^}"
        echo "Lowercase: ${name,,}"
        echo "Replace 'Bash' with 'Shell': ${name/Bash/Shell}"
        echo



}
basic_var

basic_array(){
    fruits=("apple" "banana" "orange")
    echo "=== Example 2: Basic Array Usage ==="
    echo "Fruits array: ${fruits[@]}"
    echo "First fruit: ${fruits[0]}"
    echo "Last fruit: ${fruits[-1]}"
    echo "Number of fruits: ${#fruits[@]}"
    echo "fruits from index one to three: ${#fruits[@]:1:3}"

}
basic_array



















