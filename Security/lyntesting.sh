#!/usr/bin/env bash

# Check if Lynis is installed
if ! command -v lynis &> /dev/null; then
    echo "Lynis is not installed. Please install it and try again."
    exit 1
fi

# Initialize report numbers
audit_number=1
pentest_number=1

# Prompt for audit and pentest names
read -r -p "Enter the system audit name: " audit_name
echo " "
read -r -p "Enter the system pentest name: " pentest_name

# Function to generate report
generate_report() {
    local name="$1"
    local number="$2"
    local type="$3"
    local log_file="$4"
    local report_file="${name}_${number}.txt"

    # give local user ownership to the report file
    sudo chown "$USER" "$report_file"

    # Run Lynis and generate the report with verbose output and log file
    echo "Running Lynis $type audit..."
    echo "Log file: $log_file"
    echo "Report file: $report_file"
    lynis audit system $type --verbose --log-file "$log_file" 2>/dev/null > "$report_file"
    echo "Report generated: $report_file"
}

# Run comprehensive Lynis audit
run_audit() {
    generate_report "$audit_name" "$audit_number" "" "/var/log/lynis/hardn-audit.log"
    audit_number=$((audit_number+1))
}

# Wait function to pause execution
pause_execution() {
    sleep 5
}

# Run Lynis with pentest profile for additional checks
run_pentest() {
    generate_report "$pentest_name" "$pentest_number" "--pentest" "/var/log/lynis/hardn-pentest.log"
    pentest_number=$((pentest_number+1))
}

# Call the functions
run_audit
pause_execution
run_pentest
