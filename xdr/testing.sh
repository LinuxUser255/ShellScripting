#!/usr/bin/env bash
#
# ADVISORY: READ THE ABOUT/INSTRUCTIONS BELOW
#
# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║                        HARDN-XDR Installer Script                         ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
#
# DESCRIPTION, WHAT THIS SCRIPT DOES:
#   This script automates the installation of HARDN-XDR (Extended Detection and Response)
#   tool. It provides options to install from pre-built packages or build from source.
#
# USAGE:
#   sudo ./testing.sh
#
# REQUIREMENTS:
#   - Must be run with root privileges
#   - Internet connection to download packages
#   - For build from source: git, dpkg-buildpackage, debhelper, devscripts
#
# OPTIONS:
#   1. Install from GitHub Release - Downloads and installs the latest pre-built package
#   2. Build from Source - Clones the repository and builds the package locally
#   3. Run HARDN-XDR - Launches the tool if already installed
#   4. Exit - Exits the script
#
# SCRIPT SECTIONS:
#   - Initial setup: Sets error handling, permissions, and color definitions
#   - Root check: Ensures the script runs with proper privileges
#   - Installation functions: Methods to install from release or build from source
#   - Menu system: Interactive interface for user selection
#
# SECURITY NOTES:
#   - Sets proper file permissions to avoid APT sandboxing warnings
#   - Temporarily modifies umask for better file access during installation
#   - Cleans up temporary files after installation
#
# AUTHOR:
#   LinuxUser255
#
# VERSION:
#   1.0.0
#
# SOURCE:
#   https://github.com/OpenSource-For-Freedom/HARDN-XDR
#

set -e  # Exit on error

# Store original umask and set more permissive one for downloads
OLD_UMASK=$(umask)
umask 022  # Makes files readable by all users

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ROOT CHECK METHODS:
#------------------
# Method 1: Using $EUID (Bash-specific, faster, no subprocess)
[ "$EUID" -eq 0 ] || { echo "Please run as root or with sudo privileges."; exit 1; }

# Method 2: Using id -u (POSIX-compliant, works in all shells)
#[ "$(id -u)" -ne 0 ] && { echo "Please run as root or with sudo privileges."; exit 1; }


display_banner() {
      echo -e "${BLUE}"
      echo "╔═══════════════════════════════════════════════╗"
      echo "║             HARDN-XDR Installer               ║"
      echo "╚═══════════════════════════════════════════════╝"
      echo -e "${NC}"
}

install_build_dependencies() {
       sudo apt update
       sudo apt install debhelper devscripts
}


# Install from GitHub release
install_from_release() {
        echo -e "${YELLOW}Installing HARDN-XDR from GitHub release...${NC}"

        # Get latest release URL
        LATEST_RELEASE_URL="https://github.com/OpenSource-For-Freedom/HARDN-XDR/releases/latest"

        echo -e "${BLUE}Downloading latest release package...${NC}"

        # Create temp directory with proper permissions
        TMP_DIR=$(mktemp -d)
        chmod 755 "$TMP_DIR"  # Fix 1: Set proper permissions on temp directory
        cd "$TMP_DIR"

        # Download latest .deb package
        if command -v curl &> /dev/null; then
          curl -s "$LATEST_RELEASE_URL" | grep -o 'href=".*hardn_.*_amd64.deb"' | head -n 1 | cut -d'"' -f2 | xargs -I {} curl -L "https://github.com{}" -o hardn.deb
          chmod 644 hardn.deb  # Fix 2: Ensure downloaded file is readable
        elif command -v wget &> /dev/null; then
          wget -q -O - "$LATEST_RELEASE_URL" | grep -o 'href=".*hardn_.*_amd64.deb"' | head -n 1 | cut -d'"' -f2 | xargs -I {} wget -q "https://github.com{}" -O hardn.deb
          chmod 644 hardn.deb  # Fix 2: Ensure downloaded file is readable
        else
          echo -e "${RED}Error: Neither curl nor wget found. Please install one of them.${NC}"
          exit 1
        fi

        # Check if download was successful
        if [ ! -f hardn.deb ]; then
          echo -e "${RED}Failed to download the package. Please check your internet connection or try the build from source option.${NC}"
          exit 1
        fi

        echo -e "${BLUE}Installing package...${NC}"
        # Fix 3: Use APT's built-in mechanism (alternative approach)
        # Instead of: apt install -y ./hardn.deb
        # We'll copy to /var/cache/apt/archives where APT expects packages
        cp hardn.deb /var/cache/apt/archives/
        apt install -y /var/cache/apt/archives/hardn.deb

        # Clean up
        cd - > /dev/null
        rm -rf "$TMP_DIR"

        echo -e "${GREEN}HARDN-XDR installed successfully!${NC}"
}

build_from_source() {
        echo -e "${YELLOW}Building HARDN-XDR from source...${NC}"

        # Check for required tools
        for tool in git dpkg-buildpackage; do
          if ! command -v $tool &> /dev/null; then
            echo -e "${RED}Error: $tool is not installed. Please install it first.${NC}"
            exit 1
          fi
        done

        # Install build dependencies
        echo -e "${YELLOW}Installing build dependencies...${NC}"
        apt update
        apt install -y debhelper devscripts

        # Create temp directory with proper permissions
        TMP_DIR=$(mktemp -d)
        chmod 755 "$TMP_DIR"  # Fix 1: Set proper permissions on temp directory
        cd "$TMP_DIR"

        echo -e "${BLUE}Cloning repository...${NC}"
        git clone https://github.com/OpenSource-For-Freedom/HARDN-XDR
        cd HARDN-XDR

        # Ensure all files are readable
        chmod -R o+r .  # Fix 2: Make all files readable

        echo -e "${BLUE}Building Debian package...${NC}"
        echo -e "${BLUE}Running build with dependency override...${NC}"
        dpkg-buildpackage -us -uc -d
        apt install -f -y
        cd ..

        # Ensure built package is readable
        chmod 644 ./hardn_*_amd64.deb  # Fix 2: Ensure built package is readable

        echo -e "${BLUE}Installing package...${NC}"
        # Fix 3: Use APT's built-in mechanism
        cp ./hardn_*_amd64.deb /var/cache/apt/archives/
        apt install -y /var/cache/apt/archives/hardn_*_amd64.deb

        # Clean up
        cd - > /dev/null
        rm -rf "$TMP_DIR"

        echo -e "${GREEN}HARDN-XDR built and installed successfully!${NC}"
}

# Run the tool
run_tool() {
        echo -e "${BLUE}Starting HARDN-XDR...${NC}"
        hardn-xdr
}

main_menu() {
        display_banner

        echo -e "${YELLOW}Please select an installation method:${NC}"
        echo -e "1) ${GREEN}Install from GitHub Release${NC}"
        echo -e "2) ${GREEN}Build from Source${NC}"
        echo -e "3) ${GREEN}Run HARDN-XDR (if already installed)${NC}"
        echo -e "4) ${RED}Exit${NC}"

        read -r -p "Enter your choice (1-4): " choice

        case $choice in
          1)
            install_from_release
            echo -e "${BLUE}You can now run HARDN-XDR with:${NC} sudo hardn-xdr"
            ;;
          2)
            build_from_source
            echo -e "${BLUE}You can now run HARDN-XDR with:${NC} sudo hardn-xdr"
            ;;
          3)
            run_tool
            ;;
          4)
            echo -e "${YELLOW}Exiting...${NC}"
            # Fix 4: Restore original umask before exiting
            umask "$OLD_UMASK"
            exit 0
            ;;
          *)
            echo -e "${RED}Invalid choice. Please try again.${NC}"
            main_menu
            ;;
        esac
}

# Run the main menu
main_menu

# Fix 4: Restore original umask at the end of script
umask "$OLD_UMASK"
