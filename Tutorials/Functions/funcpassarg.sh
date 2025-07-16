#!/usr/bin/env bash

showname(){
    # the $1 is a positional param passed to the first arg
    echo hello $1
    #if [ "$1" = chris ]; then
    if [ ${1,,} = chris ]; then
        return 0
    else
        return 1
    fi
}

showname $1

if [ $? = 1 ]; then
    echo "que????"
fi
