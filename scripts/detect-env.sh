#!/usr/bin/env bash
# Environment detection script for hybrid dotfiles
# Detects OS, package managers, and existing tools

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v lsb_release >/dev/null 2>&1; then
            OS=$(lsb_release -si)
            OS_VERSION=$(lsb_release -sr)
        elif [[ -f /etc/os-release ]]; then
            . /etc/os-release
            OS=$NAME
            OS_VERSION=$VERSION_ID
        else
            OS="Linux"
            OS_VERSION="Unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macOS"
        OS_VERSION=$(sw_vers -productVersion)
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        OS="Cygwin"
        OS_VERSION="Unknown"
    elif [[ "$OSTYPE" == "msys" ]]; then
        OS="MSYS"
        OS_VERSION="Unknown"
    else
        OS="Unknown"
        OS_VERSION="Unknown"
    fi
}

# Detect available package managers
detect_package_managers() {
    PACKAGE_MANAGERS=()
    
    if command -v nix >/dev/null 2>&1; then
        PACKAGE_MANAGERS+=("nix")
        NIX_VERSION=$(nix --version | cut -d' ' -f3)
    fi
    
    if command -v brew >/dev/null 2>&1; then
        PACKAGE_MANAGERS+=("brew")
        BREW_VERSION=$(brew --version | head -n1 | cut -d' ' -f2)
    fi
    
    if command -v apt >/dev/null 2>&1; then
        PACKAGE_MANAGERS+=("apt")
    fi
    
    if command -v pacman >/dev/null 2>&1; then
        PACKAGE_MANAGERS+=("pacman")
    fi
    
    if command -v dnf >/dev/null 2>&1; then
        PACKAGE_MANAGERS+=("dnf")
    fi
    
    if command -v zypper >/dev/null 2>&1; then
        PACKAGE_MANAGERS+=("zypper")
    fi
}

# Detect available shells and recommend default
detect_shells() {
    AVAILABLE_SHELLS=()
    
    # Check for available shells
    for shell in fish zsh bash; do
        if command -v "$shell" >/dev/null 2>&1; then
            AVAILABLE_SHELLS+=("$shell")
        fi
    done
    
    # Determine recommended shell (Fish preferred, fallback to Bash)
    if [[ " ${AVAILABLE_SHELLS[*]} " =~ " fish " ]]; then
        RECOMMENDED_SHELL="fish"
        SHELL_REASON="Fish is available and provides modern shell features"
    elif [[ " ${AVAILABLE_SHELLS[*]} " =~ " zsh " ]]; then
        RECOMMENDED_SHELL="zsh"
        SHELL_REASON="Zsh is available and offers good compatibility"
    elif [[ " ${AVAILABLE_SHELLS[*]} " =~ " bash " ]]; then
        RECOMMENDED_SHELL="bash"
        SHELL_REASON="Bash is the most universally available shell"
    else
        RECOMMENDED_SHELL="bash"
        SHELL_REASON="Bash fallback (will be installed if needed)"
    fi
    
    # Check if Fish can be installed in this environment
    FISH_INSTALLABLE="true"
    case "$OS" in
        "Ubuntu"|"Debian")
            if ! command -v apt >/dev/null 2>&1; then
                FISH_INSTALLABLE="false"
            fi
            ;;
        "macOS")
            if ! command -v brew >/dev/null 2>&1; then
                FISH_INSTALLABLE="false"
            fi
            ;;
        "Arch Linux")
            if ! command -v pacman >/dev/null 2>&1; then
                FISH_INSTALLABLE="false"
            fi
            ;;
        *)
            # For unknown systems, assume Fish might not be easily installable
            if [[ ! " ${PACKAGE_MANAGERS[*]} " =~ " nix " ]]; then
                FISH_INSTALLABLE="false"
            fi
            ;;
    esac
}

# Detect existing tools
detect_existing_tools() {
    EXISTING_TOOLS=()
    
    # Essential tools
    for tool in git curl wget fish bash zsh tmux nvim vim; do
        if command -v "$tool" >/dev/null 2>&1; then
            EXISTING_TOOLS+=("$tool")
        fi
    done
    
    # Development tools
    for tool in node npm yarn go rust cargo python pip; do
        if command -v "$tool" >/dev/null 2>&1; then
            EXISTING_TOOLS+=("$tool")
        fi
    done
    
    # Modern CLI tools
    for tool in bat exa fd rg fzf starship; do
        if command -v "$tool" >/dev/null 2>&1; then
            EXISTING_TOOLS+=("$tool")
        fi
    done
}

