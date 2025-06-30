#!/usr/bin/env bash
# Automated dotfiles sync and update system
# Keeps your dotfiles in sync with minimal manual intervention

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$HOME/.dotfiles-backups/$(date +%Y%m%d_%H%M%S)"

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

# Configuration files to auto-manage
declare -A DOTFILES_MAP=(
    # Shell configurations
    ["$DOTFILES_ROOT/config/bash/bashrc"]="$HOME/.bashrc"
    ["$DOTFILES_ROOT/config/fish/config.fish"]="$HOME/.config/fish/config.fish"
    ["$DOTFILES_ROOT/config/fish/fish_plugins"]="$HOME/.config/fish/fish_plugins"
    
    # Git configuration
    ["$DOTFILES_ROOT/config/git/gitconfig.template"]="$HOME/.gitconfig"
    ["$DOTFILES_ROOT/config/git/gitconfig.local"]="$HOME/.gitconfig.local"
    ["$DOTFILES_ROOT/config/git/gitignore_global"]="$HOME/.gitignore_global"
    
    # Editor configurations
    ["$DOTFILES_ROOT/config/nvim"]="$HOME/.config/nvim"
    
    # Terminal and shell tools
    ["$DOTFILES_ROOT/config/tmux/tmux.conf"]="$HOME/.tmux.conf"
    ["$DOTFILES_ROOT/config/starship/starship.toml"]="$HOME/.config/starship.toml"
    ["$DOTFILES_ROOT/config/atuin/config.toml"]="$HOME/.config/atuin/config.toml"
    ["$DOTFILES_ROOT/config/broot/conf.hjson"]="$HOME/.config/broot/conf.hjson"
    ["$DOTFILES_ROOT/system/alacritty/alacritty.yml"]="$HOME/.config/alacritty/alacritty.yml"
    ["$DOTFILES_ROOT/system/i3/i3config"]="$HOME/.config/i3/config"
    
    # Tool configurations
    ["$DOTFILES_ROOT/config/tools/bat.conf"]="$HOME/.config/bat/config"
    ["$DOTFILES_ROOT/config/tools/fd.ignore"]="$HOME/.config/fd/ignore"
    ["$DOTFILES_ROOT/config/tools/gh_config.yml"]="$HOME/.config/gh/config.yml"
    ["$DOTFILES_ROOT/config/ssh/config.template"]="$HOME/.ssh/config.template"
)

# Check if we're in a git repository
check_git_repo() {
    if ! git -C "$DOTFILES_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
        log_error "Not in a git repository: $DOTFILES_ROOT"
        exit 1
    fi
}

