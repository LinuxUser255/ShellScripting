#!/usr/bin/env bash

# This script is to automate the installation of my Neovim Config.

# First, Detect distribution and set package manager
detect_distro() {
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO="$NAME"
        elif [ -f /etc/lsb-release ]; then
            . /etc/lsb-release
            DISTRO="$DISTRIB_ID"
        elif [ -f /etc/debian_version ]; then
            DISTRO="Debian"
        elif [ -f /etc/fedora-release ]; then
            DISTRO="Fedora"
        elif [ -f /etc/arch-release ]; then
            DISTRO="Arch"
        elif [ -f /etc/alpine-release ]; then
            DISTRO="Alpine"
        elif [ -f /etc/redhat-release ]; then
            DISTRO="Red Hat"
        elif [ -f /etc/centos-release ]; then
            DISTRO="CentOS"
        elif [ -f /etc/void-release ]; then
            DISTRO="Void"
        elif uname -s | grep -q "FreeBSD"; then
            DISTRO="FreeBSD"
        else
            printf "\e[1;31m[-] Unsupported Linux distribution.\e[0m\n"
            exit 1
        fi

        # Determine package manager based on distribution
        case "$DISTRO" in
            "Debian"* | "Ubuntu"*)
                : "apt"
            ;;
            "Fedora"*)
                : "dnf"
            ;;
            "Arch"*)
                : "pacman"
            ;;
            "Alpine"*)
                : "apk"
            ;;
            "FreeBSD"*)
                : "pkg"
            ;;
            "Red Hat"* | "CentOS"*)
                : "dnf"
            ;;
            "openSUSE"*)
                : "zypper"
            ;;
            "Void"*)
                : "xbps"
            ;;
            *)
                printf "\e[1;31m[-] Unsupported Linux distribution.\e[0m\n"
                exit 1
            ;;
        esac

        # Set the package manager variable
        PKG_MANAGER="$_"

        printf "\e[1;32m[+] Detected distribution: %s (Package Manager: %s)\e[0m\n" "$DISTRO" "$PKG_MANAGER"
}

install_prompt() {
        # Acceptable inputs: yes, y, no, n and Enter1
        read -r -p "Ready to install the new Neovim configuration? (yes/no) or hit Enter: " confirm
        confirm=${confirm:"yes"}
        # Convert to lowercase for comparison
        confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]')
        if [[ "$confirm" != "yes" && "$confirm" != "y" ]]; then
            printf "\e[1;31m[-] Exiting installation.\e[0m\n"
            exit 1
        fi
}

check_neovim_version() {
        # Check if nvim is installed first
        if ! command -v nvim &> /dev/null; then
            printf "\e[1;31m[-] Neovim is not installed.\e[0m\n"
            printf "\e[1;34m[?] Would you like to install Neovim? (yes/no): \e[0m"
            read -r -p "" install_nvim
            install_nvim=${install_nvim:-"no"}
            install_nvim=$(echo "$install_nvim" | tr '[:upper:]' '[:lower:]')
            if [[ "$install_nvim" == "yes" || "$install_nvim" == "y" ]]; then
                build_neovim
            else
                printf "\e[1;31m[-] Neovim is required for this configuration. Exiting.\e[0m\n"
                exit 1
            fi
            return
        fi

        # Extract version number
        nvim_version=$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?')
        required_version="0.9.0"

        # Compare versions using sort -V
        if ! printf "%s\n%s" "$required_version" "$nvim_version" | sort -VC; then
            printf "\e[1;31m[-] Neovim version %s or higher is required. Your version: %s\e[0m\n" "$required_version" "$nvim_version"
            printf "\e[1;34m[?] Would you like to build the latest Neovim from source? (yes/no): \e[0m"
            read -r -p "" build_source
            build_source=${build_source:-"no"}
            build_source=$(echo "$build_source" | tr '[:upper:]' '[:lower:]')
            if [[ "$build_source" == "yes" || "$build_source" == "y" ]]; then
                build_neovim
            else
                printf "\e[1;31m[-] A newer version of Neovim is required. Exiting.\e[0m\n"
                exit 1
            fi
        else
            printf "\e[1;32m[+] Neovim version check passed: %s\e[0m\n" "$nvim_version"
        fi
}

