#!/usr/bin/env bash


arr=(a b c d e f g)
colors=("\033[31m" "\033[32m" "\033[33m" "\033[34m" "\033[35m" "\033[36m")
i=0

cycle() { printf "${colors[$((i % ${#colors[@]}))]}%s\033[0m\n" "${arr[i]}"; ((i=(i+1)%${#arr[@]})); }

echo -e "\n🔁 Press any key to cycle. Press 'q' to quit.\n"

while true; do
  read -n 1 -s key
  [[ $key == q ]] && echo -e "\n👋 Exiting..." && break
  cycle
done

