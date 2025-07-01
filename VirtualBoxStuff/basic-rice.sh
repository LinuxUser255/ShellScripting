#!/usr/bin/env bash

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
    # Don't exit on error, just report it
    return 1
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
        exit 1
    fi
}

# Function to check if a package is installed
is_installed() {
    dpkg -l "$1" &>/dev/null
}

cmd_exists() {
    command -v "$1" >/dev/null 2>&1
}

update_system() {
    info "Updating system..."
    apt update || warning "Failed to update package lists"
    apt upgrade -y || warning "Some packages could not be upgraded"
    success "System updated"
}

# Define packages to install
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
        x11-utils
        x11-xserver-utils
        xdotool
    )
}

# Function to install packages
install_packages() {
    info "Installing packages..."

    # Setup package list
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

        # Try alternative package names for common packages
        for pkg in "${failed[@]}"; do
            case "$pkg" in
                x11-xserver-utils)
                    info "Trying alternative package: x11-server-utils"
                    apt install -y x11-server-utils || warning "Alternative package also failed"
                    ;;
                x11-utils)
                    info "Trying alternative package: x11-apps"
                    apt install -y x11-apps || warning "Alternative package also failed"
                    ;;
                *)
                    info "No alternative package known for $pkg"
                    ;;
            esac
        done
    else
        success "All packages installed successfully"
    fi
}

# Download and install .bashrc file
bashrc(){
    info "Setting up .bashrc..."
    curl -LO https://raw.githubusercontent.com/LinuxUser255/ShellScripting/refs/heads/main/VirtualBoxStuff/.bashrc

}

# Set up neovim configuration
neovim_config(){
    info "Setting up Neovim configuration..."
    mkdir -p /root/.config/nvim/

    # Download options.lua file to ~/.config/nvim/ directory and rename to init.lua
    curl -LO https://raw.githubusercontent.com/LinuxUser255/BashAndLinux/refs/heads/main/neovim/.config/nvim/options.lua
    mv options.lua init.lua && mv init.lua -t ~/.config/nvim/

}

shortcuts(){
    info "Setting up shortcuts..."
    # Download shell script that increases cursor speed and move it to /usr/local/bin/
    curl -LO https://raw.githubusercontent.com/LinuxUser255/BashAndLinux/refs/heads/main/ShortCuts/faster.sh
    chmod +x /tmp/faster.sh
    mv faster.sh fast
    sudo mv fast -t /usr/local/bin/

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

    # Ask for confirmation
    read -rp "Do you want to proceed with the basic rice setup? [y/N] " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        info "Setup cancelled."
        exit 0
    fi

    info "Starting system configuration..."

    # Run all the functions with error handling
    info "Step 1: Updating system"
    update_system
    info "Step 1 completed"

    info "Step 2: Installing packages"
    install_packages
    info "Step 2 completed"

    info "Step 3: Configuring bashrc"
    bashrc
    info "Step 3 completed"

    info "Step 4: Setting up Neovim"
    neovim_config
    info "Step 4 completed"

    info "Step 5: Setting up shortcuts"
    shortcuts
    info "Step 5 completed"

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
