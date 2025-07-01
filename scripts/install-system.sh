#!/usr/bin/env bash
# System installation script for dotfiles
# Installs packages using system package managers

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Claude CLI installation function
install_claude_cli() {
    if command -v claude >/dev/null 2>&1; then
        log_info "Claude CLI already installed"
        return 0
    fi

    log_info "Installing Claude CLI..."
    
    # Try official installer first
    if curl -fsSL https://claude.ai/cli/install.sh | sh; then
        log_success "Claude CLI installed via official installer"
        return 0
    fi
    
    # Fallback: Try npm if available
    if command -v npm >/dev/null 2>&1; then
        if npm install -g @anthropic-ai/claude-cli 2>/dev/null; then
            log_success "Claude CLI installed via npm"
            return 0
        fi
    fi
    
    # Create local bin if needed and try direct download
    mkdir -p "$HOME/.local/bin"
    
    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
        
        # Add to shell profile for persistence
        local shell_rc=""
        if [[ -n "${BASH_VERSION:-}" ]]; then
            shell_rc="$HOME/.bashrc"
        elif [[ -n "${ZSH_VERSION:-}" ]]; then
            shell_rc="$HOME/.zshrc"
        fi
        
        if [[ -n "$shell_rc" ]] && [[ -f "$shell_rc" ]]; then
            if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$shell_rc"; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$shell_rc"
            fi
        fi
    fi
    
    log_warn "Could not install Claude CLI automatically. Please install manually:"
    log_warn "curl -fsSL https://claude.ai/cli/install.sh | sh"
}

# Package lists
ESSENTIAL_PACKAGES=(
    "git"
    "curl"
    "wget"
    "vim"
    "tmux"
    "fish"
    "bash"
)

DEVELOPMENT_PACKAGES=(
    "nodejs"
    "npm"
    "python3"
    "pip3"
    "golang"
    "rustc"
    "cargo"
)

MODERN_CLI_PACKAGES=(
    "bat"
    "eza"
    "fd-find"
    "ripgrep"
    "fzf"
    "starship"
    "delta"
    "gh"
    "lazygit"
    "atuin"
    "broot"
    "zoxide"
    "dust"
    "procs"
    "hyperfine"
    "tokei"
    "bandwhich"
    "bottom"
    "grex"
    "sd"
    "choose"
)

OPTIONAL_PACKAGES=(
    "neovim"
    "zsh"
    "htop"
    "tree"
    "jq"
    "yq"
    "kubectl"
)

# Install packages with Homebrew (macOS)
install_with_brew() {
    log_info "Installing packages with Homebrew..."
    
    # Update Homebrew
    brew update
    
    # Essential packages
    log_info "Installing essential packages..."
    for package in "${ESSENTIAL_PACKAGES[@]}"; do
        if ! brew list "$package" &>/dev/null; then
            brew install "$package"
        else
            log_info "$package already installed"
        fi
    done
    
    # Development packages
    log_info "Installing development packages..."
    for package in "${DEVELOPMENT_PACKAGES[@]}"; do
        case "$package" in
            "nodejs"|"npm")
                if ! brew list "node" &>/dev/null; then
                    brew install "node"
                fi
                ;;
            "python3"|"pip3")
                if ! brew list "python" &>/dev/null; then
                    brew install "python"
                fi
                ;;
            "golang")
                if ! brew list "go" &>/dev/null; then
                    brew install "go"
                fi
                ;;
            "rustc"|"cargo")
                if ! brew list "rust" &>/dev/null; then
                    brew install "rust"
                fi
                ;;
        esac
    done
    
    # Modern CLI tools
    log_info "Installing modern CLI tools..."
    for package in "${MODERN_CLI_PACKAGES[@]}"; do
        case "$package" in
            "fd-find")
                if ! brew list "fd" &>/dev/null; then
                    brew install "fd"
                fi
                ;;
            "git-delta"|"delta")
                if ! brew list "git-delta" &>/dev/null; then
                    brew install "git-delta"
                fi
                ;;
            *)
                if ! brew list "$package" &>/dev/null; then
                    brew install "$package" || log_warn "Failed to install $package via brew"
                fi
                ;;
        esac
    done
    
    # Optional packages
    log_info "Installing optional packages..."
    brew install neovim zsh htop tree jq yq kubectl
    
    # Install Claude CLI
    install_claude_cli
    
    # Install Fisher for Fish shell if available
    if command -v fish >/dev/null 2>&1; then
        log_info "Installing Fisher plugin manager for Fish..."
        fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher" 2>/dev/null || log_warn "Fisher installation failed - can be installed manually later"
        
        # Use fisher update to install from fish_plugins file
        log_info "Installing Fish plugins from fish_plugins file..."
        fish -c "fisher update" 2>/dev/null || log_warn "Fish plugin installation failed - can be installed manually later"
    fi
    
    log_success "Homebrew installation completed"
}

