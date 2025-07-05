
# Bash For Loops and Case Statements Tutorial

This tutorial covers two important Bash scripting concepts: for loops (both traditional and C-style) and the simplified case statement pattern.

## 1. Traditional For Loop

The traditional for loop in Bash iterates through a list of items:

```bash
# Define an array
foo=(a b c d)

# Loop through each element in the array
for item in "${foo[@]}"; do
    echo "$item"
done
```

**Output:**
```
a
b
c
d
```

**Key points:**
- `"${foo[@]}"` references all elements in the array
- The quotes preserve elements with spaces
- Each element is assigned to `item` during iteration

## 2. C-Style For Loop

The C-style for loop follows the syntax: `for ((initialization; condition; increment))`:

```bash
# Define an array of numbers
nums=(1 2 3 4 5)

# C-style for loop to iterate through array indices
for ((i=0; i<${#nums[@]}; i++)); do
    printf "%d\n" "${nums[i]}"
done
```

**Output:**
```
1
2
3
4
5
```

**Breaking down the loop components:**
- **Initialization**: `i=0` - Start with index 0
- **Condition**: `i<${#nums[@]}` - Continue while index is less than array length
  - `${#nums[@]}` gets the length of the array
- **Increment**: `i++` - Increase index by 1 after each iteration
- **Access**: `${nums[i]}` - Access the element at index i

## 3. The Simpler Case Statement Pattern

This pattern uses the `:` built-in command and `$_` variable to simplify case statements:

```bash
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

read -r -p "Enter the car number (1-8): " choice

case "$choice" in
    1)
        : "Ford"
    ;;
    2)
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
        : "Invalid choice. Enter selection is 1-8 only."
    ;;
esac

car="$_"
echo "You have selected $car"
```

**Key points:**
- The `:` command evaluates its arguments and returns success (0)
- `$_` contains the last argument of the previous command
- This pattern avoids repeating variable assignments in each case
- The final `car="$_"` captures the value after the case statement completes

## How It Works

1. The user selects a number
2. The case statement runs the `:` command with the appropriate car brand
3. The `$_` variable stores that car brand name
4. After the case statement, we assign `$_` to the `car` variable
5. We display the selected car

This pattern is especially useful for long case statements where you want to set a variable based on multiple conditions without repetition.
