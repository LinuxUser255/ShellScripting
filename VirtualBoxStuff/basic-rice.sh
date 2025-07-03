#!/usr/bin/env bash


# A shell script to automate the setup of a new install of a Linux system

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

# Function to print error messages
success(){
    print_msg "$GREEN" "Success: $1" >&2
}

# Function to print informational messages
info(){
    print_msg "$BLUE" "Info: $1"
}


# Function to print warning messages
warning(){
    print_msg "$YELLOW" "Warning: $1"
}


check_root () {
        [ "$(id -u)" -ne 0 ] && echo "Please run this script as root." && exit 1
}


# Function to check if a package is installed
is_installed() {
    dpkg-query -W "$1" >/dev/null 2>&1 | grep -q "installed"
}

cmd_exists() {
    command -v "$1" >/dev/null 2>&1
}


update_system() {
    printf "\033[1;31m[+] Updating system...\033[0m\n"
    apt update && apt upgrade -y
}

pkgs=(
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
     arandr
     chromium
     ninja-build
     gettext
     unzip
     x11-server-utils
     setxkbmap
     xdotool
     ffmpeg
     pass
     gpg
     xclip
     xsel
     texlive-full
 )


# Function to install packages
install_packages() {
        info "Installing packages..."

        local total=${#pkgs[@]}
        local count=0
        local failed=()
        local i=0

        # C-style loop through packages array
        for ((i=0; i<total; i++)); do
            local pkg="${pkgs[i]}"
            ((count++))

            # Short-circuit if statement for package check
            is_installed "$pkg" && {
                info "Package $pkg is already installed."
                continue
            }

            printf "Installing (%d/%d): %s\n" "$count" "$total" "$pkg"

            # Proper short-circuit if statement for installation
            if apt install -y "$pkg" &>/dev/null; then
                success "Installed $pkg"
            else
                warning "Failed to install $pkg"
                failed+=("$pkg")
            fi
        done

        # Proper short-circuit if statement for final status
        if ((${#failed[@]} > 0)); then
            warning "Failed to install ${#failed[@]} packages: ${failed[*]}"
        else
            success "All packages installed successfully"
        fi
}



# Build Neovim from source
build_neovim() {
        info "Building Neovim from source..."

        # Check if Neovim is already installed
        if cmd_exists nvim; then
            info "Neovim is already installed."
            return
        fi

        # Install build prerequisites
        info "Installing Neovim build dependencies..."
        apt install -y ninja-build gettext cmake curl build-essential ||
                error "Failed to install Neovim build dependencies."

        # Create a temporary directory for building Neovim
        local build_dir
        build_dir=$(mktemp -d) ||
                error "Failed to create temporary directory for building Neovim."

        # Ensure clean up after build
        trap 'rm -rf "$build_dir"' EXIT

        # Clone Neovim repository
        cd "$build_dir" ||
                error "Failed to change directory to $build_dir."

        git clone https://github.com/neovim/neovim.git ||
                error "Failed to clone Neovim repository."

        # Navigate to the cloned Neovim repository
        cd neovim ||
                error "Failed to change directory to neovim."

        # Checkout the stable branch
        git checkout stable ||
                error "Failed to checkout stable branch."

        # Build Neovim with parallel jobs
        make -j"$(nproc)" CMAKE_BUILD_TYPE=RelWithDebInfo ||
            error "Failed to build Neovim."

        # Install Neovim
        sudo make install ||
                error "Failed to install Neovim."

        info "Neovim built and installed successfully."
}

install_brave() {
    info "Installing Brave browser..."

    # Check if Brave is already installed
    if cmd_exists brave-browser; then
        info "Brave is already installed."
        return
    fi

    # Install Brave dependencies
    if ! apt install -y apt-transport-https curl gnupg gnupg2; then
        error "Failed to install Brave dependencies."
    fi

    # Import Brave's GPG key
    if ! curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg | gpg --dearmor | tee /usr/share/keyrings/brave-browser-archive-keyring.gpg >/dev/null; then
        error "Failed to import Brave's GPG key."
    fi

    # Add Brave repository to APT sources
    if ! echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list; then
        error "Failed to add Brave repository to APT sources."
    fi

    # Update APT sources and install Brave
    if ! apt update; then
        error "Failed to update APT sources."
    fi
    if ! apt install -y brave-browser; then
        error "Failed to install Brave browser."
    fi

    success "Brave browser installed successfully."
}




# My lazy scripts
lazy_scripts(){
    # place all the downloaded scripts in /usr/local/bin
        # print message in bold blue that says "Curling lasy scripts..."
        printf "\e[1m\e[34mCurling lazy scripts...\e[0m\n"

        curl -LO https://raw.githubusercontent.com/LinuxUser255/BashAndLinux/refs/heads/main/ShortCuts/fff
        chmod +x fff
        sudo mv fff -t /usr/local/bin/


        curl -LO https://raw.githubusercontent.com/LinuxUser255/BashAndLinux/refs/heads/main/ShortCuts/pwsearch.sh
        chmod +x pwsearch.sh
        mv pwsearch.sh ppp
        sudo mv ppp -t /usr/local/bin/

        curl -LO https://raw.githubusercontent.com/LinuxUser255/BashAndLinux/refs/heads/main/ShortCuts/faster.sh
        chmod +x faster.sh
        mv faster.sh fast
        sudo mv fast -t /usr/local/bin/

        curl -LO https://raw.githubusercontent.com/LinuxUser255/BashAndLinux/refs/heads/main/ShortCuts/gclone.sh
        mv gclone.sh ggg
        sudo mv ggg -t /usr/local/bin/gclone.sh

        # Make all scripts executable
        chmod +x /usr/local/bin/fff /usr/local/bin/ppp /usr/local/bin/fast /usr/local/bin/gclone.sh
}



bash_rc() {
    info "Setting up .bashrc in $HOME..."

    local url="https://raw.githubusercontent.com/LinuxUser255/ShellScripting/refs/heads/main/VirtualBoxStuff/.bashrc"
    local target="$HOME/.bashrc"

    local backup
    backup="$HOME/.bashrc.bak.$(date +%Y%m%d%H%M%S)" || error "Failed to generate backup filename with date command"

    # Back up existing .bashrc if it exists
    if [ -f "$target" ]; then
        info "Backing up existing .bashrc to $backup"
        if ! cp "$target" "$backup"; then
            error "Failed to back up existing .bashrc"
        fi
    fi

    # Download the new .bashrc
    info "Downloading .bashrc from $url..."
    if curl -fsSL "$url" -o "$target"; then
        success "Successfully installed .bashrc to $target"
    else
        error "Failed to download or install .bashrc"
    fi

    # Ensure correct ownership (since script runs as root)
    chown "$SUDO_USER:$SUDO_USER" "$target" || warning "Failed to set ownership of $target"
}

neovim_config() {
        rm -rf ~/.config/nvim; rm -rf ~/.local/share/nvim
        sleep 5
        git clone https://github.com/LinuxUser255/nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
}


main() {
    check_root
    install_packages
    update_system
    build_neovim
    install_brave
    lazy_scripts  # Added this line to call the function
    bash_rc  # Added this line to call the function
    neovim_config  # Added this line to call the function
    success "All tasks completed successfully!"
}

main
