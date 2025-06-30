#!/usr/bin/env bash
# Create symlinks for traditional dotfiles setup

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

# Create a symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    local description="${3:-}"
    
    # Create target directory if it doesn't exist
    local target_dir="$(dirname "$target")"
    if [[ ! -d "$target_dir" ]]; then
        mkdir -p "$target_dir"
        log_info "Created directory: $target_dir"
    fi
    
    # Backup existing file/link
    if [[ -e "$target" || -L "$target" ]]; then
        local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$target" "$backup"
        log_warn "Backed up existing $target to $backup"
    fi
    
    # Create symlink
    ln -sf "$source" "$target"
    if [[ -n "$description" ]]; then
        log_success "Linked $description: $target → $source"
    else
        log_success "Created symlink: $target → $source"
    fi
}

# Setup Git configuration
setup_git() {
    log_info "Setting up Git configuration..."
    
    # Process git config template
    local git_template="$DOTFILES_ROOT/config/git/gitconfig.template"
    local git_config="$HOME/.gitconfig"
    
    if [[ -f "$git_template" ]]; then
        # Get user information
        local user_name="${GIT_USER_NAME:-$(git config --global user.name 2>/dev/null || echo '')}"
        local user_email="${GIT_USER_EMAIL:-$(git config --global user.email 2>/dev/null || echo '')}"
        local editor="${EDITOR:-nvim}"
        
        # Prompt for missing information
        if [[ -z "$user_name" ]]; then
            read -p "Enter your full name for Git: " user_name
        fi
        
        if [[ -z "$user_email" ]]; then
            read -p "Enter your email for Git: " user_email
        fi
        
        # Create git config from template
        sed -e "s/%USER_NAME%/$user_name/g" \
            -e "s/%USER_EMAIL%/$user_email/g" \
            -e "s/%EDITOR%/$editor/g" \
            "$git_template" > "$git_config"
        
        log_success "Created Git configuration with user info"
    fi
    
    # Link global gitignore
    local gitignore_source="$DOTFILES_ROOT/config/git/gitignore_global"
    local gitignore_target="$HOME/.gitignore_global"
    
    if [[ -f "$gitignore_source" ]]; then
        create_symlink "$gitignore_source" "$gitignore_target" "global gitignore"
    fi
}

# Setup Tmux configuration
setup_tmux() {
    log_info "Setting up Tmux configuration..."
    
    local tmux_source="$DOTFILES_ROOT/config/tmux/tmux.conf"
    local tmux_target="$HOME/.tmux.conf"
    
    if [[ -f "$tmux_source" ]]; then
        create_symlink "$tmux_source" "$tmux_target" "tmux configuration"
    fi
}

# Setup Neovim configuration
setup_neovim() {
    log_info "Setting up Neovim configuration..."
    
    local nvim_source="$DOTFILES_ROOT/config/nvim"
    local nvim_target="$HOME/.config/nvim"
    
    if [[ -d "$nvim_source" ]]; then
        create_symlink "$nvim_source" "$nvim_target" "neovim configuration"
    fi
}

# Setup shell configurations
setup_shell() {
    log_info "Setting up shell configurations..."
    
    local shell="${PREFERRED_SHELL:-${DOTFILES_RECOMMENDED_SHELL:-bash}}"
    
    case "$shell" in
        fish)
            log_info "Setting up Fish shell configuration..."
            
            # Fish config
            local fish_source="$DOTFILES_ROOT/config/fish/config.fish"
            local fish_target="$HOME/.config/fish/config.fish"
            if [[ -f "$fish_source" ]]; then
                create_symlink "$fish_source" "$fish_target" "Fish configuration"
            fi
            
            # Check if Fish is the default shell
            if [[ "$SHELL" != *"fish" ]]; then
                log_warn "Fish is not your default shell. To make it default, run:"
                log_warn "  chsh -s \$(which fish)"
            fi
            ;;
        bash)
            log_info "Setting up Bash shell configuration..."
            
            # Bash config
            local bash_source="$DOTFILES_ROOT/config/bash/bashrc"
            local bash_target="$HOME/.bashrc"
            if [[ -f "$bash_source" ]]; then
                # For bash, we append to existing bashrc rather than replace
                if [[ -f "$bash_target" ]]; then
                    if ! grep -q "dotfiles integration" "$bash_target"; then
                        cat >> "$bash_target" << EOF

# Dotfiles integration
if [[ -f "$bash_source" ]]; then
    source "$bash_source"
fi
EOF
                        log_success "Added dotfiles integration to existing .bashrc"
                    else
                        log_info "Dotfiles integration already exists in .bashrc"
                    fi
                else
                    create_symlink "$bash_source" "$bash_target" "Bash configuration"
                fi
            fi
            ;;
        *)
            log_warn "Unknown shell: $shell, skipping shell-specific setup"
            ;;
    esac
}

# Setup tool configurations
setup_tools() {
    log_info "Setting up tool configurations..."
    
    # Starship
    local starship_source="$DOTFILES_ROOT/config/tools/starship.toml"
    local starship_target="$HOME/.config/starship.toml"
    if [[ -f "$starship_source" ]]; then
        create_symlink "$starship_source" "$starship_target" "starship configuration"
    fi
    
    # Bat
    local bat_source="$DOTFILES_ROOT/config/tools/bat.conf"
    local bat_target="$HOME/.config/bat/config"
    if [[ -f "$bat_source" ]]; then
        create_symlink "$bat_source" "$bat_target" "bat configuration"
    fi
    
    # GH Dashboard
    local gh_dash_source="$DOTFILES_ROOT/config/tools/gh-dash.yml"
    local gh_dash_target="$HOME/.config/gh-dash/config.yml"
    if [[ -f "$gh_dash_source" ]]; then
        create_symlink "$gh_dash_source" "$gh_dash_target" "gh-dash configuration"
    fi
}

# Main function
main() {
    log_info "Creating symlinks for dotfiles..."
    
    setup_git
    setup_shell
    setup_tmux
    setup_neovim
    setup_tools
    
    log_success "Symlink creation completed!"
    log_info "All configurations are now linked to your dotfiles"
    
    # Show shell-specific next steps
    local shell="${PREFERRED_SHELL:-${DOTFILES_RECOMMENDED_SHELL:-bash}}"
    if [[ "$shell" == "fish" ]] && [[ "$SHELL" != *"fish" ]]; then
        echo
        log_info "To start using Fish as your default shell:"
        log_info "  1. Run: chsh -s \$(which fish)"
        log_info "  2. Restart your terminal"
        log_info "  3. Or temporarily switch: exec fish"
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi