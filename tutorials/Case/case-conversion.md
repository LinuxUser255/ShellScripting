
# Learning how to write a Simple Case statment

## First, start with the traditional method

## Second, the Simple Case

```bash
#!/usr/bin/env bash

# Prompt user to select a distribution
echo "Please select your Linux distribution:"
echo "1) Debian"
echo "2) Ubuntu"
echo "3) Fedora"
echo "4) Arch"
echo "5) OpenSUSE"
echo "6) Void"
read -p "Enter the number (1-6): " choice

# Case statement to handle user input
case $choice in
        1)
            echo "You selected Debian."
            ;;
        2)
            echo "You selected Ubuntu."
            ;;
        3)
            echo "You selected Fedora."
            ;;
        4)
            echo "You selected Arch."
            ;;
        5)
            echo "You selected OpenSUSE."
            ;;
        6)
            echo "You selected Void."
            ;;
        *)
            echo "Invalid choice. Please enter a number between 1 and 6."
        ;;
esac

```

# The Simpler Case Statement

```bash

# Simpler Case, Non-traditional
echo "Please select your Linux disto:"
echo "1) Debian"
echo "2) Ubuntu"
echo "3) Fedora"
read -r -p "Enter the number (1-3): " choice

# Case statement to handle user input
case $choice in
        1)
            : "Debian"  # the : evals args, and returns 0 success status code
        ;;
        2)
            : "Ubuntu"
        ;;
        3)
            : "Fedora"
        ;;
        *)
            : "Invalid option. Please try again."
        ;;


esac

distro="$_"

echo "You selected $distro."

#------------------------------------------------------------------------------
# EXPLANATION: THE SIMPLER CASE STATEMENT PATTERN
#------------------------------------------------------------------------------

# How the pattern works:
# ---------------------
# 1. Use `: "Distribution Name"` instead of directly echoing the result
#    in each case branch.
# 2. After the case statement completes, we capture the value with `distro="$_"`.
# 3. Finally, we display the message with the selected distribution.
#
# This approach is particularly useful when setting a variable based on multiple
# conditions, avoiding repetition of variable assignments in each case branch.
# It follows the DRY (Don't Repeat Yourself) principle.

#------------------------------------------------------------------------------
# THE COLON COMMAND AND $_ VARIABLE
#------------------------------------------------------------------------------

# The : (colon) command:
# - Is a shell built-in that does nothing except evaluate its arguments
# - Always returns a success status code (0)
# - Takes arguments but performs no operation on them

# The `$_ `variable:
# - Contains the last argument of the most recently executed command
# - Is automatically set by the shell after each command execution

# Flow of execution:
# 1. User enters a number (e.g., 2)
# 2. The case statement matches this input with the appropriate case
# 3. For case 2, the command `: "Ubuntu"` runs
# 4. After this command executes, $_ now contains "Ubuntu" (not the number 2)
# 5. After the case statement completes, we capture this value with `distro="$_"`

#------------------------------------------------------------------------------
# THE IMPORTANCE OF THE CATCH-ALL CASE (*)
#------------------------------------------------------------------------------

# The *) pattern in the case statement:
# - Acts as a catch-all or default case for any unmatched input
# - Similar to default: in C-like languages or else in if-else chains
# - Essential for robust script behavior

# Why the catch-all case is crucial:
# 1. It ensures ALL possible user inputs are handled, not just valid options
# 2. It provides meaningful feedback for invalid inputs
# 3. It maintains the pattern of setting the $_ variable consistently
# 4. It prevents undefined behavior by ensuring distro always has a valid value

# Without this catch-all case:
# - Invalid inputs like "7" or "banana" would be silently ignored
# - The `$_ `variable might contain unpredictable values from previous commands
# - This could lead to confusing output or potential errors


```