# Clean up broken APT state
cleanup_apt_state() {
    log_info "Cleaning up APT package state..."
    
    # Fix broken packages
    sudo apt --fix-broken install -y 2>/dev/null || true
    
    # Configure pending packages
    sudo dpkg --configure -a 2>/dev/null || true
    
    # Clean package cache
    sudo apt clean
    
    # Remove unused packages
    sudo apt autoremove -y 2>/dev/null || true
    
    # Update package lists
    sudo apt update
}

# Setup modern tool repositories for APT
setup_modern_repositories() {
    log_info "Setting up modern tool repositories..."
    
    # Ensure software-properties-common is installed for add-apt-repository
    sudo apt install -y software-properties-common
    
    # Fish Shell PPA - for latest Fish shell v4.x
    if ! grep -q "fish-shell/release-4" /etc/apt/sources.list.d/* 2>/dev/null; then
        log_info "Adding Fish shell v4.x PPA..."
        sudo add-apt-repository -y ppa:fish-shell/release-4
    fi
    
    # Neovim PPA - for latest stable Neovim
    if ! grep -q "neovim-ppa/stable" /etc/apt/sources.list.d/* 2>/dev/null; then
        log_info "Adding Neovim stable PPA..."
        sudo add-apt-repository -y ppa:neovim-ppa/stable
    fi
    
    # Git PPA - for latest Git (especially important on older Ubuntu)
    if ! grep -q "git-core/ppa" /etc/apt/sources.list.d/* 2>/dev/null; then
        log_info "Adding Git PPA for latest version..."
        sudo add-apt-repository -y ppa:git-core/ppa
    fi
    
    # NodeSource repository - for latest Node.js and npm
    if ! command -v node >/dev/null 2>&1 && ! grep -q "deb.nodesource.com" /etc/apt/sources.list.d/* 2>/dev/null; then
        log_info "Adding NodeSource repository for latest Node.js..."
        # Remove any conflicting packages first
        sudo apt remove -y nodejs npm 2>/dev/null || true
        sudo apt autoremove -y 2>/dev/null || true
        
        # Add NodeSource repository
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    fi
    
    # GitHub CLI repository - for latest gh
    if ! command -v gh >/dev/null 2>&1 && ! grep -q "cli.github.com" /etc/apt/sources.list.d/* 2>/dev/null; then
        log_info "Adding GitHub CLI repository..."
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    fi
    
    # Update package lists after adding repositories
    sudo apt update
}

# Install packages with APT (Ubuntu/Debian)
install_with_apt() {
    log_info "Installing packages with APT..."
    
    # Clean up any existing issues first
    cleanup_apt_state
    
    # Setup modern repositories for latest versions
    setup_modern_repositories
    
    # Essential packages
    log_info "Installing essential packages..."
    sudo apt install -y git curl wget vim tmux fish bash
    
    # Development packages
    log_info "Installing development packages..."
    
    # Clean up any broken package state first
    sudo apt --fix-broken install -y 2>/dev/null || true
    sudo dpkg --configure -a 2>/dev/null || true
    
    # Install Node.js and npm (repository already set up in setup_modern_repositories)
    if ! command -v node >/dev/null 2>&1; then
        log_info "Installing Node.js and npm..."
        sudo apt install -y nodejs
    else
        log_info "Node.js and npm already installed"
    fi
    
    sudo apt install -y python3 python3-pip
    
    # Install Go manually (APT version is often outdated)
    if ! command -v go >/dev/null 2>&1; then
        log_info "Installing Go..."
        GO_VERSION="1.21.0"
        wget "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
        sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
        rm "go${GO_VERSION}.linux-amd64.tar.gz"
    fi
    
    # Install Rust via rustup
    if ! command -v rustc >/dev/null 2>&1; then
        log_info "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi
    
    # Modern CLI tools (some need to be installed manually)
    log_info "Installing modern CLI tools..."
    
    # bat (prefer newer version from GitHub releases if Ubuntu version is too old)
    if ! command -v bat >/dev/null 2>&1; then
        # Check Ubuntu version - if it's 20.04 or older, install from GitHub releases
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            if [[ "$VERSION_ID" < "22.04" ]]; then
                log_info "Installing bat from GitHub releases for newer version..."
                BAT_VERSION=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
                wget "https://github.com/sharkdp/bat/releases/download/${BAT_VERSION}/bat_${BAT_VERSION#v}_amd64.deb"
                sudo dpkg -i "bat_${BAT_VERSION#v}_amd64.deb"
                rm "bat_${BAT_VERSION#v}_amd64.deb"
            else
                sudo apt install -y bat
            fi
        else
            sudo apt install -y bat
        fi
        
        # Create symlink if installed as batcat
        if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
            mkdir -p ~/.local/bin
            ln -sf /usr/bin/batcat ~/.local/bin/bat
        fi
    fi
    
    # eza
    if ! command -v eza >/dev/null 2>&1; then
        # eza is not in standard Ubuntu repos, install from GitHub releases
        EZA_VERSION=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
        wget "https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz"
        tar -xzf eza_x86_64-unknown-linux-gnu.tar.gz
        sudo mv eza /usr/local/bin/
        rm eza_x86_64-unknown-linux-gnu.tar.gz
    fi
    
    # fd
    if ! command -v fd >/dev/null 2>&1; then
        sudo apt install -y fd-find
        # Create symlink
        mkdir -p ~/.local/bin
        ln -sf /usr/bin/fdfind ~/.local/bin/fd
    fi
    
    # ripgrep
    if ! command -v rg >/dev/null 2>&1; then
        sudo apt install -y ripgrep
    fi
    
    # fzf
    if ! command -v fzf >/dev/null 2>&1; then
        sudo apt install -y fzf
    fi
    
    # starship (install via script)
    if ! command -v starship >/dev/null 2>&1; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
    
    # gh (GitHub CLI) - repository already set up in setup_modern_repositories
    if ! command -v gh >/dev/null 2>&1; then
        sudo apt install -y gh
    fi
    
    # lazygit
    if ! command -v lazygit >/dev/null 2>&1; then
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name"' | sed -E 's/.*"v*([^"]+)".*/\1/')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit.tar.gz lazygit
    fi
    
    # atuin (install via cargo)
    if ! command -v atuin >/dev/null 2>&1; then
        if command -v cargo >/dev/null 2>&1; then
            cargo install atuin
        else
            log_warn "Cargo not found. Install Rust first to install atuin."
        fi
    fi
    
    # Optional packages (repositories already set up in setup_modern_repositories)
    log_info "Installing optional packages..."
    sudo apt install -y neovim zsh htop tree jq
    
    # yq (install manually)
    if ! command -v yq >/dev/null 2>&1; then
        sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
        sudo chmod +x /usr/local/bin/yq
    fi
    
    # kubectl
    if ! command -v kubectl >/dev/null 2>&1; then
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
    fi
    
    # Install Claude CLI
    install_claude_cli
    
    # Install Fisher for Fish shell if available
    if command -v fish >/dev/null 2>&1; then
        log_info "Installing Fisher plugin manager for Fish..."
        fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher" 2>/dev/null || log_warn "Fisher installation failed - can be installed manually later"
        
        # Use fisher update to install from fish_plugins file
        log_info "Installing Fish plugins from fish_plugins file..."
        fish -c "fisher update" 2>/dev/null || log_warn "Fish plugin installation failed - can be installed manually later"
    fi
    
    log_success "APT installation completed"
}

