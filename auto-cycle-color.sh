#!/usr/bin/env bash


arr=(a b c d e f g)
colors=("\033[31m" "\033[32m" "\033[33m" "\033[34m" "\033[35m" "\033[36m")
i=0

cycle() {
  printf "${colors[i % ${#colors[@]}]}%s\033[0m\n" "${arr[i]}"
  ((i=(i+1)%${#arr[@]}))
}

echo -e "\n🔁 Auto-cycling through array every 1 second. Press Ctrl+C to stop.\n"

while true; do
  cycle
  sleep 1
done

