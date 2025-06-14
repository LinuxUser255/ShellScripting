#!/usr/bin/env bash

# best-shellscript-ever.sh - A demonstration of pure bash techniques
#
# Description:
#   This script demonstrates modern bash scripting techniques including
#   parameter expansion, code golf style conditionals, and proper error handling.
#   It processes a text file by converting all lines to uppercase and outputs
#   the result to a specified file or an automatically generated one.
#
# Usage:
#   ./best-shellscript-ever.sh -f|--file <input_file> [-o|--output <output_file>]
#   ./best-shellscript-ever.sh -h|--help
#   ./best-shellscript-ever.sh -v|--version
#
# Examples:
#   ./best-shellscript-ever.sh --file input.txt
#   ./best-shellscript-ever.sh --file input.txt --output result.txt
#
# Author: Christopher Bingham
# Date: 2025-06-14
# License: GPLv3

# Strict mode - makes the script fail fast and explicitly
# -e: Exit immediately if a command exits with non-zero status
# -u: Treat unset variables as an error
# -o pipefail: Return value of a pipeline is the value of the last command to exit with non-zero status
set -euo pipefail
IFS=$'\n\t'  # Set Internal Field Separator to newline and tab (not space) to avoid issues with filenames containing spaces

# Constants - using readonly to prevent accidental modification
readonly VERSION="1.0.0"
readonly SCRIPT_NAME="${0##*/}"  # Extract just the script name from the full path
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # Get absolute path to script directory

# Color definitions for terminal output
readonly RED='\033[0;31m'    # Used for errors
readonly GREEN='\033[0;32m'  # Used for success messages
readonly YELLOW='\033[0;33m' # Used for warnings
readonly BLUE='\033[0;34m'   # Used for debug information
readonly NC='\033[0m'        # No Color - resets text formatting

# Function to display usage information
# This function prints help text showing all available options
usage() {
        cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS]

Options:
  -h, --help     Show this help message and exit
  -v, --version  Show version information and exit
  -f, --file     Specify input file
  -o, --output   Specify output file (optional, defaults to input filename with .out extension)

Examples:
  $SCRIPT_NAME --file input.txt --output result.txt
  $SCRIPT_NAME --file data.csv
EOF
}

# Function to log messages with colored formatting
# Parameters:
#   $1 - Log level (ERROR, WARN, INFO, DEBUG)
#   $2 - Message to log
log() {
        local level=$1
        local msg=$2
        local color=$NC  # Default to no color

        # Set color based on log level using code golf style conditionals
        [[ $level == "ERROR" ]] && color=$RED
        [[ $level == "WARN" ]] && color=$YELLOW
        [[ $level == "INFO" ]] && color=$GREEN
        [[ $level == "DEBUG" ]] && color=$BLUE

        # Print formatted log message to stderr (>&2)
        printf "${color}[%s] %s${NC}\n" "$level" "$msg" >&2
}

# Function to process a file by converting all lines to uppercase
# Parameters:
#   $1 - Input file path
#   $2 - Output file path
# Returns:
#   0 on success, 1 on failure
process_file() {
        local input=$1
        local output=$2

        # Check if input file exists, exit with error if not
        [[ ! -f $input ]] && { log "ERROR" "Input file not found: $input"; return 1; }

        # Process the file line by line
        while read -r line; do
                # Skip empty lines
                [[ -z $line ]] && continue
                # Convert line to uppercase and append to output file
                echo "${line^^}" >> "$output"
        done < "$input"

        # Log success message with arrow symbol for visual clarity
        log "INFO" "Processing complete: $input → $output"
}

# Main function - handles argument parsing and orchestrates execution
# Parameters:
#   Command line arguments ($@)
main() {
        local input_file=""
        local output_file=""

        # If no arguments provided, show usage and exit
        [[ $# -eq 0 ]] && { usage; exit 0; }

        # Parse command line arguments
        while [[ $# -gt 0 ]]; do
                case $1 in
                        -h|--help) usage; exit 0 ;;
                        -v|--version) echo "$SCRIPT_NAME v$VERSION"; exit 0 ;;
                        -f|--file) input_file=$2; shift 2 ;;
                        -o|--output) output_file=$2; shift 2 ;;
                        *) log "ERROR" "Unknown option: $1"; usage; exit 1 ;;
                esac
        done

        # Validate required arguments and set defaults
        [[ -z $input_file ]] && { log "ERROR" "Input file not specified"; exit 1; }
        # If no output file specified, create one based on input filename with .out extension
        [[ -z $output_file ]] && output_file="${input_file%.*}.out"

        # Process the file and exit with error if processing fails
        process_file "$input_file" "$output_file" || exit 1

        log "INFO" "Script execution completed successfully"
}

# Execute main function with all command-line arguments
# The "$@" preserves all arguments exactly as they were passed to the script
main "$@"

