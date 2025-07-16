#!/usr/bin/env bash

case "$1" in
    *.txt)
        file_type="Text"
        ;;
    *.md)
        file_type="Markdown"
        ;;
    *.sh)
        file_type="Shell Script"
        ;;
    *)
        file_type="Unknown"
        ;;
esac
echo "File type: $file_type"
