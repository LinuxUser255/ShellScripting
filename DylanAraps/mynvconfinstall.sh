#!/usr/bin/env bash

# Below is a list of Required languages for this Neovim configuration
#==============================================================

# Make sure the following languages and file formats are installed.
# This config will still work, however; you'll just encounter many error messages.

# 1. Python3
# 2. Lua
# 3. Java/TypeScript
# 4. HTML/CSS
# 5. Rust
# 6. Go
# 7. C/C++
# 8. Shell
# 9. JSON/YAML
# 10. Markdown
# 11. Docker
# 12. Solidity
# 13. Vue/Svelte
# 14. TOML
# 15. LaTeX -- coming soon

install_prompt() {
        # Acceptable inputs: yes, y, no, n and Enter1
        read -r -p "Ready to install the new Neovim configuration? (yes/no): " confirm
        confirm=${confirm:"yes"}
        # Convert to lowercase for comparison
        confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]')
        if [[ "$confirm" != "yes" && "$confirm" != "y" ]]; then
            printf "\e[1;31m[-] Exiting installation.\e[0m\n"
            exit 1
        fi
}

check_neovim_version() {
    nvim_version=$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?')
    required_version="0.9.0"

    # Compare versions using sort -V
    if ! printf "%s\n%s" "$required_version" "$nvim_version" | sort -VC; then
        printf "\e[1;31m[-] Neovim version %s or higher is required.\e[0m\n" "$required_version"
        printf "\e[1;31m[-] I suggest building from source.\e[0m\n"
        printf "\e[1;31m[-] https://github.com/neovim/neovim/blob/master/BUILD.md.\e[0m\n"
        exit 1
    fi
}

# Detect distribution and install dependencies
install_deps() {
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

    # Set package manager
    PKG_MANAGER="$_"

    # Install dependencies based on package manager
    printf "\e[1;34m[+] Installing dependencies for %s using %s...\e[0m\n" "$DISTRO" "$PKG_MANAGER"

    case "$PKG_MANAGER" in
        "apt")
            sudo apt update && sudo apt install -y \
                tree-sitter \
                tree-sitter-cli \
                nodejs npm \
                shellcheck \
                ripgrep
        ;;
        "dnf")
            sudo dnf update -y && sudo dnf install -y \
                tree-sitter \
                tree-sitter-cli \
                nodejs npm \
                ripgrep
        ;;
        "pacman")
            sudo pacman -S --noconfirm \
                tree-sitter \
                tree-sitter-cli \
                nodejs npm \
                shellcheck \
                ripgrep
        ;;
        "apk")
            sudo apk add --no-cache \
                tree-sitter \
                tree-sitter-cli \
                nodejs npm \
                shellcheck \
                ripgrep
        ;;
        "pkg")
            sudo pkg install -y \
                tree-sitter \
                tree-sitter-cli \
                nodejs npm \
                shellcheck \
                ripgrep
        ;;
        "zypper")
            sudo zypper install -y \
                tree-sitter \
                tree-sitter-cli \
                nodejs npm \
                shellcheck \
                ripgrep
        ;;
        "xbps")
            sudo xbps-install -S -y \
                tree-sitter \
                tree-sitter-cli \
                nodejs npm \
                shellcheck \
                ripgrep
        ;;
        *)
            printf "\e[1;31m[-] Unsupported package manager: %s\e[0m\n" "$PKG_MANAGER"
            exit 1
        ;;
    esac
}

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
        check_neovim_version # 2
        install_deps # 3
        remove_old_config # 4
        install_config # 5
}

main
