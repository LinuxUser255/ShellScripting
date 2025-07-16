#!/usr/bin/env bash

arr=(a b c d e f g h i j)
numbers=(1 2 3 4 5 6 7 8 9 10)
i=0
cycles=10

start_time=$(date +%s%N)

while ((i < cycles)); do
    printf '%s%s\n' "${numbers[i]}" "${arr[i]}"
    ((i++))

done

end_time=$(date +%s%N)
elapsed_ns=$((end_time - start_time))
elapsed_ns=$((end_time - start_time))

# show the elapsed time in human readable format to the tenth decimal place
echo "Elapsed time: $(bc <<< "scale=10; $elapsed_ns / 1000000000") seconds"
