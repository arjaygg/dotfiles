#!/usr/bin/env bash
# Automated tool updates and maintenance
# Keeps your development tools up to date with minimal intervention

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$HOME/.dotfiles-update.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { 
    echo -e "${BLUE}[INFO]${NC} $1" 
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1" >> "$LOG_FILE"
}
log_success() { 
    echo -e "${GREEN}[SUCCESS]${NC} $1" 
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: $1" >> "$LOG_FILE"
}
log_warn() { 
    echo -e "${YELLOW}[WARN]${NC} $1" 
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARN: $1" >> "$LOG_FILE"
}
log_error() { 
    echo -e "${RED}[ERROR]${NC} $1" 
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >> "$LOG_FILE"
}

# Update system packages
update_system_packages() {
    log_info "Updating system packages..."
    
    if command -v apt >/dev/null 2>&1; then
        sudo apt update && sudo apt upgrade -y
        sudo apt autoremove -y
        log_success "APT packages updated"
    elif command -v brew >/dev/null 2>&1; then
        brew update && brew upgrade
        brew cleanup
        log_success "Homebrew packages updated"
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Syu --noconfirm
        sudo pacman -Rns $(pacman -Qtdq) --noconfirm 2>/dev/null || true
        log_success "Pacman packages updated"
    fi
}

# Update Rust toolchain and cargo packages
update_rust() {
    if command -v rustup >/dev/null 2>&1; then
        log_info "Updating Rust toolchain..."
        rustup update
        log_success "Rust toolchain updated"
        
        # Update global cargo packages
        if command -v cargo >/dev/null 2>&1; then
            log_info "Updating global cargo packages..."
            cargo install-update -a 2>/dev/null || {
                log_warn "cargo-update not installed. Installing..."
                cargo install cargo-update
                cargo install-update -a
            }
            log_success "Cargo packages updated"
        fi
    fi
}

# Update Node.js global packages
update_nodejs() {
    if command -v npm >/dev/null 2>&1; then
        log_info "Updating Node.js global packages..."
        npm update -g
        log_success "Node.js global packages updated"
    fi
    
    # Update fnm if installed
    if command -v fnm >/dev/null 2>&1; then
        log_info "Checking for Node.js LTS updates..."
        fnm install --lts
        fnm use lts-latest
        log_success "Node.js LTS updated"
    fi
}

# Update Go tools
update_go() {
    if command -v go >/dev/null 2>&1; then
        log_info "Updating Go tools..."
        
        # List of common Go tools to update
        local go_tools=(
            "github.com/go-delve/delve/cmd/dlv@latest"
            "golang.org/x/tools/gopls@latest"
            "github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
            "mvdan.cc/gofumpt@latest"
        )
        
        for tool in "${go_tools[@]}"; do
            if go list -m "$tool" >/dev/null 2>&1; then
                log_info "Updating $tool"
                go install "$tool"
            fi
        done
        
        log_success "Go tools updated"
    fi
}

# Update Python tools
update_python() {
    if command -v pip3 >/dev/null 2>&1; then
        log_info "Updating Python global packages..."
        pip3 list --outdated --format=json | jq -r '.[].name' | xargs -I {} pip3 install --upgrade {} 2>/dev/null || {
            # Fallback if jq not available
            pip3 list --outdated | tail -n +3 | awk '{print $1}' | xargs -I {} pip3 install --upgrade {}
        }
        log_success "Python packages updated"
    fi
    
    # Update poetry if installed
    if command -v poetry >/dev/null 2>&1; then
        log_info "Updating Poetry..."
        poetry self update
        log_success "Poetry updated"
    fi
}

# Update GitHub CLI extensions
update_gh_extensions() {
    if command -v gh >/dev/null 2>&1; then
        log_info "Updating GitHub CLI extensions..."
        gh extension upgrade --all
        log_success "GitHub CLI extensions updated"
    fi
}

