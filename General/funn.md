

# I have two bash scripts
# Use the # **Intructions:** below to answer this query.

# template
```bash

arr=(
    a
    b
    c
    d
    e
    f
    g
)

cycle() {
    printf '%s ' "${arr[${i:=0}]}"
    ((i=i>=${#arr[@]}-1?0:++i))
}

cycle
```

# **Intructions:**
# 1. Use the template above to refactor the shell script below.
# 2. Write two versions of the shell script. One 'normal', and the other optimized for perfomance-fast execution.
# 3. Both need Cycle through the arrary of of letters, and print each letter's associated number.
# 4. Measure the time it takes to execute each one from start to finish.
# 5. Optimize the script for performance and explain the optimized version, and why it's faster.
# 6. Lastly, give advice on how to write shell scripts that are otimized for speed.


```bash
#!/usr/bin/env bash

arr=(a b c d e f g)
numbers=('1' ,'2', '3', '4', '5', '6', '7')
i=0

cycle() {
  printf "${numbers[i % ${#numbers[@]}]}%s\033[0m\n" "${arr[i]}"
  ((i=(i+1)%${#arr[@]}))
}

echo -e "\n Press any key to cycle. Press 'q' to quit.\n"

while true; do
  read -n 1 -s key
  [[ $key == q ]] && echo -e "\ Exiting..." && break
  cycle
done

```
