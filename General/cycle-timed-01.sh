#!/usr/bin/env bash

arr=(a b c d e f g h i j k l m n o p q r s t)
numbers=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)
arr_len=${#arr[@]}
i=0
cycles=20

start_time=$(date +%s%N)

while ((i < cycles)); do
    printf '%s%s\n' "${numbers[i]}" "${arr[i]}"
    ((i++))
    #sleep 1
done

end_time=$(date +%s%N)
elapsed_ns=$((end_time - start_time))
elapsed_sec=$(echo "scale=3; $elapsed_ns / 1000000000" | bc)

echo -e "\n⏱️ Completed $cycles cycles in ${elapsed_sec}s"

