#!/bin/sh

# A shell script to automate the setup of a new install of a Linux system

# Text formatting
BOLD="\033[1m"
RESET="\033[0m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"

# Function to print colored output
print_msg() {
    color="$1"
    msg="$2"
    printf "${color}${BOLD}%s${RESET}\n" "$msg"
}

# Function to print error messages
error() {
    print_msg "$RED" "Error: $1" >&2
    exit 1
}

# Function to print success messages
success() {
    print_msg "$GREEN" "Success: $1" >&2
}

# Function to print informational messages
info() {
    print_msg "$BLUE" "Info: $1"
}

# Function to print warning messages
warning() {
    print_msg "$YELLOW" "Warning: $1"
}

check_root() {
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

# Function to install packages
install_packages() {
    info "Installing packages..."

    # Define packages as space-separated list (POSIX compatible)
    packages="vim git curl gcc make ripgrep python3-pip exuberant-ctags ack-grep build-essential arandr chromium ninja-build gettext unzip x11-server-utils setxkbmap xdotool ffmpeg pass gpg xclip xsel texlive-full"

    total=0
    for pkg in $packages; do
        total=$((total + 1))
    done

    count=0
    failed=""

    for pkg in $packages; do
        count=$((count + 1))

        # Check if package is already installed
        if is_installed "$pkg"; then
            info "Package $pkg is already installed."
            continue
        fi

        printf "Installing (%d/%d): %s\n" "$count" "$total" "$pkg"

        # Install package
        if apt install -y "$pkg" >/dev/null 2>&1; then
            success "Installed $pkg"
        else
            warning "Failed to install $pkg"
            if [ -z "$failed" ]; then
                failed="$pkg"
            else
                failed="$failed $pkg"
            fi
        fi
    done

    # Check if any packages failed to install
    if [ -n "$failed" ]; then
        # Count failed packages
        fail_count=0
        for pkg in $failed; do
            fail_count=$((fail_count + 1))
        done
        warning "Failed to install $fail_count packages: $failed"
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
        return 0
    fi

    # Install build prerequisites
    info "Installing Neovim build dependencies..."
    if ! apt install -y ninja-build gettext cmake curl build-essential; then
        error "Failed to install Neovim build dependencies."
    fi

    # Create a temporary directory for building Neovim
    build_dir=$(mktemp -d)
    if [ "$build_dir" -ne 0 ]; then
        error "Failed to create temporary directory for building Neovim."
    fi

    # Ensure clean up after build
    trap 'rm -rf "$build_dir"' EXIT

    # Clone Neovim repository
    cd "$build_dir" || error "Failed to change directory to $build_dir."

    if ! git clone https://github.com/neovim/neovim.git; then
        error "Failed to clone Neovim repository."
    fi

    # Navigate to the cloned Neovim repository
    cd neovim || error "Failed to change directory to neovim."

    # Checkout the stable branch
    if ! git checkout stable; then
        error "Failed to checkout stable branch."
    fi

    # Build Neovim with parallel jobs
    if ! make -j"$(nproc)" CMAKE_BUILD_TYPE=RelWithDebInfo; then
        error "Failed to build Neovim."
    fi

    # Install Neovim
    if ! make install; then
        error "Failed to install Neovim."
    fi

    info "Neovim built and installed successfully."
}

install_brave() {
    info "Installing Brave browser..."

    # Check if Brave is already installed
    if cmd_exists brave-browser; then
        info "Brave is already installed."
        return 0
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
lazy_scripts() {
    # place all the downloaded scripts in /usr/local/bin
    # print message in bold blue that says "Curling lazy scripts..."
    printf "\033[1m\033[34mCurling lazy scripts...\033[0m\n"

    curl -LO https://raw.githubusercontent.com/LinuxUser255/BashAndLinux/refs/heads/main/ShortCuts/fff
    chmod +x fff
    mv fff /usr/local/bin/

    curl -LO https://raw.githubusercontent.com/LinuxUser255/BashAndLinux/refs/heads/main/ShortCuts/pwsearch.sh
    chmod +x pwsearch.sh
    mv pwsearch.sh ppp
    mv ppp /usr/local/bin/

    curl -LO https://raw.githubusercontent.com/LinuxUser255/BashAndLinux/refs/heads/main/ShortCuts/faster.sh
    chmod +x faster.sh
    mv faster.sh fast
    mv fast /usr/local/bin/

    curl -LO https://raw.githubusercontent.com/LinuxUser255/BashAndLinux/refs/heads/main/ShortCuts/gclone.sh
    mv gclone.sh ggg
    mv ggg /usr/local/bin/gclone.sh

    # Make all scripts executable
    chmod +x /usr/local/bin/fff /usr/local/bin/ppp /usr/local/bin/fast /usr/local/bin/gclone.sh
}

bash_rc() {
    info "Setting up .bashrc in $HOME..."

    url="https://raw.githubusercontent.com/LinuxUser255/ShellScripting/refs/heads/main/VirtualBoxStuff/.bashrc"
    target="$HOME/.bashrc"

    backup="$HOME/.bashrc.bak.$(date +%Y%m%d%H%M%S)"
    if [ "$backup" -ne 0 ]; then
        error "Failed to generate backup filename with date command"
    fi

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
    if ! chown "$SUDO_USER:$SUDO_USER" "$target"; then
        warning "Failed to set ownership of $target"
    fi
}

neovim_config() {
    rm -rf ~/.config/nvim
    rm -rf ~/.local/share/nvim
    sleep 5
    git clone https://github.com/LinuxUser255/nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
}

main() {
    check_root
    install_packages
    update_system
    build_neovim
    install_brave
    lazy_scripts
    bash_rc
    neovim_config
    success "All tasks completed successfully!"
}

main
