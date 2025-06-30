#!/usr/bin/env bash
# Dotfiles management CLI - Easy way to maintain your dotfiles
# Usage: dotfiles <command> [options]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors - only use if terminal supports them
if [[ -t 1 ]] && [[ "${TERM:-}" != "dumb" ]] && command -v tput >/dev/null 2>&1 && tput colors >/dev/null 2>&1; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    BOLD=''
    NC=''
fi

# Helper functions
log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✅${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}❌${NC} $1"; }
log_header() { echo -e "${BOLD}${BLUE}$1${NC}"; }

# Show help
show_help() {
    echo -e "${BOLD}Dotfiles Management CLI${NC}"
    echo
    echo -e "${BOLD}USAGE:${NC}"
    echo "    dotfiles <command> [options]"
    echo
    echo -e "${BOLD}COMMANDS:${NC}"
    echo -e "    ${GREEN}sync${NC}           Sync configurations and update repository"
    echo -e "    ${GREEN}update${NC}         Update all tools and packages"
    echo -e "    ${GREEN}install${NC}        Install dotfiles on a new system"
    echo -e "    ${GREEN}backup${NC}         Create backup of current configurations"
    echo -e "    ${GREEN}restore${NC}        Restore from a backup"
    echo -e "    ${GREEN}health${NC}         Run health checks"
    echo -e "    ${GREEN}status${NC}         Show dotfiles status"
    echo -e "    ${GREEN}schedule${NC}       Setup automated maintenance"
    echo -e "    ${GREEN}clean${NC}          Clean up old backups and caches"
    echo -e "    ${GREEN}doctor${NC}         Diagnose and fix common issues"
    echo
    echo -e "${BOLD}SYNC OPTIONS:${NC}"
    echo "    --force             Force sync even if no changes"
    echo "    --no-backup         Skip backing up existing configs"
    echo "    --skip-tools        Skip tool updates"
    echo
    echo -e "${BOLD}UPDATE OPTIONS:${NC}"
    echo "    --skip-system       Skip system package updates"
    echo "    --skip-tools        Skip development tool updates"
    echo
    echo -e "${BOLD}EXAMPLES:${NC}"
    echo "    dotfiles sync                    # Sync configurations"
    echo "    dotfiles update --skip-system    # Update tools only"
    echo "    dotfiles install                 # Fresh installation"
    echo "    dotfiles health                  # Check system health"
    echo "    dotfiles schedule daily          # Setup daily auto-updates"
    echo
    echo -e "${BOLD}FILES:${NC}"
    echo "    Logs: ~/.dotfiles-update.log"
    echo "    Backups: ~/.dotfiles-backups/"
    echo "    Config: ~/.dotfiles.conf"
    echo
    echo "For more help: dotfiles <command> --help"
}

