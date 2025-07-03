#!/usr/bin/env bash


# Install script inspired by Dylan Araps neofetch
# to symlink neovim, if needed: which nvim sudo ln -s /usr/local/bin/nvim /usr/bin/nvim

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
# 15. LaTex --- Soon

shopt -s eval_unsafe_arith &>/dev/null

XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-${HOME}/.config}
PATH=$PATH:/usr/xpg4/bin:/usr/sbin:/sbin:/usr/etc:/usr/libexec
shopt -s nocasematch

# Speed up script by not using unicode.
LC_ALL=C
LANG=C

get_os() {
    # $kernel_name is set in a function called cache_uname and is
    # just the output of "uname -s".
    case $kernel_name in
        Darwin)   os=$darwin_name ;;
        SunOS)    os=Solaris ;;
        Haiku)    os=Haiku ;;
        MINIX)    os=MINIX ;;
        AIX)      os=AIX ;;
        IRIX*)    os=IRIX ;;
        FreeMiNT) os=FreeMiNT ;;

        Linux|GNU*)
            os=Linux
        ;;

        *BSD|DragonFly|Bitrig)
            os=BSD
        ;;

        CYGWIN*|MSYS*|MINGW*)
            os=Windows
        ;;

        *)
            printf '%s\n' "Unknown OS detected: '$kernel_name', aborting..." >&2
            printf '%s\n' "Open an issue on GitHub to add support for your OS." >&2
            exit 1
        ;;
    esac
}

