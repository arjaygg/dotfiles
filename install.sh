#!/usr/bin/env bash
# Main installation script for hybrid dotfiles
# Supports both Nix and traditional installation methods

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${PURPLE}[STEP]${NC} $1"; }

# Help message
show_help() {
    cat << EOF
🏠 Hybrid Dotfiles Installation Script

USAGE:
    ./install.sh [OPTIONS]

OPTIONS:
    -m, --method METHOD     Installation method: 'nix', 'traditional', or 'auto'
    -f, --force            Force installation (overwrite existing configs)
    -d, --dry-run          Show what would be done without executing
    -q, --quiet            Suppress non-essential output
    -h, --help             Show this help message

METHODS:
    nix                    Use Nix + Home Manager for package and config management
    traditional            Use system package managers and manual config management
    auto                   Automatically detect and recommend the best method

EXAMPLES:
    ./install.sh                           # Auto-detect and install
    ./install.sh --method nix              # Force Nix installation
    ./install.sh --method traditional      # Force traditional installation
    ./install.sh --dry-run                 # Preview what would be installed
    ./install.sh --force --method nix      # Force reinstall with Nix

For more information, see: https://github.com/yourusername/dotfiles
EOF
}

# Parse command line arguments
parse_args() {
    METHOD="auto"
    FORCE=false
    DRY_RUN=false
    QUIET=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -m|--method)
                METHOD="$2"
                shift 2
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -q|--quiet)
                QUIET=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Validate method
    if [[ ! "$METHOD" =~ ^(nix|traditional|auto)$ ]]; then
        log_error "Invalid method: $METHOD. Must be 'nix', 'traditional', or 'auto'"
        exit 1
    fi
}

# Check prerequisites
check_prerequisites() {
    log_step "Checking prerequisites..."
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "This script must be run from within the dotfiles git repository"
        exit 1
    fi
    
    # Check for required scripts
    local required_scripts=("scripts/detect-env.sh")
    for script in "${required_scripts[@]}"; do
        if [[ ! -f "$script" ]]; then
            log_error "Required script not found: $script"
            exit 1
        fi
        
        if [[ ! -x "$script" ]]; then
            log_warn "Making $script executable..."
            chmod +x "$script"
        fi
    done
    
    log_success "Prerequisites check passed"
}

# Detect environment and determine installation method
detect_and_decide() {
    log_step "Detecting environment..."
    
    # Source the detection script and export variables
    if ! source scripts/detect-env.sh --export 2>/dev/null; then
        log_error "Failed to run environment detection"
        exit 1
    fi
    
    if [[ "$METHOD" == "auto" ]]; then
        if [[ -n "${DOTFILES_RECOMMENDED_METHOD:-}" ]]; then
            METHOD="$DOTFILES_RECOMMENDED_METHOD"
            log_info "Auto-detected method: $METHOD"
            log_info "Reason: Based on available package managers and system configuration"
        else
            log_warn "Could not auto-detect method, defaulting to traditional"
            METHOD="traditional"
        fi
    else
        log_info "Using specified method: $METHOD"
    fi
}

# Prompt for user information
prompt_user_info() {
    if [[ "$QUIET" == "true" ]]; then
        return 0
    fi
    
    echo
    log_step "Gathering user information..."
    
    # Git user name
    if [[ -z "${GIT_USER_NAME:-}" ]]; then
        read -p "Enter your full name for Git: " GIT_USER_NAME
    fi
    
    # Git user email
    if [[ -z "${GIT_USER_EMAIL:-}" ]]; then
        read -p "Enter your email for Git: " GIT_USER_EMAIL
    fi
    
    export GIT_USER_NAME GIT_USER_EMAIL
}

# Install using Nix method
install_nix() {
    log_step "Installing with Nix method..."
    
    # Check if Nix is installed
    if ! command -v nix >/dev/null 2>&1; then
        log_warn "Nix not found. Installing Nix..."
        if [[ "$DRY_RUN" == "false" ]]; then
            curl -L https://nixos.org/nix/install | sh -s -- --daemon
            source /etc/profile
        else
            log_info "[DRY-RUN] Would install Nix package manager"
        fi
    fi
    
    # Check if home-manager is available
    if ! command -v home-manager >/dev/null 2>&1; then
        log_warn "Home Manager not found. Installing..."
        if [[ "$DRY_RUN" == "false" ]]; then
            nix run home-manager/master -- init --switch
        else
            log_info "[DRY-RUN] Would install Home Manager"
        fi
    fi
    
    # Apply home-manager configuration
    log_info "Applying Home Manager configuration..."
    if [[ "$DRY_RUN" == "false" ]]; then
        nix run home-manager/master -- switch --flake .#$(whoami) -b backup
    else
        log_info "[DRY-RUN] Would apply: nix run home-manager/master -- switch --flake .#$(whoami)"
    fi
    
    log_success "Nix installation completed"
}

# Install using traditional method
install_traditional() {
    log_step "Installing with traditional method..."
    
    # Create traditional directories if they don't exist
    mkdir -p traditional/{installers,symlinks}
    
    # Install packages based on detected package managers
    if [[ " ${DOTFILES_PACKAGE_MANAGERS:-} " =~ " brew " ]]; then
        log_info "Installing packages with Homebrew..."
        if [[ "$DRY_RUN" == "false" ]]; then
            scripts/install-traditional.sh --brew
        else
            log_info "[DRY-RUN] Would install packages via Homebrew"
        fi
    elif [[ " ${DOTFILES_PACKAGE_MANAGERS:-} " =~ " apt " ]]; then
        log_info "Installing packages with APT..."
        if [[ "$DRY_RUN" == "false" ]]; then
            scripts/install-traditional.sh --apt
        else
            log_info "[DRY-RUN] Would install packages via APT"
        fi
    fi
    
    # Create symlinks for configurations
    log_info "Creating configuration symlinks..."
    if [[ "$DRY_RUN" == "false" ]]; then
        scripts/create-symlinks.sh
    else
        log_info "[DRY-RUN] Would create symlinks for configurations"
    fi
    
    log_success "Traditional installation completed"
}

# Main installation logic
main() {
    echo -e "${PURPLE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                   🏠 HYBRID DOTFILES                         ║
║                                                              ║
║  Supports both Nix and traditional installation methods     ║
╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    parse_args "$@"
    check_prerequisites
    detect_and_decide
    prompt_user_info
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warn "DRY RUN MODE - No changes will be made"
        echo
    fi
    
    case "$METHOD" in
        nix)
            install_nix
            ;;
        traditional)
            install_traditional
            ;;
        *)
            log_error "Unknown installation method: $METHOD"
            exit 1
            ;;
    esac
    
    echo
    log_success "🎉 Dotfiles installation completed successfully!"
    log_info "Method used: $METHOD"
    
    if [[ "$DRY_RUN" == "false" ]]; then
        log_info "Please restart your shell or run: source ~/.bashrc (or equivalent)"
        
        # Show next steps
        echo
        log_step "Next steps:"
        echo "  1. Restart your terminal or reload your shell configuration"
        echo "  2. Verify tools are working: git --version, nvim --version, etc."
        if [[ "$METHOD" == "nix" ]]; then
            echo "  3. Customize Nix configuration in modules/ directory"
        else
            echo "  3. Customize configurations in config/ directory"
        fi
        echo "  4. Enjoy your new development environment! 🚀"
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi