#!/usr/bin/env bash

#!/usr/bin/env bash

# Shell script that checks for and removes previous HARDN-XDR directory
# Then git clones a new HARDN-XDR repository
# then runs sudo ./hardn-main.sh
# Uses colored output for better readability
# All jobs are broken up into separate functions for better maintainability

red_printf() {
  printf "\e[31m%s\e[0m\n" "$1"
}

green_printf() {
  printf "\e[32m%s\e[0m\n" "$1"
}

yellow_printf() {
  printf "\e[33m%s\e[0m\n" "$1"
}

# Check if required commands are available
check_requirements() {
  if ! command -v git &> /dev/null; then
    red_printf "Error: git is not installed. Please install git first."
    exit 1
  fi

  # Check for sudo access
  if ! sudo -n true 2>/dev/null; then
    yellow_printf "This script requires sudo privileges. You may be prompted for your password."
  fi
}

# Function to remove previous HARDN-XDR directory
remove_previous_directory() {
    if [ -d "HARDN-XDR" ]; then
        yellow_printf "Removing previous HARDN-XDR directory..."
        rm -rf HARDN-XDR || {
            red_printf "Error: Failed to remove previous HARDN-XDR directory."
            exit 1
        }
        green_printf "Previous HARDN-XDR directory removed successfully."
    else
        yellow_printf "No previous HARDN-XDR directory found. Proceeding with clone."
    fi
}

# Function to clone a new HARDN-XDR repository
clone_repository() {
    yellow_printf "Cloning HARDN-XDR repository..."
    git clone https://github.com/hardn-project/HARDN-XDR.git || {
        red_printf "Error: Failed to clone HARDN-XDR repository."
        exit 1
    }
    green_printf "HARDN-XDR repository cloned successfully."

    # Move to the HARDN-XDR directory
    cd HARDN-XDR || {
        red_printf "Error: Failed to move to HARDN-XDR directory."
        exit 1
    }
}

# Function to run sudo ./hardn-main.sh
run_hardn_main() {
    # Check if hardn-main.sh exists in the expected location
    if [ -f "./src/setup/hardn-main.sh" ]; then
        yellow_printf "Running hardn-main.sh..."
        sudo ./src/setup/hardn-main.sh || {
            red_printf "Error: Failed to run sudo ./src/setup/hardn-main.sh."
            exit 1
        }
        green_printf "./hardn-main.sh executed successfully."
    elif [ -f "./hardn-main.sh" ]; then
        yellow_printf "Running hardn-main.sh from root directory..."
        sudo ./hardn-main.sh || {
            red_printf "Error: Failed to run sudo ./hardn-main.sh."
            exit 1
        }
        green_printf "./hardn-main.sh executed successfully."
    else
        red_printf "Error: hardn-main.sh not found in expected locations."
        exit 1
    fi

    # Move back to the previous directory
    cd - || {
        red_printf "Error: Failed to move back to the previous directory."
        exit 1
    }
}

# Main script
main() {
    # Check requirements first
    check_requirements

    # Remove previous HARDN-XDR directory
    remove_previous_directory

    # Clone a new HARDN-XDR repository
    clone_repository

    # Run sudo ./hardn-main.sh
    run_hardn_main

    # Print success message
    green_printf "HARDN-XDR repository cloned and hardn-main.sh executed successfully."
}

# Call the main function
main

