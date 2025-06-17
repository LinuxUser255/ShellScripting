#!/usr/bin/env bash

read_file() {
    echo " "
    read -r -p "Enter the system audit audit name: " audit_name
    echo " "
    read -r -p "Enter the system pentest audit name: " pentest_name
    echo " "
}

process_file() {
    local file_name=$1
    rg 'NONE|UNSAFE|WEAK|NOT FOUND|DISABLED' "${file_name}.txt" > "${file_name}_needs_fixing.txt"
}

count_issues() {
    local file_name=$1
    rg -o 'NONE|UNSAFE|WEAK|NOT FOUND|DISABLED' "${file_name}_needs_fixing.txt" | sort | uniq -c
}

main() {
    read_file
    process_file "${audit_name}"
    process_file "${pentest_name}"

    count_issues "${audit_name}"
    count_issues "${pentest_name}"
}

main