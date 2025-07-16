#!/usr/bin/env bash

# Conditionals
if [ ${1,,} = chris ]; then
        echo "hello"
elif [ ${1,,} = help ]; then
        echo "enter your name"
else
    echo "go away"
fi

# Conditionals
#arg=$(echo "$1" | tr '[:upper:]' '[:lower:]')
#if [ "$arg" = "chris" ]; then
#        echo "hello"
#elif [ "$arg" = "help" ]; then
#        echo "enter your name"
#else
#    echo "go away"
#fi
#

