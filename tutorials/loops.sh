#!/usr/bin/env bash


# Regular for loop
loop_one() {
for i in {0..10}; do
    echo "$i"
done
}


# C-Style for loop
loop_two() {
    for((i=0;i<=10;i++)); do echo "$i"; done
}

main(){
    loop_one
    echo "-----------"
    loop_two
}

main


