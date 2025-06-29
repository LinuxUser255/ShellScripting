#!/usr/bin/env bash

# ATTN! You need ripgrep installed first.
# sudo apt install ripgrep

# Function to process files with the first ripgrep command
process_file_set_a() {
    local file_name=$1
    rg 'NONE|UNSAFE|WEAK|NOT FOUND|DISABLED' "${file_name}.txt" > "${file_name}_a.txt"
}

# Function to process files with the second ripgrep command
process_file_set_b() {
    local file_name=$1
    rg -o 'NONE|UNSAFE|WEAK|NOT FOUND|DISABLED' "${file_name}.txt" | sort | uniq -c > "${file_name}_b.txt"
}

# This function is still a work in progress. Though not 100% necessary for this task,
# Still experimenting with the sed regex to clean the output.
# Function to clean the output files
#clean_output() {
#    local file_name=$1
#    sed 's/^[[:space:]]*//; s/-//g; s/://g; s/\[[^]]*\]//g' "${file_name}_a.txt" > "${file_name}_a_clean.txt"
#    sed 's/^[[:space:]]*//; s/-//g; s/://g; s/\[[^]]*\]//g' "${file_name}_b.txt" > "${file_name}_b_clean.txt"
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

    process_file_set_b "${audit_name}"
    process_file_set_b "${pentest_name}"

    # Clean the output files
#    clean_output "${audit_name}"
#    clean_output "${pentest_name}"
}

main
