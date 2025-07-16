#!/usr/bin/env bash

#------------------------------------------------------------------------------
# TUTORIAL: Forloops & The Simpler Case Statement
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# PART 1: Traditional For Loop
#------------------------------------------------------------------------------
# This demonstrates the standard Bash for loop that iterates through array elements
# foo=(a b c d)

# Define an array of letters
foo=(a b c d)

# Loop through each element in the array
# "${foo[@]}" references all elements in the array with proper quoting
for item in "${foo[@]}"; do
    echo "$item"
done

echo ""

#------------------------------------------------------------------------------
# PART 2: C-Style For Loop
#------------------------------------------------------------------------------
# C-Style for loop syntax:
# for (( initialization; condition; increment )); do
#     commands
# done

# Define an array of numbers
nums=(1 2 3 4 5)

# C-style for loop breakdown:
# i=0                 - Initialize counter to 0 (first element index)
# i<${#nums[@]}       - Continue while i is less than array length
#   ${#nums[@]}       - The # operator gets the length of the array
#   nums[@]           - The @ symbol references all array elements
# i++                 - Increment i by 1 after each iteration
for ((i=0; i<${#nums[@]}; i++)) do
    # ${nums[i]}      - Access the element at index i
    printf "%d\n" "${nums[i]}"
done

echo ""

#------------------------------------------------------------------------------
# PART 3: The Simpler Case Statement Using : and $_
#------------------------------------------------------------------------------
# This demonstrates a technique to simplify variable assignment in case statements
# using the : built-in command and $_ special variable

# Display options using heredoc for cleaner multi-line output
cat << 'EOF'
Choose a car brand:
Options:
1) Ford
2) Toyota
3) Honda
4) BMW
5) Nissan
6) Kia
7) Audi
8) Ferrari
EOF

# Get user input
read -r -p "Enter the car numer (1-8): " choice

# Process the input using the simplified case statement pattern
case "$choice" in
    1)
        # The : (colon) is a built-in command that:
        # 1. Does nothing except evaluate its arguments
        # 2. Always returns success (exit code 0)
        # 3. Sets $_ to its last argument ("Ford")
        : "Ford"
    ;;
    2)
        # Here, $_ will become "Toyota" after this command
        : "Toyota"
    ;;
    3)
        : "Honda"
    ;;
    4)
        : "BMW"
    ;;
    5)
        : "Nissan"
    ;;
    6)
        : "Kia"
    ;;
    7)
        : "Audi"
    ;;
    8)
        : "Ferrari"
    ;;
    *)
        # Even for invalid input, we use the same pattern
        # This ensures $_ contains a meaningful error message
        : "Invalid choice. Enter selection is 1-8 only."
    ;;
esac

# The flow of execution:
# 1. User enters a number (e.g., 2)
# 2. The case statement matches this with case 2
# 3. The command : "Toyota" runs
# 4. $_ now contains "Toyota" (not the number 2)
# 5. You now capture this value with car="$_"

# Set the car variable using the $_ special variable
# $_ contains the last argument of the most recently executed command
car="$_"

# Display the result
echo "You have selected $car"