# Install packages with Pacman (Arch Linux)
install_with_pacman() {
    log_info "Installing packages with Pacman..."
    
    # Update package database
    sudo pacman -Sy
    
    # Essential packages
    log_info "Installing essential packages..."
    sudo pacman -S --noconfirm git curl wget vim tmux fish bash
    
    # Development packages
    log_info "Installing development packages..."
    sudo pacman -S --noconfirm nodejs npm python python-pip go rust
    
    # Modern CLI tools
    log_info "Installing modern CLI tools..."
    sudo pacman -S --noconfirm bat eza fd ripgrep fzf starship git-delta github-cli lazygit atuin
    
    # Optional packages
    log_info "Installing optional packages..."
    sudo pacman -S --noconfirm neovim zsh htop tree jq yq kubectl
    
    # Install Claude CLI
    install_claude_cli
    
    # Install Fisher for Fish shell if available
    if command -v fish >/dev/null 2>&1; then
        log_info "Installing Fisher plugin manager for Fish..."
        fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher" 2>/dev/null || log_warn "Fisher installation failed - can be installed manually later"
        
        # Use fisher update to install from fish_plugins file
        log_info "Installing Fish plugins from fish_plugins file..."
        fish -c "fisher update" 2>/dev/null || log_warn "Fish plugin installation failed - can be installed manually later"
    fi
    
    log_success "Pacman installation completed"
}

