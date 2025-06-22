#!/usr/bin/env bash


# Goal, implement the features of the sshd_config into this script.
# This script should be able to convert the normal sshd_config into
# the one in this directory.
# import sshd_config


# Exit on error, undefined variable, and prevent errors in pipes from being masked
set -euo pipefail

SSH_CONFIG="/etc/ssh/sshd_config"

apply_ssh_config() {
    local setting="$1"
    local value="$2"

    if grep -qE "^\s*${setting}\s+" "$SSH_CONFIG"; then
        sed -i "s/^\s*${setting}\s+.*/${setting} ${value}/" "$SSH_CONFIG"
    else
        echo "${setting} ${value}" >> "$SSH_CONFIG"
    fi
}

backup_ssh_config() {
    local timestamp
    timestamp=$(date +%Y%m%d%H%M%S)
    cp "$SSH_CONFIG" "${SSH_CONFIG}.bak.${timestamp}"
    echo "Backup created: ${SSH_CONFIG}.bak.${timestamp}"
}

check_ssh_config() {
    local config="$1"
    local setting="$2"
    local expected="$3"
    local message="$4"

    if grep -qE "^\s*${setting}\s+${expected}" "$config"; then
        echo "[PASS] $message"
    else
        echo "[FAIL] $message"
    fi
}

check_ssh_security_settings() {
    echo "Checking SSH Security Settings..."

    # 1. Disable Passwd auth
    check_ssh_config "$SSH_CONFIG" "PasswordAuthentication" "no" "Password authentication is disabled"

    # 2. Enable Public Key Auth
    check_ssh_config "$SSH_CONFIG" "PubkeyAuthentication" "yes" "Public key authentication is enabled"

    # 3. Disable Root Login
    check_ssh_config "$SSH_CONFIG" "PermitRootLogin" "no" "Root login is disabled"
}

check_ssh_port() {
    # 4. Change Default SSH Port to 8022
    check_ssh_config "$SSH_CONFIG" "Port" "8022" "Default SSH port is changed to 8922"

    # 5. Enable TCP Wrappers
    check_ssh_config "$SSH_CONFIG" "UsePrivilegeSeparation" "yes" "TCP wrappers are enabled"
    check_ssh_config "$SSH_CONFIG" "TCPWrapperGroup" "nobody" "TCP wrappers group is set to nobody"
    check_ssh_config "$SSH_CONFIG" "TCPWrappersFile" "/etc/ssh/tcpwrappers" "TCP wrappers file is set to /etc/ssh/tcpwrappers"
}

check_user_access_restriction() {
    # 5. Restrict User Access
    if grep -qE "^\s*AllowUsers" "$SSH_CONFIG"; then
        echo "[PASS] User access is restricted with AllowUsers"
    else
        echo "[FAIL] User access is not restricted with AllowUsers"
    fi
}

check_protocol_version() {
    # 6. Use SSH Protocol 2
    check_ssh_config "$SSH_CONFIG" "Protocol" "2" "SSH Protocol 2 is used"
}

check_two_factor_authentication() {
    # 7. Enable Two-Factor Authentication (2FA)
    if grep -qE "^\s*AuthenticationMethods.*" "$SSH_CONFIG"; then
        echo "[PASS] Two-factor authentication is enabled"
    else
        echo "[FAIL] Two-factor authentication is not enabled"
    fi
}

check_idle_timeout_interval() {
    # 8. Configure Idle Timeout Interval
    check_ssh_config "$SSH_CONFIG" "ClientAliveInterval" "300" "Idle timeout interval is set"
    check_ssh_config "$SSH_CONFIG" "ClientAliveCountMax" "0" "Idle timeout count max is set"
}

check_login_attempts() {
    # 9. Limit Login Attempts
    check_ssh_config "$SSH_CONFIG" "MaxAuthTries" "3" "Login attempts are limited"
}

