#!/usr/bin/env bash

case "$USER" in
    root)
        role="Administrator"
        ;;
    guest)
        role="Guest"
        ;;
    *)
        role="Standard User"
        ;;
esac
echo "User role: $role"
