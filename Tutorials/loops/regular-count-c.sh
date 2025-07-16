#!/usr/bin/env bash

# Now, let’s refactor the same script to use a C-style for loop, which uses an
# index to access array elements and eliminates the need for a separate counter:


fruits=(apple banana orange)

for ((i=0; i<${#fruits[@]}; i++)); do
    echo "Fruit $((i+1)): ${fruits[$i]}"
done