check_firewall_settings() {
    # 10. Use a Firewall
    if command -v ufw &>/dev/null; then
        if ufw status | grep -q "22/tcp"; then
            echo "[FAIL] Firewall allows SSH on default port (22)"
        else
            echo "[PASS] Firewall does not allow SSH on default port (22)"
        fi
    else
        echo "[INFO] UFW is not installed. Skipping firewall check."
    fi

    check_ssh_config "$SSH_CONFIG" "LogLevel" "VERBOSE" "Logging level is set to VERBOSE"
}

check_fail2ban_status() {
    # 12. Use Fail2Ban
    if command -v systemctl &>/dev/null && systemctl is-active --quiet fail2ban; then
        echo "[PASS] Fail2Ban is active"
    else
        echo "[FAIL] Fail2Ban is not active or systemctl is not available"
    fi
}

check_unused_features() {
    # 14. Disable Unused Features
    check_ssh_config "$SSH_CONFIG" "X11Forwarding" "no" "X11 forwarding is disabled"
    check_ssh_config "$SSH_CONFIG" "AllowTcpForwarding" "no" "TCP forwarding is disabled"
}

apply_ssh_security_settings() {
    echo "Applying SSH Security Settings..."

    # 1. Disable Password Authentication
    apply_ssh_config "PasswordAuthentication" "no"

    # 2. Enable Public Key Authentication
    apply_ssh_config "PubkeyAuthentication" "yes"

    # 3. Disable Root Login
    apply_ssh_config "PermitRootLogin" "no"
}

apply_ssh_port() {
    # 4. Change Default SSH Port to 8922
    apply_ssh_config "Port" "8922"
}

apply_user_access_restriction() {
    # 5. Restrict User Access
    if ! grep -qE "^\s*AllowUsers" "$SSH_CONFIG"; then
        echo "AllowUsers your_user" >> "$SSH_CONFIG"
    fi
}

apply_protocol_version() {
    # 6. Use SSH Protocol 2
    apply_ssh_config "Protocol" "2"
}

apply_two_factor_authentication() {
    # 7. Enable Two-Factor Authentication (2FA)
    if ! grep -qE "^\s*AuthenticationMethods" "$SSH_CONFIG"; then
        echo "AuthenticationMethods publickey,keyboard-interactive" >> "$SSH_CONFIG"
    fi
}

apply_idle_timeout_interval() {
    # 8. Configure Idle Timeout Interval
    apply_ssh_config "ClientAliveInterval" "300"
    apply_ssh_config "ClientAliveCountMax" "0"
}

apply_login_attempts_limit() {
    # 9. Limit Login Attempts
    apply_ssh_config "MaxAuthTries" "3"
}

apply_unused_features() {
    # 14. Disable Unused Features
    apply_ssh_config "X11Forwarding" "no"
    apply_ssh_config "AllowTcpForwarding" "no"
}

restart_ssh_service() {
    if command -v systemctl &>/dev/null; then
        systemctl restart sshd
    else
        service ssh restart
    fi
}

check_all_settings() {
    check_ssh_security_settings
    check_ssh_port
    check_user_access_restriction
    check_protocol_version
    check_two_factor_authentication
    check_idle_timeout_interval
    check_login_attempts
    check_firewall_settings
    check_fail2ban_status
    echo "[INFO] Ensure your system and SSH are regularly updated"
    check_unused_features
}

main() {
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" >&2
        exit 1
    fi

    # Check if SSH config exists
    if [[ ! -f "$SSH_CONFIG" ]]; then
        echo "SSH config file not found: $SSH_CONFIG" >&2
        exit 1
    }

    # Parse command line arguments
    case "${1:-apply}" in
        check)
            check_all_settings
            ;;
        apply)
            backup_ssh_config
            apply_ssh_security_settings
            apply_ssh_port
            apply_user_access_restriction
            apply_protocol_version
            apply_two_factor_authentication
            apply_idle_timeout_interval
            apply_login_attempts_limit
            apply_unused_features
            restart_ssh_service
            echo "SSH configuration applied and service restarted."
            ;;
        *)
            echo "Usage: $0 [check|apply]" >&2
            exit 1
            ;;
    esac
}

# Execute main function with all arguments
main "$@"
