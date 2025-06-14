#!/usr/bin/env bash

arr=(a b c d e f g)
numbers=(1 2 3 4 5 6 7)
i=0
cycles=6

start_time=$(date +%s%N)

while ((i < cycles)); do
    printf '%s%s\n' "${numbers[i]}" "${arr[i]}"
    ((i++))
    # sleep 1  # optional delay
done

end_time=$(date +%s%N)
elapsed_ns=$((end_time - start_time))
elapsed_sec=$(echo "scale=3; $elapsed_ns / 1000000000" | bc)

echo -e "\n⏱️ Completed $cycles cycles in ${elapsed_sec}s"

