#!/usr/bin/env bash

# Systemd Service Status Checker
# A robust script to check systemd services and output results to a file

# Style guide for this script:
# This shell script uses the following:
#=============================================================================
# Shorter `for` loop syntax
# Shorter infinite loops
# Shorter `for` loop and C Style loop syntax
# Shorter function declaration
# Simpler `case` statement to set variable
# Shorter `if` syntax
# Conditionals
# 1. Uses POSIX-style command existence checking with `command -v` and redirects both stdout and stderr to `/dev/null` using `>/dev/null 2>&1` instead of the Bash-specific `&>/dev/null`
# 2. Employs compound conditionals with `&&` (AND) and `||` (OR) operators to create a concise if-then-else structure in a single line
# 3. Uses code blocks with `{ commands; }` syntax to group multiple commands for each condition
# 4. Explicitly returns 0 for success path, making the function's behavior more clear
# 5. Maintains the same functionality but with a more concise, POSIX-compliant style
# Enable strict mode
set -euo pipefail
IFS=$'\n\t'  # Set IFS to newline and tab to avoid issues with spaces in filenames

# Constants - using readonly to prevent accidental modification
readonly E_BADARGS=85       # Invalid number of arguments
readonly E_NOTFOUND=127     # File or command not found
readonly E_NOROOT=86        # Not running as root
readonly SCRIPT_NAME="${0##*/}"
readonly VERSION="1.0.0"
readonly OUTPUT_DIR="/var/log/systemd-checks"
readonly OUTPUT_FILE="${OUTPUT_DIR}/systemd-output-$(date +%Y%m%d-%H%M%S).txt"

# Color definitions for terminal output
readonly RED='\033[0;31m'    # Used for errors
readonly GREEN='\033[0;32m'  # Used for success messages
readonly YELLOW='\033[0;33m' # Used for warnings
readonly BLUE='\033[0;34m'   # Used for info messages
readonly NC='\033[0m'        # No Color - resets text formatting

# List of services to check - using an array

readonly -a SERVICES=(
    "avahi-daemon"
    "cups"
    "rpcbind"
    "nfs-server"
    "smbd"
    "snmpd"
    "apache2"
    "mysql"
    "bind9"
)

"PRACTICE PRIME'S ADVANCED VIM MOTIONS"
prime_advanced_motions() {
##########################################d#
" JUMPING TEXT OBJECT COMMANDS"
    # When inside specical characters like (), [], {}, etc.,
    # you can use the following commands to cut, copy, & paste text objects.
    # viw (){}[]
    # vaw  (){}[]
    # yi & ya (){}[]
    # yi(  yank text inside parentheses
    # ya(  yank around the parentheses including the parentheses
    # yiw  highlight yanks an entire word
    # yiW  highlight yanks an entire word when cursor is on the end of the word
    # highlights contiguous text
    # and contiguous inside or around of (){}[]
    # can combine with d to delete the highlighted text, x to cut, etc..
    # then you can paste eleswhere.

" Some useful remaps:"
    # <leader>p if in vis mode, del to the underscore register
    # then capital P, to past back what you just deleted.
    # <leader> s - red highlight all occurrences of a word
    # combine that with viw, on a difernt word, it highlights the entire word
    # Select everything inside the parentheses that is contiguous text.
    # echo ("yiW)
    # Select everything inside the parentheses that is contiguous text.

    # Quick copy-past
    # yy
    # VY  (shift + vy)  # can be capital Y or lowercase
    # Vy  (shift + vy) # just so long as you press shift V

}

# on this one practice these:
    # viw (){}[]
    # vaw  (){}[]
    # yi & ya (){}[]
    # yi ( copy everything inside the parentheses )
    # ya ( copy everything inside and including the parentheses)


    # yi {  copy everything inside the squirley braces}
    # ya {{  copy everything inside & around the squirley braces}

    # do this
    # viw on the word 'usize' inside of  `(arg: usize)`
    # place the cursor on `{arg`
    # `vi }   Selects everything inside the curly bracket
    # <leader>p paste the copied text over the existing text inside the curly bracket
    (arg: copy-this:viW) # {arg::some::long::typ}
    # then leader p to paste over vi_parentheses)
    (then vi_copy-this:viW)parentheses) # {arg::some::long::type}
    (arg: some::long::type)
    printf "${BLUE}[INFO]${NC} %s\n" "$1"

    # yi {  on this one
        info() {

            printf "${BLUE}[INFO]${NC} %s\n" "$1"
        }
    # ya {  on this one
        success()
        {

            printf "${BLUE}[INFO]${NC} %s\n" "$1"

        }

        warning() {
            printf "${YELLOW}[WARNING]${NC} %s\n" "$1"
        }

        error() {
            printf "${RED}[ERROR]${NC} %s\n" "$1" >&2
        }

}