# Backup existing configurations
backup_existing() {
    log_info "Creating backup at $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    
    for source_file in "${!DOTFILES_MAP[@]}"; do
        target_file="${DOTFILES_MAP[$source_file]}"
        if [[ -f "$target_file" ]] && [[ ! -L "$target_file" ]]; then
            log_info "Backing up: $target_file"
            target_dir="$BACKUP_DIR/$(dirname "${target_file#$HOME/}")"
            mkdir -p "$target_dir"
            cp "$target_file" "$BACKUP_DIR/${target_file#$HOME/}"
        fi
    done
    
    log_success "Backup completed: $BACKUP_DIR"
}

# Update dotfiles repository
update_dotfiles() {
    log_info "Updating dotfiles repository..."
    
    cd "$DOTFILES_ROOT"
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        log_warn "Uncommitted changes detected. Stashing..."
        git stash push -m "Auto-stash before sync $(date)"
    fi
    
    # Fetch and pull latest changes
    git fetch origin
    
    local current_branch=$(git branch --show-current)
    local behind_count=$(git rev-list --count HEAD..origin/"$current_branch" 2>/dev/null || echo "0")
    
    if [[ "$behind_count" -gt 0 ]]; then
        log_info "Pulling $behind_count new commits..."
        git pull origin "$current_branch"
        log_success "Repository updated successfully"
        return 0
    else
        log_info "Repository is already up to date"
        return 1
    fi
}

# Install missing tools
update_tools() {
    log_info "Checking for tool updates..."
    
    # Update package managers first
    if command -v apt >/dev/null 2>&1; then
        log_info "Updating apt packages..."
        sudo apt update >/dev/null 2>&1
    elif command -v brew >/dev/null 2>&1; then
        log_info "Updating homebrew..."
        brew update >/dev/null 2>&1
    fi
    
    # Run system installer to ensure tools are present
    if [[ -x "$DOTFILES_ROOT/scripts/install-system.sh" ]]; then
        log_info "Running system installer for missing tools..."
        "$DOTFILES_ROOT/scripts/install-system.sh" --update-only 2>/dev/null || true
    fi
}

# Create symlinks for configurations
create_symlinks() {
    log_info "Creating/updating symlinks..."
    
    for source_file in "${!DOTFILES_MAP[@]}"; do
        target_file="${DOTFILES_MAP[$source_file]}"
        
        if [[ -f "$source_file" ]] || [[ -d "$source_file" ]]; then
            # Create target directory if it doesn't exist
            target_dir=$(dirname "$target_file")
            [[ ! -d "$target_dir" ]] && mkdir -p "$target_dir"
            
            # Remove existing file/symlink and create new symlink
            if [[ -L "$target_file" ]] || [[ -f "$target_file" ]]; then
                rm -f "$target_file"
            fi
            
            ln -sf "$source_file" "$target_file"
            log_success "Linked: $source_file → $target_file"
        else
            log_warn "Source file not found: $source_file"
        fi
    done
}

# Process git config template
process_git_config() {
    local git_template="$DOTFILES_ROOT/config/git/gitconfig.template"
    local git_config="$HOME/.gitconfig"
    
    if [[ -f "$git_template" ]]; then
        log_info "Processing git configuration..."
        
        # Get git user info if not set
        local git_name git_email
        git_name=$(git config --global user.name 2>/dev/null || echo "")
        git_email=$(git config --global user.email 2>/dev/null || echo "")
        
        if [[ -z "$git_name" ]]; then
            read -p "Enter your Git name: " git_name
            git config --global user.name "$git_name"
        fi
        
        if [[ -z "$git_email" ]]; then
            read -p "Enter your Git email: " git_email
            git config --global user.email "$git_email"
        fi
        
        # Process template
        sed -e "s/{{NAME}}/$git_name/g" \
            -e "s/{{EMAIL}}/$git_email/g" \
            "$git_template" > "$git_config"
        
        log_success "Git configuration updated"
    fi
}

# Health check for configurations
health_check() {
    log_info "Running health checks..."
    
    local issues=0
    
    # Check symlinks
    for source_file in "${!DOTFILES_MAP[@]}"; do
        target_file="${DOTFILES_MAP[$source_file]}"
        if [[ -f "$source_file" ]] && [[ ! -L "$target_file" ]]; then
            log_warn "Not symlinked: $target_file"
            ((issues++))
        elif [[ -L "$target_file" ]] && [[ ! -e "$target_file" ]]; then
            log_error "Broken symlink: $target_file"
            ((issues++))
        fi
    done
    
    # Check essential tools
    local essential_tools=("git" "curl" "fish" "nvim" "tmux" "bat" "eza" "fd" "rg" "fzf")
    for tool in "${essential_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            log_warn "Missing tool: $tool"
            ((issues++))
        fi
    done
    
    if [[ $issues -eq 0 ]]; then
        log_success "All health checks passed!"
    else
        log_warn "Found $issues issues"
    fi
    
    return $issues
}

# Auto-update shell configuration
reload_shell() {
    log_info "Reloading shell configuration..."
    
    # Source bash configuration if using bash
    if [[ "$SHELL" == *bash* ]] && [[ -f "$HOME/.bashrc" ]]; then
        source "$HOME/.bashrc" 2>/dev/null || true
    fi
    
    # For fish, we'll need to restart or tell user to restart
    if [[ "$SHELL" == *fish* ]]; then
        log_info "Fish shell detected. Configuration will take effect on next shell restart."
    fi
    
    log_success "Shell configuration reloaded"
}

# Main sync function
main() {
    local force_update=false
    local run_backup=true
    local skip_tools=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force)
                force_update=true
                shift
                ;;
            --no-backup)
                run_backup=false
                shift
                ;;
            --skip-tools)
                skip_tools=true
                shift
                ;;
            --health-check-only)
                health_check
                exit $?
                ;;
            --help)
                echo "Usage: $0 [OPTIONS]"
                echo "Options:"
                echo "  --force             Force update even if no changes"
                echo "  --no-backup         Skip backing up existing configs"
                echo "  --skip-tools        Skip tool updates"
                echo "  --health-check-only Run only health checks"
                echo "  --help              Show this help"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    log_info "Starting dotfiles sync..."
    
    check_git_repo
    
    # Backup existing configurations
    if [[ "$run_backup" == true ]]; then
        backup_existing
    fi
    
    # Update repository
    local repo_updated=false
    if update_dotfiles || [[ "$force_update" == true ]]; then
        repo_updated=true
    fi
    
    # Update tools if repository was updated or forced
    if [[ "$skip_tools" == false ]] && ([[ "$repo_updated" == true ]] || [[ "$force_update" == true ]]); then
        update_tools
    fi
    
    # Always ensure symlinks are correct
    create_symlinks
    
    # Process git configuration
    process_git_config
    
    # Reload shell configuration
    reload_shell
    
    # Run health check
    if ! health_check; then
        log_warn "Some issues detected. Run with --health-check-only for details."
    fi
    
    log_success "Dotfiles sync completed!"
    
    # Show what changed if repository was updated
    if [[ "$repo_updated" == true ]]; then
        echo
        log_info "Recent changes:"
        git -C "$DOTFILES_ROOT" log --oneline -5 2>/dev/null || true
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi