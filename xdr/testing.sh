#!/usr/bin/env bash

# HARDN-XDR Installer Script
# This script provides options to install HARDN-XDR from GitHub releases or build from source

set -e  # Exit on error

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running as root
#------------------------------------------------
# Use EUID when using Bash Shells: It is a Bash built-in variable.
# And is slightly faster.
[ "$EUID" -eq 0 ] || { echo "Please run as root or with sudo privileges."; exit 1; }

# Use $(id -u)" when using non-bash shells:
#[ "$(id -u)" -ne 0 ] && { echo "Please run as root or with sudo privileges."; exit 1; }

# the $(id -u)" requires spawing a subprocess,
# However, works in virtually all POSIX-compliant shells

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


# Function to install from GitHub release
install_from_release() {
        echo -e "${YELLOW}Installing HARDN-XDR from GitHub release...${NC}"

        # Get latest release URL
        LATEST_RELEASE_URL="https://github.com/OpenSource-For-Freedom/HARDN-XDR/releases/latest"

        echo -e "${BLUE}Downloading latest release package...${NC}"

        # Create temp directory
        TMP_DIR=$(mktemp -d)
        cd "$TMP_DIR"

        # Download latest .deb package
        if command -v curl &> /dev/null; then
          curl -s "$LATEST_RELEASE_URL" | grep -o 'href=".*hardn_.*_amd64.deb"' | head -n 1 | cut -d'"' -f2 | xargs -I {} curl -L "https://github.com{}" -o hardn.deb
        elif command -v wget &> /dev/null; then
          wget -q -O - "$LATEST_RELEASE_URL" | grep -o 'href=".*hardn_.*_amd64.deb"' | head -n 1 | cut -d'"' -f2 | xargs -I {} wget -q "https://github.com{}" -O hardn.deb
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
        apt install -y ./hardn.deb

        # Clean up
        cd - > /dev/null
        rm -rf "$TMP_DIR"

        echo -e "${GREEN}HARDN-XDR installed successfully!${NC}"
}

# Function to build from source
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

        # Create temp directory
        TMP_DIR=$(mktemp -d)
        cd "$TMP_DIR"

        echo -e "${BLUE}Cloning repository...${NC}"
        git clone https://github.com/OpenSource-For-Freedom/HARDN-XDR
        cd HARDN-XDR

        echo -e "${BLUE}Building Debian package...${NC}"
        echo -e "${BLUE}Running build with dependency override...${NC}"
        dpkg-buildpackage -us -uc -d
        apt install -f -y
        cd ..

        echo -e "${BLUE}Installing package...${NC}"
        apt install -y ./hardn_*_amd64.deb

        # Clean up
        cd - > /dev/null
        rm -rf "$TMP_DIR"

        echo -e "${GREEN}HARDN-XDR built and installed successfully!${NC}"
}

# Function to run the tool
run_tool() {
        echo -e "${BLUE}Starting HARDN-XDR...${NC}"
        hardn-xdr
}

# Main menu
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
            exit 0
            ;;
          *)
            echo -e "${RED}Invalid choice. Please try again.${NC}"
            main_menu
            ;;
        esac
}

main_menu
