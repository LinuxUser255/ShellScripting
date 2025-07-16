#!/usr/bin/env bash

case "$USER" in
    root)
        : "Administrator"
        ;;
    guest)
        : "Guest"
        ;;
    *)
        : "Standard User"
        ;;
esac
role="$_"
echo "User role: $role"

