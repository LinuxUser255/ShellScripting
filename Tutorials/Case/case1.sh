#!/usr/bin/env bash

# Normal Case

echo "Please select your Linux distribution:"
echo "1) Debian"
echo "2) Ubuntu"
echo "3) Fedora"
read -r -p "Enter the number (1-3): " choice

# Case statement to handle user input
case $choice in
    1)
        echo "You selected Debian."
        ;;
    2)
        echo "You selected Ubuntu."
        ;;
    3)
        echo "You selected Fedora."
        ;;
    *)
        echo "Invalid choice. Please enter a number between 1 and 6."
        ;;
esac

















