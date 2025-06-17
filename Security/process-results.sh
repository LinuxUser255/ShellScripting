#!/usr/bin/env bash

# Function to process files with the first ripgrep command
process_file_set_a() {
    local file_name=$1
    rg 'NONE|UNSAFE|WEAK|NOT FOUND|DISABLED' "${file_name}.txt" > "${file_name}_a.txt"
}

# Function to process files with the second ripgrep command
#process_file_set_b() {
#    local file_name=$1
#    rg -o 'NONE|UNSAFE|WEAK|NOT FOUND|DISABLED' "${file_name}.txt" | sort | uniq -c > "${file_name}_b.txt"
#}

# Main function to execute the processing
main() {
    echo " "
    read -r -p "Enter the system audit file name (without extension): " audit_name
    echo " "
    read -r -p "Enter the system pentest file name (without extension): " pentest_name
    echo " "

    # Process audit and pentest files with both sets of commands
    process_file_set_a "${audit_name}"
    process_file_set_a "${pentest_name}"

#    process_file_set_b "${audit_name}"
#    process_file_set_b "${pentest_name}"
}

main