get_distro() {
    [[ $distro ]] && return

    case $os in
        Linux|BSD|MINIX)
            if [[ -f /bedrock/etc/bedrock-release && -z $BEDROCK_RESTRICT ]]; then
                case $distro_shorthand in
                    on|tiny) distro="Bedrock Linux" ;;
                    *) distro=$(< /bedrock/etc/bedrock-release)
                esac

            elif [[ -f /etc/redstar-release ]]; then
                case $distro_shorthand in
                    on|tiny) distro="Red Star OS" ;;
                    *) distro="Red Star OS $(awk -F'[^0-9*]' '$0=$2' /etc/redstar-release)"
                esac

            elif [[ -f /etc/armbian-release ]]; then
                . /etc/armbian-release
                distro="Armbian $DISTRIBUTION_CODENAME (${VERSION:-})"

            elif [[ -f /etc/siduction-version ]]; then
                case $distro_shorthand in
                    on|tiny) distro=Siduction ;;
                    *) distro="Siduction ($(lsb_release -sic))"
                esac

            elif [[ -f /etc/mcst_version ]]; then
                case $distro_shorthand in
                    on|tiny) distro="OS Elbrus" ;;
                    *) distro="OS Elbrus $(< /etc/mcst_version)"
                esac

            elif type -p pveversion >/dev/null; then
                case $distro_shorthand in
                    on|tiny) distro="Proxmox VE" ;;
                    *)
                        distro=$(pveversion)
                        distro=${distro#pve-manager/}
                        distro="Proxmox VE ${distro%/*}"
                esac

            elif type -p lsb_release >/dev/null; then
                case $distro_shorthand in
                    on)   lsb_flags=-si ;;
                    tiny) lsb_flags=-si ;;
                    *)    lsb_flags=-sd ;;
                esac
                distro=$(lsb_release "$lsb_flags")

            elif [[ -f /etc/os-release || \
                    -f /usr/lib/os-release || \
                    -f /etc/openwrt_release || \
                    -f /etc/lsb-release ]]; then

                # Source the os-release file
                for file in /etc/lsb-release /usr/lib/os-release \
                            /etc/os-release  /etc/openwrt_release; do
                    source "$file" && break
                done

                # Format the distro name.
                case $distro_shorthand in
                    on)   distro="${NAME:-${DISTRIB_ID}} ${VERSION_ID:-${DISTRIB_RELEASE}}" ;;
                    tiny) distro="${NAME:-${DISTRIB_ID:-${TAILS_PRODUCT_NAME}}}" ;;
                    off)  distro="${PRETTY_NAME:-${DISTRIB_DESCRIPTION}} ${UBUNTU_CODENAME}" ;;
                esac

            elif [[ -f /etc/GoboLinuxVersion ]]; then
                case $distro_shorthand in
                    on|tiny) distro=GoboLinux ;;
                    *) distro="GoboLinux $(< /etc/GoboLinuxVersion)"
                esac

            elif [[ -f /etc/SDE-VERSION ]]; then
                distro="$(< /etc/SDE-VERSION)"
                case $distro_shorthand in
                    on|tiny) distro="${distro% *}" ;;
                esac

            elif type -p crux >/dev/null; then
                distro=$(crux)
                case $distro_shorthand in
                    on)   distro=${distro//version} ;;
                    tiny) distro=${distro//version*}
                esac

            elif type -p tazpkg >/dev/null; then
                distro="SliTaz $(< /etc/slitaz-release)"

            elif type -p kpt >/dev/null && \
                 type -p kpm >/dev/null; then
                distro=KSLinux

            elif [[ -d /system/app/ && -d /system/priv-app ]]; then
                distro="Android $(getprop ro.build.version.release)"

            # Chrome OS doesn't conform to the /etc/*-release standard.
            # While the file is a series of variables they can't be sourced
            # by the shell since the values aren't quoted.
            elif [[ -f /etc/lsb-release && $(< /etc/lsb-release) == *CHROMEOS* ]]; then
                distro='Chrome OS'

            elif type -p guix >/dev/null; then
                case $distro_shorthand in
                    on|tiny) distro="Guix System" ;;
                    *) distro="Guix System $(guix -V | awk 'NR==1{printf $4}')"
                esac

            # Display whether using '-current' or '-release' on OpenBSD.
            elif [[ $kernel_name = OpenBSD ]] ; then
                read -ra kernel_info <<< "$(sysctl -n kern.version)"
                distro=${kernel_info[*]:0:2}

            else
                for release_file in /etc/*-release; do
                    distro+=$(< "$release_file")
                done

                if [[ -z $distro ]]; then
                    case $distro_shorthand in
                        on|tiny) distro=$kernel_name ;;
                        *) distro="$kernel_name $kernel_version" ;;
                    esac

                    distro=${distro/DragonFly/DragonFlyBSD}

                    # Workarounds for some BSD based distros.
                    [[ -f /etc/pcbsd-lang ]]       && distro=PCBSD
                    [[ -f /etc/trueos-lang ]]      && distro=TrueOS
                    [[ -f /etc/pacbsd-release ]]   && distro=PacBSD
                    [[ -f /etc/hbsd-update.conf ]] && distro=HardenedBSD
                fi
            fi

            if [[ $(< /proc/version) == *Microsoft* || $kernel_version == *Microsoft* ]]; then
                windows_version=$(wmic.exe os get Version)
                windows_version=$(trim "${windows_version/Version}")

                case $distro_shorthand in
                    on)   distro+=" [Windows $windows_version]" ;;
                    tiny) distro="Windows ${windows_version::2}" ;;
                    *)    distro+=" on Windows $windows_version" ;;
                esac

            elif [[ $(< /proc/version) == *chrome-bot* || -f /dev/cros_ec ]]; then
                [[ $distro != *Chrome* ]] &&
                    case $distro_shorthand in
                        on)   distro+=" [Chrome OS]" ;;
                        tiny) distro="Chrome OS" ;;
                        *)    distro+=" on Chrome OS" ;;
                    esac
                    distro=${distro## on }
            fi

            distro=$(trim_quotes "$distro")
            distro=${distro/NAME=}

            # Get Ubuntu flavor.
            if [[ $distro == "Ubuntu"* ]]; then
                case $XDG_CONFIG_DIRS in
                    *"studio"*)   distro=${distro/Ubuntu/Ubuntu Studio} ;;
                    *"plasma"*)   distro=${distro/Ubuntu/Kubuntu} ;;
                    *"mate"*)     distro=${distro/Ubuntu/Ubuntu MATE} ;;
                    *"xubuntu"*)  distro=${distro/Ubuntu/Xubuntu} ;;
                    *"Lubuntu"*)  distro=${distro/Ubuntu/Lubuntu} ;;
                    *"budgie"*)   distro=${distro/Ubuntu/Ubuntu Budgie} ;;
                    *"cinnamon"*) distro=${distro/Ubuntu/Ubuntu Cinnamon} ;;
                esac
            fi
        ;;

        "Mac OS X"|"macOS")
            case $osx_version in
                10.4*)  codename="Mac OS X Tiger" ;;
                10.5*)  codename="Mac OS X Leopard" ;;
                10.6*)  codename="Mac OS X Snow Leopard" ;;
                10.7*)  codename="Mac OS X Lion" ;;
                10.8*)  codename="OS X Mountain Lion" ;;
                10.9*)  codename="OS X Mavericks" ;;
                10.10*) codename="OS X Yosemite" ;;
                10.11*) codename="OS X El Capitan" ;;
                10.12*) codename="macOS Sierra" ;;
                10.13*) codename="macOS High Sierra" ;;
                10.14*) codename="macOS Mojave" ;;
                10.15*) codename="macOS Catalina" ;;
                10.16*) codename="macOS Big Sur" ;;
                11.*)  codename="macOS Big Sur" ;;
                12.*)  codename="macOS Monterey" ;;
                *)      codename=macOS ;;
            esac

            distro="$codename $osx_version $osx_build"

            case $distro_shorthand in
                on) distro=${distro/ ${osx_build}} ;;

                tiny)
                    case $osx_version in
                        10.[4-7]*)            distro=${distro/${codename}/Mac OS X} ;;
                        10.[8-9]*|10.1[0-1]*) distro=${distro/${codename}/OS X} ;;
                        10.1[2-6]*|11.0*)     distro=${distro/${codename}/macOS} ;;
                    esac
                    distro=${distro/ ${osx_build}}
                ;;
            esac
        ;;

        "iPhone OS")
            distro="iOS $osx_version"

            # "uname -m" doesn't print architecture on iOS.
            os_arch=off
        ;;

        Windows)
            distro=$(wmic os get Caption)
            distro=${distro/Caption}
            distro=${distro/Microsoft }
        ;;

        Solaris)
            case $distro_shorthand in
                on|tiny) distro=$(awk 'NR==1 {print $1,$3}' /etc/release) ;;
                *)       distro=$(awk 'NR==1 {print $1,$2,$3}' /etc/release) ;;
            esac
            distro=${distro/\(*}
        ;;

        Haiku)
            distro=Haiku
        ;;

        AIX)
            distro="AIX $(oslevel)"
        ;;

        IRIX)
            distro="IRIX ${kernel_version}"
        ;;

        FreeMiNT)
            distro=FreeMiNT
        ;;
    esac

    distro=${distro//Enterprise Server}

    [[ $distro ]] || distro="$os (Unknown)"

    # Get OS architecture.
    case $os in
        Solaris|AIX|Haiku|IRIX|FreeMiNT)
            machine_arch=$(uname -p)
        ;;

        *)  machine_arch=$kernel_machine ;;
    esac

    [[ $os_arch == on ]] && \
        distro+=" $machine_arch"

    [[ ${ascii_distro:-auto} == auto ]] && \
        ascii_distro=$(trim "$distro")
}

cache_uname() {
    # Cache the output of uname so we don't
    # have to spawn it multiple times.
    IFS=" " read -ra uname <<< "$(uname -srm)"

    kernel_name="${uname[0]}"
    kernel_version="${uname[1]}"
    kernel_machine="${uname[2]}"

    if [[ "$kernel_name" == "Darwin" ]]; then
        # macOS can report incorrect versions unless this is 0.
        # https://github.com/dylanaraps/neofetch/issues/1607
        export SYSTEM_VERSION_COMPAT=0

        IFS=$'\n' read -d "" -ra sw_vers <<< "$(awk -F'<|>' '/key|string/ {print $3}' \
                            "/System/Library/CoreServices/SystemVersion.plist")"
        for ((i=0;i<${#sw_vers[@]};i+=2)) {
            case ${sw_vers[i]} in
                ProductName)          darwin_name=${sw_vers[i+1]} ;;
                ProductVersion)       osx_version=${sw_vers[i+1]} ;;
                ProductBuildVersion)  osx_build=${sw_vers[i+1]}   ;;
            esac
        }
    fi
}

check_neovim_version() {
    # Extract version number
    nvim_version=$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?')

    # Neovim version needs to be 10 or higher
    required_version="0.9.0"

    # Compare versions using sort -V
    if ! printf "%s\n%s" "$required_version" "$nvim_version" | sort -VC; then
        printf "\e[1;31m[-] Neovim version %s or higher is required.\e[0m\n" "$required_version"
        printf "\e[1;31m[-] I suggest building from source.\e[0m\n"
        printf "\e[1;31m[-] https://github.com/neovim/neovim/blob/master/BUILD.md.\e[0m\n"
        exit 1
    fi
}

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

# Check current OS and then install dependencies using the appropriate package manager
install_deps() {
    # First ensure we have OS information
    [[ -z $os || -z $distro ]] && {
        cache_uname
        get_os
        get_distro
    }

    printf "\e[1;34m[+] Installing dependencies for %s (%s)...\e[0m\n" "$os" "$distro"

    # Common dependencies
    local deps="tree-sitter tree-sitter-cli nodejs npm shellcheck ripgrep"

    case $os in
        Linux)
            # Debian and derivatives
            if [[ -f /etc/debian_version ]] || [[ $distro == *"Debian"* ]] ||
               [[ $distro == *"Ubuntu"* ]] || [[ $distro == *"Mint"* ]] ||
               [[ $distro == *"Pop"* ]] || [[ $distro == *"Kali"* ]] ||
               [[ $distro == *"Deepin"* ]] || [[ $distro == *"MX"* ]]; then
                printf "\e[1;34m[+] Using APT package manager\e[0m\n"
                sudo apt update && sudo apt install -y $deps

            # Arch and derivatives
            elif [[ -f /etc/arch-release ]] || [[ $distro == *"Arch"* ]] ||
                 [[ $distro == *"Manjaro"* ]] || [[ $distro == *"Endeavour"* ]] ||
                 [[ $distro == *"Garuda"* ]] || [[ $distro == *"Artix"* ]]; then
                printf "\e[1;34m[+] Using Pacman package manager\e[0m\n"
                sudo pacman -Syu --needed --noconfirm $deps

            # Fedora
            elif [[ -f /etc/fedora-release ]] || [[ $distro == *"Fedora"* ]]; then
                printf "\e[1;34m[+] Using DNF package manager\e[0m\n"
                sudo dnf update -y && sudo dnf install -y $deps

            # RHEL/CentOS and derivatives
            elif [[ -f /etc/redhat-release ]] || [[ $distro == *"Red Hat"* ]] ||
                 [[ $distro == *"CentOS"* ]] || [[ $distro == *"Rocky"* ]] ||
                 [[ $distro == *"Alma"* ]] || [[ $distro == *"Oracle"* ]]; then
                printf "\e[1;34m[+] Using YUM/DNF package manager\e[0m\n"
                if command -v dnf &>/dev/null; then
                    sudo dnf update -y && sudo dnf install -y $deps
                else
                    sudo yum update -y && sudo yum install -y $deps
                fi

            # openSUSE
            elif [[ -f /etc/SuSE-release ]] || [[ $distro == *"openSUSE"* ]] ||
                 [[ $distro == *"SUSE"* ]]; then
                printf "\e[1;34m[+] Using Zypper package manager\e[0m\n"
                sudo zypper refresh && sudo zypper install -y $deps

            # Void Linux
            elif [[ $distro == *"Void"* ]]; then
                printf "\e[1;34m[+] Using XBPS package manager\e[0m\n"
                sudo xbps-install -Syu $deps

            # Gentoo
            elif [[ -f /etc/gentoo-release ]] || [[ $distro == *"Gentoo"* ]]; then
                printf "\e[1;34m[+] Using Portage package manager\e[0m\n"
                sudo emerge --sync && sudo emerge -av $deps

            # Alpine
            elif [[ -f /etc/alpine-release ]] || [[ $distro == *"Alpine"* ]]; then
                printf "\e[1;34m[+] Using APK package manager\e[0m\n"
                sudo apk update && sudo apk add $deps

            # Solus
            elif [[ $distro == *"Solus"* ]]; then
                printf "\e[1;34m[+] Using eopkg package manager\e[0m\n"
                sudo eopkg update-repo && sudo eopkg install -y $deps

            # NixOS
            elif [[ -f /etc/nixos ]] || [[ $distro == *"NixOS"* ]]; then
                printf "\e[1;34m[+] Using Nix package manager\e[0m\n"
                nix-env -iA nixos.tree-sitter nixos.nodejs nixos.npm nixos.shellcheck nixos.ripgrep

            # Clear Linux
            elif [[ $distro == *"Clear Linux"* ]]; then
                printf "\e[1;34m[+] Using Swupd package manager\e[0m\n"
                sudo swupd update && sudo swupd bundle-add $deps

            # Bedrock Linux - try to use the native package manager of the current stratum
            elif [[ -f /bedrock/etc/bedrock-release ]]; then
                printf "\e[1;34m[+] Detected Bedrock Linux\e[0m\n"
                if command -v apt &>/dev/null; then
                    printf "\e[1;34m[+] Using APT package manager\e[0m\n"
                    sudo apt update && sudo apt install -y $deps
                elif command -v pacman &>/dev/null; then
                    printf "\e[1;34m[+] Using Pacman package manager\e[0m\n"
                    sudo pacman -Syu --needed --noconfirm $deps
                elif command -v dnf &>/dev/null; then
                    printf "\e[1;34m[+] Using DNF package manager\e[0m\n"
                    sudo dnf update -y && sudo dnf install -y $deps
                else
                    printf "\e[1;31m[-] Could not determine package manager for Bedrock Linux\e[0m\n"
                    exit 1
                fi

            # Fallback for other Linux distributions - try common package managers
            else
                printf "\e[1;33m[!] Unknown Linux distribution: %s\e[0m\n" "$distro"
                printf "\e[1;33m[!] Attempting to detect package manager...\e[0m\n"

                if command -v apt &>/dev/null; then
                    printf "\e[1;34m[+] Using APT package manager\e[0m\n"
                    sudo apt update && sudo apt install -y $deps
                elif command -v pacman &>/dev/null; then
                    printf "\e[1;34m[+] Using Pacman package manager\e[0m\n"
                    sudo pacman -Syu --needed --noconfirm $deps
                elif command -v dnf &>/dev/null; then
                    printf "\e[1;34m[+] Using DNF package manager\e[0m\n"
                    sudo dnf update -y && sudo dnf install -y $deps
                elif command -v yum &>/dev/null; then
                    printf "\e[1;34m[+] Using YUM package manager\e[0m\n"
                    sudo yum update -y && sudo yum install -y $deps
                elif command -v zypper &>/dev/null; then
                    printf "\e[1;34m[+] Using Zypper package manager\e[0m\n"
                    sudo zypper refresh && sudo zypper install -y $deps
                elif command -v xbps-install &>/dev/null; then
                    printf "\e[1;34m[+] Using XBPS package manager\e[0m\n"
                    sudo xbps-install -Syu $deps
                else
                    printf "\e[1;31m[-] Could not determine package manager\e[0m\n"
                    printf "\e[1;31m[-] Please install the following dependencies manually:\e[0m\n"
                    printf "\e[1;31m    %s\e[0m\n" "$deps"
                    read -rp "Press Enter to continue after installing dependencies manually..."
                fi
            fi
        ;;

        "Mac OS X"|"macOS")
            if command -v brew &>/dev/null; then
                printf "\e[1;34m[+] Using Homebrew package manager\e[0m\n"
                brew update && brew install tree-sitter node shellcheck ripgrep
            else
                printf "\e[1;31m[-] Homebrew not found. Please install Homebrew first:\e[0m\n"
                printf "\e[1;31m    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"\e[0m\n"
                read -rp "Press Enter to continue after installing Homebrew..."
                brew update && brew install tree-sitter node shellcheck ripgrep
            fi
        ;;

        BSD)
            case $distro in
                *"FreeBSD"*)
                    printf "\e[1;34m[+] Using pkg package manager (FreeBSD)\e[0m\n"
                    sudo pkg update && sudo pkg install -y tree-sitter node npm shellcheck ripgrep
                ;;

                *"OpenBSD"*)
                    printf "\e[1;34m[+] Using pkg_add package manager (OpenBSD)\e[0m\n"
                    sudo pkg_add tree-sitter node npm shellcheck ripgrep
                ;;

                *"NetBSD"*)
                    printf "\e[1;34m[+] Using pkgin package manager (NetBSD)\e[0m\n"
                    sudo pkgin update && sudo pkgin install tree-sitter nodejs npm shellcheck ripgrep
                ;;

                *"DragonFly"*)
                    printf "\e[1;34m[+] Using pkg package manager (DragonFlyBSD)\e[0m\n"
                    sudo pkg update && sudo pkg install -y tree-sitter node npm shellcheck ripgrep
                ;;

                *)
                    printf "\e[1;31m[-] Unknown BSD variant: %s\e[0m\n" "$distro"
                    printf "\e[1;31m[-] Please install the following dependencies manually:\e[0m\n"
                    printf "\e[1;31m    %s\e[0m\n" "$deps"
                    read -rp "Press Enter to continue after installing dependencies manually..."
                ;;
            esac
        ;;

        Windows)
            if grep -q Microsoft /proc/version 2>/dev/null; then
                # WSL - use apt or the appropriate package manager based on the WSL distro
                printf "\e[1;34m[+] Detected Windows Subsystem for Linux\e[0m\n"
                if command -v apt &>/dev/null; then
                    printf "\e[1;34m[+] Using APT package manager (WSL)\e[0m\n"
                    sudo apt update && sudo apt install -y $deps
                elif command -v pacman &>/dev/null; then
                    printf "\e[1;34m[+] Using Pacman package manager (WSL)\e[0m\n"
                    sudo pacman -Syu --needed --noconfirm $deps
                elif command -v dnf &>/dev/null; then
                    printf "\e[1;34m[+] Using DNF package manager (WSL)\e[0m\n"
                    sudo dnf update -y && sudo dnf install -y $deps
                elif command -v yum &>/dev/null; then
                    printf "\e[1;34m[+] Using YUM package manager (WSL)\e[0m\n"
                    sudo yum update -y && sudo yum install -y $deps
                elif command -v zypper &>/dev/null; then
                    printf "\e[1;34m[+] Using Zypper package manager (WSL)\e[0m\n"
                    sudo zypper refresh && sudo zypper install -y $deps
                elif command -v xbps-install &>/dev/null; then
                    printf "\e[1;34m[+] Using XBPS package manager (WSL)\e[0m\n"
                    sudo xbps-install -Syu $deps
                else
                    printf "\e[1;31m[-] Could not determine package manager for WSL\e[0m\n"
                    printf "\e[1;31m[-] Please install the following dependencies manually:\e[0m\n"
                    printf "\e[1;31m    %s\e[0m\n" "$deps"
                    read -rp "Press Enter to continue after installing dependencies manually..."
                fi
            else
                printf "\e[1;31m[-] Unsupported Windows environment. Please install dependencies manually.\e[0m\n"
                printf "\e[1;31m[-] Please install the following dependencies manually:\e[0m\n"
                printf "\e[1;31m    %s\e[0m\n" "$deps"
                read -rp "Press Enter to continue after installing dependencies manually..."
            fi
        ;;

        *)
            printf "\e[1;31m[-] Unsupported OS: %s\e[0m\n" "$os"
            printf "\e[1;31m[-] Please install the following dependencies manually:\e[0m\n"
            printf "\e[1;31m    %s\e[0m\n" "$deps"
            read -rp "Press Enter to continue after installing dependencies manually..."
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
        # Open Neovim for the first time and install plugins
        nvim
}


# calling the functions
main(){
        get_os
        get_distro
        cache_uname
        check_neovim_version
        install_prompt
        install_deps
        remove_old_config
        install_config
}

main
