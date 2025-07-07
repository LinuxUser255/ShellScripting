#!/usr/bin/env bash

# Color definitions for terminal output
readonly RED='\033[0;31m'    # Used for errors
readonly GREEN='\033[0;32m'  # Used for success messages
readonly YELLOW='\033[0;33m' # Used for warnings
readonly BLUE='\033[0;34m'   # Used for information
readonly CYAN='\033[0;36m'   # Used for prompts
readonly NC='\033[0m'        # No Color - resets text formatting

# Function to print colored messages
print_msg() {
        local color="$1"
        local message="$2"
        echo -e "${color}${message}${NC}"
}

prompt_continue() {
        echo -e "${CYAN}Do you want to continue with this step? (y/n): ${NC}\c"
        read -r choice
        if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
            print_msg "$YELLOW" "Exiting script."
            exit 0
        fi
}

install_package() {
        print_msg "$BLUE" "Installing the package..."
        prompt_continue
        # check cmd exit code directly instead of using `$?`
        if sudo apt install ./hardn_*_amd64.deb; then
            print_msg "$GREEN" "✓ Package installed successfully!"
        else
            print_msg "$RED" "✗ Failed to install package."
            exit 1
        fi
}

run_tool() {
        print_msg "$BLUE" "Running the tool..."
        prompt_continue
        if sudo hardn-xdr; then
            print_msg "$GREEN" "✓ Tool executed successfully!"
        else
            print_msg "$YELLOW" "⚠ Tool exited with non-zero status."
        fi
}

# Print header
print_msg "$CYAN" "===== HARDN-XDR Installation Script ====="

print_msg "$BLUE" "Choose installation method:"
echo -e "${CYAN}1. ${NC}Install from local .deb file"
echo -e "${CYAN}2. ${NC}Build from Source"
echo -e "${CYAN}3. ${NC}Download and install from GitHub Release"
echo -e "${CYAN}Enter choice (1, 2, or 3): ${NC}\c"
read -r install_choice

case "$install_choice" in
        "1") # START INSTALLATION
            print_msg "$BLUE" "Starting installation from local .deb file..."

            print_msg "$BLUE" "Step 1: Checking for .deb package in current directory"
            if ! ls ./hardn_*_amd64.deb &>/dev/null; then
                print_msg "$RED" "Error: No .deb package found in current directory."
                print_msg "$YELLOW" "Please download the package from https://github.com/OpenSource-For-Freedom/HARDN-XDR/releases"
                exit 1
            fi
            print_msg "$GREEN" "✓ Package found!"

            print_msg "$BLUE" "Step 2: Installing the package..."
            install_package

            print_msg "$BLUE" "Step 3: Running the tool..."
            run_tool
        ;;

        "2") # BUILD FROM SOURCE
            print_msg "$BLUE" "Starting build from source..."

            print_msg "$BLUE" "Step 1: Cloning the repository..."
            prompt_continue
            if git clone https://github.com/OpenSource-For-Freedom/HARDN-XDR; then
            #if [ $? -ne 0 ]; then
                print_msg "$RED" "✗ Failed to clone repository."
                exit 1
            fi
            print_msg "$GREEN" "✓ Repository cloned successfully!"

            cd HARDN-XDR || { print_msg "$RED" "✗ Failed to enter repository directory"; exit 1; }

            print_msg "$BLUE" "Step 2: Building the Debian package..."
            prompt_continue
            if dpkg-buildpackage -us -uc ; then
            #if [ $? -ne 0 ]; then
                print_msg "$RED" "✗ Failed to build package."
                exit 1
            fi
            print_msg "$GREEN" "✓ Package built successfully!"

            sudo apt install -f
            cd .. || { print_msg "$RED" "✗ Failed to return to parent directory"; exit 1; }

            print_msg "$BLUE" "Step 3: Installing the package..."
            install_package

            print_msg "$BLUE" "Step 4: Running the tool..."
            run_tool
        ;;

        "3")
            print_msg "$BLUE" "Starting download and installation from GitHub Release..."

            print_msg "$BLUE" "Step 1: Downloading the latest release..."
            prompt_continue

            # Get latest release URL
            print_msg "$BLUE" "Fetching latest release information..."
            LATEST_URL=$(curl -s https://api.github.com/repos/OpenSource-For-Freedom/HARDN-XDR/releases/latest |
                        grep "browser_download_url.*deb" |
                        cut -d '"' -f 4)

            if [ -z "$LATEST_URL" ]; then
                print_msg "$RED" "✗ Error: Could not find latest release URL."
                exit 1
            fi

            print_msg "$GREEN" "✓ Found latest release!"
            print_msg "$BLUE" "Downloading from: $LATEST_URL"
            if curl -L -o hardn_latest.deb "$LATEST_URL"; then
            #if [ $? -ne 0 ]; then
                print_msg "$RED" "✗ Failed to download package."
                exit 1
            fi
            print_msg "$GREEN" "✓ Download completed successfully!"

            print_msg "$BLUE" "Step 2: Installing the package..."
            prompt_continue
            if sudo apt install ./hardn_latest.deb; then
            #if [ $? -ne 0 ]; then
                print_msg "$RED" "✗ Failed to install package."
                exit 1
            fi
            print_msg "$GREEN" "✓ Package installed successfully!"

            print_msg "$BLUE" "Step 3: Running the tool..."
            run_tool
        ;;

        *)
            print_msg "$RED" "Invalid choice. Exiting."
            exit 1
        ;;
esac

print_msg "$GREEN" "✓ Installation and execution completed."
