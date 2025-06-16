#!/bin/bash

# if this works, integrate it into hardn-main.sh


SSH_CONFIG="/etc/ssh/sshd_config"

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

    # 1. Disable Password Authentication
    check_ssh_config "$SSH_CONFIG" "PasswordAuthentication" "no" "Password authentication is disabled"

    # 2. Enable Public Key Authentication
    check_ssh_config "$SSH_CONFIG" "PubkeyAuthentication" "yes" "Public key authentication is enabled"

    # 3. Disable Root Login
    check_ssh_config "$SSH_CONFIG" "PermitRootLogin" "no" "Root login is disabled"
}

check_ssh_port() {
    # 4. Change Default SSH Port
    if grep -qE "^\s*Port\s+22" "$SSH_CONFIG"; then
        echo "[FAIL] Default SSH port is used (22)"
    else
        echo "[PASS] SSH port is changed from default (22)"
    fi
}

check_user_access_restriction() {
    # 5. Restrict User Access
    if grep -qE "^\s*AllowUsers" "$SSH_CONFIG"; then
        echo "[PASS] User access is restricted with AllowUsers"
    else
        echo "[FAIL] User access is not restricted with AllowUsers"
    fi
}

# 6. Use SSH Protocol 2
check_ssh_config "$SSH_CONFIG" "Protocol" "2" "SSH Protocol 2 is used"

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

# 9. Limit Login Attempts
check_ssh_config "$SSH_CONFIG" "MaxAuthTries" "3" "Login attempts are limited"

check_firewall_settings() {
    # 10. Use a Firewall
    if ufw status | grep -q "22/tcp"; then
        echo "[FAIL] Firewall allows SSH on default port (22)"
    else
        echo "[PASS] Firewall does not allow SSH on default port (22)"
    fi
    check_ssh_config "$SSH_CONFIG" "LogLevel" "VERBOSE" "Logging level is set to VERBOSE"
}

check_fail2ban_status() {
    # 12. Use Fail2Ban
    if systemctl is-active --quiet fail2ban; then
        echo "[PASS] Fail2Ban is active"
    else
        echo "[FAIL] Fail2Ban is not active"
    fi
}

# 13. Keep SSH and System Updated
echo "[INFO] Ensure your system and SSH are regularly updated"

check_unused_features() {
    # 14. Disable Unused Features
    check_ssh_config "$SSH_CONFIG" "X11Forwarding" "no" "X11 forwarding is disabled"
    check_ssh_config "$SSH_CONFIG" "AllowTcpForwarding" "no" "TCP forwarding is disabled"
}
echo "SSH Security Check Completed."

main() {
 # call the function to perform the checks
 check_ssh_security_settings
   check_ssh_port
   check_user_access_restriction
   check_two_factor_authentication
   check_idle_timeout_interval
   check_fail2ban_status
   check_firewall_settings
   check_unused_features
}

main