# Build Neovim from source
build_neovim() {
        printf "\e[1;34m[+] Building Neovim from source...\e[0m\n"

        # Check if existing Neovim should be removed
        if command -v nvim &> /dev/null; then
            printf "\e[1;34m[?] Remove existing Neovim installation? (yes/no): \e[0m"
            read -r -p "" remove_existing
            remove_existing=${remove_existing:-"yes"}
            remove_existing=$(echo "$remove_existing" | tr '[:upper:]' '[:lower:]')
            if [[ "$remove_existing" == "yes" || "$remove_existing" == "y" ]]; then
                # Complete removal: remove all files and directories & purge
                case "$PKG_MANAGER" in
                    "apt")
                        : "sudo apt remove -y neovim && sudo apt purge neovim -y"
                        ;;
                    "dnf")
                        : "sudo dnf remove -y neovim && sudo dnf purge neovim -y"
                        ;;
                    "pacman")
                        : "sudo pacman -R --noconfirm neovim && sudo pacman -R --noconfirm neovim-doc neovim-runtime neovim-common"
                        ;;
                    "apk")
                        : "sudo apk del neovim && sudo apk del neovim-doc neovim-runtime neovim-common"
                        ;;
                    "pkg")
                        : "sudo pkg delete -y neovim && sudo pkg delete -y neovim-doc neovim-runtime neovim-common"
                        ;;
                    "zypper")
                        : "sudo zypper remove -y neovim && sudo zypper remove -y neovim-doc neovim-runtime neovim-common"
                        ;;
                    "xbps")
                        : "sudo xbps-remove -y neovim && sudo xbps-remove -y neovim-doc neovim-runtime neovim-common"
                        ;;
                esac

                # Execute the removal command
                eval "$_"


                # Install build prerequisites
                printf "\e[1;34m[+] Installing Neovim build dependencies...\e[0m\n"
                case "$PKG_MANAGER" in
                    "apt")
                        : "sudo apt install -y ninja-build gettext cmake unzip curl build-essential"
                        ;;
                    "dnf")
                        : "sudo dnf install -y ninja-build gettext cmake unzip curl gcc make"
                        ;;
                    "pacman")
                        : "sudo pacman -S --noconfirm ninja gettext cmake unzip curl base-devel"
                        ;;
                    "apk")
                        : "sudo apk add ninja gettext cmake unzip curl build-base"
                        ;;
                    "pkg")
                        : "sudo pkg install -y ninja gettext cmake unzip curl"
                        ;;
                    "zypper")
                        : "sudo zypper install -y ninja gettext cmake unzip curl gcc make"
                        ;;
                    "xbps")
                        : "sudo xbps-install -S -y ninja gettext cmake unzip curl base-devel"
                        ;;
                esac

        # Execute the command
        eval "$_"

        # Create a temporary directory for building Neovim
        build_dir=$(mktemp -d)
        if [ "$build_dir" -ne 0 ]; then
            printf "\e[1;31m[-] Failed to create temporary directory for building Neovim.\e[0m\n"
            exit 1
        fi

        # Ensure clean up after build
        trap 'rm -rf "$build_dir"' EXIT

        # Clone Neovim repository
        cd "$build_dir" || {
            printf "\e[1;31m[-] Failed to change directory to %s $build_dir.\e[0m\n"
            exit 1
        }

        if ! git clone https://github.com/neovim/neovim.git; then
            printf "\e[1;31m[-] Failed to clone Neovim repository.\e[0m\n"
            exit 1
        fi

        # Navigate to the cloned Neovim repository
        cd neovim || {
            printf "\e[1;31m[-] Failed to change directory to neovim.\e[0m\n"
            exit 1
        }

        # Checkout the stable branch
        if ! git checkout stable; then
            printf "\e[1;31m[-] Failed to checkout stable branch.\e[0m\n"
            exit 1
        fi

        # Build Neovim with parallel jobs
        printf "\e[1;34m[+] Building Neovim (this may take a while)...\e[0m\n"
        if ! make -j"$(nproc)" CMAKE_BUILD_TYPE=RelWithDebInfo; then
            printf "\e[1;31m[-] Failed to build Neovim.\e[0m\n"
            exit 1
        fi

        # Install Neovim
        printf "\e[1;34m[+] Installing Neovim...\e[0m\n"
        if ! sudo make install; then
            printf "\e[1;31m[-] Failed to install Neovim.\e[0m\n"
            exit 1
        fi

        # Create a symbolic link for Neovim if it doesn't exist
        if [ ! -f /usr/bin/nvim ]; then
            sudo ln -sf /usr/local/bin/nvim /usr/bin/nvim
        fi

        printf "\e[1;32m[+] Neovim built and installed successfully.\e[0m\n"

        # Verify the installation
        nvim_version=$(nvim --version | head -n1)
        printf "\e[1;32m[+] Installed: %s\e[0m\n" "$nvim_version"
}

# Install dependencies based on package manager
printf "\e[1;34m[+] Installing dependencies for %s using %s...\e[0m\n" "$DISTRO" "$PKG_MANAGER"

case "$PKG_MANAGER" in
    "apt")
        : "sudo apt update && sudo apt install -y tree-sitter tree-sitter-cli nodejs npm shellcheck ripgrep"
    ;;
    "dnf")
        : "sudo dnf update -y && sudo dnf install -y tree-sitter tree-sitter-cli nodejs npm ripgrep"
    ;;
    "pacman")
        : "sudo pacman -S --noconfirm tree-sitter tree-sitter-cli nodejs npm shellcheck ripgrep"
    ;;
    "apk")
        : "sudo apk add --no-cache tree-sitter tree-sitter-cli nodejs npm shellcheck ripgrep"
    ;;
    "pkg")
        : "sudo pkg install -y tree-sitter tree-sitter-cli nodejs npm shellcheck ripgrep"
    ;;
    "zypper")
        : "sudo zypper install -y tree-sitter tree-sitter-cli nodejs npm shellcheck ripgrep"
    ;;
    "xbps")
        : "sudo xbps-install -S -y tree-sitter tree-sitter-cli nodejs npm shellcheck ripgrep"
    ;;
    *)
        printf "\e[1;31m[-] Unsupported package manager: %s\e[0m\n" "$PKG_MANAGER"
        exit 1
    ;;
esac

# Execute the installation command
eval "$_"

# Removing your old Neovim config to install the new one
remove_old_config() {
        printf "\e[1;34m[+] Removing old Neovim configuration...\e[0m\n"
        rm -rf ~/.config/nvim; rm -rf ~/.local/share/nvim
}

# Git clone the Neovim configuration repo
install_config() {
        printf "\e[1;34m[+] Git cloning new config & opening Neovim to install plugins...\e[0m\n"
        git clone https://github.com/LinuxUser255/nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
        printf "\e[1;34m[+] Open Neovim to install plugins...\e[0m\n"
}

main() {
        install_prompt # 1
        detect_distro
        check_neovim_version #
        build_neovim #  if required by user (if not, it will be skipped)
        remove_old_config #
        install_config #
}

main
