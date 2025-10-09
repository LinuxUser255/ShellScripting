#!/usr/bin/env bash


# Script to remove all files and directories starting with 'hardn' in the current directory
# Run with: ./remove_hardn.sh

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${GREEN}[*] $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}[!] $1${NC}"
}

# Get current directory
CURRENT_DIR=$(pwd)
print_status "Working in directory: $CURRENT_DIR"

# Check for files/directories starting with 'hardn'
FOUND_FILES=$(find "$CURRENT_DIR" -maxdepth 1 -name 'hardn*' -print)

if [ -z "$FOUND_FILES" ]; then
    print_status "No files or directories starting with 'hardn' found."
    exit 0
fi

# List what will be deleted
print_status "Found the following files/directories to delete:"
echo "$FOUND_FILES"

# Confirm before proceeding
echo "This will permanently delete all files and directories starting with 'hardn'."
read -p "Continue? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    print_error "Aborted by user."
    exit 1
fi

# Remove files and directories (requires sudo if any are root-owned)
print_status "Removing files and directories..."
if find "$CURRENT_DIR" -maxdepth 1 -name 'hardn*' -exec rm -rfv {} +; then
    print_status "Successfully deleted all files and directories starting with 'hardn'."
else
    print_error "Error during deletion. Check permissions or if files are in use."
    exit 1
fi

# Verify removal
if find "$CURRENT_DIR" -maxdepth 1 -name 'hardn*' | grep -q .; then
    print_error "Some 'hardn' files/directories may still exist. Check manually."
else
    print_status "Verification complete: No 'hardn' files or directories remain."
fi

print_status "Done!"