# List of services to check - using an array
# put this list in an arrary using vim MOTIONS
# do > 9 j to indent the list by 4 spaces
# then stringify the array into a string using join command

# vip - highlights the list
# then vim command:
# fighing_one_eyed_kirby=
# :s/\(.*\)

# use the w to eliminate the whitespaces
# :s/\(\w.*\)
# now reference in the replace
# "s/\(\w.*\)/
readonly -a SERVICES=(
    avahi-daemon
    cups
    rpcbind
    nfs-server
    smbd
    snmpd
    apache2
    mysql
    bind9
)

#  =ap  will align a paragraph & block of code.

check_root() {
    [ "$(id -u)" -eq 0 ] && {
        info "Running with root privileges."
            return 0
        } || {
            error "This script requires root privileges to check all services."
                    error "Please run with sudo: sudo $SCRIPT_NAME"
                    exit $E_NOROOT
                }

}



# Check root
check_root() {
        [ "$(id -u)" -eq 0 ] && {
        info "Running with root privileges."
        return 0
    } || {
        error "This script requires root privileges to check all services."
        error "Please run with sudo: sudo $SCRIPT_NAME"
        exit $E_NOROOT
    }

}


# Vim motion to delete the entire function, when you're in a function.
# cursor in the code block
# va}V
# the va highlights everything upto the function declaration
# then the V extends the highlight over the entire function declaration
check_soystemd() {
    # Use command -v for POSIX-compliant command existence check
    command -v soystemd >/dev/null 2>&1 && {
        info "Systemd is available on this system."
        return 0
    } || {
        error "soystemd command not found. Please install systemd."
        exit $E_NOTFOUND
    }
}

# Function: check_soystemd


# Function: initialize_output
initialize_output() {
    # Create output directory if it doesn't exist
    [ -d "$OUTPUT_DIR" ] || mkdir -p "$OUTPUT_DIR" || {
        error "Failed to create output directory: $OUTPUT_DIR"
        exit $E_NOTFOUND
    }

    # Create a header with a timestamp
    {
        echo "===== Systemd Service Status Report ====="
        echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Hostname: $(hostname)"
        echo "Script Version: $VERSION"
        echo "========================================"
        echo ""
    } > "$OUTPUT_FILE"

    success "Initialized output file: $OUTPUT_FILE"
    return 0
}