# Check for home-manager
detect_home_manager() {
    if command -v home-manager >/dev/null 2>&1; then
        HOME_MANAGER_AVAILABLE="true"
        HOME_MANAGER_VERSION=$(home-manager --version | cut -d' ' -f2)
    else
        HOME_MANAGER_AVAILABLE="false"
    fi
}

# Recommend installation method
recommend_method() {
    if [[ " ${PACKAGE_MANAGERS[*]} " =~ " nix " ]]; then
        RECOMMENDED_METHOD="nix"
        RECOMMENDATION_REASON="Nix is already installed and provides reproducible environments"
    elif [[ "$OS" == "macOS" && " ${PACKAGE_MANAGERS[*]} " =~ " brew " ]]; then
        RECOMMENDED_METHOD="traditional"
        RECOMMENDATION_REASON="Homebrew is the standard package manager for macOS"
    elif [[ " ${PACKAGE_MANAGERS[*]} " =~ " apt " ]]; then
        RECOMMENDED_METHOD="traditional"
        RECOMMENDATION_REASON="APT is available and well-supported"
    else
        RECOMMENDED_METHOD="nix"
        RECOMMENDATION_REASON="Nix provides the most consistent cross-platform experience"
    fi
}

# Generate environment report
generate_report() {
    cat << EOF

═══════════════════════════════════════
🖥️  DOTFILES ENVIRONMENT DETECTION
═══════════════════════════════════════

📋 SYSTEM INFORMATION:
   OS: $OS $OS_VERSION
   Architecture: $(uname -m)
   Current Shell: $SHELL
   Home: $HOME

📦 PACKAGE MANAGERS:
$(printf '   %s\n' "${PACKAGE_MANAGERS[@]}")
$(if [[ " ${PACKAGE_MANAGERS[*]} " =~ " nix " ]]; then echo "   Nix version: $NIX_VERSION"; fi)
$(if [[ " ${PACKAGE_MANAGERS[*]} " =~ " brew " ]]; then echo "   Homebrew version: $BREW_VERSION"; fi)

🐚 SHELL ENVIRONMENT:
   Available Shells: ${AVAILABLE_SHELLS[*]:-none}
   Recommended Shell: $RECOMMENDED_SHELL
   Fish Installable: $FISH_INSTALLABLE
   Reason: $SHELL_REASON

🛠️  EXISTING TOOLS ($(echo "${EXISTING_TOOLS[@]}" | wc -w) found):
$(printf '   %s\n' "${EXISTING_TOOLS[@]}")

🏠 HOME-MANAGER:
   Available: $HOME_MANAGER_AVAILABLE
$(if [[ "$HOME_MANAGER_AVAILABLE" == "true" ]]; then echo "   Version: $HOME_MANAGER_VERSION"; fi)

💡 RECOMMENDATION:
   Method: $RECOMMENDED_METHOD
   Reason: $RECOMMENDATION_REASON

═══════════════════════════════════════

EOF
}

# Export environment variables for other scripts
export_env_vars() {
    export DOTFILES_OS="$OS"
    export DOTFILES_OS_VERSION="$OS_VERSION"
    export DOTFILES_PACKAGE_MANAGERS="${PACKAGE_MANAGERS[*]:-}"
    export DOTFILES_EXISTING_TOOLS="${EXISTING_TOOLS[*]:-}"
    export DOTFILES_HOME_MANAGER="$HOME_MANAGER_AVAILABLE"
    export DOTFILES_RECOMMENDED_METHOD="$RECOMMENDED_METHOD"
    export DOTFILES_AVAILABLE_SHELLS="${AVAILABLE_SHELLS[*]:-}"
    export DOTFILES_RECOMMENDED_SHELL="$RECOMMENDED_SHELL"
    export DOTFILES_FISH_INSTALLABLE="$FISH_INSTALLABLE"
    export DOTFILES_SHELL_REASON="$SHELL_REASON"
}

# Main execution
main() {
    log_info "Detecting environment..."
    
    detect_os
    detect_package_managers
    detect_shells
    detect_existing_tools
    detect_home_manager
    recommend_method
    
    if [[ "${1:-}" == "--export" ]]; then
        export_env_vars
        log_success "Environment variables exported"
    else
        generate_report
    fi
}

# Only run if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi