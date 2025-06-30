#!/usr/bin/env bash
# Automated symlink management for dotfiles

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

# Configuration mapping
declare -A SYMLINK_MAP=(
    ["config/bash/bashrc"]="$HOME/.bashrc"
    ["config/fish/config.fish"]="$HOME/.config/fish/config.fish"
    ["config/git/gitignore_global"]="$HOME/.gitignore_global"
    ["config/tmux/tmux.conf"]="$HOME/.tmux.conf"
    ["traditional/alacritty/alacritty.yml"]="$HOME/.config/alacritty/alacritty.yml"
    ["traditional/i3/i3config"]="$HOME/.config/i3/config"
    ["config/shell/aliases.sh"]="$HOME/.aliases"
    ["config/shell/exports.sh"]="$HOME/.exports"
)

# Create symlink
create_symlink() {
    local source="$1"
    local target="$2"
    local force="$3"
    
    local source_path="$DOTFILES_ROOT/$source"
    
    if [[ ! -e "$source_path" ]]; then
        log_warn "Source does not exist: $source_path"
        return 1
    fi
    
    local target_dir=$(dirname "$target")
    [[ ! -d "$target_dir" ]] && mkdir -p "$target_dir"
    
    if [[ -e "$target" ]] || [[ -L "$target" ]]; then
        if [[ "$force" == "true" ]]; then
            rm -f "$target"
        else
            log_warn "Target exists: $target (use --force to overwrite)"
            return 1
        fi
    fi
    
    ln -sf "$source_path" "$target"
    log_success "Linked: $source -> $target"
    return 0
}

# Main function
main() {
    local force=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force|-f) force=true; shift ;;
            --help|-h)
                cat << EOF
Usage: $0 [OPTIONS]

Create and manage dotfiles symlinks

OPTIONS:
  --force, -f    Force overwrite existing files
  --help, -h     Show this help message

EXAMPLES:
  $0             Create symlinks (skip existing)
  $0 --force     Create symlinks (overwrite existing)
EOF
                exit 0 ;;
            *) log_error "Unknown option: $1"; exit 1 ;;
        esac
    done
    
    log_info "Creating symlinks..."
    for source in "${!SYMLINK_MAP[@]}"; do
        target="${SYMLINK_MAP[$source]}"
        create_symlink "$source" "$target" "$force"
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi