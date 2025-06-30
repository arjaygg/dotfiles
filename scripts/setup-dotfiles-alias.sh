#!/usr/bin/env bash
# Setup convenient 'dotfiles' command alias

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

# Create the dotfiles command
setup_dotfiles_command() {
    local bin_dir="$HOME/.local/bin"
    local dotfiles_cmd="$bin_dir/dotfiles"
    
    # Create ~/.local/bin if it doesn't exist
    mkdir -p "$bin_dir"
    
    # Create the dotfiles wrapper script
    cat > "$dotfiles_cmd" << EOF
#!/usr/bin/env bash
# Dotfiles management command wrapper

exec "$DOTFILES_ROOT/scripts/dotfiles.sh" "\$@"
EOF
    
    chmod +x "$dotfiles_cmd"
    
    log_success "Created dotfiles command: $dotfiles_cmd"
    
    # Check if ~/.local/bin is in PATH
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        log_info "Adding ~/.local/bin to PATH..."
        
        # Add to bash profile
        if [[ -f "$HOME/.bashrc" ]]; then
            if ! grep -q "/.local/bin" "$HOME/.bashrc"; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
                log_info "Added to ~/.bashrc"
            fi
        fi
        
        # Add to fish config
        if [[ -d "$HOME/.config/fish" ]]; then
            local fish_path_config="$HOME/.config/fish/conf.d/path.fish"
            mkdir -p "$(dirname "$fish_path_config")"
            if [[ ! -f "$fish_path_config" ]] || ! grep -q "/.local/bin" "$fish_path_config"; then
                echo 'set -gx PATH $HOME/.local/bin $PATH' >> "$fish_path_config"
                log_info "Added to fish config"
            fi
        fi
        
        log_info "Please restart your shell or run: export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
}

# Main function
main() {
    log_info "Setting up dotfiles command..."
    setup_dotfiles_command
    
    echo
    log_success "Setup complete! You can now use:"
    echo "  dotfiles sync      # Sync configurations"
    echo "  dotfiles update    # Update tools"
    echo "  dotfiles status    # Show status"
    echo "  dotfiles help      # Show all commands"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi