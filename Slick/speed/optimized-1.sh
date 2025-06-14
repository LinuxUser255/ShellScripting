#!/usr/bin/env bash

arr=(a b c d e f g)
numbers=(1 2 3 4 5 6 7)

i=0
arr_len=${#arr[@]}

cycle() {
    printf '%s%s\n' "${numbers[i]}" "${arr[i]}"
    ((i=(i+1)%arr_len))
}

echo -e "\n⚡ Fast cycling mode. Press any key. Press 'q' to quit.\n"

while true; do
    read -n 1 -s key
    [[ $key == q ]] && echo -e "\n👋 Exiting..." && break
    cycle
done

