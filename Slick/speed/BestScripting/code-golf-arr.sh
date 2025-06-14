#!/usr/bin/env bash

set -euo pipefail

IFS=$'\n\t'  # Set Internal Field Separator to newline and tab (not space)

# Color definitions for terminal output
readonly RED='\033[0;31m'    # Used for errors
readonly GREEN='\033[0;32m'  # Used for success messages
readonly YELLOW='\033[0;33m' # Used for warnings
readonly BLUE='\033[0;34m'   # Used for debug information
readonly NC='\033[0m'        # No Color - resets text formatting


# Function to print success messages
success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Function to print info messages
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Function to print warning messages
warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to print error messages
error() {
    echo -e "${RED}[ERROR]${NC} $1"
}


# Define an array of words
words=(
    vim
    git
    curl
    gcc
    make
    ripgrep
    python3-pip
    exuberant-ctags
    ack-grep
    build-essential
)

print_words() {
    # Use a code golf style to print the array elements
    echo "${words[*]}"
}

print_words