# Generic installation (try to install what we can)
install_generic() {
    log_warn "No specific package manager detected. Installing what we can..."
    
    # Install Rust (works on most systems)
    if ! command -v rustc >/dev/null 2>&1; then
        log_info "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    fi
    
    # Install Go (if wget is available)
    if ! command -v go >/dev/null 2>&1 && command -v wget >/dev/null 2>&1; then
        log_info "Installing Go..."
        GO_VERSION="1.21.0"
        case "$(uname -s)" in
            Darwin*)
                GO_OS="darwin"
                ;;
            Linux*)
                GO_OS="linux"
                ;;
            *)
                log_warn "Unsupported OS for Go installation"
                return
                ;;
        esac
        
        case "$(uname -m)" in
            x86_64)
                GO_ARCH="amd64"
                ;;
            arm64|aarch64)
                GO_ARCH="arm64"
                ;;
            *)
                log_warn "Unsupported architecture for Go installation"
                return
                ;;
        esac
        
        wget "https://go.dev/dl/go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz"
        sudo tar -C /usr/local -xzf "go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz"
        rm "go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz"
    fi
    
    # Install Node.js via NodeSource (if curl is available)
    if ! command -v node >/dev/null 2>&1 && command -v curl >/dev/null 2>&1; then
        log_info "Installing Node.js..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
    
    # Install starship
    if ! command -v starship >/dev/null 2>&1; then
        log_info "Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
    fi
    
    # Install Claude CLI
    install_claude_cli
    
    log_success "Generic installation completed"
}

# Setup shell integration
setup_shell_integration() {
    log_info "Setting up shell integration..."
    
    # Create shell configuration that sources our shared configs
    local shell_rc=""
    case "$SHELL" in
        */bash)
            shell_rc="$HOME/.bashrc"
            ;;
        */zsh)
            shell_rc="$HOME/.zshrc"
            ;;
        */fish)
            shell_rc="$HOME/.config/fish/config.fish"
            ;;
    esac
    
    if [[ -n "$shell_rc" ]]; then
        # Check if this is already a symlink to our dotfiles
        if [[ -L "$shell_rc" ]] && [[ "$(readlink "$shell_rc")" == *"dotfiles"* ]]; then
            log_info "Shell config already managed by dotfiles: $shell_rc"
            return 0
        fi
        
        # Check if it already has dotfiles integration
        if [[ -f "$shell_rc" ]] && grep -q "# Dotfiles integration" "$shell_rc"; then
            log_info "Shell integration already exists in $shell_rc"
            return 0
        fi
        
        # Only add integration if it's a real file (not symlinked)
        if [[ -f "$shell_rc" ]] && [[ ! -L "$shell_rc" ]]; then
            # Backup existing config
            cp "$shell_rc" "${shell_rc}.backup"
            
            # Add our dotfiles integration
            cat >> "$shell_rc" << EOF