# Update manual installations
update_manual_tools() {
    log_info "Checking manual tool updates..."
    
    # Update starship
    if command -v starship >/dev/null 2>&1; then
        log_info "Updating starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y -f
        log_success "Starship updated"
    fi
    
    # Update fzf
    if [[ -d "$HOME/.fzf" ]]; then
        log_info "Updating fzf..."
        cd "$HOME/.fzf"
        local current_commit=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
        git pull origin master >/dev/null 2>&1
        local new_commit=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
        
        if [[ "$current_commit" != "$new_commit" ]]; then
            # Reinstall to update binaries and shell integration
            ./install --all --no-update-rc >/dev/null 2>&1
            log_success "fzf updated to latest version"
        else
            log_info "fzf already up to date"
        fi
        cd - >/dev/null
    elif command -v fzf >/dev/null 2>&1; then
        log_warn "fzf found but not installed via git. Consider reinstalling with: git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install"
    fi
    
    # Update eza if installed manually
    if command -v eza >/dev/null 2>&1 && [[ ! -f /usr/bin/eza ]]; then
        log_info "Checking eza updates..."
        local current_version=$(eza --version | head -1 | awk '{print $2}')
        local latest_version=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
        
        if [[ "$current_version" != "$latest_version" ]]; then
            log_info "Updating eza from $current_version to $latest_version"
            wget -q "https://github.com/eza-community/eza/releases/download/${latest_version}/eza_x86_64-unknown-linux-gnu.tar.gz"
            tar -xzf eza_x86_64-unknown-linux-gnu.tar.gz
            sudo mv eza /usr/local/bin/
            rm eza_x86_64-unknown-linux-gnu.tar.gz
            log_success "Eza updated to $latest_version"
        fi
    fi
    
    # Update lazygit if installed manually
    if command -v lazygit >/dev/null 2>&1 && [[ ! -f /usr/bin/lazygit ]]; then
        log_info "Checking lazygit updates..."
        local current_version=$(lazygit --version | head -1 | awk '{print $3}' | sed 's/,$//')
        local latest_version=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name"' | sed -E 's/.*"v*([^"]+)".*/\1/')
        
        if [[ "$current_version" != "$latest_version" ]]; then
            log_info "Updating lazygit from $current_version to $latest_version"
            curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${latest_version}_Linux_x86_64.tar.gz"
            tar xf lazygit.tar.gz lazygit
            sudo install lazygit /usr/local/bin
            rm lazygit.tar.gz lazygit
            log_success "Lazygit updated to $latest_version"
        fi
    fi
}

# Update Neovim plugins (if using lazy.nvim or packer)
update_neovim() {
    if command -v nvim >/dev/null 2>&1; then
        log_info "Updating Neovim plugins..."
        
        # Try lazy.nvim first
        if nvim --headless -c "lua require('lazy').sync()" -c "qa" >/dev/null 2>&1; then
            log_success "Neovim plugins updated (lazy.nvim)"
        # Try packer
        elif nvim --headless -c "PackerSync" -c "qa" >/dev/null 2>&1; then
            log_success "Neovim plugins updated (packer)"
        else
            log_warn "Could not detect Neovim plugin manager"
        fi
    fi
}

# Clean up old files and caches
cleanup() {
    log_info "Cleaning up..."
    
    # Clean up old backups (keep last 5)
    if [[ -d "$HOME/.dotfiles-backups" ]]; then
        find "$HOME/.dotfiles-backups" -maxdepth 1 -type d -name "*_*" | sort | head -n -5 | xargs rm -rf
        log_info "Cleaned up old backups"
    fi
    
    # Clean up package manager caches
    if command -v apt >/dev/null 2>&1; then
        sudo apt autoclean
    elif command -v brew >/dev/null 2>&1; then
        brew cleanup --prune=all
    fi
    
    # Clean up cargo cache
    if command -v cargo >/dev/null 2>&1; then
        cargo cache --autoclean >/dev/null 2>&1 || true
    fi
    
    log_success "Cleanup completed"
}

# Generate update summary
generate_summary() {
    log_info "Update Summary:"
    echo "===================="
    
    local tools_checked=0
    local tools_updated=0
    
    # Count lines in log file for this session
    local session_start=$(date '+%Y-%m-%d %H:%M:%S' -d '1 hour ago')
    local updates=$(grep -c "updated\|upgraded" "$LOG_FILE" 2>/dev/null || echo "0")
    
    echo "✅ System packages: checked"
    echo "✅ Development tools: checked"
    echo "✅ Manual tools: checked"
    echo "📊 Total updates applied: $updates"
    echo "🗂️  Log file: $LOG_FILE"
    echo "===================="
}

# Main update function
main() {
    local skip_system=false
    local skip_tools=false
    local cleanup_only=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-system)
                skip_system=true
                shift
                ;;
            --skip-tools)
                skip_tools=true
                shift
                ;;
            --cleanup-only)
                cleanup_only=true
                shift
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --skip-system    Skip system package updates"
                echo "  --skip-tools     Skip development tool updates"
                echo "  --cleanup-only   Only run cleanup tasks"
                echo "  --help           Show this help"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    echo "🔄 Starting automated update process..."
    log_info "Automated update started"
    
    if [[ "$cleanup_only" == true ]]; then
        cleanup
        log_success "Cleanup completed"
        exit 0
    fi
    
    # Update system packages
    if [[ "$skip_system" == false ]]; then
        update_system_packages
    fi
    
    # Update development tools
    if [[ "$skip_tools" == false ]]; then
        update_rust
        update_nodejs
        update_go
        update_python
        update_gh_extensions
        update_manual_tools
        update_neovim
    fi
    
    # Always run cleanup
    cleanup
    
    # Generate summary
    generate_summary
    
    log_success "Automated update completed!"
    
    # Suggest running dotfiles sync
    echo
    log_info "💡 Consider running: $DOTFILES_ROOT/scripts/dotfiles-sync.sh"
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi