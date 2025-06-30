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
    
    log_success "Homebrew installation completed"
}

# Install packages with APT (Ubuntu/Debian)
install_with_apt() {
    log_info "Installing packages with APT..."
    
    # Update package list
    sudo apt update
    
    # Essential packages
    log_info "Installing essential packages..."
    sudo apt install -y git curl wget vim tmux fish bash
    
    # Development packages
    log_info "Installing development packages..."
    sudo apt install -y nodejs npm python3 python3-pip
    
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
    
    # bat (install via snap or deb)
    if ! command -v bat >/dev/null 2>&1; then
        sudo apt install -y bat
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
    
    # gh (GitHub CLI)
    if ! command -v gh >/dev/null 2>&1; then
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
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
    
    # Optional packages
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
        # Backup existing config
        if [[ -f "$shell_rc" ]]; then
            cp "$shell_rc" "${shell_rc}.backup"
        fi
        
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
    fi
}

# Main installation function
main() {
    local method=""
    
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
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
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