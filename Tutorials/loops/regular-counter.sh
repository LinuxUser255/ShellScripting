#!/usr/bin/env bash

# Counter (for each style)

fruits=(apple banana orange)

count=0
for fruit in "${fruits[@]}"; do
    ((count++))
    echo "Fruit $count: $fruit"
done
