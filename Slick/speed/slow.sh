#!/usr/bin/env bash

# trad-slow
arr=(a b c d e f g)
numbers=(1 2 3 4 5 6 7)
i=0

start=$(date +%s%N)

while true; do
    echo ${numbers[$i]}${arr[$i]}
    i=$(expr $i + 1)

    if [ $i -ge 6 ]; then
        break
    fi
done

end=$(date +%s%N)
elapsed=$(echo "scale=3; ($end - $start)/1000000000" | bc)

echo ""
echo "⏱️ Finished in ${elapsed}s"

