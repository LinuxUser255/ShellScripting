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
    # Removed exit 1 as it would terminate the script prematurely
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
    [ "$(id -u)" -ne 0 ] && error "Please run this script as root." && exit 1
}


# Function to check if a package is installed
is_installed() {
    dpkg-query -W "$1" >/dev/null 2>&1
}

cmd_exists() {
    command -v "$1" >/dev/null 2>&1
}


update_system() {
    info "Updating system..."
    apt update && apt upgrade -y
    success "System updated"
}

pkgs=(
     vim
     neovim
     git
     curl
     gcc
     make
     unzip
     x11-server-utils
     setxkbmap
     xdotool
     xclip
     xsel
)


# Function to install packages
install_packages() {
        info "Installing packages..."

        local total=${#pkgs[@]}
        local count=0
        local failed=()

        for pkg in "${pkgs[@]}"; do
            ((count++))
            if ! is_installed "$pkg"; then
                printf "Installing (%d/%d): %s\n" "$count" "$total" "$pkg"
                if apt install -y "$pkg" &>/dev/null; then
                    success "Installed $pkg"
                else
                    warning "Failed to install $pkg"
                    failed+=("$pkg")
                fi
            else
                info "Package $pkg is already installed."
            fi
        done

        if ((${#failed[@]} > 0)); then
            warning "Failed to install ${#failed[@]} packages: ${failed[*]}"
        else
            success "All packages installed successfully"
        fi

}


# Download and install .bashrc file
bashrc(){
    info "Setting up .bashrc..."
    curl -L https://raw.githubusercontent.com/LinuxUser255/ShellScripting/refs/heads/main/VirtualBoxStuff/.bashrc -o ~/.bashrc
    success "Bashrc configured"
}

# Set up neovim configuration
neovim_config(){
    info "Setting up Neovim configuration..."
    mkdir -p ~/.config/nvim/
    # Download options.lua file to ~/.config/nvim/ directory and rename to init.lua
    curl -L https://raw.githubusercontent.com/LinuxUser255/BashAndLinux/refs/heads/main/neovim/.config/nvim/options.lua -o ~/.config/nvim/init.lua
    success "Neovim configured"
}

shortcuts(){
    info "Setting up shortcuts..."
    # Download shell script that increases cursor speed and move it to /usr/local/bin/
    curl -L https://raw.githubusercontent.com/LinuxUser255/BashAndLinux/refs/heads/main/ShortCuts/faster.sh -o /tmp/faster.sh
    chmod +x /tmp/faster.sh
    mv /tmp/faster.sh /usr/local/bin/fast
    success "Shortcuts configured"
}

main() {
    check_root
    update_system
    install_packages
    bashrc
    neovim_config
    shortcuts
    success "System configuration complete!"
}

main
