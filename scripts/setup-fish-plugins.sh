#!/usr/bin/env bash
# Setup Fisher and install Fish plugins

set -euo pipefail

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# Check if Fish is installed
if ! command -v fish >/dev/null 2>&1; then
    log_warn "Fish shell not found. Please install Fish first."
    exit 1
fi

log_info "Setting up Fisher and Fish plugins..."

# Install/Update Fisher and plugins
fish -c "
    # Install fisher if not present
    if not functions -q fisher
        echo 'Installing Fisher...'
        curl -sL https://git.io/fisher | source
        fisher install jorgebucaran/fisher
    end
    
    # Install plugins from fish_plugins file
    if test -f ~/.config/fish/fish_plugins
        echo 'Installing plugins from fish_plugins file...'
        fisher update
    else
        echo 'No fish_plugins file found'
    end
    
    # List installed plugins
    echo 'Installed Fisher plugins:'
    fisher list
"

log_success "Fisher setup completed!"
log_info "The jhillyerd/plugin-git plugin provides 100+ git aliases and functions."
log_info "Use 'fish -c \"fisher list\"' to see all installed plugins."
log_info "Plugin documentation: https://github.com/jhillyerd/plugin-git"