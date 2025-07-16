#!/usr/bin/env bash

case "$1" in
    *.txt)
        : "Text"
        ;;
    *.md)
        : "Markdown"
        ;;
    *.sh)
        : "Shell Script"
        ;;
    *)
        : "Unknown"
        ;;
esac
file_type="$_"
echo "File type: $file_type"
