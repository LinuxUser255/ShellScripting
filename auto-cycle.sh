#!/usr/bin/env bash


arr=(a b c d e f g)
names=("chris" "hannah" "harry" "caroline" "vanessa" "jason")
i=0

cycle() {
  printf "${names[i % ${#names[@]}]}%s\033[0m\n" "${arr[i]}"
  ((i=(i+1)%${#arr[@]}))
}

echo -e "\n🔁 Auto-cycling through array every 1 second. Press Ctrl+C to stop.\n"

while true; do
  cycle
  sleep 1
done

