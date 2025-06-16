#!/usr/bin/env bash


#for((;i++<10;)){ echo "$i";}
# function to cycle through an arrary
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

# create another arrary called arr_two