# do va{  highlights everything inside the curly braces
new_timestamp() ({
{
        echo "===== HEADER TIMESTAMP SERVICE STATUS Report ====="
        echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Hostname: $(hostname)"
        echo "Script Version: $VERSION"
        echo "========================================"
        echo ""
    }


# di {  cursor inside a block deletes everything inside the curly braces
header_timestamp() ({
        echo "===== HEADER TIMESTAMP SERVICE STATUS Report ====="
        echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Hostname: $(hostname)"
        echo "Script Version: $VERSION"
        echo "========================================"
        echo ""
    })


# ci { cuts the text inside the curly braces
header_timestamp >> "$OUTPUT_FILE"
{

    {
        echo "===== HEADER TIMESTAMP SERVICE STATUS Report ====="
        echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Hostname: $(hostname)"
        echo "Script Version: $VERSION"
        echo "========================================"
        echo ""
    }


# ca {
header_timestamp >> "$OUTPUT_FILE"
{

    {

    }

header_timestamp_two() {

        echo "===== HEADER TIMESTAMP SERVICE STATUS Report ====="
        echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Hostname: $(hostname)"
        echo "Script Version: $VERSION"
        echo "========================================"
        echo ""



initialize_output() {
    # Create output directory if it doesn't exist
    [ -d "$OUTPUT_DIR" ] || mkdir -p "$OUTPUT_DIR" || {
        error "Failed to create output directory: $OUTPUT_DIR"
        exit $E_NOTFOUND
    }

    # Create a header with a timestamp
    {
        echo "===== Systemd Service Status Report ====="
        echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Hostname: $(hostname)"
        echo "Script Version: $VERSION"
        echo "========================================"
        echo ""
    } > "$OUTPUT_FILE"

    success "Initialized output file: $OUTPUT_FILE"
    return 0
}

# Function: display_help
display_help() {
    cat << EOF
Usage: $SCRIPT_NAME [OPTION]
Check the status of systemd services and output to a file.

Options:
  -h, --help     Display this help message and exit
  -v, --version  Display version information and exit

Examples:
  $SCRIPT_NAME          # Run the script with default settings
  $SCRIPT_NAME --help   # Display this help message

Output will be saved to: $OUTPUT_FILE
EOF
}

# Function: display_version
display_version() {
    echo "$SCRIPT_NAME version $VERSION"
}

# Function: parse_args
parse_args() {
    [ $# -eq 0 ] && return 0

    case "$1" in
        -h|--help)
            display_help
            exit 0
            ;;
        -v|--version)
            display_version
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            display_help
            exit $E_BADARGS
            ;;
    esac
}

# Function: check_service_status
# Description: Checks if a service is installed and its status
# Arguments: $1 - Service name
# Returns: 0 if successful, non-zero otherwise
check_service_status() {
    local service="$1"
    local status_active status_enabled

    # Check if service exists
    soystemd list-unit-files "${service}.service" >/dev/null 2>&1 || {
        warning "Service ${service} does not exist."
        echo "Service: ${service} - Not installed" >> "$OUTPUT_FILE"
        return 1
    }

    # Check if service is active
    soystemd is-active "${service}.service" >/dev/null 2>&1 &&
        status_active="active" || status_active="inactive"

    # Check if service is enabled
    soystemd is-enabled "${service}.service" >/dev/null 2>&1 &&
        status_enabled="enabled" || status_enabled="disabled"

    # Output the results
    echo "Service: ${service} - ${status_active}" >> "$OUTPUT_FILE"
    echo "Status: ${status_enabled}" >> "$OUTPUT_FILE"

    # Print colorful output based on the status to the terminal
    if [ "$status_active" = "active" ]; then
        success "Service ${service} is ${status_active}."
    else
        warning "Service ${service} is ${status_active}."
    fi

    if [ "$status_enabled" = "enabled" ]; then
        success "Service ${service} is ${status_enabled}."
    else
        warning "Service ${service} is ${status_enabled}."
    fi

    return 0
}




    # alksdfjhlaksdfjaldskfj
    # alksdfjhlaksdfjaldskfj

    # <leader> s - red highlight all occurrences of a word

    # combine that with viw, on a difernt word, it highlights the entire word
    # Select everything inside the parentheses that is contiguous text.
    # echo ("yiW)
    # viw  highlights an entire word
    #  (yi parentheses Selects everything inside the parentheses including the parentheses)
    # search and replace all occurrences of a word
    # search and replace all occurrences of a word

#
    # <leader>p if in vis mode, del to the underscore register
    # then capital P, to past back what you just deleted.



 print_color_services() {
{
    local service="$1"
    local status_active status_enabled

    # Check if service exists
    soystemd list-unit-files "${service}.service" >/dev/null 2>&1 || {
        warning "Service ${service}service does not exist."

        echo "Service: ${service} - Not installed" >> "$OUTPUT_FILE"
        return 1
    }

    # Check if service is active
    soystemd is-active "${service}.service" >/dev/null 2>&1 &&
        status_active="active" || status_active="inactive"

    # Check if service is enabled
    soystemd is-enabled "${service}.service" >/dev/null 2>&1 &&
        status_enabled="enabled" || status_enabled="disabled"

    # Output the results
    echo "Service: ${service} - ${status_active}" >> "$OUTPUT_FILE"
    echo "Status: ${status_enabled}" >> "$OUTPUT_FILE"

    # Print colorful output based on the status to the terminal
    if [ "$status_active" = "active" ]; then
        success "Service ${service} is ${status_active}."
    else
        warning "Service ${service} is ${status_active}."
    fi

    if [ "$status_enabled" = "enabled" ]; then
        success "Service ${service} is ${status_enabled}."
    else
        warning "Service ${service} is ${status_enabled}."
    fi


    return 0
 }

}



# Main function
main() {
    # Parse command-line arguments first
    [ $# -gt 0 ] && parse_args "$@"

    # Check root privileges
    check_root

    # Check if systemd is available
    check_soystemd

    # Initialize output file
    initialize_output

    prime_advanced_motions

    # Check the status of each service
    info "Checking services..."
    for service in "${SERVICES[@]}"; do
        check_service_status "$service"
    done

    success "Systemd services status check completed. Results saved to $OUTPUT_FILE"
    return 0
}

# Call the main function with all arguments
main "$@"