# Dotfiles integration
if [[ -f "$DOTFILES_ROOT/config/shell/exports.sh" ]]; then
    source "$DOTFILES_ROOT/config/shell/exports.sh"
fi

if [[ -f "$DOTFILES_ROOT/config/shell/aliases.sh" ]]; then
    source "$DOTFILES_ROOT/config/shell/aliases.sh"
fi
EOF
            log_success "Shell integration added to $shell_rc"
        else
            log_info "Skipping shell integration - $shell_rc is symlinked or missing"
        fi
    fi
}

# Check repository state
check_repo_state() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local dotfiles_root="$(dirname "$script_dir")"
    
    if [[ -d "$dotfiles_root/.git" ]]; then
        cd "$dotfiles_root"
        if ! git diff-index --quiet HEAD --; then
            log_error "Repository has uncommitted changes. Please commit or stash your changes first:"
            echo
            git status --short
            echo
            log_info "To fix this, run one of:"
            log_info "  git add -A && git commit -m 'your message'"
            log_info "  git stash push -m 'your stash message'"
            log_info "  git restore .  # to discard changes"
            exit 1
        fi
    fi
}

# Main installation function
main() {
    local method=""
    local force_reset=false
    
    # Check repository state first
    check_repo_state
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --brew)
                method="brew"
                shift
                ;;
            --apt)
                method="apt"
                shift
                ;;
            --pacman)
                method="pacman"
                shift
                ;;
            --generic)
                method="generic"
                shift
                ;;
            --force-reset)
                force_reset=true
                shift
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --brew        Use Homebrew (macOS)"
                echo "  --apt         Use APT (Ubuntu/Debian)"
                echo "  --pacman      Use Pacman (Arch Linux)"
                echo "  --generic     Generic installation"
                echo "  --force-reset Clean up package state before installation"
                echo "  --help        Show this help"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    # Force cleanup if requested
    if [[ "$force_reset" == true ]] && [[ "$method" == "apt" || -z "$method" ]] && command -v apt >/dev/null 2>&1; then
        log_info "Force reset requested - cleaning up package state..."
        cleanup_apt_state
    fi
    
    # Auto-detect if no method specified
    if [[ -z "$method" ]]; then
        if command -v brew >/dev/null 2>&1; then
            method="brew"
        elif command -v apt >/dev/null 2>&1; then
            method="apt"
        elif command -v pacman >/dev/null 2>&1; then
            method="pacman"
        else
            method="generic"
        fi
        log_info "Auto-detected package manager: $method"
    fi
    
    # Install packages
    case "$method" in
        brew)
            install_with_brew
            ;;
        apt)
            install_with_apt
            ;;
        pacman)
            install_with_pacman
            ;;
        generic)
            install_generic
            ;;
        *)
            log_error "Unknown installation method: $method"
            exit 1
            ;;
    esac
    
    # Setup shell integration
    setup_shell_integration
    
    # Setup dotfiles command
    log_info "Setting up dotfiles management command..."
    "$DOTFILES_ROOT/scripts/setup-dotfiles-alias.sh"
    
    # Create initial symlinks
    log_info "Creating configuration symlinks..."
    "$DOTFILES_ROOT/scripts/create-symlinks.sh" --force
    
    log_success "Traditional installation completed!"
    log_info "Please restart your shell or run: source ~/.bashrc (or equivalent)"
    echo
    log_info "💡 Quick start commands:"
    echo "  dotfiles status    # Check installation"
    echo "  dotfiles sync      # Sync configurations"
    echo "  dotfiles update    # Update tools"
    echo "  dotfiles schedule  # Setup auto-updates"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi