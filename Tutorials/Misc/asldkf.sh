#!/usr/bin/env bash

# Conditionals
arg=$(echo "$1" | tr '[:upper:]' '[:lower:]')
if [ "$arg" = "chris" ]; then
        echo "hello"
elif [ "$arg" = "help" ]; then
        echo "enter your name"
else
    echo "go away"
fi

