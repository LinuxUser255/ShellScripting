#!/usr/bin/env bash


SHELL_NAME="$(ps -p $$ -o comm=)"

echo "Current shell: $SHELL_NAME"

if [ "$SHELL_NAME" = "zsh" ]; then
    echo "You're curetnt shell is zsh."
else
    echo "You're currently using a different shell. Please switch to zsh."
fi
