#!/usr/bin/env bash

arr=(a b c d e f g)
numbers=(1 2 3 4 5 6 7)
cycles=10  # You can increase this to 100 or more if needed

echo "🔁 Starting benchmark with $cycles cycles..."

echo -e "\n--- 🚀 Optimized Version ---"

start_opt=$(date +%s%N)

i=0
while ((i < cycles)); do
    idx=$(( i % ${#arr[@]} ))
    printf '%s%s\n' "${numbers[idx]}" "${arr[idx]}"
    ((i++))
done

end_opt=$(date +%s%N)
elapsed_opt=$((end_opt - start_opt))
elapsed_opt_sec=$(echo "scale=3; $elapsed_opt / 1000000000" | bc)

echo "✅ Optimized version completed in ${elapsed_opt_sec} seconds."

echo -e "\n--- 🐢 Traditional Version ---"

start_trad=$(date +%s%N)

i=0
while true; do
    idx=$(( i % ${#arr[@]} ))
    echo "${numbers[idx]}${arr[idx]}"
    i=$(expr $i + 1)
    if [ $i -ge $cycles ]; then
        break
    fi
done

end_trad=$(date +%s%N)
elapsed_trad=$((end_trad - start_trad))
elapsed_trad_sec=$(echo "scale=3; $elapsed_trad / 1000000000" | bc)

echo "✅ Traditional version completed in ${elapsed_trad_sec} seconds."

echo -e "\n🏁 Benchmark complete."

