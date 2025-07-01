#!/usr/bin/env bash


# Strict mode
set -euo pipefail
IFS=$'\n\t'

# Text formatting
readonly BOLD="\e[1m"
readonly RESET="\e[0m"
readonly RED="\e[31m"
readonly GREEN="\e[32m"
readonly YELLOW="\e[33m"
readonly BLUE="\e[34m"


# Function to print colored output
print_msg() {
    local color="$1"
    local msg="$2"
    printf "${color}${BOLD}%s${RESET}\n" "$msg"
}

# Function to print error messages
error(){
    print_msg "$RED" "Error: $1" >&2
    exit 1
}

# Function to print success messages
success(){
    print_msg "$GREEN" "Success: $1"
}

# Function to print informational messages
info(){
    print_msg "$BLUE" "Info: $1"
}


# Function to print warning messages
warning(){
    print_msg "$YELLOW" "Warning: $1"
}


check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error "Please run this script as root."
    fi
}


# Function to check if a package is installed
is_installed() {
    dpkg -l | grep -q "ii  $1 "
}

cmd_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check distribution
check_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        info "Detected distribution: $NAME $VERSION_ID"
        return 0
    else
        warning "Could not detect distribution, assuming Debian-based"
        return 1
    fi
}

update_system() {
    info "Updating system..."
    apt update || error "Failed to update package lists"
    apt upgrade -y || warning "Some packages could not be upgraded"
    success "System updated"
}

# Define packages based on distribution
setup_packages() {
    # Common packages for all distributions
    pkgs=(
        vim
        neovim
        git
        curl
        gcc
        make
        unzip
        xclip
        xsel
    )

    # Add distribution-specific packages
    if [ -f /etc/debian_version ]; then
        # Debian/Ubuntu packages
        pkgs+=(x11-utils x11-xserver-utils xdotool)
    elif [ -f /etc/fedora-release ]; then
        # Fedora packages
        pkgs+=(xorg-x11-utils xorg-x11-server-utils xdotool)
    elif [ -f /etc/arch-release ]; then
        # Arch Linux packages
        pkgs+=(xorg-xdpyinfo xorg-server-utils xdotool)
    else
        # Try common package names as fallback
        pkgs+=(x11-utils x11-xserver-utils xdotool)
        warning "Unknown distribution, using default package names"
    fi
}

# Function to install packages
install_packages() {
    info "Installing packages..."

    # Setup package list based on distribution
    setup_packages

    local total=${#pkgs[@]}
    local count=0
    local failed=()

    for pkg in "${pkgs[@]}"; do
        ((count++))
        info "Checking package ($count/$total): $pkg"

        if ! is_installed "$pkg"; then
            info "Installing package: $pkg"
            if apt install -y "$pkg"; then
                success "Installed $pkg"
            else
                warning "Failed to install $pkg"
                failed+=("$pkg")
            fi
        else
            info "Package $pkg is already installed."
        fi
    done

    if [ ${#failed[@]} -gt 0 ]; then
        warning "Failed to install ${#failed[@]} packages: ${failed[*]}"

        # Try to install failed packages one by one with more verbose output
        info "Attempting to install failed packages individually with more verbose output..."
        for pkg in "${failed[@]}"; do
            info "Retrying installation of $pkg..."
            apt install -y "$pkg" || warning "Package $pkg installation failed again"
        done
    else
        success "All packages installed successfully"
    fi
}

# Download and install .bashrc file
bashrc(){
    info "Setting up .bashrc..."
    curl -L https://raw.githubusercontent.com/LinuxUser255/ShellScripting/refs/heads/main/VirtualBoxStuff/.bashrc -o /tmp/.bashrc || {
        error "Failed to download .bashrc file"
    }

    # Make a backup of the existing .bashrc
    if [ -f /root/.bashrc ]; then
        cp /root/.bashrc /root/.bashrc.backup
        info "Backed up existing .bashrc to .bashrc.backup"
    fi

    mv /tmp/.bashrc /root/.bashrc
    success "Bashrc configured"
}

# Set up neovim configuration
neovim_config(){
    info "Setting up Neovim configuration..."
    mkdir -p /root/.config/nvim/

    # Download options.lua file to ~/.config/nvim/ directory and rename to init.lua
    curl -L https://raw.githubusercontent.com/LinuxUser255/BashAndLinux/refs/heads/main/neovim/.config/nvim/options.lua -o /tmp/options.lua || {
        error "Failed to download Neovim configuration"
    }

    mv /tmp/options.lua /root/.config/nvim/init.lua
    success "Neovim configured"
}

shortcuts(){
    info "Setting up shortcuts..."
    # Download shell script that increases cursor speed and move it to /usr/local/bin/
    curl -L https://raw.githubusercontent.com/LinuxUser255/BashAndLinux/refs/heads/main/ShortCuts/faster.sh -o /tmp/faster.sh || {
        error "Failed to download shortcuts script"
    }

    chmod +x /tmp/faster.sh
    mv /tmp/faster.sh /usr/local/bin/fast
    success "Shortcuts configured"
}

main() {
    # Print banner
    echo -e "${RED}${BOLD}"
    echo "======================================"
    echo "       Basic Linux Rice Script        "
    echo "======================================"
    echo -e "${RESET}"

    # Check if running as root
    check_root

    # Check distribution
    check_distro

    # Ask for confirmation
    read -rp "Do you want to proceed with the basic rice setup? [y/N] " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        info "Setup cancelled."
        exit 0
    fi

    info "Starting system configuration..."

    # Run all the functions
    update_system
    install_packages
    bashrc
    neovim_config
    shortcuts

    success "System configuration complete!"

    # Ask for reboot
    read -rp "Do you want to reboot now to apply all changes? [y/N] " reboot_response
    if [[ "$reboot_response" =~ ^[Yy]$ ]]; then
        info "Rebooting system..."
        reboot
    else
        info "Reboot skipped. Some changes may require a reboot to take effect."
    fi
}

# Run the main function
main
