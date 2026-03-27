#!/usr/bin/env bash
# =============================================================================
#  check_litellm_exposure.sh
#  Checks whether your system was exposed to the LiteLLM supply chain attack
#  (TeamPCP / CVE-2026-33634) — malicious PyPI versions 1.82.7 and 1.82.8
#  published March 24, 2026 between 10:39–16:00 UTC.
#
#  Supports: macOS and Linux
#  Usage:    chmod +x check_litellm_exposure.sh && ./check_litellm_exposure.sh
# =============================================================================

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ── State tracking ────────────────────────────────────────────────────────────
FINDINGS=()
WARNINGS=()
CHECKS_PASSED=0
CHECKS_WARNED=0
CHECKS_FAILED=0

# ── Detect OS ─────────────────────────────────────────────────────────────────
OS="$(uname -s)"
IS_MAC=false
IS_LINUX=false
[[ "$OS" == "Darwin" ]] && IS_MAC=true
[[ "$OS" == "Linux" ]]  && IS_LINUX=true

# ── Helpers ───────────────────────────────────────────────────────────────────
header() {
    echo ""
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${CYAN}${BOLD}  $1${RESET}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

pass() {
    echo -e "  ${GREEN}✔  $1${RESET}"
    (( CHECKS_PASSED++ )) || true
}

warn() {
    echo -e "  ${YELLOW}⚠  $1${RESET}"
    WARNINGS+=("$1")
    (( CHECKS_WARNED++ )) || true
}

fail() {
    echo -e "  ${RED}✘  $1${RESET}"
    FINDINGS+=("$1")
    (( CHECKS_FAILED++ )) || true
}

info() {
    echo -e "  ${DIM}→  $1${RESET}"
}

run_find() {
    # Wrapper: run find, return results, never exit on no-match
    find "$@" 2>/dev/null || true
}

# =============================================================================
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║       LiteLLM Supply Chain Exposure Checker          ║${RESET}"
echo -e "${BOLD}║       TeamPCP / CVE-2026-33634 / March 24 2026       ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo -e "  ${DIM}OS: $OS  |  User: $USER  |  Date: $(date)${RESET}"


# =============================================================================
header "1. pip — Direct Installation Check"
# =============================================================================

PYTHONS=(python python3 python3.10 python3.11 python3.12 python3.13 python3.14)
$IS_MAC && PYTHONS+=(/opt/homebrew/bin/python3)

LITELLM_FOUND_PIP=false
for py in "${PYTHONS[@]}"; do
    if command -v "$py" &>/dev/null 2>&1; then
        result=$("$py" -m pip show litellm 2>/dev/null || true)
        if [[ -n "$result" ]]; then
            version=$(awk '/^Version:/{print $2; exit}' <<< "$result")
            fail "litellm $version found via $py"
            LITELLM_FOUND_PIP=true
            if [[ "$version" == "1.82.7" || "$version" == "1.82.8" ]]; then
                fail "CRITICAL: Malicious version $version detected via $py"
            fi
        else
            info "$py → not installed"
        fi
    fi
done
$LITELLM_FOUND_PIP || pass "litellm not found in any pip environment"

# pip cache
info "Checking pip download cache..."
if pip cache list 2>/dev/null | grep -q "litellm"; then
    warn "litellm found in pip cache (cached but may not be installed)"
else
    pass "litellm not in pip cache"
fi


# =============================================================================
header "2. Malicious .pth File — litellm_init.pth"
# =============================================================================

PTH_SEARCH_DIRS=(/usr "$HOME/.local" "$HOME/Projects")
$IS_MAC && PTH_SEARCH_DIRS+=(/opt/homebrew /opt "$HOME/Library")
$IS_LINUX && PTH_SEARCH_DIRS+=(/opt)
[[ -d "$HOME/.pyenv" ]] && PTH_SEARCH_DIRS+=("$HOME/.pyenv")

PTH_FOUND=false
for dir in "${PTH_SEARCH_DIRS[@]}"; do
    [[ -d "$dir" ]] || continue
    results=$(run_find "$dir" -name "litellm_init.pth")
    if [[ -n "$results" ]]; then
        while IFS= read -r f; do
            fail "Malicious .pth file found: $f"
            PTH_FOUND=true
        done <<< "$results"
    fi
done
$PTH_FOUND || pass "litellm_init.pth not found anywhere"

# sysmon persistence file (dropped by payload)
info "Checking for sysmon persistence file..."
if [[ -f "$HOME/.config/sysmon/sysmon.py" ]]; then
    fail "Persistence file found: ~/.config/sysmon/sysmon.py — SYSTEM MAY BE COMPROMISED"
else
    pass "~/.config/sysmon/sysmon.py not present"
fi


# =============================================================================
header "3. Suspicious .pth Content Scan (base64 / subprocess)"
# =============================================================================

scan_pth_content() {
    local label="$1"; shift
    local dirs=("$@")
    local found=false
    for dir in "${dirs[@]}"; do
        [[ -d "$dir" ]] || continue
        matches=$(run_find "$dir" -name "*.pth" | xargs -r grep -l "litellm\|subprocess\|base64" 2>/dev/null || true)
        if [[ -n "$matches" ]]; then
            while IFS= read -r f; do
                warn "Suspicious .pth content in ($label): $f"
                found=true
            done <<< "$matches"
        fi
    done
    $found || pass "No suspicious .pth content in $label"
}

# Active Python site-packages
SITE_DIRS=()
for py in python3 python3.11 python3.12 python3.14; do
    if command -v "$py" &>/dev/null 2>&1; then
        while IFS= read -r d; do
            SITE_DIRS+=("$d")
        done < <("$py" -c "import site; print('\n'.join(site.getsitepackages() + [site.getusersitepackages()]))" 2>/dev/null || true)
    fi
done
scan_pth_content "active Python site-packages" "${SITE_DIRS[@]:-/dev/null}"
scan_pth_content "pyenv versions"   "${HOME}/.pyenv/versions"
scan_pth_content "Projects venvs"   "${HOME}/Projects"
$IS_MAC && scan_pth_content "Homebrew Python" "/opt/homebrew/lib"


# =============================================================================
header "4. litellm Package in site-packages"
# =============================================================================

INSTALL_SEARCH=(/usr/local /opt/homebrew "$HOME/.local" "$HOME/.pyenv" "$HOME/Projects")
$IS_MAC && INSTALL_SEARCH+=("$HOME/Library")

INSTALLED_FOUND=false
for dir in "${INSTALL_SEARCH[@]}"; do
    [[ -d "$dir" ]] || continue
    results=$(run_find "$dir" -path "*/site-packages/litellm*" -type d)
    if [[ -n "$results" ]]; then
        while IFS= read -r f; do
            fail "litellm package directory found: $f"
            INSTALLED_FOUND=true
        done <<< "$results"
    fi
done
$INSTALLED_FOUND || pass "No litellm package directory found in site-packages"


# =============================================================================
header "5. Persistence Mechanisms"
# =============================================================================

if $IS_MAC; then
    info "Checking macOS LaunchAgents / LaunchDaemons..."

    for dir in "$HOME/Library/LaunchAgents" "/Library/LaunchAgents" "/Library/LaunchDaemons"; do
        [[ -d "$dir" ]] || continue
        matches=$(ls "$dir" 2>/dev/null | grep -i "sysmon\|litellm" || true)
        if [[ -n "$matches" ]]; then
            fail "Suspicious LaunchAgent/Daemon in $dir: $matches"
        else
            pass "No suspicious entries in $dir"
        fi
    done

    # Running launchctl services (excluding Apple/common vendors)
    info "Scanning active launchctl services for anomalies..."
    suspicious=$(launchctl list 2>/dev/null \
        | grep -v "com\.apple\|com\.google\|com\.adobe\|homebrew\|org\.cups\|com\.openssh\|PID" \
        | grep -v "com\.microsoft\|com\.dropbox\|com\.jetbrains" \
        | awk '{print $3}' | grep -v "^-$" || true)
    if [[ -n "$suspicious" ]]; then
        warn "Unusual launchctl services (review manually):"
        echo "$suspicious" | while IFS= read -r s; do info "  $s"; done
    else
        pass "No obviously suspicious launchctl services"
    fi
fi

if $IS_LINUX; then
    info "Checking systemd user services..."
    suspicious=$(systemctl list-units --type=service --no-pager 2>/dev/null \
        | grep -i "sysmon\|litellm" || true)
    if [[ -n "$suspicious" ]]; then
        fail "Suspicious systemd service found: $suspicious"
    else
        pass "No suspicious systemd services found"
    fi

    # Cron
    info "Checking crontab..."
    cron_content=$(crontab -l 2>/dev/null || true)
    if echo "$cron_content" | grep -qi "litellm\|sysmon"; then
        fail "Suspicious cron entry detected"
    else
        pass "No suspicious cron entries"
    fi
fi


# =============================================================================
header "6. Network — Exfiltration Endpoint Check"
# =============================================================================

EXFIL_DOMAINS=("models.litellm.cloud" "scan.aquasecurtiy.org" "checkmarx.zone")

if $IS_MAC; then
    info "Checking DNS cache..."
    for domain in "${EXFIL_DOMAINS[@]}"; do
        if dscacheutil -cachedump -entries Host 2>/dev/null | grep -q "$domain"; then
            fail "Exfiltration domain in DNS cache: $domain"
        else
            pass "DNS cache clean: $domain"
        fi
    done
fi

if $IS_LINUX; then
    info "Checking /etc/hosts and nscd cache..."
    for domain in "${EXFIL_DOMAINS[@]}"; do
        if grep -q "$domain" /etc/hosts 2>/dev/null; then
            warn "Domain found in /etc/hosts: $domain"
        else
            pass "/etc/hosts clean: $domain"
        fi
    done
fi

# Live outbound connections
info "Checking live outbound connections..."
if $IS_MAC; then
    live=$(lsof -i 2>/dev/null \
        | grep -v LISTEN \
        | grep -iv "apple\|google\|icloud\|amazon\|akamai\|cloudflare\|localhost\|127\.0\.0" \
        || true)
else
    live=$(ss -tnp 2>/dev/null | grep -v LISTEN | grep -v "127\.0\.0\|::1" || true)
fi

if [[ -n "$live" ]]; then
    warn "Active outbound connections found (review manually):"
    echo "$live" | while IFS= read -r l; do info "$l"; done
else
    pass "No unexpected live outbound connections"
fi

# System log check (macOS only, scoped to attack date)
if $IS_MAC; then
    info "Scanning system log for exfiltration domains (March 24 only — may take a moment)..."
    log_hits=$(log show \
        --predicate 'eventMessage contains "litellm.cloud" OR eventMessage contains "aquasecurtiy.org"' \
        --start "2026-03-24 00:00:00" \
        --end "2026-03-24 23:59:59" \
        2>/dev/null | grep -v "^Filtering\|^Skipping" || true)
    if [[ -n "$log_hits" ]]; then
        fail "System log contains exfiltration domain references on March 24!"
        echo "$log_hits"
    else
        pass "System log clean for March 24 (no exfiltration domains)"
    fi
fi


# =============================================================================
header "7. Project Dependency Files"
# =============================================================================

info "Scanning requirements.txt files..."
req_hits=$(run_find "$HOME/Projects" -name "requirements*.txt" \
    | xargs -r grep -l "litellm" 2>/dev/null || true)
if [[ -n "$req_hits" ]]; then
    warn "litellm referenced in requirements file(s):"
    echo "$req_hits" | while IFS= read -r f; do info "$f"; done
else
    pass "No requirements.txt files reference litellm"
fi

info "Scanning pyproject.toml files..."
pyproject_hits=$(run_find "$HOME/Projects" -name "pyproject.toml" \
    | xargs -r grep -l "litellm" 2>/dev/null || true)
if [[ -n "$pyproject_hits" ]]; then
    warn "litellm referenced in pyproject.toml:"
    echo "$pyproject_hits" | while IFS= read -r f; do info "$f"; done
else
    pass "No pyproject.toml files reference litellm"
fi

info "Scanning package.json files..."
pkg_hits=$(run_find "$HOME/Projects" -name "package.json" \
    -not -path "*/node_modules/*" \
    | xargs -r grep -l "litellm" 2>/dev/null || true)
if [[ -n "$pkg_hits" ]]; then
    warn "litellm referenced in package.json:"
    echo "$pkg_hits" | while IFS= read -r f; do info "$f"; done
else
    pass "No package.json files reference litellm"
fi


# =============================================================================
header "8. PyCharm Configuration"
# =============================================================================

JBDIR=""
$IS_MAC  && JBDIR="$HOME/Library/Application Support/JetBrains"
$IS_LINUX && JBDIR="$HOME/.config/JetBrains"

if [[ -d "$JBDIR" ]]; then
    info "Scanning JetBrains config directory..."
    jb_pth=$(run_find "$JBDIR" -name "litellm_init.pth")
    if [[ -n "$jb_pth" ]]; then
        fail "Malicious .pth found in JetBrains config: $jb_pth"
    else
        pass "No malicious .pth in JetBrains config"
    fi

    jb_ref=$(run_find "$JBDIR" -type f -name "*.xml" \
        | xargs -r grep -l "litellm" 2>/dev/null || true)
    if [[ -n "$jb_ref" ]]; then
        warn "litellm referenced in JetBrains XML config:"
        echo "$jb_ref" | while IFS= read -r f; do info "$f"; done
    else
        pass "No litellm references in JetBrains XML config"
    fi
else
    info "JetBrains config directory not found — skipping"
fi


# =============================================================================
header "9. Warp Terminal"
# =============================================================================

WARP_DIRS=("$HOME/.warp")
$IS_MAC && WARP_DIRS+=("$HOME/Library/Application Support/dev.warp.Warp-Stable")

WARP_FOUND=false
for dir in "${WARP_DIRS[@]}"; do
    [[ -d "$dir" ]] || continue
    results=$(run_find "$dir" \( -name "litellm*" -o -name "*.pth" \) | grep -v ".pyc" || true)
    if [[ -n "$results" ]]; then
        warn "Suspicious files in Warp directory ($dir):"
        echo "$results" | while IFS= read -r f; do info "$f"; done
        WARP_FOUND=true
    fi
    ref=$(run_find "$dir" -type f \( -name "*.json" -o -name "*.yaml" -o -name "*.toml" -o -name "*.txt" \) \
        | xargs -r grep -l "litellm" 2>/dev/null || true)
    if [[ -n "$ref" ]]; then
        warn "litellm reference in Warp config: $ref"
        WARP_FOUND=true
    fi
done
$WARP_FOUND || pass "No litellm references found in Warp directories"


# =============================================================================
header "10. Conda / Miniforge / Anaconda Environments"
# =============================================================================

CONDA_ROOTS=(
    "$HOME/miniforge3"
    "$HOME/mambaforge"
    "$HOME/opt/anaconda3"
    "$HOME/opt/miniconda3"
    "$HOME/anaconda3"
    "$HOME/miniconda3"
    "/opt/conda"
    "/opt/anaconda3"
)

CONDA_CHECKED=false
for root in "${CONDA_ROOTS[@]}"; do
    [[ -d "$root" ]] || continue
    CONDA_CHECKED=true
    info "Scanning conda root: $root"
    results=$(run_find "$root" -name "litellm_init.pth")
    if [[ -n "$results" ]]; then
        fail "Malicious .pth in conda env: $results"
    else
        pass "No malicious .pth in $root"
    fi

    installed=$(run_find "$root" -path "*/site-packages/litellm*" -type d)
    if [[ -n "$installed" ]]; then
        fail "litellm installed in conda env: $installed"
    else
        pass "litellm not installed in $root"
    fi
done
$CONDA_CHECKED || info "No conda/miniforge installation found — skipping"


# =============================================================================
header "11. GitHub Actions / CI — docs-tpcp Repo Indicator"
# =============================================================================

info "Checking for docs-tpcp directory (attacker-created GitHub repo indicator)..."
tpcp=$(run_find "$HOME" -maxdepth 4 -type d -name "docs-tpcp" 2>/dev/null || true)
if [[ -n "$tpcp" ]]; then
    fail "docs-tpcp directory found — possible attacker GitHub repo cloned: $tpcp"
else
    pass "No docs-tpcp directory found"
fi

# Check git configs/remotes for the exfil domain
info "Scanning git remotes for exfiltration domains..."
git_hits=$(run_find "$HOME/Projects" -name "config" -path "*/.git/config" \
    | xargs -r grep -l "litellm\.cloud\|aquasecurtiy" 2>/dev/null || true)
if [[ -n "$git_hits" ]]; then
    fail "Suspicious git remote found in: $git_hits"
else
    pass "No suspicious git remotes"
fi


# =============================================================================
#  SUMMARY
# =============================================================================

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║                      SUMMARY                        ║${RESET}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  ${GREEN}Passed:${RESET}  $CHECKS_PASSED checks"
echo -e "  ${YELLOW}Warned:${RESET}  $CHECKS_WARNED checks (review recommended)"
echo -e "  ${RED}Failed:${RESET}  $CHECKS_FAILED checks"
echo ""

if [[ ${#FINDINGS[@]} -gt 0 ]]; then
    echo -e "${RED}${BOLD}  ✘ CRITICAL FINDINGS — YOU MAY BE COMPROMISED:${RESET}"
    for f in "${FINDINGS[@]}"; do
        echo -e "    ${RED}•  $f${RESET}"
    done
    echo ""
    echo -e "${RED}${BOLD}  Recommended actions:${RESET}"
    echo -e "    1. Rotate ALL credentials: SSH keys, cloud tokens, API keys, .env secrets"
    echo -e "    2. Check for and remove systemd/LaunchAgent persistence"
    echo -e "    3. Audit network logs for traffic to models.litellm.cloud"
    echo -e "    4. Consider rebuilding affected environments from a clean state"
    echo -e "    5. Review: https://docs.litellm.ai/blog/security-update-march-2026"
elif [[ ${#WARNINGS[@]} -gt 0 ]]; then
    echo -e "${YELLOW}${BOLD}  ⚠ WARNINGS — Manual review recommended:${RESET}"
    for w in "${WARNINGS[@]}"; do
        echo -e "    ${YELLOW}•  $w${RESET}"
    done
    echo ""
    echo -e "${GREEN}${BOLD}  No critical findings. Likely not compromised, but review warnings above.${RESET}"
else
    echo -e "${GREEN}${BOLD}  ✔ ALL CLEAR — No indicators of litellm compromise found.${RESET}"
    echo ""
    echo -e "  ${DIM}litellm does not appear to be installed, referenced, or"
    echo -e "  active in any environment on this machine. No persistence"
    echo -e "  mechanisms, exfiltration traffic, or malicious files detected.${RESET}"
fi

echo ""
echo -e "  ${DIM}CVE: CVE-2026-33634  |  Affected versions: 1.82.7 and 1.82.8"
echo -e "  Exposure window: March 24 2026, 10:39–16:00 UTC${RESET}"
echo ""