# Show dotfiles status
show_status() {
    log_header "📊 Dotfiles Status"
    echo
    
    cd "$DOTFILES_ROOT"
    
    # Git status
    echo "📁 Repository:"
    echo "   Path: $DOTFILES_ROOT"
    echo "   Branch: $(git branch --show-current 2>/dev/null || echo "unknown")"
    echo "   Status: $(git status --porcelain | wc -l) uncommitted changes"
    echo "   Last update: $(git log -1 --format="%cr" 2>/dev/null || echo "unknown")"
    echo
    
    # Tool status
    echo "🛠️  Tools:"
    local tools=("git" "fish" "nvim" "tmux" "bat" "eza" "fd" "rg" "fzf" "gh" "lazygit" "atuin" "broot")
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            local version="unknown"
            case "$tool" in
                tmux)
                    version=$(tmux -V 2>/dev/null | awk '{print $2}' || echo "unknown")
                    ;;
                git)
                    version=$(git --version 2>/dev/null | awk '{print $3}' || echo "unknown")
                    ;;
                nvim)
                    version=$(nvim --version 2>/dev/null | head -1 | awk '{print $2}' || echo "unknown")
                    ;;
                bat|eza|fd|rg|fzf|gh|lazygit|atuin|broot)
                    version=$(command "$tool" --version 2>/dev/null | head -1 | awk '{print $NF}' || echo "unknown")
                    ;;
                fish)
                    version=$(fish --version 2>/dev/null | awk '{print $3}' || echo "unknown")
                    ;;
                *)
                    version=$(command "$tool" --version 2>/dev/null | head -1 | awk '{print $NF}' || echo "unknown")
                    ;;
            esac
            echo "   ✅ $tool ($version)"
        else
            echo "   ❌ $tool (not installed)"
        fi
    done
    echo
    
    # Backup status
    if [[ -d "$HOME/.dotfiles-backups" ]]; then
        local backup_count=$(find "$HOME/.dotfiles-backups" -maxdepth 1 -type d -name "*_*" | wc -l)
        local latest_backup=$(find "$HOME/.dotfiles-backups" -maxdepth 1 -type d -name "*_*" | sort | tail -1)
        echo "💾 Backups:"
        echo "   Count: $backup_count"
        echo "   Latest: $(basename "$latest_backup" 2>/dev/null || echo "none")"
    else
        echo "💾 Backups: No backups found"
    fi
    echo
    
    # Health check summary
    log_info "Running quick health check..."
    if "$SCRIPT_DIR/dotfiles-sync.sh" --health-check-only >/dev/null 2>&1; then
        echo "🏥 Health: All checks passed"
    else
        echo "🏥 Health: Issues detected (run 'dotfiles doctor' for details)"
    fi
}

# Setup automated maintenance
setup_schedule() {
    local frequency="${1:-daily}"
    
    log_header "⏰ Setting up automated maintenance"
    
    local cron_entry=""
    case "$frequency" in
        daily)
            cron_entry="0 9 * * * $DOTFILES_ROOT/scripts/auto-update.sh --skip-system >> ~/.dotfiles-update.log 2>&1"
            ;;
        weekly)
            cron_entry="0 9 * * 0 $DOTFILES_ROOT/scripts/auto-update.sh >> ~/.dotfiles-update.log 2>&1"
            ;;
        monthly)
            cron_entry="0 9 1 * * $DOTFILES_ROOT/scripts/auto-update.sh >> ~/.dotfiles-update.log 2>&1"
            ;;
        *)
            log_error "Invalid frequency. Use: daily, weekly, or monthly"
            exit 1
            ;;
    esac
    
    # Add to crontab if not already present
    if ! crontab -l 2>/dev/null | grep -q "auto-update.sh"; then
        (crontab -l 2>/dev/null || true; echo "$cron_entry") | crontab -
        log_success "$frequency maintenance scheduled"
    else
        log_warn "Automated maintenance already scheduled"
    fi
    
    # Also setup weekly dotfiles sync
    local sync_entry="0 10 * * 0 $DOTFILES_ROOT/scripts/dotfiles-sync.sh >> ~/.dotfiles-update.log 2>&1"
    if ! crontab -l 2>/dev/null | grep -q "dotfiles-sync.sh"; then
        (crontab -l 2>/dev/null || true; echo "$sync_entry") | crontab -
        log_success "Weekly dotfiles sync scheduled"
    fi
    
    echo
    log_info "Scheduled tasks:"
    crontab -l | grep -E "(auto-update|dotfiles-sync)" || echo "No scheduled tasks found"
}

# Doctor - diagnose and fix issues
run_doctor() {
    log_header "🩺 Dotfiles Doctor"
    echo
    
    local issues=0
    
    # Check git repository
    log_info "Checking git repository..."
    cd "$DOTFILES_ROOT"
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log_error "Not a git repository"
        ((issues++))
    else
        log_success "Git repository OK"
    fi
    
    # Check essential scripts
    log_info "Checking essential scripts..."
    local scripts=("install-system.sh" "dotfiles-sync.sh" "auto-update.sh")
    for script in "${scripts[@]}"; do
        if [[ -x "$SCRIPT_DIR/$script" ]]; then
            log_success "$script is executable"
        else
            log_error "$script missing or not executable"
            if [[ -f "$SCRIPT_DIR/$script" ]]; then
                chmod +x "$SCRIPT_DIR/$script"
                log_success "Fixed permissions for $script"
            else
                ((issues++))
            fi
        fi
    done
    
    # Check symlinks
    log_info "Checking configuration symlinks..."
    "$SCRIPT_DIR/dotfiles-sync.sh" --health-check-only || ((issues++))
    
    # Check tool installations
    log_info "Checking essential tools..."
    local tools=("git" "curl" "fish" "nvim")
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            log_success "$tool installed"
        else
            log_warn "$tool not installed"
            log_info "Run 'dotfiles install' to install missing tools"
        fi
    done
    
    # Check configuration directories
    log_info "Checking configuration directories..."
    local dirs=("$HOME/.config" "$HOME/.config/fish" "$HOME/.config/nvim")
    for dir in "${dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            log_success "$(basename "$dir") directory exists"
        else
            log_warn "Creating missing directory: $dir"
            mkdir -p "$dir"
        fi
    done
    
    echo
    if [[ $issues -eq 0 ]]; then
        log_success "🎉 All checks passed! Your dotfiles are healthy."
    else
        log_warn "Found $issues issues. Some may have been automatically fixed."
        log_info "Consider running 'dotfiles sync' to fix configuration issues."
    fi
}

# Backup management
manage_backups() {
    local action="${1:-list}"
    
    case "$action" in
        list)
            log_header "💾 Available Backups"
            if [[ -d "$HOME/.dotfiles-backups" ]]; then
                find "$HOME/.dotfiles-backups" -maxdepth 1 -type d -name "*_*" | sort -r | head -10 | while read -r backup; do
                    local size=$(du -sh "$backup" 2>/dev/null | cut -f1 || echo "unknown")
                    echo "  📁 $(basename "$backup") ($size)"
                done
            else
                echo "  No backups found"
            fi
            ;;
        create)
            log_info "Creating manual backup..."
            "$SCRIPT_DIR/dotfiles-sync.sh" --no-backup
            log_success "Backup created"
            ;;
        clean)
            log_info "Cleaning old backups (keeping last 5)..."
            if [[ -d "$HOME/.dotfiles-backups" ]]; then
                find "$HOME/.dotfiles-backups" -maxdepth 1 -type d -name "*_*" | sort | head -n -5 | xargs rm -rf
                log_success "Old backups cleaned"
            fi
            ;;
        *)
            log_error "Invalid backup action. Use: list, create, or clean"
            exit 1
            ;;
    esac
}

# Main function
main() {
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi
    
    local command="$1"
    shift
    
    case "$command" in
        sync)
            "$SCRIPT_DIR/dotfiles-sync.sh" "$@"
            ;;
        update)
            "$SCRIPT_DIR/auto-update.sh" "$@"
            ;;
        install)
            log_header "🚀 Installing Dotfiles"
            "$SCRIPT_DIR/install-system.sh" "$@"
            "$SCRIPT_DIR/dotfiles-sync.sh" --no-backup
            log_success "Installation completed!"
            ;;
        backup)
            manage_backups "${1:-list}"
            ;;
        restore)
            log_error "Restore functionality not implemented yet"
            log_info "Manually copy files from ~/.dotfiles-backups/"
            ;;
        health)
            "$SCRIPT_DIR/dotfiles-sync.sh" --health-check-only
            ;;
        status)
            show_status
            ;;
        schedule)
            setup_schedule "${1:-daily}"
            ;;
        clean)
            "$SCRIPT_DIR/auto-update.sh" --cleanup-only
            manage_backups clean
            ;;
        doctor)
            run_doctor
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: $command"
            echo "Run 'dotfiles help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"